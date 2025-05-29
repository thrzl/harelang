// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use bufio;
use errors;
use fs;
use io;

// Opens a file and allocates read and/or write buffers for buffered I/O. To
// open an unbuffered [[io::file]] see [[open]].
//
// [[fs::flag::CREATE]] isn't very useful with this function, since the new
// file's mode is set to zero. For this use-case, use [[create]] instead.
export fn open_buffered(
	path: str,
	flags: fs::flag = fs::flag::RDONLY,
) (bufio::stream | fs::error | nomem) = {
	const (rd, wr) = mkbuffers(flags)?;
	match (open(path, flags)) {
	case let file: io::file =>
		return bufio::init(file, rd, wr, bufio::flag::MANAGED);
	case let err: fs::error =>
		free(rd);
		free(wr);
		return err;
	};
};

// Creates a new file with the given mode if it doesn't already exist and opens
// it for writing, allocating read and/or write buffers for buffered I/O. To
// open an unbuffered [[io::file]] see [[create]].
//
// Only the permission bits of the mode are used. If other bits are set, they
// are discarded.
export fn create_buffered(
	path: str,
	mode: fs::mode,
	flags: fs::flag = fs::flag::WRONLY | fs::flag::TRUNC,
) (bufio::stream | fs::error | nomem) = {
	const (rd, wr) = mkbuffers(flags)?;
	match (create(path, mode, flags)) {
	case let file: io::file =>
		return bufio::init(file, rd, wr, bufio::flag::MANAGED);
	case let err: fs::error =>
		free(rd);
		free(wr);
		return err;
	};
};

fn mkbuffers(flags: fs::flag) (([]u8, []u8) | nomem) = {
	const mode = flags & 0b11;
	const need_read = mode != fs::flag::WRONLY;
	const need_write = mode != fs::flag::RDONLY;

	let ok = false;
	let read: []u8 = [];
	let write: []u8 = [];
	defer if (!ok) {
		free(read);
		free(write);
	};

	if (need_read) {
		read = alloc([0...], BUFSZ)?;
	};

	if (need_write) {
		write = alloc([0...], BUFSZ)?;
	};

	ok = true;
	return (read, write);
};
