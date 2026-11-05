"""The OKI ADPCM image as samples and WAVs (docs/10-adpcm.md); the format is tools/adpcm/__init__.py.

tools/adpcm is a package directory, run as `uv run python tools/adpcm <cmd>` (the Makefile's
$(PYTHON) tools/adpcm).

    tools/adpcm info   [--image build/stunrun-oki.bin] [--manifest data/oki/samples.json]
    tools/adpcm split  [--image build/stunrun-oki.bin] [--manifest data/oki/samples.json]
                       --out build/oki/wav [--missing]
    tools/adpcm asm    [--manifest data/oki/samples.json] [--wav build/oki/wav] --out build/oki
    tools/adpcm pcm    [--manifest data/oki/samples.json] [--wav build/oki/wav] --out build/oki/pcm
    tools/adpcm wav    IN.bin OUT.wav [--name NAME]
    tools/adpcm unwav  IN.wav OUT.bin
    tools/adpcm decode IN.wav OUT.wav
    tools/adpcm encode IN.wav OUT.wav
    tools/adpcm encoder-check [--image build/stunrun-oki.bin] [--manifest data/oki/samples.json]
    tools/adpcm survey [--image build/stunrun-oki.bin] [--jsa build/stunrun-jsa.bin]
                       [--manifest data/oki/samples.json] [TRACE ...]

info     checks the image against the manifest and prints the phrase table (numbers, names,
         addresses, lengths, durations, the chips each sample lies on).
split    writes one WAV per phrase of the image's own phrase table, NN-name.wav (names from the
         manifest), the sample's ADPCM bytes verbatim in a Dialogic OKI ADPCM WAV (format tag
         0x0017), and removes any other *.wav in --out (a renamed phrase's old file). The
         addresses are the image's, so a manifest edited for a relayout does not stop it.
         --missing writes only the WAVs absent from --out and keeps the others (`make` runs it
         every time on build/oki/wav, so a deleted or renamed phrase's WAV comes back).
asm      reads NN-name.wav for every phrase of the manifest from --wav, recovers its bytes into
         <out>/bin/NN.bin and writes <out>/samples.asm, the vasm include asm/oki/samples.asm
         assembles (`make`): one labelled incbin per sample, cut at each chip boundary, asserts
         at every sample and chip boundary, the zero tail as dcb.b. Fails when a WAV is missing,
         not the format, or not the length the manifest gives.
pcm      decodes NN-name.wav for every phrase of the manifest from --wav to 16-bit PCM in
         --out (as decode) and removes any other *.wav there (`make oki-pcm`).
wav      one sample's bytes -> its verbatim ADPCM WAV;  unwav  the inverse (the data chunk).
decode   an ADPCM WAV (or a raw .bin) -> 16-bit PCM WAV, through MAME's M6295 decoder
         (okiadpcm.cpp), for listening and editing.
encode   a 16-bit PCM WAV -> an ADPCM WAV by the greedy encoder (experiments only: the build
         never encodes PCM).
encoder-check reports, per phrase, whether encode(decode(sample)) gives the sample's bytes back
         (counts only).
survey   rewrites the manifest from the image's phrase table (names kept), the 6502 program's
         command tables (--jsa: which sound commands play each phrase) and the MAME traces of
         tools/mame/okitrace.lua (build/mame/okitrace-<run>.txt: how often each run saw it
         start). `make okitrace` runs it.

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
    MAX_PHRASES,
    PIN7,
    FormatError,
    Layout,
    Phrase,
    adpcm_wav,
    check_image,
    decode,
    decode_table,
    encode,
    is_label,
    nibbles,
    pcm_wav,
    rate,
    read_manifest,
    read_pcm_wav,
    split,
    unwav,
)

REPO = Path(__file__).resolve().parent.parent.parent
MANIFEST = REPO / "data/oki/samples.json"
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


def cmd_info(args: argparse.Namespace) -> int:
    layout = read_manifest(args.manifest)
    if args.image.exists():
        check_image(args.image.read_bytes(), layout)
        print(f"{args.image}: the phrase table, samples and zero tail match {args.manifest}")
    hz = rate()
    chip_list = chips()
    print(f"table 00000-{layout.table_end - 1:05X}: {layout.entries} entries of {ENTRY} bytes")
    print(f"{'phrase':>6}  {'name':<24}{'start':>6}{'end':>7}{'bytes':>7}{'seconds':>9}  chips")
    for p in layout.phrases:
        print(
            f"{p.number:>6}  {p.name:<24}{p.start:>6X}{p.end:>7X}{p.length:>7}"
            f"{2 * p.length / hz:>9.3f}  {', '.join(chips_of(p, chip_list))}"
        )
    print(f"tail {layout.tail:05X}-{IMAGE_SIZE - 1:05X}: {IMAGE_SIZE - layout.tail} zero bytes")
    print(f"rate {hz:.2f} Hz (pin 7 {PIN7})")
    return 0


def remove_stale(directory: Path, keep: set[str]) -> list[str]:
    """Remove the *.wav files in directory that are not in keep (a renamed phrase's old WAV)."""
    stale = sorted(f.name for f in directory.glob("*.wav") if f.name not in keep)
    for name in stale:
        (directory / name).unlink()
    return stale


def cmd_split(args: argparse.Namespace) -> int:
    """One WAV per phrase of the image's own table, named from the manifest. The addresses come
    from the image, not the manifest, so a manifest edited for a relayout (other lengths, built
    from WAVs in another OKI_WAV_DIR) does not stop the split of the unchanged reference image;
    `make check` and `tools/adpcm info` compare the image with the manifest."""
    image = read_image(args.image)
    if len(image) != IMAGE_SIZE:
        raise FormatError(f"image is {len(image)} bytes, not {IMAGE_SIZE}")
    names = {p.number: p.name for p in read_manifest(args.manifest).phrases}
    _, spans = table_layout(image)
    args.out.mkdir(parents=True, exist_ok=True)
    keep = set()
    written = 0
    for n, (s, e) in enumerate(spans, 1):
        name = names.get(n, f"sample_{n:02d}")
        wav = args.out / f"{n:02d}-{name}.wav"
        keep.add(wav.name)
        if args.missing and wav.exists():
            continue
        wav.write_bytes(adpcm_wav(image[s : e + 1], name))
        written += 1
    stale = remove_stale(args.out, keep)
    if args.missing and not written and not stale:
        return 0
    print(f"{written} WAVs -> {args.out}" + (f" ({len(stale)} stale removed)" if stale else ""))
    return 0


def cmd_pcm(args: argparse.Namespace) -> int:
    """Every phrase the manifest names, decoded to 16-bit PCM from its WAV in --wav (oki-pcm)."""
    layout = read_manifest(args.manifest)
    args.out.mkdir(parents=True, exist_ok=True)
    for p in layout.phrases:
        wav = args.wav / f"{p.stem}.wav"
        if not wav.exists():
            raise FormatError(f"phrase {p.number}: {wav} absent")
        (args.out / f"{p.stem}.wav").write_bytes(pcm_wav(decode(unwav(wav.read_bytes()))))
    stale = remove_stale(args.out, {f"{p.stem}.wav" for p in layout.phrases})
    print(f"{len(layout.phrases)} PCM WAVs -> {args.out}"
          + (f" ({len(stale)} stale removed)" if stale else ""))
    return 0


def asm_source(layout: Layout, wav_dir: Path, bin_dir: str) -> tuple[str, dict[int, bytes]]:
    """The generated include and the recovered bytes per phrase."""
    chip_list = chips()
    boundaries = {a: name for a, name in chip_list if a}
    samples: dict[int, bytes] = {}
    emitted: set[int] = set()
    lines = [
        f"; Generated by tools/adpcm asm from {MANIFEST.relative_to(REPO)} and the WAVs in",
        f"; {wav_dir}: do not edit (docs/10-adpcm.md). One incbin per sample of the bytes",
        "; recovered from its WAV (cut where a ROM file ends), the zero tail as dcb.b.",
        "",
        f"oki_phrases\tequ\t{len(layout.phrases)}",
    ]
    for p in layout.phrases:
        wav = wav_dir / f"{p.stem}.wav"
        if not wav.exists():
            raise FormatError(
                f"phrase {p.number}: {wav} absent (make rewrites a WAV missing from "
                "build/oki/wav; for another OKI_WAV_DIR copy it from there)"
            )
        try:
            data = unwav(wav.read_bytes())
        except FormatError as e:
            raise FormatError(f"{wav}: {e}") from None
        if len(data) != p.length:
            raise FormatError(
                f"{wav}: {len(data)} bytes, data/oki/samples.json says {p.length} for phrase "
                f"{p.number} ({p.start:05X}-{p.end:05X}); a sample of another length needs the "
                "manifest's addresses changed and the WAVs in a directory of your own "
                "(make OKI_WAV_DIR=dir)"
            )
        samples[p.number] = data
        label = f"phrase_{p.number:02d}"
        path = f'"{bin_dir}/{p.number:02d}.bin"'
        lines += ["", f"; phrase {p.number}: {p.name}, {p.start:05X}-{p.end:05X}, {p.length} bytes"]
        # the manifest reader refuses a name that is one of the tree's own labels
        lines += [f"{label}:", f"{p.name}:"]
        lines.append(f'\tassert\t*=${p.start:05X},"phrase {p.number} misplaced"')
        # a file starting at the sample's first byte gets its label and assert before the
        # incbin, one starting inside it splits the incbin there
        cuts = sorted(a for a in boundaries if p.start <= a <= p.end)
        offset = 0
        for a in cuts:
            if a > p.start:
                lines.append(f"\tincbin\t{path},{offset},${a - p.start - offset:X}")
            offset = a - p.start
            name = boundaries[a]
            where = "at the start of" if a == p.start else "inside"
            lines += [
                f"; {name} starts here, {where} phrase {p.number}",
                f"{chip_label(name)}:",
                f'\tassert\t*=${a:05X},"{name} misplaced"',
            ]
            emitted.add(a)
        lines.append(f"\tincbin\t{path},${offset:X}" if offset else f"\tincbin\t{path}")
        lines.append(f"{label}_last\tequ\t*-1")
    tail = layout.tail
    lines += [
        "",
        "; after the last sample the image is zero",
        "oki_tail:",
        f'\tassert\t*=${tail:05X},"the samples do not end at {tail:05X}"',
    ]
    for a in sorted(boundaries):
        if a >= tail:
            raise FormatError(f"{boundaries[a]} would start inside the zero tail: not supported")
        if a not in emitted:
            raise FormatError(f"{boundaries[a]} ({a:05X}) starts in no sample: not supported")
    lines.append(f"\tdcb.b\t${IMAGE_SIZE - tail:X},0")
    return "\n".join(lines) + "\n", samples


def cmd_asm(args: argparse.Namespace) -> int:
    layout = read_manifest(args.manifest)
    text, samples = asm_source(layout, args.wav, args.bin_path)
    bin_dir = args.out / "bin"
    bin_dir.mkdir(parents=True, exist_ok=True)
    for number, data in samples.items():
        (bin_dir / f"{number:02d}.bin").write_bytes(data)
    (args.out / "samples.asm").write_text(text)
    print(f"{len(samples)} samples from {args.wav} -> {args.out}/samples.asm")
    return 0


def cmd_wav(args: argparse.Namespace) -> int:
    args.output.write_bytes(adpcm_wav(args.input.read_bytes(), args.name))
    return 0


def cmd_unwav(args: argparse.Namespace) -> int:
    args.output.write_bytes(unwav(args.input.read_bytes()))
    return 0


def cmd_decode(args: argparse.Namespace) -> int:
    blob = args.input.read_bytes()
    data = unwav(blob) if blob[:4] == b"RIFF" else blob
    args.output.write_bytes(pcm_wav(decode(data)))
    return 0


def cmd_encode(args: argparse.Namespace) -> int:
    args.output.write_bytes(adpcm_wav(encode(read_pcm_wav(args.input.read_bytes()))))
    return 0


def cmd_encoder_check(args: argparse.Namespace) -> int:
    layout = read_manifest(args.manifest)
    samples = split(read_image(args.image), layout)
    exact = 0
    print(f"{'phrase':>6}  {'nibbles':>8}  {'differ':>7}  {'pcm equal':>9}")
    for p in layout.phrases:
        data = samples[p.number]
        pcm = decode(data)
        again = encode(pcm)
        differ = sum(a != b for a, b in zip(nibbles(again), nibbles(data), strict=True))
        same_pcm = decode(again) == pcm
        exact += differ == 0
        print(f"{p.number:>6}  {2 * p.length:>8}  {differ:>7}  {'yes' if same_pcm else 'no':>9}")
    print(f"{exact} of {len(layout.phrases)} samples come back byte for byte from their PCM")
    return 0


# --- survey ------------------------------------------------------------------------------------

TRACE_START = re.compile(
    r"^start (\d+) [0-9A-F] [0-9A-F] \S+ ([0-9A-F]{2}|--) ([0-9A-F]{2}|--) (\d+) \d+$"
)


def table_layout(image: bytes) -> tuple[int, list[tuple[int, int]]]:
    """The number of table entries the image's own table implies: phrase 1 starts right after
    the table, and every phrase starts where the previous one ends."""
    start1 = int.from_bytes(image[ENTRY : ENTRY + 3], "big")
    if start1 % ENTRY or not 2 * ENTRY <= start1 <= MAX_PHRASES * ENTRY:
        raise FormatError(f"phrase 1 starts at {start1:05X}: no table length explains it")
    entries = start1 // ENTRY
    if any(image[:ENTRY]):
        raise FormatError("phrase table entry 0 is not zero")
    spans = decode_table(image, entries)
    expect = start1
    for n, (s, e) in enumerate(spans, 1):
        if s != expect or e < s:
            raise FormatError(f"phrase {n} ({s:05X}-{e:05X}) does not follow at {expect:05X}")
        expect = e + 1
    return entries, spans


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


def cmd_survey(args: argparse.Namespace) -> int:
    image = read_image(args.image)
    entries, spans = table_layout(image)
    old: dict[str, Any] = json.loads(args.manifest.read_text()) if args.manifest.exists() else {}
    names = {p["number"]: p["name"] for p in old.get("phrases", [])}
    commands = jsa_commands(read_image(args.jsa))
    runs = {}
    for t in args.traces:
        run = t.stem.removeprefix("okitrace-")
        runs[run] = read_trace(t)
    hz = rate()
    phrases = []
    for n, (s, e) in enumerate(spans, 1):
        name = names.get(n, f"sample_{n:02d}")
        if not is_label(name):
            raise FormatError(f"phrase {n}: name {name!r} is not a label")
        entry: dict[str, Any] = {
            "number": n,
            "name": name,
            "start": f"{s:05X}",
            "end": f"{e:05X}",
            "length": e - s + 1,
            "seconds": round(2 * (e - s + 1) / hz, 3),
            "commands": [f"{c:02X}" for c in commands.get(n, [])],
            "starts": {run: sum(found.get(n, {}).values()) for run, found in runs.items()},
        }
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
            "The OKI M6295 image: table_entries entries of 8 bytes from 00000 (entry 0 zero), "
            "then the samples back to back in phrase order, then zero to 3FFFF. start/end are "
            "the table's (end inclusive), seconds at pin 7 low (CLOCK / 165). commands: the "
            "sound commands whose 6502 handler plays the phrase (tables at 6100, 616D, 6532). "
            "starts: how often each MAME run of tools/mame/okitrace.lua saw the 6502 start it. "
            "Names describe what is known; sample_NN means not identified yet."
        ),
        "table_entries": entries,
        "pin7": PIN7,
        "phrases": phrases,
    }
    # one phrase per line: easier to read and diff than json.dumps' layout
    body = json.dumps({k: v for k, v in manifest.items() if k != "phrases"}, indent=2)
    rows = ",\n".join(f"    {json.dumps(p)}" for p in phrases)
    text = body[:-2] + f',\n  "phrases": [\n{rows}\n  ]\n}}\n'
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(text)
    read_manifest(args.manifest)  # what was written must read back
    print(f"{len(phrases)} phrases, {entries} table entries -> {args.manifest}")
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="tools/adpcm", description=(__doc__ or "").split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)

    def with_image(p: argparse.ArgumentParser) -> None:
        p.add_argument("--image", type=Path, default=IMAGE)
        p.add_argument("--manifest", type=Path, default=MANIFEST)

    p = sub.add_parser("info")
    with_image(p)
    p.set_defaults(func=cmd_info)
    p = sub.add_parser("split")
    with_image(p)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument(
        "--missing",
        action="store_true",
        help="write only the WAVs absent from --out (keep the others, edited or not)",
    )
    p.set_defaults(func=cmd_split)
    p = sub.add_parser("asm")
    p.add_argument("--manifest", type=Path, default=MANIFEST)
    p.add_argument("--wav", type=Path, default=REPO / "build/oki/wav")
    p.add_argument("--out", type=Path, required=True)
    p.add_argument(
        "--bin-path",
        default="../../build/oki/bin",
        help="the bin directory as the incbin statements name it (relative to asm/oki)",
    )
    p.set_defaults(func=cmd_asm)
    p = sub.add_parser("pcm")
    p.add_argument("--manifest", type=Path, default=MANIFEST)
    p.add_argument("--wav", type=Path, default=REPO / "build/oki/wav")
    p.add_argument("--out", type=Path, required=True)
    p.set_defaults(func=cmd_pcm)
    for name, func in (("wav", cmd_wav), ("unwav", cmd_unwav), ("decode", cmd_decode),
                       ("encode", cmd_encode)):
        p = sub.add_parser(name)
        p.add_argument("input", type=Path)
        p.add_argument("output", type=Path)
        if name == "wav":
            p.add_argument("--name", default="")
        p.set_defaults(func=func)
    p = sub.add_parser("encoder-check")
    with_image(p)
    p.set_defaults(func=cmd_encoder_check)
    p = sub.add_parser("survey")
    with_image(p)
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
