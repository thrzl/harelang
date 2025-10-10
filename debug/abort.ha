// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use debug::image;
use fmt;
use fs;
use os;
use rt;

let default_abort: *rt::abort_handler = @undefined;

@init fn init_abort() void = {
	default_abort = rt::onabort(&debug_abort);
};

// Note: take care not to get into an abort loop when working on this code
fn debug_abort(
	path: *str,
	line: u64,
	col: u64,
	msg: str,
) never = {
	begin_fatal();

	const self = match (image::self()) {
	case let img: image::image =>
		yield img;
	case =>
		_ = fmt::errorfln("Abort: {}:{}:{}: {}", *path, line, col, msg);
		halt();
	};
	defer image::close(&self);

	const st = match (os::fstat(self.fd)) {
	case let st: fs::filestat =>
		yield st;
	case fs::error =>
		yield fs::filestat { mask = 0, ... };
	};

	_ = fmt::errorfln("Abort: {}:{}:{}: {}", *path, line, col, msg);
	print_context(*path, line, col, st.mtime);

	let frame = walk();
	// Skip rt::abort and debug::debug_abort
	for (let skip = 2; skip > 0; skip -= 1) {
		match (next(frame)) {
		case let next: stackframe =>
			frame = next;
		case done => halt();
		};
	};

	backtrace(&self, frame);
	halt();
};

fn halt() never = {
	_ = rt::kill(rt::getpid(), rt::SIGABRT);
	for (true) void;
};
