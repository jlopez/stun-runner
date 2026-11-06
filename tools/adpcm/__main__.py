"""The OKI ADPCM image from PCM WAVs and back (docs/10-adpcm.md); the format is tools/adpcm/__init__.py.

tools/adpcm is a package directory, run as `uv run python tools/adpcm <cmd>` (the Makefile's
$(PYTHON) tools/adpcm).

    tools/adpcm asm     [--data data/oki] --out build/oki
    tools/adpcm info    [--data data/oki] [--image build/stunrun-oki.bin]
    tools/adpcm check   [--data data/oki] [WAV ...]
    tools/adpcm samples [--image build/stunrun-oki.bin] [--manifest data/oki/samples.json]
                        [--out data/oki]
    tools/adpcm decode  IN.bin OUT.wav
    tools/adpcm encode  IN.wav OUT.bin
    tools/adpcm encoder-check [--image build/stunrun-oki.bin]
    tools/adpcm survey  [--image build/stunrun-oki.bin] [--jsa build/stunrun-jsa.bin]
                        [--manifest data/oki/samples.json] [TRACE ...]

asm      the build step (`make`): encodes the WAV of every phrase the manifest names
         (data/oki/NN-name.wav) to ADPCM, lays the samples out in phrase order from their
         lengths and writes <out>/samples.asm, the vasm include asm/oki/samples.asm assembles:
         per sample a label, an assert and its bytes as dc.b, cut at each ROM file boundary
         with the file's label and assert, the zero tail as dcb.b. Fails on a missing WAV, a
         WAV no phrase names, a WAV that is not mono 16-bit PCM at the M6295 rate, or samples
         that no longer fit 256 KB. Prints the round-trip error of every WAV whose PCM the
         encoder cannot give back exactly (an edit).
info     the layout the WAVs give (numbers, names, addresses, lengths, durations, the chips
         each sample lies on); with --image (default when it exists) checks the image is that
         layout's table, samples and zero tail.
check    the round-trip error per WAV: exact, or how many samples decode to another value and
         by how much (16-bit units). Exit 0 either way: an edit is not an error.
samples  `make samples`: decodes every phrase of the image's own phrase table into
         <out>/NN-name.wav (names from the manifest), the decoder's PCM exactly, and removes
         any other *.wav in --out (a renamed phrase's old file).
decode   one sample's raw ADPCM bytes -> its PCM WAV;  encode  a PCM WAV -> raw ADPCM bytes by
         the build's encoder (with its round-trip error).
encoder-check per phrase of the image: whether the encoder gives the sample's bytes back from
         its PCM, and how many outputs sit at a clamp (-2048 or 2047), the only place two
         nibbles can reach one output (counts only).
survey   rewrites the manifest from the image's phrase table (names, descriptions and
         audio_test kept), the 6502 program's command tables (--jsa: which sound commands play
         each phrase) and the MAME traces of tools/mame/okitrace.lua
         (build/mame/okitrace-<run>.txt: how often each run saw it start). `make okitrace`
         runs it.

Output carries numbers, names, addresses and lengths only, never sample bytes. Exit status 1 on
a format error, 2 when an input file is absent.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from romset import load_snapshot  # noqa: E402

from adpcm import (  # noqa: E402
    ENTRY,
    FORMAT,
    IMAGE_SIZE,
    PIN7,
    SIGNAL_MAX,
    SIGNAL_MIN,
    FormatError,
    Layout,
    Manifest,
    Phrase,
    RoundTrip,
    check_image,
    decode,
    encode,
    is_label,
    layout,
    pcm,
    pcm_wav,
    rate,
    read_manifest,
    read_wav,
    round_trip,
    table_layout,
)

REPO = Path(__file__).resolve().parent.parent.parent
DATA = REPO / "data/oki"
MANIFEST = DATA / "samples.json"
IMAGE = REPO / "build/stunrun-oki.bin"
JSA = REPO / "build/stunrun-jsa.bin"

# The 6502 program's command tables (docs/10-adpcm.md section 4): the main loop dispatches a
# command Y < 6Dh through 4371 (CPY #$6D): handler type at 6100+Y, parameter at 616D+Y. Type 13h
# (5BFE) plays the effect given by the parameter, whose phrase is at 6532+effect (5C43).
JSA_COMMANDS = 0x6D
JSA_TYPES = 0x6100
JSA_PARAMS = 0x616D
JSA_OKI_PLAY = 0x13
JSA_EFFECT_PHRASE = 0x6532

BYTES_PER_LINE = 16


def chips(set_name: str = "stunrun") -> list[tuple[int, str]]:
    """(OKI address, file name) of each ROM file of the OKI image, in address order."""
    roms = load_snapshot(set_name)["roms"]
    return sorted((r["offset"], r["name"]) for r in roms if r["region"] == "mainpcb:jsa:oki1")


def chip_label(name: str) -> str:
    return "oki_" + name.rsplit(".", 1)[1]


def chips_of(p: Phrase, chip_list: list[tuple[int, str]]) -> list[str]:
    bounds = [a for a, _ in chip_list] + [IMAGE_SIZE]
    return [
        name
        for (a, name), b in zip(chip_list, bounds[1:], strict=True)
        if p.start < b and p.end >= a
    ]


def read_image(path: Path) -> bytes:
    if not path.exists():
        print(f"SKIP: {path} absent (make {path.relative_to(REPO)} needs the reference set)")
        sys.exit(2)
    return path.read_bytes()


# --- the WAVs ----------------------------------------------------------------------------------


def wav_files(data: Path, manifest: Manifest) -> dict[int, Path]:
    """Phrase number -> its WAV in data, after checking that every phrase has one and every
    WAV there belongs to a phrase."""
    wanted = {e.number: data / f"{e.stem}.wav" for e in manifest.phrases}
    names = {p.name for p in wanted.values()}
    for path in sorted(data.glob("*.wav")):
        if path.name not in names:
            raise FormatError(
                f"{path}: no phrase of the manifest has this name (a WAV is NN-name.wav, the "
                "phrase's number and its manifest name; rename the file with the manifest)"
            )
    for number, path in wanted.items():
        if not path.exists():
            raise FormatError(f"phrase {number}: {path} absent")
    return wanted


def encode_all(data: Path, manifest_path: Path) -> tuple[Layout, dict[int, bytes],
                                                          dict[int, RoundTrip]]:
    """Every phrase's WAV encoded: the layout their lengths give, the bytes and the round trip
    of each."""
    manifest = read_manifest(manifest_path)
    samples: dict[int, bytes] = {}
    trips: dict[int, RoundTrip] = {}
    for number, path in wav_files(data, manifest).items():
        try:
            values = read_wav(path.read_bytes())
        except FormatError as e:
            raise FormatError(f"{path}: {e}") from None
        samples[number] = encode(values)
        trips[number] = round_trip(values, samples[number])
    lay = layout(manifest, {n: len(b) for n, b in samples.items()})
    return lay, samples, trips


def describe(trip: RoundTrip) -> str:
    if trip.exact:
        return "exact"
    out = (
        f"{trip.differ} of {trip.samples} samples decode to another value (max error "
        f"{trip.max_error}, rms {trip.rms_error:.1f}, 16-bit units)"
    )
    return out + (", odd length: one sample appended" if trip.padded else "")


# --- asm ---------------------------------------------------------------------------------------


def dc_lines(data: bytes) -> list[str]:
    return [
        "\tdc.b\t" + ",".join(f"${b:02X}" for b in data[i : i + BYTES_PER_LINE])
        for i in range(0, len(data), BYTES_PER_LINE)
    ]


def chip_mark(address: int, name: str, where: str) -> list[str]:
    return [
        f"; {name} starts here, {where}",
        f"{chip_label(name)}:",
        f'\tassert\t*=${address:05X},"{name} misplaced"',
    ]


def asm_source(lay: Layout, samples: dict[int, bytes], source: str = "data/oki") -> str:
    """The generated include: per sample its labels, an assert and its bytes, cut at every ROM
    file boundary (labelled, with an assert), then the zero tail, cut the same way."""
    boundaries = {a: name for a, name in chips() if a}
    if any(not 0 < a < IMAGE_SIZE for a in boundaries):
        raise FormatError("a ROM file boundary outside the image")
    lines = [
        f"; Generated by tools/adpcm asm from {source}/samples.json and the WAVs in {source}:",
        "; do not edit (docs/10-adpcm.md). Each sample is the encoder's ADPCM for its WAV, laid",
        "; out in phrase order from the lengths; the zero tail as dcb.b.",
        "",
        f"oki_phrases\tequ\t{len(lay.phrases)}",
    ]
    for p in lay.phrases:
        data = samples[p.number]
        label = f"phrase_{p.number:02d}"
        lines += ["", f"; phrase {p.number}: {p.name}, {p.start:05X}-{p.end:05X}, {p.length} bytes"]
        # the manifest reader refuses a name that is one of the tree's own labels
        lines += [f"{label}:", f"{p.name}:", f'\tassert\t*=${p.start:05X},"phrase {p.number} misplaced"']
        offset = 0
        for a in sorted(a for a in boundaries if p.start <= a <= p.end):
            lines += dc_lines(data[offset : a - p.start])
            offset = a - p.start
            where = "at the start of" if a == p.start else "inside"
            lines += chip_mark(a, boundaries[a], f"{where} phrase {p.number}")
        lines += dc_lines(data[offset:])
        lines.append(f"{label}_last\tequ\t*-1")
    tail = lay.tail
    lines += [
        "",
        "; after the last sample the image is zero",
        "oki_tail:",
        f'\tassert\t*=${tail:05X},"the samples do not end at {tail:05X}"',
    ]
    at = tail
    for a in sorted(a for a in boundaries if a >= tail):
        if a > at:
            lines.append(f"\tdcb.b\t${a - at:X},0")
        lines += chip_mark(a, boundaries[a], "in the zero tail")
        at = a
    lines.append(f"\tdcb.b\t${IMAGE_SIZE - at:X},0")
    return "\n".join(lines) + "\n"


def cmd_asm(args: argparse.Namespace) -> int:
    lay, samples, trips = encode_all(args.data, args.data / "samples.json")
    data = args.data.resolve()
    text = asm_source(lay, samples, str(data.relative_to(REPO) if data.is_relative_to(REPO)
                                        else data))
    args.out.mkdir(parents=True, exist_ok=True)
    target = args.out / "samples.asm"
    if not target.exists() or target.read_text() != text:
        target.write_text(text)
    edited = [p for p in lay.phrases if not trips[p.number].exact]
    for p in edited:
        print(f"phrase {p.number} ({p.stem}.wav): edited, the build plays the encoder's nearest "
              f"ADPCM: {describe(trips[p.number])}")
    print(f"{len(samples)} samples from {args.data} -> {target}, the samples end at "
          f"{lay.tail - 1:05X}, {IMAGE_SIZE - lay.tail} bytes free")
    return 0


# --- info, check, samples, decode, encode ------------------------------------------------------


def cmd_info(args: argparse.Namespace) -> int:
    lay, _, trips = encode_all(args.data, args.data / "samples.json")
    image = args.image if args.image is not None else IMAGE
    if image.exists():
        check_image(image.read_bytes(), lay)
        print(f"{image}: the phrase table, samples and zero tail match the layout of {args.data}")
    elif args.image is not None:
        read_image(image)
    hz = rate()
    chip_list = chips()
    print(f"table 00000-{lay.table_end - 1:05X}: {lay.entries} entries of {ENTRY} bytes")
    print(f"{'phrase':>6}  {'name':<38}{'start':>6}{'end':>7}{'bytes':>7}{'seconds':>9}  chips")
    for p in lay.phrases:
        mark = "" if trips[p.number].exact else "  (edited)"
        print(
            f"{p.number:>6}  {p.name:<38}{p.start:>6X}{p.end:>7X}{p.length:>7}"
            f"{2 * p.length / hz:>9.3f}  {', '.join(chips_of(p, chip_list))}{mark}"
        )
    print(f"tail {lay.tail:05X}-{IMAGE_SIZE - 1:05X}: {IMAGE_SIZE - lay.tail} zero bytes")
    print(f"rate {hz:.2f} Hz (pin 7 {PIN7})")
    return 0


def cmd_check(args: argparse.Namespace) -> int:
    paths = args.wavs or [args.data / f"{e.stem}.wav"
                          for e in read_manifest(args.data / "samples.json").phrases]
    exact = 0
    for path in paths:
        values = read_wav(path.read_bytes())
        trip = round_trip(values, encode(values))
        exact += trip.exact
        print(f"{path.name}: {describe(trip)}")
    print(f"{exact} of {len(paths)} WAVs come back exactly through the encoder")
    return 0


def remove_stale(directory: Path, keep: set[str]) -> list[str]:
    """Remove the *.wav files in directory that are not in keep (a renamed phrase's old WAV)."""
    stale = sorted(f.name for f in directory.glob("*.wav") if f.name not in keep)
    for name in stale:
        (directory / name).unlink()
    return stale


def cmd_samples(args: argparse.Namespace) -> int:
    """One PCM WAV per phrase of the image's own table, named from the manifest."""
    image = read_image(args.image)
    manifest = read_manifest(args.manifest)
    names = {e.number: e.name for e in manifest.phrases}
    entries, spans = table_layout(image)
    if entries != manifest.entries:
        raise FormatError(f"the image's table has {entries} entries, the manifest "
                          f"{manifest.entries}")
    args.out.mkdir(parents=True, exist_ok=True)
    keep = set()
    written = 0
    for n, (s, e) in enumerate(spans, 1):
        wav = args.out / f"{n:02d}-{names[n]}.wav"
        keep.add(wav.name)
        blob = pcm_wav(pcm(image[s : e + 1]))
        if not wav.exists() or wav.read_bytes() != blob:
            wav.write_bytes(blob)
            written += 1
    stale = remove_stale(args.out, keep)
    print(f"{len(spans)} WAVs in {args.out}, {written} written"
          + (f", {len(stale)} stale removed" if stale else ""))
    return 0


def cmd_decode(args: argparse.Namespace) -> int:
    args.output.write_bytes(pcm_wav(pcm(args.input.read_bytes())))
    return 0


def cmd_encode(args: argparse.Namespace) -> int:
    values = read_wav(args.input.read_bytes())
    data = encode(values)
    args.output.write_bytes(data)
    print(f"{args.input.name}: {len(data)} bytes, {describe(round_trip(values, data))}")
    return 0


def cmd_encoder_check(args: argparse.Namespace) -> int:
    image = read_image(args.image)
    _, spans = table_layout(image)
    exact = clamped_total = 0
    print(f"{'phrase':>6}  {'nibbles':>8}  {'at a clamp':>10}  {'bytes back':>10}")
    for n, (s, e) in enumerate(spans, 1):
        data = image[s : e + 1]
        clamped = sum(v in (SIGNAL_MIN, SIGNAL_MAX) for v in decode(data))
        same = encode(pcm(data)) == data
        exact += same
        clamped_total += clamped
        print(f"{n:>6}  {2 * len(data):>8}  {clamped:>10}  {'yes' if same else 'no':>10}")
    print(f"{exact} of {len(spans)} samples come back byte for byte from their PCM; "
          f"{clamped_total} outputs at -2048 or 2047")
    return 0


# --- survey ------------------------------------------------------------------------------------

TRACE_START = re.compile(
    r"^start (\d+) [0-9A-F] [0-9A-F] \S+ ([0-9A-F]{2}|--) ([0-9A-F]{2}|--) (\d+) \d+$"
)


def jsa_commands(jsa: bytes) -> dict[int, list[int]]:
    """Phrase -> the sound commands whose handler plays it (the 6502's tables)."""
    out: dict[int, list[int]] = {}
    for y in range(JSA_COMMANDS):
        if jsa[JSA_TYPES + y] == JSA_OKI_PLAY:
            phrase = jsa[JSA_EFFECT_PHRASE + jsa[JSA_PARAMS + y]]
            out.setdefault(phrase, []).append(y)
    return out


def read_trace(path: Path) -> dict[int, dict[str, int]]:
    """Phrase -> {command: starts} from a tools/mame/okitrace.lua output."""
    out: dict[int, dict[str, int]] = {}
    for line in path.read_text().splitlines():
        m = TRACE_START.match(line)
        if m:
            per = out.setdefault(int(m.group(1)), {})
            per[m.group(2)] = per.get(m.group(2), 0) + int(m.group(4))
    return out


# the fields survey keeps from the old manifest, as they are (names are Jesus's, card A8)
KEPT = ("name", "description", "audio_test")


def manifest_text(manifest: dict[str, Any]) -> str:
    """One phrase per line: easier to read and diff than json.dumps' layout."""
    body = json.dumps({k: v for k, v in manifest.items() if k != "phrases"}, indent=2)
    rows = ",\n".join(f"    {json.dumps(p)}" for p in manifest["phrases"])
    return body[:-2] + f',\n  "phrases": [\n{rows}\n  ]\n}}\n'


def cmd_survey(args: argparse.Namespace) -> int:
    image = read_image(args.image)
    entries, spans = table_layout(image)
    old: dict[str, Any] = json.loads(args.manifest.read_text()) if args.manifest.exists() else {}
    kept = {p["number"]: {k: p[k] for k in KEPT if k in p} for p in old.get("phrases", [])}
    commands = jsa_commands(read_image(args.jsa))
    runs = {}
    for t in args.traces:
        run = t.stem.removeprefix("okitrace-")
        runs[run] = read_trace(t)
    phrases = []
    for n in range(1, len(spans) + 1):
        entry: dict[str, Any] = {"number": n, "name": f"sample_{n:02d}", **kept.get(n, {})}
        if not is_label(entry["name"]):
            raise FormatError(f"phrase {n}: name {entry['name']!r} is not a label")
        entry["commands"] = [f"{c:02X}" for c in commands.get(n, [])]
        entry["starts"] = {run: sum(found.get(n, {}).values()) for run, found in runs.items()}
        # "--": a start with no dispatch read before it, which no table explains either
        traced = sorted({c for found in runs.values() for c in found.get(n, {})})
        stray = [c for c in traced if c not in entry["commands"]]
        if stray:
            raise FormatError(f"phrase {n}: MAME saw it started by command(s) {stray}, "
                              "which the 6502's tables do not map to it")
        phrases.append(entry)
    manifest = {
        "format": FORMAT,
        "doc": "docs/10-adpcm.md; the format is tools/adpcm/__init__.py",
        "comment": (
            "The OKI M6295 image's phrases, each the PCM WAV data/oki/NN-name.wav. The build "
            "lays the samples out after the table (table_entries entries of 8 bytes from "
            "00000, entry 0 zero) back to back in phrase order from the WAV lengths, then zero "
            "to 3FFFF; no address is written here. name: a label from Jesus's listening "
            "(card A8; maybe_ where he marked a doubt); description: his words verbatim; "
            "audio_test: cross evidence, the 68010's audio-test names of the commands that "
            "play the phrase (data/sound/commands.json). commands: the sound commands whose "
            "6502 handler plays the phrase (tables at 6100, 616D, 6532). starts: how often each "
            "MAME run of tools/mame/okitrace.lua saw the 6502 start it. pin7: the rate the "
            "WAVs are at (CLOCK / 165)."
        ),
        "table_entries": entries,
        "pin7": PIN7,
        "phrases": phrases,
    }
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(manifest_text(manifest))
    read_manifest(args.manifest)  # what was written must read back
    print(f"{len(phrases)} phrases, {entries} table entries -> {args.manifest}")
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="tools/adpcm", description=(__doc__ or "").split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("asm")
    p.add_argument("--data", type=Path, default=DATA)
    p.add_argument("--out", type=Path, required=True)
    p.set_defaults(func=cmd_asm)
    p = sub.add_parser("info")
    p.add_argument("--data", type=Path, default=DATA)
    p.add_argument("--image", type=Path, default=None)
    p.set_defaults(func=cmd_info)
    p = sub.add_parser("check")
    p.add_argument("--data", type=Path, default=DATA)
    p.add_argument("wavs", nargs="*", type=Path)
    p.set_defaults(func=cmd_check)
    p = sub.add_parser("samples")
    p.add_argument("--image", type=Path, default=IMAGE)
    p.add_argument("--manifest", type=Path, default=MANIFEST)
    p.add_argument("--out", type=Path, default=DATA)
    p.set_defaults(func=cmd_samples)
    for name, func in (("decode", cmd_decode), ("encode", cmd_encode)):
        p = sub.add_parser(name)
        p.add_argument("input", type=Path)
        p.add_argument("output", type=Path)
        p.set_defaults(func=func)
    p = sub.add_parser("encoder-check")
    p.add_argument("--image", type=Path, default=IMAGE)
    p.set_defaults(func=cmd_encoder_check)
    p = sub.add_parser("survey")
    p.add_argument("--image", type=Path, default=IMAGE)
    p.add_argument("--manifest", type=Path, default=MANIFEST)
    p.add_argument("--jsa", type=Path, default=JSA)
    p.add_argument("traces", nargs="*", type=Path)
    p.set_defaults(func=cmd_survey)

    args = ap.parse_args(argv)
    try:
        return int(args.func(args))
    except FormatError as e:
        print(f"FAIL {args.cmd}: {e}", file=sys.stderr)
        return 1
    except FileNotFoundError as e:
        print(f"FAIL {args.cmd}: {e.filename} absent", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
