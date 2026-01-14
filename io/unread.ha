// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

export type unstream = struct {
	vtable: stream,
	source: handle,
	buf: []u8,
};

const unstream_vtable = vtable {
	reader = &unstream_read,
	closer = &unstream_close,
	...
};

// Create an overlay stream that allows bytes to be "unread", such that the
// unread bytes are always returned before new bytes are fetched from the
// underlying stream. For example,
//
// 	let s = io::unreader(...);
// 	io::unread(&s, [3, 4])!;
// 	io::unread(&s, [1, 2])!;
// 	let buf: [4]u8 = [0...];
// 	io::read(&s, buf)!;
//
// will fill buf with [1, 2, 3, 4] and not issue any reads to the underlying
// stream.
//
// There is no limit to the number of bytes which may be unread. The unreader
// stream must be closed, and doing so will not automatically close the
// underlying stream.
export fn unreader(source: handle) unstream = unstream {
	vtable = &unstream_vtable,
	source = source,
	buf = [],
};

// Unreads bytes onto an unreader stream, such that they're returned before new
// bytes are fetched from the underlying stream. See [[unreader]] for details.
export fn unread(s: *unstream, buf: []u8) (void | nomem) = {
	insert(s.buf[0], buf...)?;
};

fn unstream_read(s: *stream, buf: []u8) (size | EOF | error) = {
	let s = s: *unstream;
	assert(s.vtable == &unstream_vtable);
	assert(len(buf) != 0);

	let z = if (len(s.buf) < len(buf)) len(s.buf) else len(buf);
	if (z != 0) {
		buf[..z] = s.buf[..z];
		buf = buf[z..];
		delete(s.buf[..z]);
	};

	match (read(s.source, buf)?) {
	case EOF =>
		if (z == 0) {
			return EOF;
		} else {
			return z;
		};
	case let z2: size =>
		return z + z2;
	};
};

fn unstream_close(s: *stream) (void | error) = {
	let s = s: *unstream;
	assert(s.vtable == &unstream_vtable);

	free(s.buf);
};
