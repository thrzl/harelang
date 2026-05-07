// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use fs;
use io;
use path;
use rt;
use strings;

fn shm_path(name: str) (str | fs::error) = {
	const name = strings::ltrim(name, '/');
	if (len(name) > rt::NAME_MAX) {
		return errors::invalid;
	};
	if (name == "." || name == "..") {
		return errors::invalid;
	};
	static let buf = path::buffer { ... };
	path::set(&buf, "/", name)!;
	return path::string(&buf);
};

// TODO: port shm_open, shm_unlink from libc
