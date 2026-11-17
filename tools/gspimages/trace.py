"""MAME traces of the 68010's image unpackers (tools/mame/gspimages.lua) against the decoder.

A run is <name>.txt (calls, table reads, palette dump frames), <name>.words (every HSTDATA word
the unpackers wrote, in call order), <name>.vram (the same GSP words read back one frame later)
and <name>.pal (MAME's palette at the IMG_PAL frames). All four stay in build/: the words and the
palettes are image data. The summary this module writes has entries, frames, destinations and
counts only.

An unpacking starts with a call whose first stream read is a stream's first byte (its 00); a call
that starts inside a stream continues the open unpacking of that stream (the resumable twin
022766 runs a few commands per call). Checks: the words of every unpacking are the decoded
stream's words from its start (all of them when the stream's end was read), each call's
destination continues its unpacking's at 16 bits per word, and the read-back GSP words equal the
written ones (counted, not required: the screen may be redrawn within a frame).
"""

from __future__ import annotations

import re
from collections.abc import Mapping, Sequence
from dataclasses import dataclass, field
from pathlib import Path

from gspimages import Manifest, Palette, compose, read_palettes
from gspimages.stream import unpack, words

CALL = re.compile(
    r"call (\d+) frame (\d+) dest ([0-9A-F]+) words (\d+) first ([0-9A-F]+) last ([0-9A-F]+) "
    r"pc ([0-9A-F]+)"
)
ENTRY = re.compile(r"entry (\d+) frame (\d+) pc ([0-9A-F]+)")
PAL = re.compile(r"pal (\d+)")


@dataclass
class Call:
    frame: int
    dest: int
    count: int
    first: int
    last: int
    pc: int
    words: list[int] = field(default_factory=list)
    vram: list[int] = field(default_factory=list)


@dataclass
class Run:
    name: str
    header: dict[str, str]
    calls: list[Call]
    table_reads: list[tuple[int, int, int]]  # entry, frame, pc
    palettes: list[tuple[int, list[tuple[int, int, int]]]]


def _u16(blob: bytes) -> list[int]:
    return [(blob[k] << 8) | blob[k + 1] for k in range(0, len(blob) - 1, 2)]


def read_run(txt: Path) -> Run:
    header: dict[str, str] = {}
    calls: list[Call] = []
    reads: list[tuple[int, int, int]] = []
    pal_frames: list[int] = []
    for line in txt.read_text().splitlines():
        if line.startswith("# "):
            key, _, value = line[2:].partition(" ")
            header[key] = value
        elif m := CALL.match(line):
            calls.append(Call(int(m[2]), int(m[3], 16), int(m[4]), int(m[5], 16), int(m[6], 16),
                              int(m[7], 16)))
        elif m := ENTRY.match(line):
            reads.append((int(m[1]), int(m[2]), int(m[3], 16)))
        elif m := PAL.match(line):
            pal_frames.append(int(m[1]))
    if "done" not in header:
        raise ValueError(f"{txt}: the run did not finish (no '# done')")
    w = _u16(txt.with_suffix(".words").read_bytes())
    vr = _u16(txt.with_suffix(".vram").read_bytes())
    at = 0
    for c in calls:
        c.words = w[at : at + c.count]
        c.vram = vr[at : at + c.count]
        at += c.count
    if at != len(w):
        raise ValueError(f"{txt}: {len(w)} words in .words, the calls account for {at}")
    pals = []
    pfile = txt.with_suffix(".pal")
    if pal_frames:
        blob = pfile.read_bytes()
        for k, f in enumerate(pal_frames):
            chunk = blob[768 * k : 768 * (k + 1)]
            pals.append((f, [(chunk[i], chunk[i + 1], chunk[i + 2]) for i in range(0, 768, 3)]))
    return Run(txt.stem, header, calls, reads, pals)


@dataclass
class Unpacking:
    stream: int  # start address
    frame: int
    dest: int
    words: list[int] = field(default_factory=list)
    readback_equal: int = 0
    last_read: int = 0
    calls: int = 0


@dataclass
class EntryStats:
    entries: list[int]
    stream: int
    runs: dict[str, dict[str, int]] = field(default_factory=dict)
    destinations: set[int] = field(default_factory=set)
    unpackings: int = 0
    complete: int = 0
    words: int = 0
    readback_equal: int = 0

    def doc(self) -> dict[str, object]:
        return {
            "entries": self.entries, "stream": f"{self.stream:06X}", "runs": self.runs,
            "destinations": [f"{d:08X}" for d in sorted(self.destinations)],
            "unpackings": self.unpackings, "complete": self.complete, "words": self.words,
            "readback_equal": self.readback_equal,
        }


def summary(
    m: Manifest, image: bytes, traces: Sequence[Path], palettes: Path = Path("data/palettes")
) -> tuple[dict[str, object], list[str]]:
    problems: list[str] = []
    table = [int.from_bytes(image[0x0BFE00 + 4 * e : 0x0BFE04 + 4 * e], "big") for e in range(70)]
    streams: dict[int, tuple[int, list[int], list[int]]] = {}  # start -> end, entries, words
    for s in m.streams:
        start = table[s.entries[0]]
        up = unpack(image, start)
        streams[start] = (up.end, list(s.entries), words(up.data))
    starts = sorted(streams)

    def containing(a: int) -> int | None:
        for st in starts:
            if st <= a < streams[st][0]:
                return st
        return None

    pals = read_palettes(palettes)
    palettes_doc: dict[str, dict[str, int | str]] = {}
    entries: dict[int, EntryStats] = {}
    runs_doc = []
    for path in traces:
        run = read_run(path)
        open_: dict[int, Unpacking] = {}
        done: list[Unpacking] = []
        for c in run.calls:
            if not c.count and c.first == 0:
                continue
            st = containing(c.first)
            if st is None:
                problems.append(f"{run.name}: call at frame {c.frame} reads {c.first:06X}, in no stream")
                continue
            if c.first == st:
                if st in open_:
                    done.append(open_.pop(st))
                u = Unpacking(st, c.frame, c.dest)
                open_[st] = u
            elif st in open_:
                u = open_[st]
            else:
                problems.append(f"{run.name}: call at frame {c.frame} continues {st:06X}, not open")
                continue
            want_dest = u.dest + 16 * len(u.words)
            if c.count and c.dest != want_dest:
                problems.append(
                    f"{run.name}: frame {c.frame}: stream {st:06X} continues at {c.dest:08X}, "
                    f"{want_dest:08X} expected"
                )
            u.words += c.words
            u.readback_equal += sum(1 for a, b in zip(c.words, c.vram, strict=True) if a == b)
            u.last_read = max(u.last_read, c.last)
            u.calls += 1
            if u.last_read == streams[st][0] - 1:
                done.append(open_.pop(st))
        partial = list(open_.values())
        for u in done + partial:
            end, ents, want = streams[u.stream]
            complete = u in done and u.last_read == end - 1
            got = u.words
            if complete and got != want:
                problems.append(f"{run.name}: stream {u.stream:06X} (entry {ents[0]}) at frame "
                                f"{u.frame}: {len(got)} words, not the decoded {len(want)}")
            elif not complete and got != want[: len(got)]:
                problems.append(f"{run.name}: stream {u.stream:06X} (entry {ents[0]}) at frame "
                                f"{u.frame}: its words are not the decoded stream's start")
            e = entries.setdefault(ents[0], EntryStats(ents, u.stream))
            rr = e.runs.setdefault(run.name, {"first_frame": u.frame, "unpackings": 0})
            rr["unpackings"] += 1
            e.unpackings += 1
            e.complete += 1 if complete else 0
            e.words += len(got)
            e.readback_equal += u.readback_equal
            e.destinations.add(u.dest)
        reads: dict[int, dict[str, int]] = {}
        for ent, fr, _pc in run.table_reads:
            d = reads.setdefault(ent, {"count": 0, "first_frame": fr})
            d["count"] += 1
        runs_doc.append({
            "run": run.name,
            "frames": int(run.header.get("frames", "0")),
            "play": int(run.header.get("play", "0")),
            "level": int(run.header.get("level", "0")),
            "reset_at_frame": int(run.header["reset_at_frame"]) if "reset_at_frame" in run.header else None,
            "calls": len(run.calls),
            "words": sum(c.count for c in run.calls),
            "table_reads": " ".join(f"{k}:{v['count']}" for k, v in sorted(reads.items())),
        })
        for key, best in palette_matches(m, run, pals).items():
            have = palettes_doc.get(key)
            if have is None or int(best["best_equal"]) > int(have["best_equal"]):
                palettes_doc[key] = {**best, "run": run.name}
    doc: dict[str, object] = {
        "comment": "make imgtrace (tools/mame/gspimages.lua, tools/gspimages trace): per stream "
                   "(keyed by its first table entry) the MAME runs that unpacked it, the GSP "
                   "destinations, unpackings, complete ones, HSTDATA words checked against the "
                   "decoder and read back equal one frame later; per run the image-table reads "
                   "(entry:count); per palette spec of the manifest the most colours it defines "
                   "that equal MAME's palette at one dump (every 100 frames), with the run and "
                   "frame. Counts, frames and addresses only.",
        "entries": {str(k): entries[k].doc() for k in sorted(entries)},
        "not_seen": [s.entries[0] for s in m.stream_order() if s.entries[0] not in entries],
        "palettes": dict(sorted(palettes_doc.items())),
        "runs": runs_doc,
    }
    return doc, problems


def spec_key(spec: Mapping[str, object]) -> str:
    """A palette spec as a short text: base + overlay@at/count, ..."""
    parts = [str(spec.get("base") or "grey")]
    overlays = spec.get("overlays", [])
    assert isinstance(overlays, list)
    for ov in overlays:
        parts.append(f"{ov['name']}@{ov['at']}/{ov.get('count')}")
    return " + ".join(parts)


def palette_matches(
    m: Manifest, run: Run, pals: Mapping[str, Palette]
) -> dict[str, dict[str, int | str]]:
    """For every distinct palette spec of the manifest: over the run's palette dumps, the most
    colours the spec defines (all 256 for a base, the overlay ranges for an overlay; a grey spec
    defines none and is left out) that equal MAME's palette at one frame, and the first such frame.
    A base palette rarely matches all 256: the game cycles a few colours (tables 047C9A-047D0C)."""
    specs: dict[str, tuple[list[tuple[int, int, int]], list[int]]] = {}
    subs: list[Mapping[str, object]] = []
    for info in m.images.values():
        spec = info.get("palette", {})
        assert isinstance(spec, dict)
        subs += [spec, *spec.get("aliases", [])]
    for spec in subs:
        idx: list[int] = list(range(256)) if spec.get("base") else []
        overlays = spec.get("overlays", [])
        assert isinstance(overlays, list)
        for ov in overlays:
            at = int(ov["at"], 16)
            idx += list(range(at, at + int(ov.get("count", pals[ov["name"]].count))))
        if idx:
            specs[spec_key(spec)] = (compose(spec, pals), sorted(set(idx)))
    out: dict[str, dict[str, int | str]] = {}
    for key, (mine, idx) in sorted(specs.items()):
        best, at = 0, 0
        for f, mame in run.palettes:
            eq = sum(1 for i in idx if mine[i] == mame[i])
            if eq > best:
                best, at = eq, f
        out[key] = {"defined": len(idx), "best_equal": best, "frame": at}
    return out
