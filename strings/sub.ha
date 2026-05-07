// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use encoding::utf8;

// Passed to [[strings::sub]] to make the returned substring span to the end of
// the original string.
export type end = void;

fn utf8_byte_len_bounded(iter: *iterator, end: size) size = {
	for (let i = 0z; i < end; i += 1) {
		match (next(iter)) {
		case let r: rune =>
			continue;
		case done =>
			abort("index exceeds string length");
		};
	};
	return iter.dec.offs;
};

// Returns a substring in the range [start, end - 1], where each argument is the
// index of the Nth rune. If the end argument is given as [[end]], the end of
// the substring is the end of the original string. The lifetime of the
// substring is the same as that of the original string.
//
// Note that substringing rune-wise is not always the correct thing to do, and
// it may cause unexpected linguistic errors to arise. You may want to use a
// third-party Unicode module instead.
export fn sub(s: str, start: size, end: (size | end) = end) str = {
	let iter = iter(s);
	let starti = utf8_byte_len_bounded(&iter, start);
	let endi = match (end) {
	case let sz: size =>
		assert(start <= sz, "start is higher than end");
		yield utf8_byte_len_bounded(&iter, sz - start);
	case =>
		yield len(s);
	};
	let bytes = toutf8(s);
	return fromutf8_unsafe(bytes[starti..endi]);
};

@test fn sub() void = {
	assert(sub("a string", 2) == "string");
	assert(sub("a string", 2, end) == "string");
	assert(sub("a string", 0, 1) == "a");
	assert(sub("a string", 0, 3) == "a s");
	assert(sub("a string", 2, 8) == "string");
	assert(sub("a string", 4, 4) == "");
	assert(sub("こんにちは", 1, 3) == "んに");
};

// Returns a substring in the range [start, end - 1], where each argument is the
// index of the rune at the byte-wise index N. [[encoding::utf8::invalid]] is
// returned if it would cut through the middle of a codepoint. An end argment of
// [[end]] is the same as len(s). The lifetime of the substring is the same as
// that of the original string.
export fn bytesub(
	s: str,
	start: size,
	end: (size | end) = end,
) (str | utf8::invalid) = {
	const end = match (end) {
	case let z: size =>
		yield z;
	case =>
		yield len(s);
	};

	const s = toutf8(s);
	if ((start < len(s) && s[start] & 0xc0 == 0x80)
			|| (end < len(s) && s[end] & 0xc0 == 0x80)) {
		return utf8::invalid;
	};
	return fromutf8_unsafe(s[start..end]);
};

@test fn bytesub() void = {
	assert(bytesub("a string", 2)! == "string");
	assert(bytesub("a string", 2, end)! == "string");
	assert(bytesub("a string", 0, 1)! == "a");
	assert(bytesub("a string", 0, 3)! == "a s");
	assert(bytesub("a string", 2, 8)! == "string");
	assert(bytesub("a string", 4, 4)! == "");
	assert(bytesub("こんにちは", 3, 9)! == "んに");
	assert(bytesub("こんにちは", 1, 3) is utf8::invalid);
};
