"""Which long immediates are addresses (data/68k/operands.json, docs/14 section 4).

Byte identity cannot tell `#$47406` the address from `#$47406` the number. Every long immediate
of a code instruction whose value lies in 000100-0BFFFF (where the image's addresses are; below
000100 only the vector table) gets a decision and the rule that made it:

    address    the generator writes a label (the shift test checks it moves with its target)
    constant   the generator writes the number (the address lint allows it)
    undecided  the generator writes the number; the lint reports it (docs/14 lists them)

The rules, in order (the first that matches decides):

    R1 address    movea.l #X,An: a value loaded into an address register
    R2 address    X = 0BFE00, the image pointer table (docs/06 section 4.2), added to an index
    R2b address   add/addi.l #X,Dn followed at once by movea.l Dn,An, X in a data, text or
                  pointer range of the classification: a table base added to an index, the
                  sum read through An (the boot program's 002FBE, 00307C, 00317E, 0048CC,
                  0049A6)
    R3 address    move.l/pea of X where X starts a routine (a call target or an entry with
                  evidence): a routine's address handed on (a callback)
    R4 address    move.l of X >= 020000 where X is an address some instruction uses as an
                  absolute or PC-relative operand
    R5 constant   and/or/eor (immediate or not): a mask
    R6 constant   add/sub/cmp and their immediate and address forms, mul/div: an arithmetic
                  operand
    R7 undecided  move.l of X >= 04397E (the data island, the data, the images): a pointer into
                  the data or a large number (16.16 fixed point), not decided
    R8 constant   move.l of a smaller X: a count, a delay or a fixed-point value

A code leg overrides a rule with a reviewed decision (rule `reviewed`, decision `address` or
`constant`, and a `reason` of at least 40 characters that cites the instructions): `tools/m68k
classify` keeps every reviewed entry of the file it rewrites (`load_reviewed`, `build`), so a
re-run of `make classify` never loses one. M5c decided the 32 R7 operands this way (docs/16).

The file holds instruction addresses, operand indexes, decisions, rule names and reasons: no
value.
"""

from __future__ import annotations

import json
from pathlib import Path

from .decode import AN, DN, IMM, Insn

LO, HI = 0x000100, 0x0C0000
FORMAT = "stunrun-68k-operands 1"
RULES = {
    "R1": ("address", "movea.l into an address register"),
    "R2": ("address", "the image pointer table 0BFE00 (docs/06 4.2)"),
    "R2b": ("address", "a table base added to an index register that is then moved into an "
            "address register"),
    "R3": ("address", "a routine's address handed on (a callback)"),
    "R4": ("address", "an address other instructions use as an operand"),
    "R5": ("constant", "a mask"),
    "R6": ("constant", "an arithmetic or compare operand"),
    "R7": ("undecided", "a pointer into the data or a large number, not decided"),
    "R8": ("constant", "a count, a delay or a fixed-point value below the data"),
}
REVIEWED = "reviewed"
REVIEWED_TEXT = "address or constant: decided by a code leg, the reason in the entry"
LOGICAL = {"and", "andi", "or", "ori", "eor", "eori"}
ARITH = {"add", "addi", "adda", "sub", "subi", "suba", "cmp", "cmpi", "cmpa", "mulu", "muls",
         "divu", "divs", "addq", "subq"}


def candidates(insn: Insn) -> list[int]:
    """Operand indexes of the long immediates in the decided range."""
    return [i for i, o in enumerate(insn.operands)
            if o.mode == IMM and o.size == "l" and LO <= o.value < HI]


def table_base(insn: Insn, nxt: Insn | None, v: int, tables: list[tuple[int, int]]) -> bool:
    """add/addi.l #X,Dn then movea.l Dn,An, with X in a table range (rule R2b)."""
    if insn.mnemonic not in ("add", "addi") or insn.size != "l" or nxt is None:
        return False
    dst = insn.operands[-1]
    if dst.mode != DN or nxt.mnemonic != "movea" or nxt.size != "l":
        return False
    src = nxt.operands[0]
    return src.mode == DN and src.reg == dst.reg and any(a <= v < b for a, b in tables)


def decide(insn: Insn, i: int, routine_starts: set[int], operand_addresses: set[int],
           nxt: Insn | None = None, tables: list[tuple[int, int]] | None = None) -> str:
    """nxt: the instruction after insn; tables: the data, text and pointer ranges."""
    v = insn.operands[i].value
    mn = insn.mnemonic
    if mn == "movea" and insn.operands[-1].mode == AN:
        return "R1"
    if v == 0x0BFE00:
        return "R2"
    if table_base(insn, nxt, v, tables or []):
        return "R2b"
    if mn in ("move", "pea") and v in routine_starts:
        return "R3"
    if mn == "move" and v in operand_addresses and v >= 0x020000:
        return "R4"
    if mn in LOGICAL:
        return "R5"
    if mn in ARITH:
        return "R6"
    if v >= 0x04397E:
        return "R7"
    return "R8"


def build(insns: dict[int, Insn], routine_starts: set[int], operand_addresses: set[int],
          tables: list[tuple[int, int]] | None = None,
          reviewed: dict[tuple[int, int], dict[str, object]] | None = None
          ) -> list[dict[str, object]]:
    """tables: the classification's data, text and pointer ranges (rule R2b); reviewed: the
    reviewed entries to keep (load_reviewed), each in place of its rule's decision."""
    out: list[dict[str, object]] = []
    reviewed = reviewed or {}
    for a in sorted(insns):
        for i in candidates(insns[a]):
            if (a, i) in reviewed:
                out.append(dict(reviewed[(a, i)]))
                continue
            nxt = insns.get(a + insns[a].length)
            rule = decide(insns[a], i, routine_starts, operand_addresses, nxt, tables)
            out.append({"at": f"{a:06X}", "operand": i, "decision": RULES[rule][0],
                        "rule": rule})
    return out


def dump(entries: list[dict[str, object]]) -> str:
    rules = {k: f"{d}: {why}" for k, (d, why) in RULES.items()}
    rules[REVIEWED] = REVIEWED_TEXT
    lines = ["{", f'  "format": "{FORMAT}",', f'  "rules": {json.dumps(rules, indent=4)},',
             '  "operands": [']
    lines[-2] = lines[-2].replace("\n}", "\n  }")
    body = [f"    {json.dumps(e)}," for e in entries]
    if body:
        body[-1] = body[-1].rstrip(",")
    return "\n".join(lines + body + ["  ]", "}"]) + "\n"


def check_reviewed(e: dict[str, object]) -> None:
    """A reviewed entry: address or constant, with a written reason."""
    if e.get("decision") not in ("address", "constant") or set(e) != {
            "at", "operand", "decision", "rule", "reason"} or len(str(e["reason"])) < 40:
        raise ValueError(f"operand {e.get('at')}/{e.get('operand')}: a reviewed decision needs "
                         f"decision address or constant and a reason of 40 characters or more")


def load_reviewed(path: Path) -> dict[tuple[int, int], dict[str, object]]:
    """The reviewed entries of an operands file (none when it does not exist)."""
    if not path.exists():
        return {}
    j = json.loads(path.read_text())
    out = {}
    for e in j["operands"]:
        if e.get("rule") == REVIEWED:
            check_reviewed(e)
            out[(int(e["at"], 16), int(e["operand"]))] = e
    return out


def load(path: Path) -> dict[tuple[int, int], str]:
    """(instruction address, operand index) -> decision."""
    j = json.loads(path.read_text())
    if j.get("format") != FORMAT:
        raise ValueError(f"{path}: not {FORMAT}")
    for e in j["operands"]:
        if e.get("rule") == REVIEWED:
            check_reviewed(e)
    return {(int(e["at"], 16), int(e["operand"])): e["decision"] for e in j["operands"]}
