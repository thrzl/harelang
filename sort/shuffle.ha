// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use math::random;

// Shuffles a slice using [[math::random::]] to provide pseudo-randomness.
export fn shuffle(items: []opaque, itemsz: size, rand: *random::random) void = {
	if (len(items) <= 1) {
		return;
	};

	const data = items: *[*]u8;
	for (let i = len(items) - 1; i > 0; i -= 1) {
		const j = random::u64n(rand, i: u64): size;
		let a = &data[i * itemsz];
		let b = &data[j * itemsz];
		swap(a, b, itemsz);
	};
};
