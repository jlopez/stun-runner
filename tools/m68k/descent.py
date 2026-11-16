"""Recursive descent over a 68010 image (docs/14-68k-descent.md section 2).

The descent decides what is code from the image alone: it starts at the seeds the image gives
(vector tables, entry tables, extra seeds with their evidence), follows every static flow
(fall-through, branches, `jsr`/`jmp`/`bsr` with a static target, `dbcc`), and recognises the
idioms that hide a flow behind a register or a table:

- the C switch: `move.w (T,pc,dN.w),dN` directly before `jmp (d,pc,dN.w)`, the word table right
  after the `jmp`, each target = the `jmp`'s base + the entry; the entry count from the bound
  check before it (`cmpi #hi,dN` then `bhi`/`bgt`, or `#hi+1` then `bcc`/`bge`; the first case is
  lo = (table - T) / 2, so the move's T may lie before the table) or, without one, up to the
  lowest target;
- a computed call or jump: an address register set to a constant (`lea abs`/`lea (d,pc)`,
  `movea.l #`, then `adda`/`suba`/`addq`/`subq`/`lea (d,An)` on it) and used by
  `jsr`/`jmp (An)`/`(d,An)` in the same straight line;
- a code-pointer table: an address register set to a table base, a long loaded through it with
  an index (`movea.l (d,An,Xn)`, `movea.l (d,pc,Xn)`) or without (`movea.l (An)`/`(d,An)`), then
  `jsr`/`jmp (Am)` through the loaded register; the table's longs are taken while each one
  descends cleanly;
- the return address of the boot program, which runs without a stack: `lea ret,An` directly
  before an unconditional `bra`/`jmp`, with ret the address right after that branch (the callee
  returns with `jmp (An)`).

A seed's descent is a transaction: it is committed only if every instruction it reaches by a
static flow decodes as a 68010 instruction (decode.py), lies inside the code-eligible ranges, does
not overlap an instruction committed at another boundary or a table, and every static target it
needs does the same. Idiom targets and the fall-through after a call are later transactions of
their own (a call that never returns is followed by data; a wrong idiom must not poison the code
that led to it); a failure is recorded with its reason.
"""

from __future__ import annotations

import heapq
from dataclasses import dataclass, field

from .decode import (
    ABSL,
    ABSW,
    AN,
    BRANCH,
    CALL,
    DISP,
    DN,
    FALL,
    IMM,
    IND,
    INDEX,
    JUMP,
    PCDISP,
    PCINDEX,
    POSTINC,
    PREDEC,
    QUICK,
    Insn,
    Operand,
    decode,
)

Range = tuple[int, int]
Regs = dict[int, tuple[str, int, int]]  # An -> (kind, value, set at)

# priorities of the queue: smaller first
P_PLAIN, P_SWITCH, P_COMPUTED, P_TABLE, P_LATE = 0, 1, 2, 3, 4


@dataclass
class Switch:
    jmp: int  # address of the jmp (d8,pc,Xn)
    table: int  # first entry
    count: int  # entries
    base: int  # targets = base + signed entry
    lo: int  # the case value of the first entry
    bound: str  # how the count was found

    @property
    def end(self) -> int:
        return self.table + 2 * self.count

    def targets(self, image: bytes) -> list[int]:
        out = []
        for i in range(self.count):
            a = self.table + 2 * i
            e = int.from_bytes(image[a : a + 2], "big", signed=True)
            out.append((self.base + e) & 0xFFFFFF)
        return out


@dataclass
class PointerTable:
    start: int
    count: int  # longs
    evidence: str

    @property
    def end(self) -> int:
        return self.start + 4 * self.count


@dataclass
class Result:
    insns: dict[int, Insn] = field(default_factory=dict)
    entries: dict[int, str] = field(default_factory=dict)  # evidence of the non-plain entries
    plain: set[int] = field(default_factory=set)  # instructions reached from plain seeds
    switches: dict[int, Switch] = field(default_factory=dict)  # by table start
    pointer_tables: dict[int, PointerTable] = field(default_factory=dict)
    rejected: dict[int, str] = field(default_factory=dict)  # seed -> why
    noreturn: dict[int, str] = field(default_factory=dict)  # call -> why its fall-through failed


class _ConflictError(Exception):
    def __init__(self, why: str):
        super().__init__(why)
        self.why = why


@dataclass
class _Txn:
    new: dict[int, Insn] = field(default_factory=dict)
    own: dict[int, int] = field(default_factory=dict)
    table_bytes: set[int] = field(default_factory=set)
    switches: list[Switch] = field(default_factory=list)
    calls: list[int] = field(default_factory=list)
    followups: list[tuple[int, int, str]] = field(default_factory=list)  # (prio, addr, evidence)
    tables: list[tuple[int, int, str]] = field(default_factory=list)  # (start, limit, evidence)


class Descent:
    def __init__(self, image: bytes, eligible: list[Range],
                 untaken: dict[int, str] | None = None, external: set[int] | None = None):
        self.image = image
        # instruction starts outside the eligible ranges that a flow may reach (another range)
        self.external = set(external or ())
        # branches whose static target is never taken (a reviewed argument each): not followed
        self.untaken = dict(untaken or {})
        self.eligible = sorted(eligible)
        self.r = Result()
        self.owner: dict[int, int] = {}  # byte -> instruction start
        self.table_bytes: set[int] = set()
        # (priority, order, job, address, evidence, plain); job: seed, call, table
        self._queue: list[tuple[int, int, str, int, str | None, bool]] = []
        self._n = 0

    # --- predicates ---------------------------------------------------------------------------
    def is_eligible(self, a: int) -> bool:
        return a % 2 == 0 and any(lo <= a < hi for lo, hi in self.eligible)

    def _range_of(self, a: int) -> Range:
        return next((lo, hi) for lo, hi in self.eligible if lo <= a < hi)

    def is_free(self, a: int, n: int) -> bool:
        return all(b not in self.owner and b not in self.table_bytes for b in range(a, a + n))

    # --- the queue ----------------------------------------------------------------------------
    def add(self, addr: int, evidence: str | None, prio: int = P_PLAIN, plain: bool = False
            ) -> None:
        """Queue a seed; evidence None with plain=True marks a plain seed (vector, entry
        table)."""
        self._push("seed", addr, evidence, prio, plain)

    def _push(self, job: str, addr: int, evidence: str | None, prio: int, plain: bool) -> None:
        self._n += 1
        heapq.heappush(self._queue, (prio, self._n, job, addr, evidence, plain))

    def run(self) -> Result:
        while self._queue:
            _, _, job, addr, evidence, plain = heapq.heappop(self._queue)
            if job == "table":
                assert evidence is not None
                self._expand_table(addr, evidence)
            elif job == "call":
                self._after_call(addr, plain)
            else:
                self._seed(addr, evidence, plain)
        return self.r

    def _seed(self, addr: int, evidence: str | None, plain: bool) -> bool:
        if addr in self.r.insns:
            return True  # reached already: the descent that reached it is its evidence
        try:
            t = self._descend(addr)
        except _ConflictError as c:
            self.r.rejected.setdefault(addr, f"{c.why} (seed: {evidence or 'plain'})")
            return False
        for a, insn in t.new.items():
            self.r.insns[a] = insn
            for b in range(a, a + insn.length):
                self.owner[b] = a
        if plain:
            self.r.plain.update(t.new)
        for s in t.switches:
            self.r.switches[s.table] = s
            self.table_bytes.update(range(s.table, s.end))
        if evidence:
            self.r.entries[addr] = evidence
        for call in t.calls:
            self._push("call", call, None, P_PLAIN, plain)
        for prio, a, ev in t.followups:
            self.add(a, ev, prio)
        for start, limit, ev in t.tables:
            self._push("table", start, f"{limit}:{ev}", P_TABLE, False)
        return True

    def _after_call(self, call: int, plain: bool) -> None:
        nxt = call + self.r.insns[call].length
        if nxt in self.r.insns:
            return
        if not self._seed(nxt, None, plain):
            self.r.noreturn[call] = self.r.rejected.pop(nxt, "")

    def _expand_table(self, start: int, spec: str) -> None:
        limit_s, _, ev = spec.partition(":")
        limit = int(limit_s)
        if start in self.r.pointer_tables:
            return
        count = 0
        while count < limit:
            p = start + 4 * count
            if not self.is_free(p, 4):
                break
            v = int.from_bytes(self.image[p : p + 4], "big")
            if not self.is_eligible(v):
                break
            self.table_bytes.update(range(p, p + 4))
            if not self._seed(v, f"entry {count} of the code-pointer table at {start:06X} "
                                 f"({ev})", False):
                self.table_bytes.difference_update(range(p, p + 4))
                self.r.rejected.pop(v, None)
                break
            count += 1
        if count:
            self.r.pointer_tables[start] = PointerTable(start, count, ev)

    # --- one transaction ----------------------------------------------------------------------
    def _descend(self, seed: int) -> _Txn:
        t = _Txn()
        work: list[tuple[int, Regs]] = [(seed, {})]
        while work:
            a, regs = work.pop()
            if a in self.r.insns or a in t.new or a in self.external:
                continue
            if not self.is_eligible(a):
                raise _ConflictError(f"flow to {a:06X} outside the code ranges")
            insn = decode(self.image, a)
            if insn is None:
                raise _ConflictError(f"no 68010 instruction at {a:06X}")
            if a + insn.length > self._range_of(a)[1]:
                raise _ConflictError(f"the instruction at {a:06X} crosses the end of its range")
            for b in range(a, a + insn.length):
                o = self.owner.get(b, t.own.get(b))
                if o is not None and o != a:
                    raise _ConflictError(f"{a:06X} overlaps the instruction at {o:06X}")
                if b in self.table_bytes or b in t.table_bytes:
                    raise _ConflictError(f"{a:06X} overlaps a table")
            t.new[a] = insn
            for b in range(a, a + insn.length):
                t.own[b] = a
            target = insn.target
            if insn.flow in (JUMP, BRANCH, CALL) and target is not None:
                if a not in self.untaken:
                    work.append((target, {}))
            elif insn.flow in (JUMP, CALL):
                self._idioms(insn, regs, t)
            if insn.flow == JUMP:
                self._return_address(insn, t)
            if insn.flow == CALL:
                t.calls.append(a)
            elif insn.flow in (FALL, BRANCH):
                work.append((a + insn.length, _track(insn, regs)))
        return t

    def _prev(self, addr: int, t: _Txn) -> Insn | None:
        for k in (2, 4, 6, 8, 10):
            p = t.new.get(addr - k) or self.r.insns.get(addr - k)
            if p is not None and p.addr + p.length == addr:
                return p
        return None

    def _return_address(self, insn: Insn, t: _Txn) -> None:
        prev = self._prev(insn.addr, t)
        if prev is None or prev.mnemonic != "lea":
            return
        src = prev.operands[0]
        if src.mode not in (PCDISP, ABSL, ABSW):
            return
        ret = _abs(src)
        if ret == insn.addr + insn.length:
            t.followups.append((P_COMPUTED, ret, f"return address: lea at {prev.addr:06X} before "
                                                 f"the {insn.mnemonic} at {insn.addr:06X}"))

    def _idioms(self, insn: Insn, regs: Regs, t: _Txn) -> None:
        op = insn.operands[0]
        # the switch
        sw = self._switch(insn, t)
        if sw is not None:
            for b in range(sw.table, sw.end):
                if self.owner.get(b, t.own.get(b)) is not None or b in self.table_bytes:
                    raise _ConflictError(f"the switch table at {sw.table:06X} overlaps code")
            t.table_bytes.update(range(sw.table, sw.end))
            t.switches.append(sw)
            for k, tgt in enumerate(sw.targets(self.image)):
                t.followups.append((P_SWITCH, tgt, f"case {sw.lo + k} of the switch at "
                                                   f"{sw.jmp:06X} (table {sw.table:06X}, "
                                                   f"{sw.bound})"))
            return
        if op.mode not in (IND, DISP):
            return
        cur = regs.get(op.reg)
        if cur is None:
            return
        kind, value, at = cur
        if kind == "const":
            off = op.value if op.mode == DISP else 0
            target = (value + off) & 0xFFFFFF
            if self.is_eligible(target):
                t.followups.append((P_COMPUTED, target, f"computed {insn.mnemonic}: a{op.reg} "
                                                        f"set at {at:06X}, {insn.mnemonic} at "
                                                        f"{insn.addr:06X}"))
        elif kind in ("table", "ptr") and op.mode == IND and value % 2 == 0:
            how = "an indexed" if kind == "table" else "a"
            t.tables.append((value, 1024 if kind == "table" else 1,
                             f"{how} load at {at:06X}, {insn.mnemonic} at {insn.addr:06X}"))

    def _switch(self, insn: Insn, t: _Txn) -> Switch | None:
        op = insn.operands[0]
        if insn.mnemonic != "jmp" or op.mode != PCINDEX or not op.xreg.startswith("d") \
                or not op.xreg.endswith(".w"):
            return None
        n = int(op.xreg[1])
        prev = self._prev(insn.addr, t)
        if prev is None or prev.mnemonic != "move" or prev.size != "w":
            return None
        src, dst = prev.operands
        if src.mode != PCINDEX or src.xreg[:2] != op.xreg[:2] or dst.mode != DN or dst.reg != n:
            return None
        table = insn.addr + 4
        if (table - src.value) % 2:
            return None
        lo = (table - src.value) // 2
        hi, how = self._bound(prev, n, t)
        if hi is not None:
            count = hi - lo + 1
            if count <= 0 or count > 1024:
                return None
            sw = Switch(insn.addr, table, count, op.value, lo, how)
        else:
            count, limit = 0, 1 << 24
            while table + 2 * count < limit and count < 1024:
                p = table + 2 * count
                e = int.from_bytes(self.image[p : p + 2], "big", signed=True)
                tgt = (op.value + e) & 0xFFFFFF
                if not self.is_eligible(tgt) or tgt < table + 2 * (count + 1):
                    break
                limit = min(limit, tgt)
                count += 1
            if count == 0:
                return None
            sw = Switch(insn.addr, table, count, op.value, lo, "no bound check: up to the "
                                                               "lowest case")
        for tgt in sw.targets(self.image):
            if not self.is_eligible(tgt) or sw.table <= tgt < sw.end:
                return None
        return sw

    def _bound(self, move: Insn, n: int, t: _Txn) -> tuple[int | None, str]:
        """The compare and branch that bound the switch's index dN, in the straight line before
        the move: `cmp(i) #V,dN` then `bhi`/`bgt` (or `bcc`/`bge` with V - 1), or `moveq #V,dM`,
        `cmp dN,dM` then `blt`/`bcs` (or `ble`/`bls`); a `sub #K,dN` after the compare moves
        the bound down by K."""
        cur = move
        offset = 0
        for _ in range(10):
            p = self._prev(cur.addr, t)
            if p is None:
                return None, ""
            nxt, cur = cur, p
            ops = cur.operands
            if cur.mnemonic in ("sub", "subi", "subq") and ops[-1].mode == DN \
                    and ops[-1].reg == n and ops[0].mode in (IMM, QUICK):
                offset += ops[0].value
                continue
            if cur.mnemonic in ("cmpi", "cmp") and ops[-1].mode == DN and ops[-1].reg == n \
                    and ops[0].mode == IMM and nxt.mnemonic in ("bhi", "bgt", "bcc", "bge"):
                v = ops[0].value - (1 if nxt.mnemonic in ("bcc", "bge") else 0)
                return v - offset, (f"bound: {cur.mnemonic} at {cur.addr:06X}, {nxt.mnemonic} "
                                    f"at {nxt.addr:06X}")
            if cur.mnemonic == "cmp" and ops[0].mode == DN and ops[0].reg == n \
                    and ops[1].mode == DN and nxt.mnemonic in ("blt", "bcs", "ble", "bls"):
                q = self._prev(cur.addr, t)
                if q is not None and q.mnemonic == "moveq" and q.operands[1].reg == ops[1].reg:
                    v = q.operands[0].value - (1 if nxt.mnemonic in ("ble", "bls") else 0)
                    return v - offset, (f"bound: moveq at {q.addr:06X}, cmp at {cur.addr:06X}, "
                                        f"{nxt.mnemonic} at {nxt.addr:06X}")
        return None, ""


def _sw(v: int) -> int:
    return v - 0x10000 if v & 0x8000 else v


def _abs(op: Operand) -> int:
    if op.mode == ABSW:
        return (op.value | 0xFF0000) & 0xFFFFFF if op.value & 0x8000 else op.value
    return op.value & 0xFFFFFF


def _track(insn: Insn, regs: Regs) -> Regs:
    """Address-register constants along straight-line code, for the idioms. Anything that may
    change a register forgets it; a call, movem or exg forgets them all."""
    ops = insn.operands
    mn = insn.mnemonic
    if insn.flow == CALL or mn in ("movem", "exg"):
        return {}
    out = dict(regs)
    dst = ops[-1] if ops else None
    if mn == "lea" and dst is not None:
        src = ops[0]
        if src.mode in (ABSW, ABSL, PCDISP):
            out[dst.reg] = ("const", _abs(src), insn.addr)
        elif src.mode == DISP and regs.get(src.reg, ("",))[0] == "const":
            out[dst.reg] = ("const", (regs[src.reg][1] + src.value) & 0xFFFFFF, insn.addr)
        else:
            out.pop(dst.reg, None)
        return out
    if mn == "movea" and dst is not None:
        src = ops[0]
        base = regs.get(src.reg) if src.mode in (IND, DISP, INDEX) else None
        if insn.size == "l" and src.mode == IMM:
            out[dst.reg] = ("const", src.value & 0xFFFFFF, insn.addr)
        elif insn.size == "l" and src.mode == INDEX and base and base[0] == "const":
            out[dst.reg] = ("table", (base[1] + src.value) & 0xFFFFFF, insn.addr)
        elif insn.size == "l" and src.mode == PCINDEX:
            out[dst.reg] = ("table", src.value, insn.addr)
        elif insn.size == "l" and src.mode in (IND, DISP) and base and base[0] == "const":
            off = src.value if src.mode == DISP else 0
            out[dst.reg] = ("ptr", (base[1] + off) & 0xFFFFFF, insn.addr)
        else:
            out.pop(dst.reg, None)
        return out
    if mn in ("adda", "suba", "addq", "subq") and dst is not None and dst.mode == AN:
        src = ops[0]
        cur = regs.get(dst.reg)
        if cur and cur[0] == "const" and src.mode in (IMM, QUICK):
            d = _sw(src.value) if src.mode == IMM and insn.size == "w" else src.value
            if mn in ("suba", "subq"):
                d = -d
            out[dst.reg] = ("const", (cur[1] + d) & 0xFFFFFF, cur[2])
        else:
            out.pop(dst.reg, None)
        return out
    for i, o in enumerate(ops):
        if o.mode in (POSTINC, PREDEC):
            out.pop(o.reg, None)
        elif o.mode == AN and (i == len(ops) - 1 or mn in ("unlk", "link")):
            out.pop(o.reg, None)
    return out


def operand_refs(insn: Insn) -> list[tuple[int, int, str]]:
    """(operand index, address, mode) of every absolute or PC-relative address an instruction's
    operands designate, and of its long immediates (mode 'imm')."""
    out = []
    for i, o in enumerate(insn.operands):
        if o.mode in (ABSW, ABSL):
            out.append((i, _abs(o), o.mode))
        elif o.mode in (PCDISP, PCINDEX):
            out.append((i, o.value, o.mode))
        elif o.mode == IMM and o.size == "l":
            out.append((i, o.value & 0xFFFFFFFF, "imm"))
    return out
