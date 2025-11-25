// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use hare::lex;

// A constant declaration.
//
// 	def foo: int = 0;
export type decl_const = struct {
	ident: ident,
	_type: nullable *_type,
	init: *expr,
};

// A global declaration.
//
// 	let foo: int = 0;
// 	const foo: int = 0;
export type decl_global = struct {
	is_const: bool,
	is_threadlocal: bool,
	symbol: str,
	ident: ident,
	_type: nullable *_type,
	init: nullable *expr,
};

// A type declaration.
//
// 	type foo = int;
export type decl_type = struct {
	ident: ident,
	_type: *_type,
};

// Attributes applicable to a function declaration.
export type fndecl_attr = enum {
	NONE,
	FINI,
	INIT,
	TEST,
};

// A function declaration.
//
// fn main() void = void;
export type decl_func = struct {
	symbol: str,
	ident: ident,
	prototype: *_type,
	body: nullable *expr,
	attrs: fndecl_attr,
};

// A Hare declaration.
export type decl = struct {
	exported: bool,
	loc: location,
	decl: (decl_const | decl_global | decl_type | decl_func | assert_expr),

	// Only valid if the lexer has comments enabled
	docs: str,
};

// Frees resources associated with a declaration.
export fn decl_finish(d: decl) void = {
	free(d.docs);
	match (d.decl) {
	case let g: decl_global =>
		free(g.symbol);
		ident_free(g.ident);
		type_finish(g._type);
		free(g._type);
		expr_finish(g.init);
		free(g.init);
	case let t: decl_type =>
		ident_free(t.ident);
		type_finish(t._type);
		free(t._type);
	case let f: decl_func =>
		free(f.symbol);
		ident_free(f.ident);
		type_finish(f.prototype);
		free(f.prototype);
		expr_finish(f.body);
		free(f.body);
	case let c: decl_const =>
		ident_free(c.ident);
		type_finish(c._type);
		free(c._type);
		expr_finish(c.init);
		free(c.init);
	case let e: assert_expr =>
		expr_finish(e.cond);
		free(e.cond);
		expr_finish(e.message);
		free(e.message);
	};
};
