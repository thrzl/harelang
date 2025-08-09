// SPDX-License-Identifier: GPL-3.0-only
// (c) Hare authors <https://harelang.org>

use errors;
use fmt;
use getopt;
use os;
use os::exec;
use path;
use strings;

fn tool(name: str, cmd: *getopt::command) (void | error) = {
	if (len(cmd.args) < 1) {
		getopt::printusage(os::stderr, name, cmd.help)!;
		os::exit(os::status::FAILURE);
	};

	const args: []str = [];
	if (len(cmd.args) > 1) {
		args = cmd.args[1..];
	};

	const toolpaths = os::tryenv("HARE_TOOLPATH", TOOLDIR);
	const paths = strings::tokenize(toolpaths, ":");
	const tool = cmd.args[0];
	const name = fmt::asprintf("hare-{}", tool)!;
	defer free(name);

	for (const segment => strings::next_token(&paths)) {
		const path = path::init(segment)?;
		path::push(&path, name)?;

		const cmd = match (exec::cmd(path::string(&path), args...)) {
		case let cmd: exec::command =>
			yield cmd;
		case errors::noentry =>
			continue;
		case let err: exec::error =>
			return err;
		};

		const argv0 = fmt::asprintf("hare tool {}", tool)!;
		exec::setname(&cmd, argv0)!;
		const err = exec::exec(&cmd);
		fmt::fatalf("exec {}: {}", path::string(&path), exec::strerror(err));
	};

	fmt::fatalf("hare tool {}: tool not found", tool);
};
