// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>
// (c) 2023 Nicholas Rodrigues Lordello <n@lordello.net>

use encoding::hex;
use hash;
use strings;

@test fn sha3_224() void = {
	// generated with: printf "$input" | openssl dgst -sha3-224
	const vectors = [
		("",
			"6b4e03423667dbb73b6e15454f0eb1abd4597f9a1b078e3f5b5a6bc7"),
		("abc",
			"e642824c3f8cf24ad09234ee7d3c766fc9a3a5168d0c94ad73b46fdf"),
		("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
			"8a24108b154ada21c9fd5574494479ba5c7e7ab76ef264ead0fcce33"),
		("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu",
			"543e6868e1666c1a643630df77367ae5a62a85070a51c14cbf665cbc"),
		("'UNIX was not designed to stop its users from doing stupid things, as that would also stop them from doing clever things' - Doug Gwyn",
			"a0deb4285eda8d99ddda6b7d5a008f46ac9bfe11db59b661ac11ec7c"),
		("'Life is too short to run proprietary software' - Bdale Garbee",
			"96467d658d16199c208cc352ebf6b4064981aa3aa73a26e9abf94bb6"),
		("'The central enemy of reliability is complexity.' - Geer et al",
			"1290f76a5c2da0c1452ea4b6fd6125de64360a9060c6eb9d0e4c5302"),
	];

	let hash = sha3_224();
	for (const (input, output) .. vectors) {
		hash::reset(&hash);
		hash::write(&hash, strings::toutf8(input));

		let buf: [SZ224]u8 = [0...];
		hash::sum(&hash, buf);

		let digest = hex::encodestr(buf)!;
		defer free(digest);

		assert(digest == output);
	};
};

@test fn sha3_256() void = {
	// generated with: printf "$input" | openssl dgst -sha3-256
	const vectors = [
		("",
			"a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a"),
		("abc",
			"3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532"),
		("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
			"41c0dba2a9d6240849100376a8235e2c82e1b9998a999e21db32dd97496d3376"),
		("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu",
			"916f6061fe879741ca6469b43971dfdb28b1a32dc36cb3254e812be27aad1d18"),
		("'UNIX was not designed to stop its users from doing stupid things, as that would also stop them from doing clever things' - Doug Gwyn",
			"42961be157a1f514a009f77dbfc4d5ee0ef198c5d57d806be5896623912b9bd9"),
		("'Life is too short to run proprietary software' - Bdale Garbee",
			"c5962bb8e4cd3e1c19d20af76041560f041ab76b238bb0167dc7c8b14c794700"),
		("'The central enemy of reliability is complexity.' - Geer et al",
			"f99db0c8f709e363ad44d25e363bfa847f2e97014e66b4e5b0ec36b9044aee25"),
	];

	let hash = sha3_256();
	for (const (input, output) .. vectors) {
		hash::reset(&hash);
		hash::write(&hash, strings::toutf8(input));

		let buf: [SZ256]u8 = [0...];
		hash::sum(&hash, buf);

		let digest = hex::encodestr(buf)!;
		defer free(digest);

		assert(digest == output);
	};
};

@test fn sha3_384() void = {
	// generated with: printf "$input" | openssl dgst -sha3-384
	const vectors = [
		("",
			"0c63a75b845e4f7d01107d852e4c2485c51a50aaaa94fc61995e71bbee983a2ac3713831264adb47fb6bd1e058d5f004"),
		("abc",
			"ec01498288516fc926459f58e2c6ad8df9b473cb0fc08c2596da7cf0e49be4b298d88cea927ac7f539f1edf228376d25"),
		("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
			"991c665755eb3a4b6bbdfb75c78a492e8c56a22c5c4d7e429bfdbc32b9d4ad5aa04a1f076e62fea19eef51acd0657c22"),
		("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu",
			"79407d3b5916b59c3e30b09822974791c313fb9ecc849e406f23592d04f625dc8c709b98b43b3852b337216179aa7fc7"),
		("'UNIX was not designed to stop its users from doing stupid things, as that would also stop them from doing clever things' - Doug Gwyn",
			"513f4df3f60c9e2ca478a475c6466b728198d90796edf3c39585111e14fdce3cd984db40c2b069b3e094eca4e32ddb8b"),
		("'Life is too short to run proprietary software' - Bdale Garbee",
			"8a3963103c95be40f9f1c0693a14dcfe2dff4bdb0785605b8000608f0f05a970e80f5bd548324b24694303bb2e0b3e8f"),
		("'The central enemy of reliability is complexity.' - Geer et al",
			"b05f6eef328a7f521f0dc9bfa2ee4b1e565310e702b98f05b23767d3be7ba5b4cbe4c4eca6b8126250576ff8100161a2"),
	];

	let hash = sha3_384();
	for (const (input, output) .. vectors) {
		hash::reset(&hash);
		hash::write(&hash, strings::toutf8(input));

		let buf: [SZ384]u8 = [0...];
		hash::sum(&hash, buf);

		let digest = hex::encodestr(buf)!;
		defer free(digest);

		assert(digest == output);
	};
};

@test fn sha3_512() void = {
	// generated with: printf "$input" | openssl dgst -sha3-512
	const vectors = [
		("",
			"a69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26"),
		("abc",
			"b751850b1a57168a5693cd924b6b096e08f621827444f70d884f5d0240d2712e10e116e9192af3c91a7ec57647e3934057340b4cf408d5a56592f8274eec53f0"),
		("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
			"04a371e84ecfb5b8b77cb48610fca8182dd457ce6f326a0fd3d7ec2f1e91636dee691fbe0c985302ba1b0d8dc78c086346b533b49c030d99a27daf1139d6e75e"),
		("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu",
			"afebb2ef542e6579c50cad06d2e578f9f8dd6881d7dc824d26360feebf18a4fa73e3261122948efcfd492e74e82e2189ed0fb440d187f382270cb455f21dd185"),
		("'UNIX was not designed to stop its users from doing stupid things, as that would also stop them from doing clever things' - Doug Gwyn",
			"cf36c0b94c70c49bd8a199214e0dd5f9d4599600cb7b23f899467a3be1dfbb13878740532182d7b72db9796d42a7c8f085ee328ae181a564b15624ec4fc68e73"),
		("'Life is too short to run proprietary software' - Bdale Garbee",
			"25d81e23fe6c99cdc7325a83e70744f904b98d2c8d3af75d0ed047451d7465d572fc5ae82cfb0558ab730dbb6c7c898cc6085d5712aa2510a54291c14fddff48"),
		("'The central enemy of reliability is complexity.' - Geer et al",
			"0a017786853e442357139323404b64f62157c92b61253ed25879604166850fd66b41a9374de0c04109d1be81290cf9dc22bf9cfcb0d8e88a16505d86c3235ade"),
	];

	let hash = sha3_512();
	for (const (input, output) .. vectors) {
		hash::reset(&hash);
		hash::write(&hash, strings::toutf8(input));

		let buf: [SZ512]u8 = [0...];
		hash::sum(&hash, buf);

		let digest = hex::encodestr(buf)!;
		defer free(digest);

		assert(digest == output);
	};
};

@test fn sha3_sum_many() void = {
	let buf: [SZ256]u8 = [0...];
	let hash = sha3_256();

	hash::write(&hash, strings::toutf8("a"));
	hash::sum(&hash, buf);
	let digest = hex::encodestr(buf)!;
	defer free(digest);
	// generated with: printf "a" | openssl dgst -sha3-256
	assert(digest ==
		"80084bf2fba02475726feb2cab2d8215eab14bc6bdd8bfb2c8151257032ecd8b");

	hash::write(&hash, strings::toutf8("a"));
	hash::sum(&hash, buf);
	let digest = hex::encodestr(buf)!;
	defer free(digest);
	// generated with: printf "aa" | openssl dgst -sha3-256
	assert(digest ==
		"3d3f583ee3cf8547afab715006ca5e0248da718b7a925201c218d380ad4e6a23");
};
