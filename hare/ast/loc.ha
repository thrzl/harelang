// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use hare::lex;

// The location of an AST node
export type location = struct {
	// The location of the start of the AST node
	start: lex::location,
	// The location of the end of the AST node
	end: lex::location,
};
