// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use bytes;

@test fn unread() void = {
	let buf: [4]u8 = [0...];
	let source = teststream_open();

	let un = unreader(&source);
	assert(read(&un, buf)! as size == 4);
	unread(&un, [1, 2])!;
	assert(read(&un, buf)! as size == 4);
	assert(bytes::equal(buf, [1, 2, 0, 0]));
	unread(&un, [3, 4])!;
	unread(&un, [1, 2])!;
	assert(read(&un, buf)! as size == 4);
	assert(bytes::equal(buf, [1, 2, 3, 4]));
};
