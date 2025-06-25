// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use io;
use os;
use bufio;

@test fn env() void = {
	let cmd = cmd("env")!;
	setenv(&cmd, "HARETEST", "vval")!;

	const (rd, wr) = pipe();
	addfile(&cmd, os::stdout_file, wr)!;
	let proc = start(&cmd)!;
	io::close(wr)!;

	let found = false;
	let sc = bufio::newscanner(rd);
	for (let l => bufio::scan_line(&sc)!) {
		if (l == "HARETEST=vval") {
			found = true;
			break;
		};
	};

	io::close(rd)!;
	wait(&proc)!;
	assert(found);
};

@test fn args() void = {
	let cmd = cmd("env", "-i", "HARETEST=vval2")!;

	const (rd, wr) = pipe();
	addfile(&cmd, os::stdout_file, wr)!;
	let proc = start(&cmd)!;
	io::close(wr)!;

	let sc = bufio::newscanner(rd);
	for (let l => bufio::scan_line(&sc)!) {
		assert(l == "HARETEST=vval2");
	};
	io::close(rd)!;
	wait(&proc)!;
};

@test fn clearenv() void = {
	let cmd = cmd("env")!;
	clearenv(&cmd);
	setenv(&cmd, "HARETEST", "single")!;

	const (rd, wr) = pipe();
	addfile(&cmd, os::stdout_file, wr)!;
	let proc = start(&cmd)!;
	io::close(wr)!;

	let sc = bufio::newscanner(rd);
	defer io::close(&sc)!;
	for (let l => bufio::scan_line(&sc)!) {
		assert(l == "HARETEST=single");
	};
	io::close(rd)!;
	wait(&proc)!;
};
