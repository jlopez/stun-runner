// MAME's own M6295 decoder as an oracle for tools/adpcm's decode (tools/test_adpcm.py).
//
// Built by the test against a MAME source tree (MAME_SRC, default ~/.local/src/mame):
//   c++ -std=c++17 -I<dir with a stub emu.h> -I$MAME_SRC/src/devices/sound \
//     tools/adpcm/mame_oracle.cpp $MAME_SRC/src/devices/sound/okiadpcm.cpp -o oracle
// okiadpcm.cpp needs nothing from emu.h but <cstdint> and <cmath>, which the stub includes.
//
// Reads a sample's bytes on stdin and writes, as little-endian int16, the output of
// oki_adpcm_state::clock for every nibble, fetched as okim_voice::generate_adpcm
// (okim6295.cpp) fetches it: byte m_sample / 2, shifted right by ((m_sample & 1) << 2) ^ 4,
// from a freshly reset state, as a voice starts a phrase.

#include <cstdint>
#include <cstdio>
#include <vector>

#include "okiadpcm.h"

int main()
{
	std::vector<uint8_t> rom;
	int c;
	while ((c = std::getchar()) != EOF)
		rom.push_back(uint8_t(c));

	oki_adpcm_state adpcm;
	adpcm.reset();
	for (size_t sample = 0; sample < 2 * rom.size(); sample++)
	{
		int nibble = rom[sample / 2] >> (((sample & 1) << 2) ^ 4);
		int16_t out = adpcm.clock(nibble);
		std::putchar(out & 0xff);
		std::putchar((out >> 8) & 0xff);
	}
	return 0;
}
