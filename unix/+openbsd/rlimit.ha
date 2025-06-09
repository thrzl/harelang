// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use rt;

// A resource limit.
export type limit = rt::rlim_t;

// A [[limit]] representing an unlimited value.
export def INFINITY: limit = rt::RLIM_INFINITY;

// Resources with limited or limitable usage constraints.
//
// Note that OpenBSD does not support the POSIX-standard AS (aka VMEM) limit.
export type resource = enum int {
	// Maximum CPU time (seconds)
	CPU = rt::RLIMIT_CPU,
	// Maximum size of files (bytes)
	FSIZE = rt::RLIMIT_FSIZE,
	// Maximum size of data segment (bytes)
	DATA = rt::RLIMIT_DATA,
	// Maximum size of stack(s) (bytes)
	STACK = rt::RLIMIT_STACK,
	// Maximum size of a core dump (bytes)
	CORE = rt::RLIMIT_CORE,
	// Maximum number of open files
	NOFILE = rt::RLIMIT_NOFILE,

	// Total processes per user ID (Linux)
	NPROC = rt::RLIMIT_NPROC,
	// Maximum size of resident set (bytes, Linux)
	RSS = rt::RLIMIT_RSS,
	// Maximum amount of data "locked" in RAM (bytes, Linux)
	MEMLOCK = rt::RLIMIT_MEMLOCK,
};

// Soft and hard limits for a [[resource]].
export type rlimit = struct {
	soft: limit,
	hard: limit,
};

// Returns the current limits for a [[resource]].
export fn getrlimit(res: resource) rlimit = {
	let rlim = rt::rlimit { ... };
	rt::getrlimit(res, &rlim)!;
	return rlimit {
		soft = rlim.rlim_cur,
		hard = rlim.rlim_max,
	};
};

// Modifies a [[resource]] limit.
export fn setrlimit(res: resource, limit: *rlimit) (void | errors::error) = {
	let rlim = rt::rlimit {
		rlim_cur = limit.soft,
		rlim_max = limit.hard,
	};
	match (rt::setrlimit(res, &rlim)) {
	case let err: rt::errno =>
		return errors::errno(err);
	case void =>
		return;
	};
};
