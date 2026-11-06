"""data/sound/commands.json, the sound commands of the 68010 -> 6502 protocol (docs/11-sound-
protocol.md), against its own shape, data/oki/samples.json, the two images and the MAME traces.

The shape and the OKI agreement run everywhere (CI). The image tests skip without
build/stunrun-68k.bin and build/stunrun-jsa.bin (`make` needs the ROMs): the 6502's command tables
give each command's class, type, parameter, handler and phrase; the 68010's audio test list gives
the names; every call of queue_sound_command (0301CA) in the image is listed, with the value its
`pea` pushes. The trace tests skip without the `make sndproto` traces
(build/mame/sndproto-<run>.txt): the counts and call sites the file records are what MAME saw, no
command was lost between the two CPUs, and the responses are the ones docs/11 lists.
"""

from __future__ import annotations

import json
import re
import struct
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent
COMMANDS = REPO / "data/sound/commands.json"
SAMPLES = REPO / "data/oki/samples.json"
IMAGE_68K = REPO / "build/stunrun-68k.bin"
IMAGE_JSA = REPO / "build/stunrun-jsa.bin"
TRACES = REPO / "build/mame"

RUNS = ("attract", "game", "selftest", "soundtest", "inject")
QUEUE = 0x0301CA  # queue_sound_command
TYPES_USED = {"00", "01", "03", "05", "08", "09", "0A", "0B", "13", "14", "FF"}
HEX2 = re.compile(r"^[0-9A-F]{2}$")
HEX6 = re.compile(r"^[0-9A-F]{6}$")


def load() -> dict:
    return json.loads(COMMANDS.read_text())


def commands() -> list[dict]:
    return load()["commands"]


def h(text: str) -> int:
    return int(text, 16)


# --- shape (everywhere) -------------------------------------------------------------------------


def test_every_value_00_to_6c_once_in_order() -> None:
    doc = load()
    assert doc["limit"] == "6D"
    assert [c["value"] for c in doc["commands"]] == [f"{v:02X}" for v in range(0x6D)]


def test_fields_and_names() -> None:
    names = set()
    for c in commands():
        for key in ("class", "type", "param"):
            assert HEX2.match(c[key]), (c["value"], key)
        assert c["type"] in TYPES_USED, c["value"]
        assert c["type"] in load()["types"], c["value"]
        # bit 7 of the class: queued for main_loop, with a type; else an immediate command
        assert (h(c["class"]) >= 0x80) == (c["type"] != "FF"), c["value"]
        if c["type"] == "FF":
            assert h(c["class"]) < 4, c["value"]
        assert re.match(r"^[0-9A-F]{4}$", c["handler"]), c["value"]
        assert re.match(r"^[a-z][a-z0-9_]*$", c["name"]), c["name"]
        if c["audio_test"] is None:
            assert c["name"] == f"cmd_{c['value']}_imm"
            assert c["audio_test_entry"] is None
        else:
            assert c["name"] == "snd_" + c["audio_test"].lower()
            assert HEX6.match(c["audio_test_entry"])
        assert c["name"] not in names, c["name"]
        names.add(c["name"])
        assert set(c["mame"]) == set(RUNS)
        assert all(isinstance(n, int) and n >= 0 for n in c["mame"].values())
        for site, routine in c["call_sites"] + c["direct_sends"]:
            assert HEX6.match(site) and HEX6.match(routine), c["value"]
            assert h(routine) <= h(site)
        sites = {s for s, _ in c["call_sites"]}
        assert set(c["mame_sites"]) <= sites, c["value"]


def test_type_fields() -> None:
    by_value = {c["value"]: c for c in commands()}
    for c in commands():
        t = c["type"]
        assert ("phrase" in c) == (t == "13"), c["value"]
        assert ("stops_phrase" in c) == (t == "14"), c["value"]
        assert ("stream" in c) == (t == "08"), c["value"]
        assert ("target" in c) == (t in ("05", "0A")), c["value"]
        assert ("group" in c) == (t == "0B"), c["value"]
        if t == "08":
            assert c["stream"] == c["param"]
        if t in ("05", "0A"):
            # the command whose stream is stopped or released starts a stream (type 08)
            assert by_value[c["target"]]["type"] == "08", c["value"]
            assert c["target"] == c["param"]


def test_site_notes_name_listed_sites() -> None:
    doc = load()
    listed = {s for c in doc["commands"] for s, _ in c["call_sites"]}
    assert set(doc["site_notes"]) <= listed
    # a site several commands share is a computed or alternative value, explained in a note
    count: dict[str, int] = {}
    for c in doc["commands"]:
        for s, _ in c["call_sites"]:
            count[s] = count.get(s, 0) + 1
    assert {s for s, n in count.items() if n > 1} <= set(doc["site_notes"])


def test_oki_commands_agree_with_samples_json() -> None:
    """Each OKI play command (type 13) names its phrase; data/oki/samples.json's `commands` lists
    exactly the play commands of each phrase (tools/adpcm survey wrote it from the same tables)."""
    phrases = {p["number"]: p for p in json.loads(SAMPLES.read_text())["phrases"]}
    plays: dict[int, list[str]] = {}
    for c in commands():
        if c["type"] == "13":
            plays.setdefault(c["phrase"], []).append(c["value"])
        if c["type"] == "14":
            assert c["stops_phrase"] in phrases
            assert h(c["param"]) == c["stops_phrase"]
    assert set(plays) <= set(phrases)
    for number, phrase in phrases.items():
        assert sorted(phrase["commands"]) == sorted(plays.get(number, [])), number


# --- against the images (skip without `make`) ---------------------------------------------------


@pytest.fixture(scope="module")
def m68k() -> bytes:
    if not IMAGE_68K.exists():
        pytest.skip(f"no {IMAGE_68K} (make needs the ROMs)")
    return IMAGE_68K.read_bytes()


@pytest.fixture(scope="module")
def jsa() -> bytes:
    if not IMAGE_JSA.exists():
        pytest.skip(f"no {IMAGE_JSA} (make needs the ROMs)")
    return IMAGE_JSA.read_bytes()


def test_6502_tables(jsa: bytes) -> None:
    tables = load()["tables"]
    cls, typ, par = h(tables["cmd_class"]), h(tables["cmd_type"]), h(tables["cmd_param"])
    imm, hnd = h(tables["imm_handlers"]), h(tables["cmdtype_handlers"])
    assert typ == cls + 0x6D and par == typ + 0x6D and imm == par + 0x6D
    for c in commands():
        v = h(c["value"])
        assert (jsa[cls + v], jsa[typ + v], jsa[par + v]) == (
            h(c["class"]),
            h(c["type"]),
            h(c["param"]),
        ), c["value"]
        if c["type"] != "FF":
            (word,) = struct.unpack_from("<H", jsa, hnd + 2 * h(c["type"]))
        else:
            (word,) = struct.unpack_from("<H", jsa, imm + 2 * (h(c["class"]) + 1))
        assert word + 1 == h(c["handler"]), c["value"]  # RTS dispatch: address - 1
        if c["type"] == "13":
            assert jsa[h(tables["oki_phrase"]) + h(c["param"])] == c["phrase"]
    # no command reaches type 10 (ymtimer.asm's way in) or the unused types
    assert not {jsa[typ + v] for v in range(0x6D)} - {h(t) for t in TYPES_USED}


def test_audio_test_list_names_the_commands(m68k: bytes) -> None:
    """The game's audio test (043718) lists 22-byte entries, a word (the command it sends,
    04394E-04395C) and a name, sorted by name, to a word FFFF."""
    tables = load()["tables"]
    entries = {}
    a = h(tables["audio_test"])
    while (word := struct.unpack_from(">H", m68k, a)[0]) != 0xFFFF:
        name = m68k[a + 2 : a + 22].split(b"\0")[0].decode("ascii")
        assert word not in entries
        entries[word] = (a, name)
        a += 22
    assert a == h(tables["audio_test_end"])
    names = [n for _, n in sorted(entries.values())]
    assert names == sorted(names)
    for c in commands():
        v = h(c["value"])
        if c["audio_test"] is None:
            assert v not in entries
        else:
            assert entries[v] == (h(c["audio_test_entry"]), c["audio_test"])


def _w(image: bytes, a: int) -> int:
    return int(struct.unpack_from(">H", image, a)[0])


def test_every_queue_call_is_listed(m68k: bytes) -> None:
    """Each `jsr queue_sound_command` (4EB9 0003 01CA) and each `jsr (A2)` of the four routines
    that load A2 with it is a listed call site; a site without a note is preceded by `pea N.w`
    and queues N; a note's `pea N at A` holds N."""
    doc = load()
    per_site: dict[str, set[int]] = {}
    for c in doc["commands"]:
        for s, _ in c["call_sites"]:
            per_site.setdefault(s, set()).add(h(c["value"]))
    found = set()
    for a in range(0x020000, 0x0C0000, 2):
        if _w(m68k, a) == 0x4EB9 and struct.unpack_from(">I", m68k, a + 2)[0] == QUEUE:
            found.add(f"{a:06X}")
    loads = [
        a
        for a in range(0x020000, 0x0C0000, 2)
        if _w(m68k, a) == 0x247C and struct.unpack_from(">I", m68k, a + 2)[0] == QUEUE
    ]
    assert [f"{a:06X}" for a in loads] == ["02430E", "02819C", "028350", "029B82"]
    indirect = {s for s in per_site if _w(m68k, h(s)) == 0x4E92}
    for s in indirect:
        assert any(0 < h(s) - a < 0x1200 for a in loads), s
    assert found | indirect == set(per_site)
    for s, values in per_site.items():
        a = h(s)
        if s in doc["site_notes"]:
            for value, at in re.findall(r"pea ([0-9A-F]{2}) at ([0-9A-F]{6})", doc["site_notes"][s]):
                assert _w(m68k, h(at)) == 0x4878 and _w(m68k, h(at) + 2) == h(value), s
            continue
        assert _w(m68k, a - 4) == 0x4878, s
        assert values == {_w(m68k, a - 2)}, s


def test_direct_sends(m68k: bytes) -> None:
    """The boot program writes its test commands with move.b #N,$600000 (13FC 00NN 0060 0000);
    the game's audio test and the watchdog push them for send_sound_byte (023EDA) or
    try_sound_byte (023EDE)."""
    for c in commands():
        for s, _ in c["direct_sends"]:
            a = h(s)
            if a < 0x020000:
                assert m68k[a : a + 8] == bytes([0x13, 0xFC, 0, h(c["value"]), 0, 0x60, 0, 0]), s
            else:
                (target,) = struct.unpack_from(">I", m68k, a + 2)
                assert _w(m68k, a) == 0x4EB9 and target in (0x023EDA, 0x023EDE), s


def test_sounds_in_attract_is_option_bit_11(m68k: bytes) -> None:
    """The option menu's item decoder (042CE4-042D2C) takes the field from the item's first byte:
    shift = low nibble, 2 << (high - low) choices. "SOUNDS IN ATTRACT" (text at 020F52) is bit 11
    of option word 0D, which the game copies to FF94EE (0243B8-0243BE) and 028364 tests (0800)."""
    item = m68k[0x020F51]
    assert m68k[0x020F52 : 0x020F52 + 17] == b"SOUNDS IN ATTRACT"
    shift, width = item & 0x0F, (item >> 4) - (item & 0x0F) + 1
    assert (shift, width) == (11, 1)
    assert struct.unpack_from(">HI", m68k, 0x028364)[1] == 0xFF94EE
    assert struct.unpack_from(">HI", m68k, 0x02836A)[1] == 1 << shift


# --- against the MAME traces (skip without `make sndproto`) -------------------------------------


def trace(run: str) -> list[list[str]]:
    path = TRACES / f"sndproto-{run}.txt"
    if not path.exists():
        pytest.skip(f"no {path} (make sndproto)")
    return [line.split() for line in path.read_text().splitlines() if line]


def header(lines: list[list[str]]) -> dict[str, str]:
    return {p[1]: p[2] for p in lines if p[0] == "#" and len(p) == 3}


@pytest.mark.parametrize("run", RUNS)
def test_mame_counts_and_sites(run: str) -> None:
    lines = trace(run)
    sent: dict[int, int] = {}
    queued: dict[int, set[str]] = {}
    for p in lines:
        if p[0] in ("send", "inject"):
            sent[h(p[1])] = sent.get(h(p[1]), 0) + int(p[-2])
        if p[0] == "queue":
            queued.setdefault(h(p[1]), set()).add(p[2])
    for c in commands():
        v = h(c["value"])
        assert c["mame"][run] == sent.get(v, 0), (run, c["value"])
        sites = {s for s, _ in c["call_sites"]}
        assert queued.get(v, set()) <= sites, (run, c["value"])
        assert queued.get(v, set()) <= set(c["mame_sites"]), (run, c["value"])
    assert sum(sent.values()) == int(header(lines)["commands"])


@pytest.mark.parametrize("run", RUNS)
def test_mame_protocol(run: str) -> None:
    lines = trace(run)
    head = header(lines)
    taken = {p[1]: int(p[2]) for p in lines if p[0] == "taken"}
    resets = sum(int(p[3]) for p in lines if p[0] == "reset")
    # every command written was taken by h_nmi (5839) or as imm_04's data byte (57FC); 4139 is
    # the read after each reset that drops what the latch holds
    assert taken.get("5839", 0) + taken.get("57FC", 0) == int(head["commands"])
    assert taken.get("4139", 0) == resets
    responses = {(p[1], p[2]) for p in lines if p[0] == "response"}
    # FF after reset (413E); 00 status for 07 and the input state for 03 (send_response 455D);
    # 55 for 09 (main_loop 4164); 6D for 06, AA and the echoed byte for 08 (455D)
    assert {r for r, pc in responses if pc == "413E"} <= {"FF"}
    assert {pc for _, pc in responses} <= {"413E", "455D", "4164"}
    assert {r for r, pc in responses if pc == "4164"} <= {"55"}
    # the game only resets the board (023FA8) through reset_sound; the boot program at 00023C,
    # 000FC2 and 008DB8
    assert {p[1] for p in lines if p[0] == "reset"} <= {"00023C", "000FC2", "008DB8", "023FA8"}
    # the watchdog counters FFDB5C-FFDB63: written by reset_sound (030102-030110) and the RAM
    # clears, never by the unreferenced routine at 03001E
    for p in lines:
        if p[0] == "watchdog_write":
            assert not 0x03001E <= h(p[1]) < 0x0300F8, p
    # the YM2151 timer registers 10-14: never selected (ymtimer.asm never runs)
    assert not [p for p in lines if p[0] == "ym_timer_reg"]


def test_mame_immediate_responses() -> None:
    lines = trace("inject")
    responses = {(p[1], p[2]) for p in lines if p[0] == "response"}
    assert {("6D", "455D"), ("55", "4164"), ("AA", "455D"), ("5A", "455D"), ("00", "455D")} <= (
        responses
    )
    # 6D, 7F, 80 and FF are queued as 6D (5836) and never dispatched
    dispatched = {p[1] for p in lines if p[0] == "dispatch"}
    assert not dispatched & {"6D", "7F", "80", "FF"}
    assert not {p[1] for p in lines if p[0] == "jsa_queue" and p[2] == "5846"} & {"6D", "7F", "80"}


def test_mame_audio_test_plays_every_entry() -> None:
    """PLAY SOUNDS: each entry of the list, played in turn, writes its own command (04395C)."""
    lines = trace("soundtest")
    played = {p[1] for p in lines if p[0] == "send" and p[3] == "04395C"}
    assert played == {c["value"] for c in commands() if c["audio_test"] is not None}
