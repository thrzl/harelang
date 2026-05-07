// SPDX-License-Identifier: GPL-3.0-only
// (c) Hare authors <https://harelang.org>

use bufio;
use fmt;
use fs;
use hare::module;
use io;
use memio;
use os;
use path;
use sort;
use sort::cmp;
use strings;

let firstline: bool = true;

fn trim_comment(s: str) str = {
	let trimmed = memio::dynamic();
	let tok = strings::tokenize(s, "\n");
	for (let line => strings::next_token(&tok)) {
		memio::concat(&trimmed, strings::trimprefix(line, " "), "\n")!;
	};
	return strings::dup(memio::string(&trimmed)!)!;
};

export type submodule = struct {
	name: str,
	desc: str,
};

export fn submodules(path: str, show_undocumented: bool) ([]submodule | error) = {
	let submodules: []submodule = [];
	let it = os::iter(path)?;
	defer fs::finish(it);
	let pathbuf = path::init(path)!;
	for (let d => module::next(it)?) {
		path::set(&pathbuf, path, d.name, "README")!;

		const file = match (os::open(path::string(&pathbuf))) {
		case let f: io::file =>
			yield f;
		case =>
			if (show_undocumented) {
				append(submodules, submodule {
					name = strings::dup(d.name)!,
					desc = "",
				})!;
			};
			continue;
		};
		defer io::close(file)!;

		let mod = submodule {
			name = strings::dup(d.name)!,
			desc = "",
		};

		const scan = bufio::newscanner(file);
		defer bufio::finish(&scan);

		const prefix = fmt::asprintf("{}: ", d.name)!;
		defer free(prefix);

		match (bufio::scan_line(&scan)) {
		case let s: const str =>
			if (strings::hasprefix(s, prefix)) {
				const desc = strings::sub(s, len(prefix));
				mod.desc = strings::dup(desc)!;
			};
		case => void;
		};

		append(submodules, mod)!;
	};
	sort::sort(submodules, size(submodule), &submodule_cmp)!;
	return submodules;
};

export fn submodules_finish(subs: []submodule) void = {
	for (let sub .. subs) {
		free(sub.name);
		free(sub.desc);
	};
	free(subs);
};

fn submodule_cmp(a: *const opaque, b: *const opaque) int = {
	const a = a: *const submodule;
	const b = b: *const submodule;
	return cmp::strs(&a.name, &b.name);
};

// Trims the cwd from a path if applicable.
export fn cwdpath(path: str) str = {
	static let cwd = "";
	if (cwd == "") {
		cwd = os::getcwd();
	};
	if (strings::hasprefix(path, cwd)) {
		return strings::sub(path, len(cwd) + 1);
	};
	return path;
};
