// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use io;
use rt;

// Returns whether the given stream is connected to a terminal.
export fn isatty(fd: io::file) bool = {
	let t = rt::termios { ... };
	match (rt::ioctl(fd, rt::TIOCGETA, &t: *opaque)) {
	case let e: rt::errno =>
		return false;
	case let r: int =>
		return r == 0;
	};
};
