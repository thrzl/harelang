// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

// Implements the Ed25519 signature scheme.
//
// This implementation is a straightforward port of TweetNaCl,
// with the API of crypto/ed25519 from the Go standard library.
use bytes;
use crypto::sha512;
use hash;

// The size of an Ed25519 seed.
export def SEEDSZ: size = 32;

// The size of an Ed25519 public key.
export def PUBKEYSZ: size = 32;

// The size of an Ed25519 private key.
export def PRIVKEYSZ: size = 64;

// The size of an Ed25519 signature.
export def SIGNATURESZ: size = 64;

export type privkey = [PRIVKEYSZ]u8;
export type pubkey = [PUBKEYSZ]u8;
export type seed = [SEEDSZ]u8;

// Invalid signature
export type invalidsig = !void;

// Invalid key
export type invalidkey = !void;

// Possible errors returned by this module.
export type error = !(invalidsig | invalidkey);

// String representation of error 'e'.
export fn strerror(e: error) str = {
	match (e) {
	case invalidsig =>
		return "invalid signature";
	case invalidkey =>
		return "invalid key";
	};
};

// Derives a new Ed25519 private key from a given seed. The seed must be
// initialized to cryptographically random data; [[crypto::random::]] is
// recommended for this purpose.
export fn privkey_init(priv: []u8, seed: []u8) void = {
	assert(len(priv) == PRIVKEYSZ);
	assert(len(seed) == SEEDSZ);

	let h: [64]u8 = [0...];
	let sha = sha512::sha512();
	hash::write(&sha, seed[..]);
	hash::sum(&sha, h[..]);
	hash::close(&sha);

	let s: scalar = [0...];
	s[..] = h[..SCALARSZ];
	scalar_clamp(&s);

	let A = point { ... };
	scalarmult_base(&A, &s);
	let A_bytes: [POINTSZ]u8 = [0...];
	point_encode(&A_bytes, &A);

	priv[0..SEEDSZ] = seed[..];
	priv[SEEDSZ..PRIVKEYSZ] = A_bytes[..];
};

// Derive the public key for a given private key. '
export fn privkey_getpubkey(priv: []u8) pubkey = {
	assert(len(priv) == PRIVKEYSZ);
	let pk: pubkey = [0...];
	pk[0..] = priv[SEEDSZ..];
	return pk;
};

// Signs a message with a private key, returning the signature.
export fn sign(priv: []u8, msg: []u8) [SIGNATURESZ]u8 = {
	assert(len(priv) == PRIVKEYSZ);

	let h: [64]u8 = [0...];
	let sha = sha512::sha512();
	hash::write(&sha, priv[0..SEEDSZ]);
	hash::sum(&sha, h);
	let esk: scalar = [0...];
	esk[..] = h[0..32];
	scalar_clamp(&esk);

	hash::reset(&sha);
	hash::write(&sha, h[32..64]);
	hash::write(&sha, msg);
	let msg_digest: [64]u8 = [0...];
	hash::sum(&sha, msg_digest);
	let msg_reduced: scalar = [0...];
	scalar_reduce(&msg_reduced, &msg_digest);

	let R = point {...};
	scalarmult_base(&R, &msg_reduced);
	let R_bytes: [POINTSZ]u8 = [0...];
	point_encode(&R_bytes, &R);

	hash::reset(&sha);
	hash::write(&sha, R_bytes[..]);
	hash::write(&sha, priv[32..64]);
	hash::write(&sha, msg);
	let hram: [64]u8 = [0...];
	hash::sum(&sha, hram);
	hash::close(&sha);
	let hram_reduced: scalar = [0...];
	scalar_reduce(&hram_reduced, &hram);

	let s: scalar = [0...];
	scalar_multiply_add(&s, &hram_reduced, &esk, &msg_reduced);

	let sig: [SIGNATURESZ]u8 =[0...];
	sig[0..32] = R_bytes[..];
	sig[32..64] = s[..];
	return sig;
};

export type hash = struct {
	h: sha512::digest,
	pub: []u8,
	point: point,
	sig: []u8,
};

// Creates a [[hash::hash]] function in that the message to be verified can
// be written into. [[verify]] needs to be called afterwards, to verify
// if the signature is valid for the given message.
export fn verifier(pub: []u8, sig: []u8) (hash | invalidkey | invalidsig) = {
	if (len(pub) != PUBKEYSZ) {
		return invalidkey;
	};

	if (len(sig) != SIGNATURESZ) {
		return invalidsig;
	};

	let h = hash {
		h = sha512::sha512(),
		pub = pub,
		point = point { ... },
		sig = sig,
	};


	if (!point_decode(&h.point, pub)) {
		return invalidkey;
	};

	hash::write(&h.h, sig[0..32]);
	hash::write(&h.h, pub[..]);
	return h;
};

// Given a public key, verifies a signature produced with the
// corresponding private key for a given message, returning true if the
// signature is valid and false otherwise.
export fn verify_buf(pub: []u8, msg: []u8, sig: []u8) (void | error) = {
	let h = verifier(pub, sig)?;
	hash::write(&h, msg);
	verify(&h)?;
};

// Checks if the given hash 'h' is valid.
export fn verify(h: *hash) (void | invalidsig) = {
	let A = point { ... };

	let hram: [64]u8 = [0...];
	hash::sum(&h.h, hram);
	hash::close(&h.h);

	let hram_reduced: scalar = [0...];
	scalar_reduce(&hram_reduced, &hram);
	let check_R = point { ... };
	scalarmult(&check_R, &h.point, &hram_reduced);

	let s: scalar = [0...];
	s[..] = h.sig[32..64];
	scalarmult_base(&A, &s);
	point_add(&check_R, &check_R, &A);
	let R_bytes: [POINTSZ]u8 = [0...];
	point_encode(&R_bytes, &check_R);
	if (!bytes::equal(R_bytes, h.sig[0..32])) {
		return invalidsig;
	};
};
