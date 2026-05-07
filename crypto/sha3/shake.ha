// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>
// (c) 2023 Nicholas Rodrigues Lordello <n@lordello.net>

use bytes;
use io;

// The rate or block size, in bytes, of a SHAKE128 XOF.
export def SHAKE_BLOCKSZ128: size = 168;

// The rate or block size, in bytes, of a SHAKE256 XOF.
export def SHAKE_BLOCKSZ256: size = 136;

// The domain separation byte **including** the first bit of padding for the
// SHAKE family of XOFs as specified in Appendix B.2 of FIPS 202.
def SHAKE_DS: u8 = 0x1f;

// Creates an [[io::stream]] that acts as a SHAKE128 eXtendable-Output Function
// (XOF). XOFs produce an output of unlimited size given some input data.
//
//	let shake = sha3::shake128();
//	// Absorb some input:
//	io::write(&shake, strings::toutf8("hello "))!;
//	io::write(&shake, strings::toutf8("hare!"))!;
//
//	// Copying the XOF copies its state:
//	let dup = shake;
//
//	// Squeeze some output:
//	let buf: []u8 = alloc([0...], 1337);
//	io::read(&shake, buf[..42])!;
//	io::read(&shake, buf[42..])!;
//
//	// Absorbing (i.e. writing) more input is an error:
//	assert(io::write(&shake, []) is errors::unsupported);
//
// All calls to [[io::write]] while absorbing and to [[io::read]] always
// write/read the full specified buffer and never fail. If this stream is used
// to write sensitive information, the caller should call [[io::close]] to erase
// sensitive data from memory after use; if not, the use of [[io::close]] is
// optional.
export fn shake128() xof = shake_init(SHAKE_BLOCKSZ128);

// Creates an [[io::stream]] that acts as a SHAKE256 eXtendable-Output Function
// (XOF). See [[shake128]] for more information.
export fn shake256() xof = shake_init(SHAKE_BLOCKSZ256);

export type xof = struct {
	stream: io::stream,
	e: sponge,
};

fn shake_init(rate: size) xof = {
	return xof {
		stream = &shake_absorb_vtable,
		e = sponge {
			rate = rate,
			ds = SHAKE_DS,
			s = [0...],
			pos = 0,
		},
	};
};

const shake_absorb_vtable: io::vtable = io::vtable {
	reader = &shake_first_read,
	writer = &shake_write,
	closer = &shake_close,
	...
};

const shake_squeeze_vtable: io::vtable = io::vtable {
	reader = &shake_read,
	closer = &shake_close,
	...
};

fn shake_first_read(st: *io::stream, buf: []u8) (size | io::EOF | io::error) = {
	let f = st: *xof;
	// once a sponge starts being squeezed, it cannot absorb new data anymore.
	f.stream = &shake_squeeze_vtable;
	pad(&f.e);
	squeeze(&f.e, buf);
	return len(buf);
};

fn shake_read(st: *io::stream, buf: []u8) (size | io::EOF | io::error) = {
	let f = st: *xof;
	squeeze(&f.e, buf);
	return len(buf);
};

fn shake_write(st: *io::stream, buf: const []u8) (size | io::error) = {
	let f = st: *xof;
	absorb(&f.e, buf);
	return len(buf);
};

fn shake_close(st: *io::stream) (void | io::error) = {
	let f = st: *xof;
	f.stream = &shake_absorb_vtable;
	reset(&f.e);
};
