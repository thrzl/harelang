// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>
// (c) 2023 Nicholas Rodrigues Lordello <n@lordello.net>

use bytes;
use crypto::math;
use endian;

// The Keccak-p[1600,24] permutation function (also referred to as
// Keccak-f[1600]). This is an implementation of Algorithm 7 from FIPS 202 for
// b = 1600 and nr = 24.
fn keccakf(a: *[25]u64) void = {
	let b: [25]u64 = [0...];
	let c: [5]u64 = [0...];
	let d: [5]u64 = [0...];

	for (const rc .. RC) {
		// π ∘ ρ ∘ θ:
		c[0] = a[0] ^ a[5] ^ a[10] ^ a[15] ^ a[20];
		c[1] = a[1] ^ a[6] ^ a[11] ^ a[16] ^ a[21];
		c[2] = a[2] ^ a[7] ^ a[12] ^ a[17] ^ a[22];
		c[3] = a[3] ^ a[8] ^ a[13] ^ a[18] ^ a[23];
		c[4] = a[4] ^ a[9] ^ a[14] ^ a[19] ^ a[24];
		d[0] = c[4] ^ math::rotl64(c[1], 1);
		d[1] = c[0] ^ math::rotl64(c[2], 1);
		d[2] = c[1] ^ math::rotl64(c[3], 1);
		d[3] = c[2] ^ math::rotl64(c[4], 1);
		d[4] = c[3] ^ math::rotl64(c[0], 1);
		b[0] = a[0] ^ d[0];
		b[1] = math::rotl64(a[6] ^ d[1], 44);
		b[2] = math::rotl64(a[12] ^ d[2], 43);
		b[3] = math::rotl64(a[18] ^ d[3], 21);
		b[4] = math::rotl64(a[24] ^ d[4], 14);
		b[5] = math::rotl64(a[3] ^ d[3], 28);
		b[6] = math::rotl64(a[9] ^ d[4], 20);
		b[7] = math::rotl64(a[10] ^ d[0], 3);
		b[8] = math::rotl64(a[16] ^ d[1], 45);
		b[9] = math::rotl64(a[22] ^ d[2], 61);
		b[10] = math::rotl64(a[1] ^ d[1], 1);
		b[11] = math::rotl64(a[7] ^ d[2], 6);
		b[12] = math::rotl64(a[13] ^ d[3], 25);
		b[13] = math::rotl64(a[19] ^ d[4], 8);
		b[14] = math::rotl64(a[20] ^ d[0], 18);
		b[15] = math::rotl64(a[4] ^ d[4], 27);
		b[16] = math::rotl64(a[5] ^ d[0], 36);
		b[17] = math::rotl64(a[11] ^ d[1], 10);
		b[18] = math::rotl64(a[17] ^ d[2], 15);
		b[19] = math::rotl64(a[23] ^ d[3], 56);
		b[20] = math::rotl64(a[2] ^ d[2], 62);
		b[21] = math::rotl64(a[8] ^ d[3], 55);
		b[22] = math::rotl64(a[14] ^ d[4], 39);
		b[23] = math::rotl64(a[15] ^ d[0], 41);
		b[24] = math::rotl64(a[21] ^ d[1], 2);

		// ι ∘ χ:
		a[0] = b[0] ^ (~b[1] & b[2]) ^ rc;
		a[1] = b[1] ^ (~b[2] & b[3]);
		a[2] = b[2] ^ (~b[3] & b[4]);
		a[3] = b[3] ^ (~b[4] & b[0]);
		a[4] = b[4] ^ (~b[0] & b[1]);
		a[5] = b[5] ^ (~b[6] & b[7]);
		a[6] = b[6] ^ (~b[7] & b[8]);
		a[7] = b[7] ^ (~b[8] & b[9]);
		a[8] = b[8] ^ (~b[9] & b[5]);
		a[9] = b[9] ^ (~b[5] & b[6]);
		a[10] = b[10] ^ (~b[11] & b[12]);
		a[11] = b[11] ^ (~b[12] & b[13]);
		a[12] = b[12] ^ (~b[13] & b[14]);
		a[13] = b[13] ^ (~b[14] & b[10]);
		a[14] = b[14] ^ (~b[10] & b[11]);
		a[15] = b[15] ^ (~b[16] & b[17]);
		a[16] = b[16] ^ (~b[17] & b[18]);
		a[17] = b[17] ^ (~b[18] & b[19]);
		a[18] = b[18] ^ (~b[19] & b[15]);
		a[19] = b[19] ^ (~b[15] & b[16]);
		a[20] = b[20] ^ (~b[21] & b[22]);
		a[21] = b[21] ^ (~b[22] & b[23]);
		a[22] = b[22] ^ (~b[23] & b[24]);
		a[23] = b[23] ^ (~b[24] & b[20]);
		a[24] = b[24] ^ (~b[20] & b[21]);
	};
};

// Pre-computed RC values per round index for the ι step. See Algorithms 5 and 6
// from FIPS 202.
const RC: [24]u64 = [
	0x0000000000000001,
	0x0000000000008082,
	0x800000000000808a,
	0x8000000080008000,
	0x000000000000808b,
	0x0000000080000001,
	0x8000000080008081,
	0x8000000000008009,
	0x000000000000008a,
	0x0000000000000088,
	0x0000000080008009,
	0x000000008000000a,
	0x000000008000808b,
	0x800000000000008b,
	0x8000000000008089,
	0x8000000000008003,
	0x8000000000008002,
	0x8000000000000080,
	0x000000000000800a,
	0x800000008000000a,
	0x8000000080008081,
	0x8000000000008080,
	0x0000000080000001,
	0x8000000080008008,
];

// The Keccak sponge function is definied in Algorithm 8 from FIPS 202. The
// implementation here is split between the [[absorb]], [[pad]] and [[squeeze]]
// functions to allow streaming input into and output from the [[sponge]]:
//
//	let e = sponge { ... };
//	absorb(&e, input[..]);
//	absorb(&e, input[..]);
//	// ...
//	pad(&e);
//	squeeze(&e, output[..]);
//	squeeze(&e, output[..]);
//	// ...
//
// The shared [[sponge]] state contains fields:
// - rate: the number of input bytes processed or output bytes generated at a
//   time.
// - ds: The domain separation byte for the sponge construction instance
//   **including** the first bit of padding. Different domain separators are
//   used for hashing and XOFs. See Table 6 from FIPS 202.
// - s: The 1600-bit/200-byte state of the sponge, stored as an array of u64s
//   ready for the [[keccakf]] permutation function.
// - pos: The position in bytes to continue writing to (in case the sponge is
//   [[absorb]]-ing) or reading from (in case the sponge is [[squeeze]]-ing).

export type sponge = struct {
	rate: size,
	ds: u8,
	s: [25]u64,
	pos: size,
};

// Absorb some data into the sponge. This function must not be called after
// [[pad]]-ing or [[squeeze]]-ing data from the sponge.
fn absorb(e: *sponge, data: const []u8) void = {
	let d = data[..];
	for (len(d) > 0) {
		if (e.pos & 7 == 0 && len(d) >= 8) {
			// fast-path: if we are at a 64-bit boundary and have a
			// full 64-bit word to write.
			e.s[e.pos >> 3] ^= endian::legetu64(d);
			e.pos += 8;
			d = d[8..];
		} else {
			// slow-path.
			let buf: [8]u8 = [0...];
			let o = e.pos & 7;
			let n = 8 - o;
			if (n > len(d)) {
				n = len(d);
			};
			buf[o..][..n] = d[..n];
			e.s[e.pos >> 3] ^= endian::legetu64(buf);
			e.pos += n;
			d = d[n..];
		};

		if (e.pos == e.rate) {
			keccakf(&e.s);
			e.pos = 0;
		};
		assert(e.pos < e.rate);
	};
};

// Write the domain separation string and pad the input to the sponge. This
// function must only be called once, and before [[squeeze]]-ing data from the
// sponge. See Appendix B.2 from FIPS 202.
fn pad(e: *sponge) void = {
	let sb = &e.s: *[200]u8;
	sb[e.pos] ^= e.ds;
	sb[e.rate - 1] ^= 0x80;
	keccakf(&e.s);
	e.pos = 0;
};

// Sqeeze some data out of the sponge. This function must not be called before
// [[pad]]-ing the sponge.
fn squeeze(e: *sponge, data: []u8) void = {
	let d = data[..];
	for (len(d) > 0) {
		if (e.pos == e.rate) {
			keccakf(&e.s);
			e.pos = 0;
		};
		assert(e.pos < e.rate);

		if (e.pos & 7 == 0 && len(d) >= 8) {
			// fast-path: if we are at a 64-bit boundary and have a
			// full 64-bit word to read.
			endian::leputu64(d, e.s[e.pos >> 3]);
			e.pos += 8;
			d = d[8..];
		} else {
			// slow-path.
			let buf: [8]u8 = [0...];
			endian::leputu64(buf[..], e.s[e.pos >> 3]);
			let o = e.pos & 7;
			let n = 8 - o;
			if (n > len(d)) {
				n = len(d);
			};
			d[..n] = buf[o..][..n];
			e.pos += n;
			d = d[n..];
		};
	};
};

// Resets a sponge to its initial state.
fn reset(e: *sponge) void = {
	let sb = &e.s: *[200]u8;
	bytes::zero(sb[..]);
	e.pos = 0;
};
