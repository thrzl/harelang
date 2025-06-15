// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

static assert(size(char) == size(schar));
static assert(size(char) == size(uchar));
static assert(size(char) == 1);
static assert(size(short) == size(ushort));
static assert(size(long) == size(ulong));
static assert(size(longlong) == size(ulonglong));
static assert(size(intmax) == size(uintmax));
static assert(size(intptr) == size(uintptr));
static assert(size(ssize) == size(size));
static assert(size(short) <= size(int));
static assert(size(long) >= 4);
static assert(size(longlong) >= 8);
static assert(size(short) >= size(char));
static assert(size(int) >= size(short));
static assert(size(long) >= size(int));
static assert(size(longlong) >= size(long));

static assert(align(char) == align(schar));
static assert(align(char) == align(uchar));
static assert(align(char) == 1);
static assert(align(short) == align(ushort));
static assert(align(long) == align(ulong));
static assert(align(longlong) == align(ulonglong));
static assert(align(intmax) == align(uintmax));
static assert(align(intptr) == align(uintptr));
static assert(align(ssize) == align(size));

@test fn strings() void = {
	let s = fromstr("hello!")!;
	defer free(s);
	assert(tostr(s)! == "hello!");
	let s = nulstr("hello!\0");
	assert(tostr(s)! == "hello!");
};

@test fn strlen() void = {
	assert(strlen(nulstr("hello!\0")) == 6);
	assert(strlen(nulstr("\0")) == 0);
};

@test fn strnlen() void = {
	assert(strnlen(nulstr("hello!\0"), 10) == 6);
	assert(strnlen(nulstr("hello!\0"), 6) == 6);
	assert(strnlen(nulstr("hello!\0"), 4) == 4);
	assert(strnlen(nulstr("hello!\0"), 0) == 0);
	assert(strnlen(nulstr("\0"), 1) == 0);
	assert(strnlen(null: *const char, 0) == 0);
};

@test fn strcmp() void = {
	assert(strcmp(nulstr("ABC\0"), nulstr("ABC\0")) == 0);
	assert(strcmp(nulstr("ABC\0"), nulstr("AB\0")) > 0);
	assert(strcmp(nulstr("AB\0"), nulstr("ABC\0")) < 0);
	assert(strcmp(nulstr("BCD\0"), nulstr("ABC\0")) > 0);
	assert(strcmp(nulstr("ABC\0"), nulstr("こんにちは\0")) < 0);
	assert(strcmp(nulstr("ABC\0"), nulstr("abc\0")) < 0);
	assert(strcmp(nulstr("\0"), nulstr("\0")) == 0);
};

@test fn strncmp() void = {
	assert(strncmp(nulstr("ABC\0"), nulstr("ABC\0"), 2) == 0);
	assert(strncmp(nulstr("ABC\0"), nulstr("ABC\0"), 3) == 0);
	assert(strncmp(nulstr("ABC\0"), nulstr("ABC\0"), 4) == 0);
	assert(strncmp(nulstr("ABC\0"), nulstr("ABC\0"), 5) == 0);
	assert(strncmp(nulstr("ABC\0"), nulstr("AB\0"), 2) == 0);
	assert(strncmp(nulstr("ABC\0"), nulstr("AB\0"), 3) > 0);
	assert(strncmp(nulstr("AB\0"), nulstr("ABC\0"), 2) == 0);
	assert(strncmp(nulstr("AB\0"), nulstr("ABC\0"), 3) < 0);
	assert(strncmp(nulstr("BCD\0"), nulstr("ABC\0"), 2) > 0);
	assert(strncmp(nulstr("ABC\0"), nulstr("abc\0"), 0) == 0);
	assert(strncmp(nulstr("ABC\0"), nulstr("abc\0"), 1) < 0);
	assert(strncmp(nulstr("\0"), nulstr("\0"), 1) == 0);
	assert(strncmp(unterminatedstr("ABC"), unterminatedstr("ABC"), 3) == 0);
	assert(strncmp(null: *const char, null: *const char, 0) == 0);
};
