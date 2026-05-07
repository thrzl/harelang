// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>
// (c) 2023 Nicholas Rodrigues Lordello <n@lordello.net>

use hash;
use io;

// The size, in bytes, of a SHA3-224 digest.
export def SZ224: size = 28;

// The rate or block size, in bytes, of a SHA3-224 hash.
export def BLOCKSZ224: size = 144;

// The size, in bytes, of a SHA3-256 digest.
export def SZ256: size = 32;

// The rate or block size, in bytes, of a SHA3-256 hash.
export def BLOCKSZ256: size = 136;

// The size, in bytes, of a SHA3-384 digest.
export def SZ384: size = 48;

// The rate or block size, in bytes, of a SHA3-384 hash.
export def BLOCKSZ384: size = 104;

// The size, in bytes, of a SHA3-512 digest.
export def SZ512: size = 64;

// The rate or block size, in bytes, of a SHA3-512 hash.
export def BLOCKSZ512: size = 72;

// The domain separation byte **including** the first bit of padding for SHA3
// family of hashes as specified in Appendix B.2 of FIPS 202.
def SHA3_DS: u8 = 0x06;

// Creates a [[hash::hash]] which computes a SHA3-224 hash. If this function is
// used to hash sensitive information, the caller should call [[hash::close]] to
// erase sensitive data from memory after use; if not, the use of
// [[hash::close]] is optional.
export fn sha3_224() hash = sha3_init(SZ224, BLOCKSZ224);

// Creates a [[hash::hash]] which computes a SHA3-256 hash. If this function is
// used to hash sensitive information, the caller should call [[hash::close]] to
// erase sensitive data from memory after use; if not, the use of
// [[hash::close]] is optional.
export fn sha3_256() hash = sha3_init(SZ256, BLOCKSZ256);

// Creates a [[hash::hash]] which computes a SHA3-384 hash. If this function is
// used to hash sensitive information, the caller should call [[hash::close]] to
// erase sensitive data from memory after use; if not, the use of
// [[hash::close]] is optional.
export fn sha3_384() hash = sha3_init(SZ384, BLOCKSZ384);

// Creates a [[hash::hash]] which computes a SHA3-512 hash. If this function is
// used to hash sensitive information, the caller should call [[hash::close]] to
// erase sensitive data from memory after use; if not, the use of
// [[hash::close]] is optional.
export fn sha3_512() hash = sha3_init(SZ512, BLOCKSZ512);

export type hash = struct {
	hash::hash,
	e: sponge,
};

fn sha3_init(sz: size, rate: size) hash = {
	return hash {
		stream = &sha3_vtable,
		sum = &sha3_sum,
		reset = &sha3_reset,
		sz = sz,
		// The rate is an approximation of the block size as defined in
		// the [[hash::hash]] type. In fact, because of the domain
		// separation bits, there is no possible value that fits the
		// description, as there will **always** be padding required.
		bsz = rate,
		e = sponge {
			rate = rate,
			ds = SHA3_DS,
			s = [0...],
			pos = 0,
		},
	};
};

const sha3_vtable: io::vtable = io::vtable {
	writer = &sha3_write,
	closer = &sha3_close,
	...
};

fn sha3_write(st: *io::stream, buf: const []u8) (size | io::error) = {
	let h = st: *hash;
	absorb(&h.e, buf);
	return len(buf);
};

fn sha3_close(st: *io::stream) (void | io::error) = {
	let h = st: *hash;
	reset(&h.e);
};

fn sha3_sum(h: *hash::hash, buf: []u8) void = {
	let h = h: *hash;
	// Make a copy of the sponge; this way, the caller can request the
	// current sum but also continue updating the state of the hash with new
	// data afterwards.
	let e = h.e;
	pad(&e);
	squeeze(&e, buf[..h.sz]);
};

fn sha3_reset(h: *hash::hash) void = {
	let h = h: *hash;
	reset(&h.e);
};
