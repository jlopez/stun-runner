"""A 68010 instruction decoder for the descent and the generator (docs/14-68k-descent.md).

Pure Python, no tables from a disassembler: CI has vasm only, so the tests assemble 68010 code
with vasm and decode it with this module. `decode(image, addr)` returns an `Insn` (length, the
mnemonic and size, structured operands, the control flow) or None when the words at addr are not
a 68010 instruction a 68010 program could contain: line A and line F, the 68020 forms
(`bra.l`, `chk.l`, a full extension word, a scale factor), and every addressing mode the
instruction does not allow on the 68000/68010 (unidasm decodes some of those, e.g.
`cmpi.w #N,(d16,PC)`; a decode that needs them is "not code"). Locally, `tools/m68k check-unidasm`
compares every instruction boundary with unidasm's.

Operands keep the offset of their extension data inside the instruction (`Operand.at`, -1 for
none), so the shift test and the reference collectors know which bytes hold an address.
Formatting is `format_insn(insn, resolve)`: vasm Motorola syntax as decision C2 writes it (lower
case, every branch sized, absolute short `.w`, absolute long without a suffix, PC-relative operands
as a target); `resolve` turns addresses into symbols.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass, field

# operand modes
DN, AN, IND, POSTINC, PREDEC, DISP, INDEX = "dn", "an", "ind", "postinc", "predec", "disp", "index"
ABSW, ABSL, PCDISP, PCINDEX, IMM = "absw", "absl", "pcdisp", "pcindex", "imm"
TARGET = "target"  # a branch or dbcc destination (value = the absolute address)
QUICK = "quick"  # an immediate encoded in the opcode (moveq, addq, trap, shift count, bkpt)
SR, CCR, USP, CTRL, REGLIST = "sr", "ccr", "usp", "ctrl", "reglist"

CONDITIONS = ["t", "f", "hi", "ls", "cc", "cs", "ne", "eq", "vc", "vs", "pl", "mi", "ge", "lt",
              "gt", "le"]
CONTROL_REGS = {0x000: "sfc", 0x001: "dfc", 0x800: "usp", 0x801: "vbr"}  # the 68010's four

# flow kinds
FALL, STOP, JUMP, BRANCH, CALL = "fall", "stop", "jump", "branch", "call"


@dataclass
class Operand:
    mode: str
    reg: int = 0
    value: int = 0  # displacement, address, immediate, branch target, register mask
    at: int = -1  # byte offset of the extension data in the instruction (-1: none)
    width: int = 0  # bytes of extension data holding value (2 or 4; 0 for none)
    xreg: str = ""  # index register for INDEX/PCINDEX, e.g. "d0.w"
    size: str = ""  # operation size for IMM ("b", "w", "l")
    raw: int = 0  # the extension word as stored (IMM byte: the whole word)

    @property
    def address(self) -> int | None:
        """The absolute address an operand designates, when the encoding gives one."""
        if self.mode in (ABSW, ABSL, PCDISP, PCINDEX, TARGET):
            return self.value
        return None


@dataclass
class Insn:
    addr: int
    length: int
    mnemonic: str  # without size, e.g. "move", "bne"
    size: str  # "b", "w", "l", "s" (short branch) or ""
    operands: list[Operand] = field(default_factory=list)
    flow: str = FALL
    words: tuple[int, ...] = ()

    @property
    def target(self) -> int | None:
        """The static destination of a branch, bsr, dbcc, jmp or jsr, if the encoding has one."""
        if self.flow in (JUMP, BRANCH, CALL):
            op = self.operands[-1]
            if op.mode in (TARGET, ABSW, ABSL, PCDISP):
                return op.value & 0xFFFFFF if op.mode != ABSW else _absw(op.value)
        return None

    @property
    def text(self) -> str:
        return format_insn(self, None)


def _absw(v: int) -> int:
    return (v | 0xFF0000) & 0xFFFFFF if v & 0x8000 else v


def _s8(v: int) -> int:
    return v - 0x100 if v & 0x80 else v


def _s16(v: int) -> int:
    return v - 0x10000 if v & 0x8000 else v


class _BadError(Exception):
    pass


class _Reader:
    def __init__(self, image: bytes, addr: int):
        self.image = image
        self.addr = addr
        self.pos = 2

    def word(self) -> int:
        a = self.addr + self.pos
        if a + 2 > len(self.image):
            raise _BadError
        self.pos += 2
        return int.from_bytes(self.image[a : a + 2], "big")

    def long(self) -> int:
        return (self.word() << 16) | self.word()


# EA classes (68000/68010)
ALL, DATA, MEM, CONTROL, ALTER, DALT, MALT = "all", "data", "mem", "control", "alter", "dalt", "malt"


def _allowed(mode: int, reg: int, cls: str) -> bool:
    if mode == 7 and reg > 4:
        return False
    if cls == ALL:
        return True
    if cls == DATA:
        return mode != 1
    if cls == MEM:
        return mode not in (0, 1)
    if cls == CONTROL:
        return mode in (2, 5, 6) or (mode == 7 and reg in (0, 1, 2, 3))
    if cls == ALTER:
        return mode < 7 or (mode == 7 and reg in (0, 1))
    if cls == DALT:
        return mode != 1 and (mode < 7 or reg in (0, 1))
    if cls == MALT:
        return mode >= 2 and (mode < 7 or reg in (0, 1))
    raise ValueError(cls)


def _ea(r: _Reader, mode: int, reg: int, size: str, cls: str) -> Operand:
    if not _allowed(mode, reg, cls):
        raise _BadError
    if mode == 0:
        return Operand(DN, reg)
    if mode == 1:
        if size == "b":
            raise _BadError  # byte operations on an address register do not exist
        return Operand(AN, reg)
    if mode == 2:
        return Operand(IND, reg)
    if mode == 3:
        return Operand(POSTINC, reg)
    if mode == 4:
        return Operand(PREDEC, reg)
    if mode == 5:
        at = r.pos
        return Operand(DISP, reg, _s16(r.word()), at, 2)
    if mode == 6:
        at = r.pos
        ext = r.word()
        return Operand(INDEX, reg, _s8(ext & 0xFF), at, 2, _xreg(ext))
    if reg == 0:
        at = r.pos
        return Operand(ABSW, 0, r.word(), at, 2)
    if reg == 1:
        at = r.pos
        return Operand(ABSL, 0, r.long(), at, 4)
    if reg == 2:
        at = r.pos
        base = r.addr + r.pos
        return Operand(PCDISP, 0, (base + _s16(r.word())) & 0xFFFFFF, at, 2)
    if reg == 3:
        at = r.pos
        base = r.addr + r.pos
        ext = r.word()
        return Operand(PCINDEX, 0, (base + _s8(ext & 0xFF)) & 0xFFFFFF, at, 2, _xreg(ext))
    if reg == 4:
        return _imm(r, size)
    raise _BadError


def _xreg(ext: int) -> str:
    if ext & 0x0700:
        raise _BadError  # bit 8 (full format) or a scale factor: 68020 and up
    kind = "a" if ext & 0x8000 else "d"
    return f"{kind}{(ext >> 12) & 7}.{'l' if ext & 0x0800 else 'w'}"


def _imm(r: _Reader, size: str) -> Operand:
    at = r.pos
    if size == "b":
        w = r.word()
        # the high byte of a byte immediate is 00, or FF as a sign extension (the 68010 ignores
        # it; assemblers write 00, the ROM has ten FFFF, macros.asm): anything else is not code
        if not (w >> 8 == 0 or (w >> 8 == 0xFF and w & 0x80)):
            raise _BadError
        return Operand(IMM, 0, w & 0xFF, at, 2, size="b", raw=w)
    if size == "w":
        w = r.word()
        return Operand(IMM, 0, w, at, 2, size="w", raw=w)
    if size == "l":
        v = r.long()
        return Operand(IMM, 0, v, at, 4, size="l", raw=v)
    raise _BadError


SIZES = {0: "b", 1: "w", 2: "l"}


def decode(image: bytes, addr: int) -> Insn | None:
    """The instruction at addr, or None if the bytes there are not a 68010 instruction."""
    if addr % 2 or addr + 2 > len(image):
        return None
    r = _Reader(image, addr)
    op = int.from_bytes(image[addr : addr + 2], "big")
    try:
        mn, size, ops, flow = _decode(r, op, addr)
    except _BadError:
        return None
    words = tuple(
        int.from_bytes(image[addr + i : addr + i + 2], "big") for i in range(0, r.pos, 2)
    )
    return Insn(addr, r.pos, mn, size, ops, flow, words)


Decoded = tuple[str, str, list[Operand], str]


def _decode(r: _Reader, op: int, addr: int) -> Decoded:
    line = op >> 12
    mode, reg = (op >> 3) & 7, op & 7
    if line == 0:
        return _line0(r, op, mode, reg)
    if line in (1, 2, 3):
        size = {1: "b", 3: "w", 2: "l"}[line]
        src = _ea(r, mode, reg, size, ALL)
        dmode, dreg = (op >> 6) & 7, (op >> 9) & 7
        if dmode == 1:
            if size == "b":
                raise _BadError
            return "movea", size, [src, Operand(AN, dreg)], FALL
        dst = _ea(r, dmode, dreg, size, DALT)
        return "move", size, [src, dst], FALL
    if line == 4:
        return _line4(r, op, mode, reg)
    if line == 5:
        cond = (op >> 8) & 15
        if (op >> 6) & 3 == 3:
            if mode == 1:
                at = r.pos
                base = addr + 2
                disp = _s16(r.word())
                t = Operand(TARGET, 0, (base + disp) & 0xFFFFFF, at, 2)
                return "db" + CONDITIONS[cond], "", [Operand(DN, reg), t], BRANCH
            return "s" + CONDITIONS[cond], "b", [_ea(r, mode, reg, "b", DALT)], FALL
        size = SIZES[(op >> 6) & 3]
        q = (op >> 9) & 7 or 8
        dst = _ea(r, mode, reg, size, ALTER)
        return ("subq" if op & 0x100 else "addq"), size, [Operand(QUICK, 0, q), dst], FALL
    if line == 6:
        cond = (op >> 8) & 15
        d8 = op & 0xFF
        base = addr + 2
        if d8 == 0:
            at = r.pos
            t = Operand(TARGET, 0, (base + _s16(r.word())) & 0xFFFFFF, at, 2)
            size = "w"
        elif d8 == 0xFF:
            raise _BadError  # bcc.l: 68020
        else:
            t = Operand(TARGET, 0, (base + _s8(d8)) & 0xFFFFFF, -1, 0)
            size = "s"
        if cond == 0:
            return "bra", size, [t], JUMP
        if cond == 1:
            return "bsr", size, [t], CALL
        return "b" + CONDITIONS[cond], size, [t], BRANCH
    if line == 7:
        if op & 0x100:
            raise _BadError
        return "moveq", "l", [Operand(QUICK, 0, _s8(op & 0xFF)), Operand(DN, (op >> 9) & 7)], FALL
    if line in (8, 9, 0xB, 0xC, 0xD):
        return _arith(r, op, line, mode, reg)
    if line == 0xE:
        return _shift(r, op, mode, reg)
    raise _BadError  # line A, line F


def _line0(r: _Reader, op: int, mode: int, reg: int) -> Decoded:
    if op & 0x100:
        dreg = (op >> 9) & 7
        kind = (op >> 6) & 3
        if mode == 1:  # movep
            at = r.pos
            d = Operand(DISP, reg, _s16(r.word()), at, 2)
            size = "l" if kind & 1 else "w"
            if kind & 2:
                return "movep", size, [Operand(DN, dreg), d], FALL
            return "movep", size, [d, Operand(DN, dreg)], FALL
        names = ["btst", "bchg", "bclr", "bset"]
        if kind == 0:
            dst = _ea(r, mode, reg, "b", DATA)
        else:
            dst = _ea(r, mode, reg, "b", DALT)
        return names[kind], "", [Operand(DN, dreg), dst], FALL
    top = (op >> 9) & 7
    kind = (op >> 6) & 3
    if top == 4:  # static bit operations
        names = ["btst", "bchg", "bclr", "bset"]
        at = r.pos
        w = r.word()
        if w & 0xFF00:
            raise _BadError
        n = Operand(IMM, 0, w & 0xFF, at, 2, size="b", raw=w)
        cls = DATA if kind == 0 else DALT
        if kind == 0 and mode == 7 and reg == 4:
            raise _BadError  # btst #n,#imm
        return names[kind], "", [n, _ea(r, mode, reg, "b", cls)], FALL
    if top == 7:  # moves (68010)
        if kind == 3:
            raise _BadError
        size = SIZES[kind]
        ext = r.word()
        if ext & 0x07FF:
            raise _BadError
        rn = Operand(AN if ext & 0x8000 else DN, (ext >> 12) & 7)
        ea = _ea(r, mode, reg, size, MALT)
        if ext & 0x0800:
            return "moves", size, [rn, ea], FALL
        return "moves", size, [ea, rn], FALL
    names0 = {0: "ori", 1: "andi", 2: "subi", 3: "addi", 5: "eori", 6: "cmpi"}
    if top not in names0 or kind == 3:
        raise _BadError
    name = names0[top]
    if mode == 7 and reg == 4:  # to CCR / SR
        if top not in (0, 1, 5) or kind == 2:
            raise _BadError
        size = "b" if kind == 0 else "w"
        imm = _imm(r, size)
        return name, "", [imm, Operand(CCR if kind == 0 else SR)], FALL
    size = SIZES[kind]
    imm = _imm(r, size)
    return name, size, [imm, _ea(r, mode, reg, size, DALT)], FALL


def _line4(r: _Reader, op: int, mode: int, reg: int) -> Decoded:
    if op & 0x100:
        dreg = (op >> 9) & 7
        kind = (op >> 6) & 3
        if kind == 3:
            return "lea", "l", [_ea(r, mode, reg, "l", CONTROL), Operand(AN, dreg)], FALL
        if kind == 2:
            return "chk", "w", [_ea(r, mode, reg, "w", DATA), Operand(DN, dreg)], FALL
        raise _BadError  # chk.l: 68020
    sub = (op >> 8) & 0xF
    kind = (op >> 6) & 3
    if sub in (0x0, 0x2, 0x4, 0x6) and kind != 3:
        name = {0: "negx", 2: "clr", 4: "neg", 6: "not"}[sub]
        size = SIZES[kind]
        return name, size, [_ea(r, mode, reg, size, DALT)], FALL
    if sub == 0x0 and kind == 3:
        return "move", "w", [Operand(SR), _ea(r, mode, reg, "w", DALT)], FALL
    if sub == 0x2 and kind == 3:
        return "move", "w", [Operand(CCR), _ea(r, mode, reg, "w", DALT)], FALL  # 68010
    if sub == 0x4 and kind == 3:
        return "move", "w", [_ea(r, mode, reg, "w", DATA), Operand(CCR)], FALL
    if sub == 0x6 and kind == 3:
        return "move", "w", [_ea(r, mode, reg, "w", DATA), Operand(SR)], FALL
    if sub == 0x8:
        if kind == 0:
            return "nbcd", "b", [_ea(r, mode, reg, "b", DALT)], FALL
        if kind == 1:
            if mode == 0:
                return "swap", "", [Operand(DN, reg)], FALL
            if mode == 1:
                return "bkpt", "", [Operand(QUICK, 0, reg)], FALL  # 68010
            return "pea", "l", [_ea(r, mode, reg, "l", CONTROL)], FALL
        if mode == 0:
            return "ext", ("w" if kind == 2 else "l"), [Operand(DN, reg)], FALL
        size = "w" if kind == 2 else "l"
        at = r.pos
        mask = r.word()
        lst = Operand(REGLIST, 0, mask, at, 2)
        if mode == 4:
            lst.reg = 1  # predecrement: the mask is reversed
        elif not _allowed(mode, reg, CONTROL) or not _allowed(mode, reg, ALTER):
            raise _BadError
        return "movem", size, [lst, _ea(r, mode, reg, size, ALL)], FALL
    if sub == 0xC:
        if kind < 2:
            raise _BadError  # mul.l / div.l: 68020
        size = "w" if kind == 2 else "l"
        at = r.pos
        mask = r.word()
        if mode == 3:
            pass
        elif not _allowed(mode, reg, CONTROL):
            raise _BadError
        src = _ea(r, mode, reg, size, ALL)
        return "movem", size, [src, Operand(REGLIST, 0, mask, at, 2)], FALL
    if sub == 0xA:
        if op == 0x4AFC:
            return "illegal", "", [], STOP
        if kind == 3:
            return "tas", "b", [_ea(r, mode, reg, "b", DALT)], FALL
        size = SIZES[kind]
        return "tst", size, [_ea(r, mode, reg, size, DALT)], FALL
    if sub == 0xE:
        if kind == 1:
            low = op & 0x3F
            if low < 0x10:
                return "trap", "", [Operand(QUICK, 0, low)], FALL
            if low < 0x18:
                return "link", "w", [Operand(AN, reg), _imm(r, "w")], FALL
            if 0x18 <= low < 0x20:
                return "unlk", "", [Operand(AN, reg)], FALL
            if 0x20 <= low < 0x28:
                return "move", "l", [Operand(AN, reg), Operand(USP)], FALL
            if 0x28 <= low < 0x30:
                return "move", "l", [Operand(USP), Operand(AN, reg)], FALL
            if op == 0x4E70:
                return "reset", "", [], FALL
            if op == 0x4E71:
                return "nop", "", [], FALL
            if op == 0x4E72:
                return "stop", "", [_imm(r, "w")], FALL
            if op == 0x4E73:
                return "rte", "", [], STOP
            if op == 0x4E74:
                return "rtd", "", [_imm(r, "w")], STOP  # 68010
            if op == 0x4E75:
                return "rts", "", [], STOP
            if op == 0x4E76:
                return "trapv", "", [], FALL
            if op == 0x4E77:
                return "rtr", "", [], STOP
            if op in (0x4E7A, 0x4E7B):
                ext = r.word()
                if ext & 0xFFF not in CONTROL_REGS:
                    raise _BadError
                rn = Operand(AN if ext & 0x8000 else DN, (ext >> 12) & 7)
                c = Operand(CTRL, ext & 0xFFF)
                return "movec", "", ([c, rn] if op == 0x4E7A else [rn, c]), FALL
            raise _BadError
        if kind == 2:
            return "jsr", "", [_ea(r, mode, reg, "l", CONTROL)], CALL
        if kind == 3:
            return "jmp", "", [_ea(r, mode, reg, "l", CONTROL)], JUMP
    raise _BadError


def _arith(r: _Reader, op: int, line: int, mode: int, reg: int) -> Decoded:
    dreg = (op >> 9) & 7
    opmode = (op >> 6) & 7
    name = {8: "or", 9: "sub", 0xB: "cmp", 0xC: "and", 0xD: "add"}[line]
    if opmode in (3, 7):
        if line == 8:
            return ("divu" if opmode == 3 else "divs"), "w", [_ea(r, mode, reg, "w", DATA),
                                                             Operand(DN, dreg)], FALL
        if line == 0xC:
            return ("mulu" if opmode == 3 else "muls"), "w", [_ea(r, mode, reg, "w", DATA),
                                                             Operand(DN, dreg)], FALL
        size = "w" if opmode == 3 else "l"
        return name + "a", size, [_ea(r, mode, reg, size, ALL), Operand(AN, dreg)], FALL
    size = SIZES[opmode & 3]
    if opmode < 3:
        cls = DATA if line in (8, 0xC) else ALL
        return name, size, [_ea(r, mode, reg, size, cls), Operand(DN, dreg)], FALL
    # opmode 4-6: Dn,<ea> forms, and the register-register specials at modes 0 and 1
    if line == 0xB:
        if mode == 1:
            return "cmpm", size, [Operand(POSTINC, reg), Operand(POSTINC, dreg)], FALL
        return "eor", size, [Operand(DN, dreg), _ea(r, mode, reg, size, DALT)], FALL
    if mode in (0, 1):
        if line in (9, 0xD):
            nm = "subx" if line == 9 else "addx"
        elif opmode == 4:
            nm = "sbcd" if line == 8 else "abcd"
        elif line == 0xC:
            return _exg(op, opmode, mode, reg, dreg)
        else:
            raise _BadError
        if nm in ("sbcd", "abcd") and opmode != 4:
            raise _BadError
        if mode == 0:
            return nm, size, [Operand(DN, reg), Operand(DN, dreg)], FALL
        return nm, size, [Operand(PREDEC, reg), Operand(PREDEC, dreg)], FALL
    return name, size, [Operand(DN, dreg), _ea(r, mode, reg, size, MALT)], FALL


def _exg(op: int, opmode: int, mode: int, reg: int, dreg: int) -> Decoded:
    sel = (op >> 3) & 0x1F
    if sel == 0x08:
        return "exg", "", [Operand(DN, dreg), Operand(DN, reg)], FALL
    if sel == 0x09:
        return "exg", "", [Operand(AN, dreg), Operand(AN, reg)], FALL
    if sel == 0x11:
        return "exg", "", [Operand(DN, dreg), Operand(AN, reg)], FALL
    raise _BadError


def _shift(r: _Reader, op: int, mode: int, reg: int) -> Decoded:
    names = ["as", "ls", "rox", "ro"]
    direction = "l" if op & 0x100 else "r"
    if (op >> 6) & 3 == 3:
        if op & 0x0800:
            raise _BadError  # bit-field instructions: 68020
        kind = (op >> 9) & 3
        return names[kind] + direction, "w", [_ea(r, mode, reg, "w", MALT)], FALL
    size = SIZES[(op >> 6) & 3]
    kind = (op >> 3) & 3
    count = (op >> 9) & 7
    if op & 0x20:
        src = Operand(DN, count)
    else:
        src = Operand(QUICK, 0, count or 8)
    return names[kind] + direction, size, [src, Operand(DN, reg)], FALL


# --- formatting ------------------------------------------------------------------------------

Resolve = Callable[[Insn, int, Operand], str | None]


def hexs(v: int) -> str:
    """A signed value as vasm hex: $1F, -$1F."""
    return f"-${-v:X}" if v < 0 else f"${v:X}"


def _reg(kind: str, n: int) -> str:
    if kind == "a" and n == 7:
        return "sp"
    return f"{kind}{n}"


def _xfmt(x: str) -> str:
    if x.startswith("a7"):
        return "sp" + x[2:]
    return x


def reglist(mask: int, reverse: bool) -> str:
    if reverse:
        mask = int(f"{mask:016b}"[::-1], 2)
    names = [f"d{i}" for i in range(8)] + [f"a{i}" for i in range(8)]
    parts = []
    i = 0
    while i < 16:
        if mask & (1 << i):
            j = i
            while j + 1 < 16 and (mask & (1 << (j + 1))) and (j + 1) // 8 == i // 8:
                j += 1
            parts.append(names[i] if i == j else f"{names[i]}-{names[j]}")
            i = j + 1
        else:
            i += 1
    return "/".join(parts).replace("a7", "sp")


def format_operand(insn: Insn, i: int, op: Operand, resolve: Resolve | None) -> str:
    sym = resolve(insn, i, op) if resolve else None
    m = op.mode
    if m == DN:
        return _reg("d", op.reg)
    if m == AN:
        return _reg("a", op.reg)
    if m == IND:
        return f"({_reg('a', op.reg)})"
    if m == POSTINC:
        return f"({_reg('a', op.reg)})+"
    if m == PREDEC:
        return f"-({_reg('a', op.reg)})"
    if m == DISP:
        return f"({sym or hexs(op.value)},{_reg('a', op.reg)})"
    if m == INDEX:
        return f"({sym or hexs(op.value)},{_reg('a', op.reg)},{_xfmt(op.xreg)})"
    if m == ABSW:
        if sym:
            return f"{sym}.w"
        return f"${(op.value | 0xFFFF0000) if op.value & 0x8000 else op.value:X}.w"
    if m == ABSL:
        return sym or f"${op.value:X}"
    if m == PCDISP:
        return f"({sym or f'${op.value:X}'},pc)"
    if m == PCINDEX:
        return f"({sym or f'${op.value:X}'},pc,{_xfmt(op.xreg)})"
    if m == TARGET:
        return sym or f"${op.value:X}"
    if m == IMM:
        return f"#{sym or f'${op.value:X}'}"
    if m == QUICK:
        if insn.mnemonic == "moveq":
            return f"#{hexs(op.value)}"
        return f"#{op.value}"
    if m == SR:
        return "sr"
    if m == CCR:
        return "ccr"
    if m == USP:
        return "usp"
    if m == CTRL:
        return CONTROL_REGS[op.reg]
    if m == REGLIST:
        return reglist(op.value, bool(op.reg))
    raise ValueError(m)


# instructions with one size only: written without a suffix
UNSIZED = {"lea", "pea", "moveq", "link", "chk", "tas", "nbcd", "swap", "exg", "unlk"}


def format_insn(insn: Insn, resolve: Resolve | None) -> str:
    sized = insn.size and insn.mnemonic not in UNSIZED and not (
        insn.mnemonic.startswith("s") and insn.mnemonic[1:] in CONDITIONS
    )
    name = insn.mnemonic + (f".{insn.size}" if sized else "")
    ops = ",".join(format_operand(insn, i, o, resolve) for i, o in enumerate(insn.operands))
    return f"{name}\t{ops}" if ops else name
