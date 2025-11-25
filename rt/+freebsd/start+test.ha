// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

@symbol("__test_main") fn test_main() size;

@symbol("__init_array_start") const init_start: [*]*fn() void;
@symbol("__init_array_end") const init_end: [*]*fn() void;
@symbol("__fini_array_start") const fini_start: [*]*fn() void;
@symbol("__fini_array_end") const fini_end: [*]*fn() void;

export fn start_ha() never = {
	init();
	const nfail = test_main();
	fini();
	exit(if (nfail > 0) 1 else 0);
};
