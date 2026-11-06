"""The annotation snapshot of an IDA database: what the repository commits instead of the .i64.

An IDA database embeds every byte of the image it was made from, and the ROMs never enter this
public repository (CLAUDE.md section 2). The repository commits a snapshot per database instead:
segments, user names, function starts, comments and the data items at named addresses, never a
byte. `ida.headless.create` applies it to a freshly analysed database and `ida.headless.export`
regenerates it, so that create -> export reproduces the committed file exactly.

This module is pure Python: the IDA side implements the `Database` protocol
(`ida.headless.idadb`), and the tests use an in-memory one.
"""

from __future__ import annotations

import json
import re
from collections.abc import Iterable
from dataclasses import dataclass, field
from typing import Any, Protocol

# "anterior": the lines IDA shows above an address (its extra comments), one text joined by
# line breaks.
COMMENT_KINDS = ("regular", "repeatable", "function", "function_repeatable", "anterior")
DATA_TYPES = {"byte": 1, "word": 2, "dword": 4}

# What IDA's own analysis writes as if it were a user annotation (has_user_name is true for the
# switch names): left out of the snapshot, since auto-analysis makes them again. Full matches
# only, so a name or comment edited by hand is kept.
IDA_GENERATED_NAMES = [re.compile(r"(jpt|def)_[0-9A-F]+")]
IDA_GENERATED_COMMENTS = [
    re.compile(r"switch( jump| \d+ cases| with an invalid jump table)"),
    re.compile(r"jump table for switch statement"),
    re.compile(r"jumptable [0-9A-F]+ (default case|cases? [0-9,-]+)(, cases? [0-9,-]+)?"),
    # mc68k: the exception each vector-table target serves, one per line
    re.compile(r"(initial_sp|[a-z0-9_]+_entry)(\n(initial_sp|[a-z0-9_]+_entry))*"),
    # the binary loader: the anterior lines at the first address (the image's local path)
    re.compile(r"; File Name +: .*\n; Format +: .*(\n; Base Address: .*)?"),
]


def ida_generated_name(name: str) -> bool:
    return any(p.fullmatch(name) for p in IDA_GENERATED_NAMES)


def ida_generated_comment(text: str) -> bool:
    return any(p.fullmatch(text) for p in IDA_GENERATED_COMMENTS)


@dataclass(frozen=True, order=True)
class Segment:
    start: int
    end: int
    name: str
    sclass: str  # IDA segment class: CODE or DATA
    bitness: int  # 16 or 32
    file_offset: int | None = None  # where the bytes come from in the image; None = no bytes
    comment: str = ""


@dataclass(frozen=True, order=True)
class Name:
    ea: int
    name: str
    local: bool = False  # an IDA local name (SN_LOCAL), valid inside the function at ea


@dataclass(frozen=True, order=True)
class Comment:
    ea: int
    kind: str  # one of COMMENT_KINDS
    text: str


@dataclass(frozen=True, order=True)
class DataItem:
    ea: int
    type: str  # one of DATA_TYPES
    count: int = 1
    offset: bool = False  # the value is an address (an IDA offset)
    # An offset whose value is its target plus `delta` (IDA's refinfo tdelta): -1 for the 6502's
    # RTS-dispatch words, `.word handler-1`, whose target is the handler. 0 for a plain offset.
    delta: int = 0


@dataclass
class Snapshot:
    database: str
    processor: str
    segments: list[Segment] = field(default_factory=list)
    names: list[Name] = field(default_factory=list)
    functions: list[int] = field(default_factory=list)
    comments: list[Comment] = field(default_factory=list)
    data: list[DataItem] = field(default_factory=list)
    # Instruction ranges [start, end): only for a database whose classification the repository
    # owns (`classified` in `export`), where every instruction head is recorded.
    code: list[tuple[int, int]] = field(default_factory=list)

    def normalized(self) -> Snapshot:
        """Sorted, duplicate-free copy: the canonical order of the committed file."""
        return Snapshot(
            self.database,
            self.processor,
            sorted(set(self.segments)),
            sorted(set(self.names)),
            sorted(set(self.functions)),
            sorted(set(self.comments), key=lambda c: (c.ea, COMMENT_KINDS.index(c.kind))),
            sorted(set(self.data)),
            merge_ranges(self.code),
        )


def merge_ranges(ranges: Iterable[tuple[int, int]]) -> list[tuple[int, int]]:
    """Sorted ranges with the touching and overlapping ones joined."""
    out: list[tuple[int, int]] = []
    for start, end in sorted(ranges):
        if out and start <= out[-1][1]:
            out[-1] = (out[-1][0], max(out[-1][1], end))
        else:
            out.append((start, end))
    return out


class Database(Protocol):
    """What `apply` and `export` need from a database (IDA, or a fake in the tests)."""

    def segments(self) -> list[Segment]: ...
    def add_segment(self, segment: Segment) -> None: ...
    def names(self) -> list[Name]: ...  # global and local
    def set_name(self, ea: int, name: str, local: bool = False) -> None: ...
    def function_starts(self) -> list[int]: ...
    def add_function(self, ea: int) -> None: ...
    def comments(self, eas: Iterable[int]) -> list[Comment]: ...
    def set_comment(self, comment: Comment) -> None: ...
    def data_item(self, ea: int) -> DataItem | None: ...
    def create_data(self, item: DataItem) -> None: ...
    def data_items(self, start: int, end: int) -> list[DataItem]: ...
    def code_ranges(self, start: int, end: int) -> list[tuple[int, int]]: ...
    def create_code(self, start: int, end: int) -> None: ...


def apply(snapshot: Snapshot, db: Database) -> None:
    """Segments, then data items, then code, then functions, then names (so that a function
    keeps its name; local names after the global ones, inside their functions), then comments (a
    function comment needs the function).

    Functions are created from the highest address down: a function made first would otherwise
    absorb the code of a later start that its flow falls or branches into (on this ROM the 68010
    exception handlers share a tail, so the first one created swallowed the others)."""
    for segment in snapshot.segments:
        db.add_segment(segment)
    for item in snapshot.data:
        db.create_data(item)
    for start, end in snapshot.code:
        db.create_code(start, end)
    for ea in sorted(snapshot.functions, reverse=True):
        db.add_function(ea)
    for name in sorted(snapshot.names, key=lambda n: n.local):
        db.set_name(name.ea, name.name, name.local)
    for comment in snapshot.comments:
        db.set_comment(comment)


def export(
    db: Database, database: str, processor: str, classified: Iterable[tuple[int, int]] = ()
) -> Snapshot:
    """The snapshot of `db`. Comments are looked up at function starts and named addresses and
    at every head the database reports (the IDA side adds its heads in `comments`); data items
    at named addresses, and every data item and instruction range inside the `classified`
    ranges (the 6502 image, whose source owns the classification). Names and comments IDA's
    analysis generates are left out."""
    names = [n for n in db.names() if not ida_generated_name(n.name)]
    functions = db.function_starts()
    named = sorted({n.ea for n in names})
    data = [item for ea in named if (item := db.data_item(ea)) is not None]
    code: list[tuple[int, int]] = []
    for start, end in classified:
        data += db.data_items(start, end)
        code += db.code_ranges(start, end)
    comments = [
        c
        for c in db.comments(sorted(set(named) | set(functions)))
        if not ida_generated_comment(c.text)
    ]
    return Snapshot(
        database, processor, db.segments(), names, functions, comments, data, code
    ).normalized()


def _hex(ea: int) -> str:
    return f"0x{ea:06X}"


def _ea(text: str) -> int:
    return int(text, 16)


def _name(n: Name) -> dict[str, Any]:
    entry: dict[str, Any] = {"ea": _hex(n.ea), "name": n.name}
    if n.local:
        entry["local"] = True
    return entry


def to_dict(snapshot: Snapshot) -> dict[str, Any]:
    s = snapshot.normalized()
    segments = []
    for seg in s.segments:
        entry: dict[str, Any] = {
            "start": _hex(seg.start),
            "end": _hex(seg.end),
            "name": seg.name,
            "class": seg.sclass,
            "bitness": seg.bitness,
            "file_offset": None if seg.file_offset is None else _hex(seg.file_offset),
        }
        if seg.comment:
            entry["comment"] = seg.comment
        segments.append(entry)
    out: dict[str, Any] = {
        "database": s.database,
        "processor": s.processor,
        "segments": segments,
        "names": [_name(n) for n in s.names],
        "functions": [_hex(ea) for ea in s.functions],
        "comments": [{"ea": _hex(c.ea), "kind": c.kind, "text": c.text} for c in s.comments],
        "data": [_data(d) for d in s.data],
    }
    if s.code:  # absent from a snapshot without classified ranges (the 68k's)
        out["code"] = [[_hex(a), _hex(b)] for a, b in s.code]
    return out


def _data(d: DataItem) -> dict[str, Any]:
    out: dict[str, Any] = {"ea": _hex(d.ea), "type": d.type, "count": d.count, "offset": d.offset}
    if d.delta:  # only on an offset to a target other than its value (none in the 68k's)
        out["delta"] = d.delta
    return out


def from_dict(d: dict[str, Any]) -> Snapshot:
    def offset(v: str | None) -> int | None:
        return None if v is None else _ea(v)

    return Snapshot(
        d["database"],
        d["processor"],
        [
            Segment(
                _ea(s["start"]),
                _ea(s["end"]),
                s["name"],
                s["class"],
                s["bitness"],
                offset(s["file_offset"]),
                s.get("comment", ""),
            )
            for s in d["segments"]
        ],
        [Name(_ea(n["ea"]), n["name"], n.get("local", False)) for n in d["names"]],
        [_ea(ea) for ea in d["functions"]],
        [Comment(_ea(c["ea"]), c["kind"], c["text"]) for c in d["comments"]],
        [
            DataItem(_ea(x["ea"]), x["type"], x["count"], x["offset"], x.get("delta", 0))
            for x in d["data"]
        ],
        [(_ea(a), _ea(b)) for a, b in d.get("code", [])],
    ).normalized()


def dumps(snapshot: Snapshot) -> str:
    """Stable JSON: the top-level keys in a fixed order, one list entry per line (reviewable
    diffs), compact entries, UTF-8, trailing newline."""
    d = to_dict(snapshot)
    lines = ["{"]
    keys = list(d)
    for i, key in enumerate(keys):
        sep = "," if i < len(keys) - 1 else ""
        value = d[key]
        if isinstance(value, list):
            if not value:
                lines.append(f"  {json.dumps(key)}: []{sep}")
                continue
            lines.append(f"  {json.dumps(key)}: [")
            for j, entry in enumerate(value):
                comma = "," if j < len(value) - 1 else ""
                lines.append(f"    {json.dumps(entry, ensure_ascii=False)}{comma}")
            lines.append(f"  ]{sep}")
        else:
            lines.append(f"  {json.dumps(key)}: {json.dumps(value, ensure_ascii=False)}{sep}")
    lines.append("}")
    return "\n".join(lines) + "\n"


def loads(text: str) -> Snapshot:
    return from_dict(json.loads(text))
