// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use bufio;
use fmt;
use fs;
use io;
use os;
use time;

// Prints a context line from the source file.
fn print_context(
	path: str,
	line: u64,
	col: u64,
	age: time::instant,
) void = {
	const file = match (os::open(path)) {
	case fs::error =>
		return;
	case let file: io::file =>
		yield file;
	};
	defer _ = io::close(file);

	match (os::fstat(file)) {
	case let st: fs::filestat =>
		if (st.mask & fs::stat_mask::MTIME == 0) yield;
		if (time::compare(st.mtime, age) == 1) {
			_ = fmt::errorln("* Warning: file was modified after executable was built");
		};
	case => void;
	};

	static let linebuf: [1024]u8 = [0...];
	const scan = bufio::newscanner_static(file, linebuf);

	let context = "";
	for (let i = 0u; i < line; i += 1) {
		match (bufio::scan_line(&scan)) {
		case let s: const str =>
			context = s;
		case =>
			return;
		};
	};

	_ = fmt::errorfln("| {}", context);

	if (col != 0) {
		_ = fmt::errorf("  ");
		for (let i = 1u; i < col - 1; i += 1) {
			_ = fmt::errorf(" ");
		};
		_ = fmt::errorf("^");
	};

	_ = fmt::errorln();
};
