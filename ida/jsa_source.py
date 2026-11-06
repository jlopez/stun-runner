"""The 6502 source tree asm/jsa as IDA annotations: what `make ida-sync` writes (docs/05 section 6).

Pure Python (64tass is the only outside program): `load(tree)` assembles the tree twice and
returns a `Source`, the annotations the source carries at their IDA addresses.

- **Addresses.** The tree is assembled as `make` does, with a listing (-L) and a labels file
  (-l); a copy is assembled with a marker `sync__N = *` before every label and statement line of
  the image's files (a `name = *` opens no 64tass scope, and the copy must give the same bytes),
  and the labels file gives each line's address. The listing gives the statements the image is
  made of, macro expansions included (data/macros.asm), with their sizes.
- **IDA addresses.** File 4000-FFFF is the `ROM` segment at its own address; the four bank pages,
  file 0000-3FFF, are `BANK0`-`BANK3` at `(n+1)<<16 | 0x3000` (docs/05 section 4). The equates of
  ram.asm are names in `RAM`, those of hardware.asm whose value lies in 2000-2FFF names in `IO`.
- **Names.** A global label is the IDA name at its address, a `_local` an IDA local name (with
  its underscore) in the function that holds it. IDA has one name per address: a second label
  there is reported, not carried.
- **Functions.** Every global label of the code files whose first statement is an instruction
  starts a function (`ROUTINE_FILES`): each 64tass local scope is then one IDA function.
- **Code and data.** Every instruction is code; every data statement (.byte, .word, .text, .fill,
  and the ones a macro call expands to) is one data item of its size: bytes, or words where the
  statement is .word, offsets where every operand of a .word names a label of the image.
- **Comments.** A column-0 comment block directly above a global label (its `; ---` rules
  dropped) is the label's header: the function comment of a routine, the repeatable comment of
  any other label. The comments on a line, its continuation lines (comment-only lines at the
  column of the line's comment) and an indented block directly above it are the regular comment
  of the line's address, joined by line breaks in source order. The block above an equate and its
  line comment are the equate's repeatable comment. A block followed by a blank line, or above a
  directive that makes no bytes, belongs to no address (`Source.loose`). IDA keeps at most
  `MAX_COMMENT` characters of a comment: a longer header goes whole into the anterior lines
  above the address and its leading paragraphs into the function or repeatable comment.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import tempfile
from collections import defaultdict
from collections.abc import Callable
from dataclasses import dataclass, field
from pathlib import Path

from ida.snapshot import Comment, DataItem, Name

REPO_ROOT = Path(__file__).resolve().parents[1]
TREE = REPO_ROOT / "asm" / "jsa"
MAIN = "jsa.asm"
TASS_FLAGS = ("-q", "-C", "-b")

CONST_FILES = {"ram.asm": (0x0000, 0x2000), "hardware.asm": (0x2000, 0x3000)}  # IDA RAM, IO
SKIP_FILES = ("data/macros.asm",)  # macro definitions and their constants: no IDA counterpart
ROUTINE_FILES = (
    "system.asm",
    "commands.asm",
    "sequencer.asm",
    "nmi.asm",
    "ymtimer.asm",
    "oki.asm",
    "io.asm",
)
BANK_SIZE = 0x1000
BANKS = 4
MAX_COMMENT = 1023  # IDA 9.1 keeps 1024 characters of a comment, one less for safety
ANTERIOR_LINE = 1000  # one anterior line
MARKER = "sync__"

RULE = re.compile(r"^-{3,}$")
GLOBAL_LABEL = re.compile(r"^([A-Za-z][A-Za-z0-9_]*)\s*$")
LOCAL_LABEL = re.compile(r"^(_[A-Za-z0-9_]+)\s*$")
EQUATE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+?)\s*$")
INCLUDE = re.compile(r'^\s*\.include\s+"([^"]+)"')
NO_BYTES = re.compile(r"^\.(cerror|cwarn|include|if|else|elsif|endif|fi|comment|endc)\b")
ORG = re.compile(r"^\*\s*=")
SYMBOL = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(\$[0-9A-Fa-f]+|\d+)\s*$")
LISTED = re.compile(r"^([.>])([0-9a-f]{4})$")
HEX = re.compile(r"^[0-9a-f]{2}( [0-9a-f]{2})*$")
DATA_KIND = re.compile(r"^\.(byte|char|word|addr|text|fill)\b\s*(.*)$")
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


def ida_ea(offset: int) -> int:
    """The IDA address of a file offset of 136070-2123.10c (docs/05 section 4)."""
    if not 0 <= offset < 0x10000:
        raise ValueError(f"{offset:#x} is outside the 64 KB image")
    if offset >= BANKS * BANK_SIZE:
        return offset
    return ((offset // BANK_SIZE + 1) << 16) | 0x3000 | (offset % BANK_SIZE)


def source_value(ea: int) -> int:
    """The value 64tass gives the label at IDA address `ea`: the file offset for a bank page,
    the address itself elsewhere (ROM, RAM, IO)."""
    if ea >= 0x10000:
        n = (ea >> 16) - 1
        if not 0 <= n < BANKS or not 0x3000 <= (ea & 0xFFFF) < 0x4000:
            raise ValueError(f"{ea:#x} is in no bank page")
        return n * BANK_SIZE + (ea & 0xFFF)
    return ea


def in_image(ea: int) -> bool:
    """An IDA address that holds image bytes (ROM or a bank page)."""
    if 0x4000 <= ea < 0x10000:
        return True
    return any(((n + 1) << 16) | 0x3000 <= ea < ((n + 1) << 16) | 0x4000 for n in range(BANKS))


def image_ranges() -> list[tuple[int, int]]:
    """The IDA ranges the source owns the classification of: the banks and the ROM."""
    banks = [(((n + 1) << 16) | 0x3000, ((n + 1) << 16) | 0x4000) for n in range(BANKS)]
    return [(0x4000, 0x10000), *banks]


# --- source lines -------------------------------------------------------------------------------


def split_comment(text: str) -> tuple[str, str | None]:
    """(code, comment) of a source line; a `;` inside quotes is not a comment. The comment loses
    its `;` and one space after it, and its trailing spaces."""
    quote = ""
    for i, ch in enumerate(text):
        if quote:
            if ch == quote:
                quote = ""
        elif ch in "\"'" and text[:i].strip():  # an apostrophe only matters inside code
            quote = ch
        elif ch == ";":
            body = text[i + 1 :]
            return text[:i].rstrip(), (body[1:] if body.startswith(" ") else body).rstrip()
    return text.rstrip(), None


def clean_block(lines: list[str]) -> list[str]:
    """A comment block without its `; ---` rules and its leading and trailing empty lines."""
    out = [x.rstrip() for x in lines if not RULE.match(x.strip())]
    while out and not out[0]:
        out.pop(0)
    while out and not out[-1]:
        out.pop()
    return out


def include_order(tree: Path, main: str = MAIN) -> list[str]:
    """The tree's files, relative to the tree, in the order the assembler reads them."""
    out: list[str] = []

    def walk(rel: str) -> None:
        out.append(rel)
        base = Path(rel).parent
        for line in (tree / rel).read_text().splitlines():
            m = INCLUDE.match(split_comment(line)[0])
            if m:
                walk(str(base / m.group(1)) if str(base) != "." else m.group(1))

    walk(main)
    return out


def needs_marker(line: str) -> bool:
    """A line that has an address in the image: a label, or a statement that may emit bytes."""
    code, _ = split_comment(line)
    if not code.strip():
        return False
    if not line[0].isspace():
        return bool(GLOBAL_LABEL.match(code) or LOCAL_LABEL.match(code))
    body = code.strip()
    return not (NO_BYTES.match(body) or ORG.match(body) or EQUATE.match(body))


def instrument(text: str, first: int) -> tuple[str, dict[str, int]]:
    """`text` with a marker before every line that needs one; the markers' line numbers."""
    out: list[str] = []
    marks: dict[str, int] = {}
    for no, line in enumerate(text.splitlines(), 1):
        if needs_marker(line):
            name = f"{MARKER}{first + len(marks)}"
            marks[name] = no
            out.append(f"{name} = *")
        out.append(line)
    return "\n".join(out) + "\n", marks


def symbols(text: str) -> dict[str, int]:
    """64tass's -l output: `name = value`, the value in $hex or decimal."""
    out = {}
    for line in text.splitlines():
        m = SYMBOL.match(line.strip())
        if m:
            v = m.group(2)
            out[m.group(1)] = int(v[1:], 16) if v.startswith("$") else int(v)
    return out


# --- the listing --------------------------------------------------------------------------------


@dataclass(frozen=True)
class Statement:
    """A statement of the 64tass listing that makes bytes: file offset, kind, operand text."""

    offset: int
    kind: str  # "code", or the data directive: byte, char, word, addr, text, fill
    operands: str
    size: int = 0


def listing_statements(listing: str, image_size: int = 0x10000) -> list[Statement]:
    """The statements of a 64tass -L listing in address order, each with its size (up to the
    next statement's address). Label lines and continuation lines of bytes are not statements."""
    found: list[tuple[int, str, str]] = []
    for line in listing.splitlines():
        fields = line.split("\t")
        m = LISTED.match(fields[0])
        if not m:
            continue
        rest = [f for f in fields[1:] if f]
        if not rest or not HEX.match(rest[0]):
            continue  # a label line, or a line without bytes
        text = [f for f in rest[1:] if not HEX.match(f)]
        if not text:
            continue
        code = split_comment(text[-1])[0].strip()
        if m.group(1) == ".":
            found.append((int(m.group(2), 16), "code", code))
            continue
        d = DATA_KIND.match(code)
        if d is None:
            raise ValueError(f"unknown data statement in the listing: {line!r}")
        found.append((int(m.group(2), 16), d.group(1), d.group(2)))
    found.sort(key=lambda s: s[0])
    out = []
    for i, (offset, kind, operands) in enumerate(found):
        end = found[i + 1][0] if i + 1 < len(found) else image_size
        if end <= offset:
            raise ValueError(f"listing: statement at {offset:04X} has no bytes")
        out.append(Statement(offset, kind, operands, end - offset))
    return out


def operand_list(text: str) -> list[str]:
    """The comma-separated operands of a data statement (no strings in this tree's .word)."""
    return [x.strip() for x in text.split(",") if x.strip()]


def data_item(st: Statement, image_labels: set[str]) -> DataItem:
    ea = ida_ea(st.offset)
    if st.kind in ("word", "addr") and st.size % 2 == 0:
        ops = operand_list(st.operands)
        offset = bool(ops) and all(any(i in image_labels for i in IDENT.findall(op)) for op in ops)
        return DataItem(ea, "word", st.size // 2, offset)
    return DataItem(ea, "byte", st.size, False)


# --- equates -------------------------------------------------------------------------------------


@dataclass(frozen=True)
class Equate:
    ea: int
    name: str
    lines: tuple[str, ...]  # the comment: the block directly above, the line's, its continuation
    where: str

    @property
    def comment(self) -> str:
        return "\n".join(clean_block(list(self.lines)))


def equates(
    rel: str, text: str, lo: int, hi: int, value: Callable[[str, str], int | None]
) -> tuple[list[Equate], list[str]]:
    """The equates of a constants file (ram.asm, hardware.asm) whose value lies in [lo, hi),
    with their comments; and the comment blocks that belong to no address there. `value` gives
    an equate's value from its name and expression."""
    out: list[Equate] = []
    loose: list[str] = []
    pending: list[str] = []
    current: list[str] | None = None  # the comment lines of the last equate, while continued
    cont_col = 0
    meta: tuple[int, str, str] | None = None
    lines = text.splitlines()

    def flush() -> None:
        nonlocal current, meta
        if meta is not None and current is not None:
            out.append(Equate(meta[0], meta[1], tuple(current), meta[2]))
        current, meta = None, None

    for no, line in enumerate(lines, 1):
        stripped = line.strip()
        if not stripped:
            flush()
            if pending:
                loose.append(f"{rel}:{no - len(pending)} {pending[0][:70]}")
            pending = []
            continue
        if stripped.startswith(";"):
            col = line.index(";")
            body = split_comment(line)[1] or ""
            if current is not None and col == cont_col and col > 8:
                current.append(body)
                continue
            flush()
            pending.append(body)
            continue
        flush()
        code, comment = split_comment(line)
        m = EQUATE.match(code) if not line[0].isspace() else None
        v = value(m.group(1), m.group(2)) if m else None
        if m is None or v is None or not lo <= v < hi:
            what = f"constant {m.group(1)}" if m else "not an equate"
            if pending or comment:
                loose.append(f"{rel}:{no} ({what}) {(pending or [comment or ''])[0][:60]}")
            pending = []
            continue
        current = clean_block(pending)
        pending = []
        if comment is not None:
            current.append(comment)
            cont_col = line.index(";", len(code))
        else:
            cont_col = 40
        meta = (v, m.group(1), f"{rel}:{no}")
    flush()
    return out, loose


def evaluate(expr: str, known: dict[str, int]) -> int | None:
    """The value of a simple equate expression: $hex, decimal or a known name, joined by + and
    -; None for anything else."""
    total, sign = 0, 1
    for token in re.findall(r"\$[0-9A-Fa-f]+|\d+|[A-Za-z_]\w*|[+-]|\S", expr):
        if token in "+-":
            sign = 1 if token == "+" else -1
            continue
        if token.startswith("$"):
            v = int(token[1:], 16)
        elif token.isdigit():
            v = int(token)
        elif token in known:
            v = known[token]
        else:
            return None
        total += sign * v
    return total


def hardware_io(tree: Path = TREE) -> list[Equate]:
    """The I/O names of hardware.asm (values in the IO segment, 2000-2FFF) with their comments,
    from the file alone: the setup of the 6502 database (ida/memory_map.py) reads them here."""
    known: dict[str, int] = {}

    def value(name: str, expr: str) -> int | None:
        v = evaluate(expr, known)
        if v is not None:
            known[name] = v
        return v

    lo, hi = CONST_FILES["hardware.asm"]
    found, _ = equates("hardware.asm", (tree / "hardware.asm").read_text(), lo, hi, value)
    return found


# --- the model ----------------------------------------------------------------------------------


@dataclass
class Source:
    names: list[Name] = field(default_factory=list)  # globals and locals the database carries
    functions: list[int] = field(default_factory=list)
    comments: list[Comment] = field(default_factory=list)
    data: list[DataItem] = field(default_factory=list)
    code: list[tuple[int, int]] = field(default_factory=list)  # instruction (ea, size)
    left_out: list[str] = field(default_factory=list)  # labels IDA cannot carry, with the reason
    loose: list[str] = field(default_factory=list)  # comment blocks attached to no address
    where: dict[int, str] = field(default_factory=dict)  # ea -> file:line of its first label
    scope: dict[int, str] = field(default_factory=dict)  # local's ea -> its global label

    def global_names(self) -> dict[int, str]:
        return {n.ea: n.name for n in self.names if not n.local}

    def local_names(self) -> dict[int, str]:
        return {n.ea: n.name for n in self.names if n.local}


def anterior_lines(text: str) -> list[str]:
    out = []
    for para in text.split("\n"):
        while len(para) > ANTERIOR_LINE:
            cut = para.rfind(" ", 0, ANTERIOR_LINE)
            cut = cut if cut > 0 else ANTERIOR_LINE
            out.append(para[:cut])
            para = para[cut:].lstrip()
        out.append(para)
    return out


def summary(text: str) -> str:
    """The leading paragraphs of `text` that fit in one IDA comment (the rest is above)."""
    tail = "\n(continued in the comment lines above)"
    room = MAX_COMMENT - len(tail)
    out = ""
    for para in text.split("\n\n"):
        joined = f"{out}\n\n{para}" if out else para
        if len(joined) > room:
            break
        out = joined
    if not out:
        cut = text.rfind(". ", 0, room)
        out = text[: cut + 1] if cut > 0 else text[:room]
    return out + tail


def build(
    files: dict[str, str],
    order: list[str],
    addresses: dict[tuple[str, int], int],
    statements: list[Statement],
    syms: dict[str, int],
) -> Source:
    """The annotations of the tree. `files` maps each file (relative to the tree) to its text,
    `order` is the include order, `addresses` maps (file, line) to the file offset the line
    starts at, `statements` are the listing's and `syms` the labels file's."""
    src = Source()
    globals_at: dict[int, list[str]] = defaultdict(list)
    locals_at: dict[int, list[tuple[str, str]]] = defaultdict(list)
    header: dict[int, list[str]] = {}
    regular: dict[int, list[str]] = defaultdict(list)
    repeatable: dict[int, list[str]] = defaultdict(list)
    routine_candidates: set[int] = set()
    code_offsets = {s.offset for s in statements if s.kind == "code"}
    image_labels: set[str] = set()

    for rel in order:
        if rel in SKIP_FILES:
            continue
        if rel in CONST_FILES:
            lo, hi = CONST_FILES[rel]
            found, loose = equates(rel, files[rel], lo, hi, lambda name, _expr: syms.get(name))
            for eq in found:
                globals_at[eq.ea].append(eq.name)
                src.where.setdefault(eq.ea, eq.where)
                repeatable[eq.ea].extend(eq.lines)
            src.loose += loose
            continue
        pending: list[tuple[int, str]] = []
        cont: tuple[int, int, dict[int, list[str]]] | None = None  # (column, ea, comments)
        scope = ""
        for no, text in enumerate(files[rel].splitlines(), 1):
            stripped = text.strip()
            if not stripped:
                if pending:
                    src.loose.append(f"{rel}:{no - len(pending)} {pending[0][1][:70]}")
                pending, cont = [], None
                continue
            if stripped.startswith(";"):
                col = text.index(";")
                body = split_comment(text)[1] or ""
                if cont is not None and col == cont[0] and col > 8:
                    cont[2][cont[1]].append(body)
                    continue
                cont = None
                pending.append((col, body))
                continue
            code, comment = split_comment(text)
            above = [b for _, b in pending]
            column0 = bool(pending) and all(c == 0 for c, _ in pending)
            pending = []
            where = f"{rel}:{no}"

            if not text[0].isspace() and (GLOBAL_LABEL.match(code) or LOCAL_LABEL.match(code)):
                offset = addresses.get((rel, no))
                if offset is None:
                    raise ValueError(f"{where}: label without an address")
                ea = ida_ea(offset)
                name = code.strip()
                src.where.setdefault(ea, where)
                if name.startswith("_"):
                    locals_at[ea].append((scope, name))
                    src.scope.setdefault(ea, scope)
                    regular[ea].extend(clean_block(above))
                else:
                    scope = name
                    image_labels.add(name)
                    globals_at[ea].append(name)
                    if column0:
                        header.setdefault(ea, []).extend(clean_block(above))
                    else:
                        regular[ea].extend(clean_block(above))
                    if rel in ROUTINE_FILES and offset in code_offsets:
                        routine_candidates.add(ea)
                if comment is not None:
                    regular[ea].append(comment)
                    cont = (text.index(";", len(code)), ea, regular)
                else:
                    cont = None
                continue

            body = code.strip()
            if not text[0].isspace() or NO_BYTES.match(body) or ORG.match(body):
                if above or comment:
                    src.loose.append(f"{where} (directive) {(above or [comment or ''])[0][:60]}")
                cont = None
                continue
            offset = addresses.get((rel, no))
            if offset is None:
                raise ValueError(f"{where}: statement without an address")
            ea = ida_ea(offset)
            regular[ea].extend(clean_block(above))
            if comment is not None:
                regular[ea].append(comment)
                cont = (text.index(";", len(code)), ea, regular)
            else:
                cont = (40, ea, regular)

    # names: one global per address; a local beside a global is left out
    for ea, names in sorted(globals_at.items()):
        src.names.append(Name(ea, names[0]))
        for extra in names[1:]:
            src.left_out.append(f"{ea:06X} {extra}: a second name at the address of {names[0]}")
    for ea, locs in sorted(locals_at.items()):
        if ea in globals_at:
            for _, name in locs:
                src.left_out.append(
                    f"{ea:06X} {name}: a local at the address of {globals_at[ea][0]}"
                )
            continue
        if ida_ea_offset_is_code(ea, code_offsets):
            src.names.append(Name(ea, locs[0][1], local=True))
        else:
            src.left_out.append(f"{ea:06X} {locs[0][1]}: a local over data (no function)")
        for _, name in locs[1:]:
            src.left_out.append(f"{ea:06X} {name}: a second local at the address of {locs[0][1]}")

    src.functions = sorted(routine_candidates)
    functions = set(src.functions)

    # comments
    for ea, block in sorted(header.items()):
        text = "\n".join(clean_block(block))
        if not text:
            continue
        if len(text) > MAX_COMMENT:
            src.comments.append(Comment(ea, "anterior", "\n".join(anterior_lines(text))))
            text = summary(text)
        src.comments.append(Comment(ea, "function" if ea in functions else "repeatable", text))
    for table, kind in ((regular, "regular"), (repeatable, "repeatable")):
        for ea, lines in sorted(table.items()):
            text = "\n".join(clean_block(lines))
            if not text:
                continue
            if kind == "repeatable" and any(
                c.ea == ea and c.kind == "repeatable" for c in src.comments
            ):
                raise ValueError(f"{ea:06X}: a header and an equate comment at one address")
            if len(text) > MAX_COMMENT:
                raise ValueError(f"{src.where.get(ea, hex(ea))}: a line comment over {MAX_COMMENT}")
            src.comments.append(Comment(ea, kind, text))

    # code and data
    for st in statements:
        if st.kind == "code":
            if st.offset < BANKS * BANK_SIZE:
                raise ValueError(f"{st.offset:04X}: an instruction in a bank page")
            src.code.append((ida_ea(st.offset), st.size))
        else:
            src.data += [data_item(part, image_labels) for part in split_at_pages(st)]
    return src


def split_at_pages(st: Statement) -> list[Statement]:
    """A statement over file 0000-3FFF cut where a bank page ends (each page is its own IDA
    segment)."""
    out = []
    offset, end = st.offset, st.offset + st.size
    while offset < end:
        stop = (
            end if offset >= BANKS * BANK_SIZE else min(end, (offset // BANK_SIZE + 1) * BANK_SIZE)
        )
        out.append(Statement(offset, st.kind, st.operands, stop - offset))
        offset = stop
    return out


def ida_ea_offset_is_code(ea: int, code_offsets: set[int]) -> bool:
    return ea in code_offsets  # the ROM's IDA address is its file offset; banks hold no code


# --- assembling ---------------------------------------------------------------------------------


def tass_program() -> str:
    found = shutil.which(os.path.expanduser(os.environ.get("TASS", "64tass")))
    if found is None:
        raise FileNotFoundError("64tass not found (TASS=...)")
    return found


def assembled_symbols(tree: Path, work: Path) -> dict[str, int]:
    """The global symbols 64tass resolves for `tree` (its -l output)."""
    _assemble(tree, work / "jsa.bin", "-l", str(work / "jsa.labels"))
    return symbols((work / "jsa.labels").read_text())


def _assemble(tree: Path, out: Path, *extra: str) -> bytes:
    args = [tass_program(), *TASS_FLAGS, *extra, "-o", str(out), MAIN]
    r = subprocess.run(args, cwd=tree, capture_output=True, text=True, check=False)
    if r.returncode != 0:
        raise RuntimeError(f"64tass failed in {tree}:\n{r.stdout}{r.stderr}")
    return out.read_bytes()


def load(tree: Path = TREE, work: Path | None = None) -> Source:
    """Assemble `tree` (plain and with markers) and build its annotations."""
    tmp = Path(tempfile.mkdtemp(prefix="jsa-sync-")) if work is None else work
    try:
        tmp.mkdir(parents=True, exist_ok=True)
        image = _assemble(
            tree, tmp / "jsa.bin", "-L", str(tmp / "jsa.lst"), "-l", str(tmp / "jsa.labels")
        )
        order = include_order(tree)
        files = {rel: (tree / rel).read_text() for rel in order}
        copy = tmp / "marked"
        if copy.exists():
            shutil.rmtree(copy)
        shutil.copytree(tree, copy)
        where: dict[str, tuple[str, int]] = {}
        for rel in order:
            if rel in SKIP_FILES or rel in CONST_FILES:
                continue
            text, marks = instrument(files[rel], len(where))
            (copy / rel).write_text(text)
            where.update({name: (rel, no) for name, no in marks.items()})
        marked = _assemble(copy, tmp / "marked.bin", "-l", str(tmp / "marked.labels"))
        if marked != image:
            raise RuntimeError("the source with markers does not assemble to the same image")
        values = symbols((tmp / "marked.labels").read_text())
        addresses = {where[name]: values[name] for name in where}
        statements = listing_statements((tmp / "jsa.lst").read_text(errors="replace"), len(image))
        syms = symbols((tmp / "jsa.labels").read_text())
        return build(files, order, addresses, statements, syms)
    finally:
        if work is None:
            shutil.rmtree(tmp, ignore_errors=True)
