// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use io;
use rt;
use unix;

// Sets the process group on the foreground of this terminal.
export fn tcsetpgrp(fd: io::file, pg: unix::pid) (void | errors::error) = {
	match (rt::ioctl(fd, rt::TIOCSPGRP, &pg)) {
	case int => void;
	case let err: rt::errno =>
		return errors::errno(err);
	};
};

// Gets the process group on the foreground of this terminal.
export fn tcgetpgrp(fd: io::file) (unix::pid | errors::error) = {
	let pg: unix::pid = @undefined;
	match (rt::ioctl(fd, rt::TIOCGPGRP, &pg)) {
	case int =>
		return pg;
	case let err: rt::errno =>
		return errors::errno(err);
	};
};
