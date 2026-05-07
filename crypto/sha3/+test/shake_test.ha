// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>
// (c) 2023 Nicholas Rodrigues Lordello <n@lordello.net>

use bytes;
use encoding::hex;
use errors;
use io;
use strings;

@test fn shake128() void = {
	// generated with: printf "$input" | openssl dgst -shake128 -xoflen 100
	const vectors = [
		("",
			"7f9c2ba4e88f827d616045507605853ed73b8093f6efbc88eb1a6eacfa66ef263cb1eea988004b93103cfb0aeefd2a686e01fa4a58e8a3639ca8a1e3f9ae57e235b8cc873c23dc62b8d260169afa2f75ab916a58d974918835d25e6a435085b2badfd6df"),
		("abc",
			"5881092dd818bf5cf8a3ddb793fbcba74097d5c526a6d35f97b83351940f2cc844c50af32acd3f2cdd066568706f509bc1bdde58295dae3f891a9a0fca5783789a41f8611214ce612394df286a62d1a2252aa94db9c538956c717dc2bed4f232a0294c85"),
		("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
			"1a96182b50fb8c7e74e0a707788f55e98209b8d91fade8f32f8dd5cff7bf21f54ee5f19550825a6e070030519e944263ac1c6765287065621f9fcb3201723e3223b63a46c2938aa953ba8401d0ea77b8d26490775566407b95673c0f4cc1ce9fd966148d"),
		("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu",
			"7b6df6ff181173b6d7898d7ff63fb07b7c237daf471a5ae5602adbccef9ccf4b37e06b4a3543164ffbe0d0557c02f9b25ad434005526d88ca04a6094b93ee57a55d5ea66e744bd391f8f52baf4e031d9e60e5ca32a0ed162bb89fc908097984548796652"),
	];

	for (const (input, output) .. vectors) {
		let xof = shake128();
		io::write(&xof, strings::toutf8(input))!;

		let buf: [100]u8 = [0...];
		io::read(&xof, buf)!;

		let digest = hex::encodestr(buf)!;
		defer free(digest);

		assert(digest == output);
	};
};

@test fn shake256() void = {
	// generated with: printf "$input" | openssl dgst -shake256 -xoflen 100
	const vectors = [
		("",
			"46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762fd75dc4ddd8c0f200cb05019d67b592f6fc821c49479ab48640292eacb3b7c4be141e96616fb13957692cc7edd0b45ae3dc07223c8e92937bef84bc0eab862853349ec755"),
		("abc",
			"483366601360a8771c6863080cc4114d8db44530f8f1e1ee4f94ea37e78b5739d5a15bef186a5386c75744c0527e1faa9f8726e462a12a4feb06bd8801e751e41385141204f329979fd3047a13c5657724ada64d2470157b3cdc288620944d78dbcddbd9"),
		("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
			"4d8c2dd2435a0128eefbb8c36f6f87133a7911e18d979ee1ae6be5d4fd2e332940d8688a4e6a59aa8060f1f9bc996c05aca3c696a8b66279dc672c740bb224ec37a92b65db0539c0203455f51d97cce4cfc49127d7260afc673af208baf19be21233f3de"),
		("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu",
			"98be04516c04cc73593fef3ed0352ea9f6443942d6950e29a372a681c3deaf4535423709b02843948684e029010badcc0acd8303fc85fdad3eabf4f78cae165635f57afd28810fc22abf63df55c5ead450fdfb64209010e982102aa0b5f0a4b4753b53eb"),
	];

	for (const (input, output) .. vectors) {
		let xof = shake256();
		io::write(&xof, strings::toutf8(input))!;

		let buf: [100]u8 = [0...];
		io::read(&xof, buf)!;

		let digest = hex::encodestr(buf)!;
		defer free(digest);

		assert(digest == output);
	};
};

@test fn shake_dup() void = {
	let xof = shake128();
	io::write(&xof, strings::toutf8("hello "))!;

	let dup = xof;

	io::write(&xof, strings::toutf8("hare!"))!;

	let buf: [32]u8 = [0...];
	io::read(&xof, buf)!;

	assert(io::write(&xof, []) is errors::unsupported);

	io::write(&dup, strings::toutf8("h"))!;
	io::write(&dup, strings::toutf8("a"))!;
	io::write(&dup, strings::toutf8("r"))!;
	io::write(&dup, strings::toutf8("e"))!;
	io::write(&dup, strings::toutf8("!"))!;

	io::read(&dup, [])!;
	assert(io::write(&dup, []) is errors::unsupported);

	let dup2 = dup;
	assert(io::write(&dup2, []) is errors::unsupported);

	for (let b .. buf) {
		let byte = [0u8];
		io::read(&dup, byte[..])!;
		assert(byte[0] == b);
	};

	let buf2: [32]u8 = [0...];
	io::read(&dup2, buf2)!;
	assert(bytes::equal(buf, buf2));
};
