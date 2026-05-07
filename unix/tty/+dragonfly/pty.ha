// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use fmt;
use fs;
use io;
use os;
use rt;
use types::c;

// Opens an available pseudoterminal and returns the file descriptors of the
// master and slave.
export fn openpty() ((io::file, io::file) | fs::error) = {
	let master = open_master()?;
	let slave = match (get_slave(master)) {
	case let e: fs::error =>
		io::close(master)!;
		return e;
	case let s: io::file =>
		yield s;
	};
	return (master, slave);
};

// Opens an available pseudoterminal master.
fn open_master() (io::file | fs::error) = {
	match (rt::open("/dev/ptmx", rt::O_RDWR | rt::O_NOCTTY, 0)) {
	case let e: rt::errno =>
		return errors::errno(e);
	case let i: int =>
		return io::fdopen(i);
	};
};

// Returns a file descriptor referring to the pseudoterminal slave for a
// pseudoterminal master.
fn get_slave(master: io::file) (io::file | fs::error) =
	os::open(ptsname(master)?, fs::flag::RDWR);

// Returns the filename of the pseudoterminal slave. The return value is
// statically allocated and will be overwritten on subsequent calls to this
// function.
export fn ptsname(master: io::file) (str | error) = {
	// Ensure that the file descriptor refers to a master
	match (rt::ioctl(master, rt::TIOCISPTMASTER, null)) {
	case let e: rt::errno =>
		if (e == rt::EBADF) return errors::invalid
		else return errors::unsupported;
	case => void;
	};

	let name: [rt::NAME_MAX + 1]u8 = [0...];
	let fiodgname_arg = rt::fiodname_args {
		name = &name,
		length = len(name): uint
	};
	match (rt::ioctl(master, rt::FIODNAME, &fiodgname_arg)) {
	case let e: rt::errno =>
		switch (e) {
		case rt::EBADF =>
			return errors::invalid;
		case rt::EINVAL, rt::ENOTTY =>
			return errors::unsupported;
		case =>
			abort("Unexpected error from ioctl");
		};
	case =>
		name[2] = 's'; // ptm -> pts
		static let path_buf: [len("/dev/")+rt::NAME_MAX+1]u8 = [0...];
		return fmt::bsprintf(path_buf,
			"/dev/{}", c::tostr(&name: *const c::char)!)!;
	};
};

// Sets the dimensions of the underlying pseudoterminal for an [[io::file]].
export fn set_winsize(pty: io::file, sz: ttysize) (void | error) = {
	let wsz = rt::winsize { ws_row = sz.rows, ws_col = sz.columns, ... };
	match (rt::ioctl(pty, rt::TIOCSWINSZ, &wsz)) {
	case let e: rt::errno =>
		switch (e) {
		case rt::EBADF, rt::EINVAL =>
			return errors::invalid;
		case rt::ENOTTY =>
			return errors::unsupported;
		case =>
			abort("Unexpected error from ioctl");
		};
	case => void;
	};
};
