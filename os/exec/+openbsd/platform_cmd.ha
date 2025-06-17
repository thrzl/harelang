// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use path;
use strings;
use types::c;

export type platform_cmd = path::buffer;

fn platform_finish(cmd: *command) void = void;

export type strlist = []nullable *const c::char;

fn free_strlist(l: strlist) void = {
	for (let i = 0z; i < len(l) - 1; i += 1) {
		free(l[i]: *const c::char);
	};
	free(l);
};

export type platform_argv = strlist;

fn platform_newargv(name: str, args: str...) (platform_argv | nomem) = {
	let ok = false;
	let argv: platform_argv = alloc([null...], len(args) + 2z)?;
	defer if (!ok) platform_free_argv(argv);

	argv[0] = c::fromstr(name)?;

	let i = 1z;
	for (let arg .. args) {
		argv[i] = c::fromstr(arg)?;
		i += 1;
	};

	ok = true;
	return argv;
};

fn platform_free_argv(argv: platform_argv) void = free_strlist(argv);

fn platform_setname(cmd: *command, name: str) (void | nomem) = {
	cmd.argv[0] = c::fromstr(name)?;
};

export type platform_env = strlist;

fn platfrom_newenv() platform_env = [];

fn platform_dup_env(env: []str) (platform_env | nomem) = {
	let ok = false;
	let dup: platform_env = [];
	defer if (!ok) platform_free_env(dup);

	for (let e .. env) {
		let centry = c::fromstr(e)?;
		if (append(dup, centry) is nomem) {
			free(centry);
			return nomem;
		};
	};
	append(dup, null)?;

	ok = true;
	return dup;
};

fn platform_free_env(env: platform_env) void = free_strlist(env);

fn platform_setenv(
	cmd: *command,
	key: str,
	value: str
) (void | errors::invalid | nomem) = {
	if (len(cmd.env) == 0) {
		append(cmd.env, null)?;
	};

	let entry = strings::join("=", key, value)?;
	defer free(entry);
	let centry = c::fromstr(entry)?;

	if (insert(cmd.env[len(cmd.env)-1], centry) is nomem) {
		free(centry);
		return nomem;
	};
};

fn platform_unsetenv(cmd: *command, key: str) (void | errors::invalid) = {
	// XXX: This can be a binary search
	for (let i = 0z; i < len(cmd.env) - 1; i += 1) {
		let e = c::tostr(cmd.env[i]: *const c::char)!;
		if (strings::cut(e, "=").0 == key) {
			free(cmd.env[i]);
			delete(cmd.env[i]);
			break;
		};
	};
};
