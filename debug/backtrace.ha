// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use debug::dwarf;
use debug::image;
use fmt;
use format::elf;
use fs;
use io;
use os;

def MAX_FRAMES_TOP: size = 16z;
def MAX_FRAMES_BOTTOM: size = 16z;
def MAX_FRAMES: size = MAX_FRAMES_TOP + MAX_FRAMES_BOTTOM;

// Prints a backtrace to the standard error.
export fn backtrace(self: *image::image, frame: stackframe) void = {
	let orig = frame;
	let nframe = 1z;
	for (true; nframe += 1) {
		match (next(frame)) {
		case let next: stackframe =>
			frame = next;
		case done => break;
		};
	};
	frame = orig;

	const st = match (os::fstat(self.fd)) {
	case let st: fs::filestat =>
		yield st;
	case fs::error =>
		yield fs::filestat { mask = 0, ... };
	};

	static let seen: [MAX_FRAMES]uintptr = [0: uintptr...];
	let seen = seen[..0];

	for (let i = 0z; i < nframe; i += 1) {
		if (i < MAX_FRAMES_TOP || i > nframe - MAX_FRAMES_BOTTOM) {
			printframe(self, &seen, &st, frame);
		};
		if (i == MAX_FRAMES_TOP && nframe > MAX_FRAMES) {
			_ = fmt::errorfln("\t({} additional frames omitted)",
				nframe - MAX_FRAMES);
		};

		match (next(frame)) {
		case let next: stackframe =>
			frame = next;
		case done =>
			break;
		};
	};
};

fn printframe(
	self: *image::image,
	seen: *[]uintptr,
	imgstat: *fs::filestat,
	frame: stackframe,
) void = {
	const pc = frame_pc(frame);

	// Try to translate the address
	match (translate(pc: uintptr)) {
	case let ptr: uintptr =>
		pc = ptr;
	case =>
		void;
	};

	const sym = match (symbol_byaddr(self, pc)) {
	case let sym: elf::sym64 =>
		yield sym;
	case =>
		_ = fmt::errorfln("(unknown) [0x{:x}]", pc);
		return;
	};
	const name = match (symbol_name(self, &sym)) {
	case let name: const str =>
		yield name;
	case =>
		_ = fmt::errorfln("(unknown) [0x{:x}]", pc);
		return;
	};

	// Look for DWARF line numbers, if possible
	const (path, line, col) = match (dwarf::addr_to_line(self, pc)) {
	case (void | io::error) =>
		// No line number available, print what we've got
		_ = fmt::errorfln("{}+0x{:x} [0x{:x}]", symname_to_ident(name),
			pc - sym.st_value: uintptr, pc);
		return;
	case let tuple: (const str, uint, uint) =>
		yield tuple;
	};

	_ = fmt::errorf("{}:{}:{} {}+0x{:x} [0x{:x}]",
		path, line, col, symname_to_ident(name),
		pc - sym.st_value: uintptr, pc);

	// Skip context on frames we've already printed
	for (let i = 0z; i < len(seen); i += 1) {
		if (seen[i] == pc) {
			_ = fmt::errorfln(" (already shown)");
			return;
		};
	};
	static append(seen, pc)!;
	_ = fmt::errorln();

	print_context(path, line, col, imgstat.mtime);
};

fn printframe_with_symbol(
	sym: *elf::sym64,
	name: str,
	path: str,
	loc: (uint, uint),
	pc: uintptr,
) void = {
	_ = fmt::errorfln("{}:{}:{} {}+0x{:x} [0x{:x}]",
		path, loc.0, loc.1, symname_to_ident(name),
		pc - sym.st_value: uintptr, pc);
	_ = fmt::errorln();
};
