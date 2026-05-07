// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

// Returns the size of a rune, in octets, when encoded as UTF-8.
export fn runesz(r: rune) size = {
	const ch = r: u32;
	return if (ch < 0x80) 1
		else if (ch < 0x800) 2
		else if (ch < 0x10000) 3
		else 4;
};

// Returns the expected length of a UTF-8 codepoint in bytes given its first
// byte, or [[invalid]] if the given byte doesn't begin a valid UTF-8 sequence.
export fn utf8sz(c: u8) (size | invalid) = {
	if (c < 0b1000_0000) return 1;
	if (c < 0b1100_0010 || c >= 0b1111_1000) return invalid;
	if (c < 0b1110_0000) return 2;
	if (c < 0b1111_0000) return 3;
	return 4;
};
