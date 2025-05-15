// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use ascii;
use strings;

const tspecial: str = "()<>@,;:\\/[]?=";
export type type_params = strings::tokenizer;

// A syntax error.
export type syntax = !void;

// Converts an error into a human-friendly string.
export fn strerror(err: syntax) str = "Can't parse Media Type";

// Parses a Media Type, returning a tuple of the content type (e.g.
// "text/plain") and a parameter parser object, or [[syntax]] if the input
// cannot be parsed.
//
// To enumerate the Media Type parameter list, pass the type_params object into
// [[next_param]]. If you do not need the parameter list, you can safely discard
// the object. Note that any format errors following the ";" token will not
// cause [[syntax]] to be returned unless [[next_param]] is used to enumerate
// all of the parameters.
export fn parse(in: str) ((str, type_params) | syntax) = {
	const (mtype, params) = strings::cut(in, ";");
	const (_type, subtype) = strings::cut(mtype, "/");
	typevalid(_type)?;
	typevalid(subtype)?;
	return (mtype, strings::tokenize(params, ";"));
};

// Returns the next parameter as a (key, value) tuple from a [[type_params]]
// object that was prepared via [[parse]], done if there are no remaining
// parameters, and [[syntax]] if a syntax error was encountered.
export fn next_param(in: *type_params) ((str, str) | done | syntax) = {
	const tok = match (strings::next_token(in: *strings::tokenizer)) {
	case let s: str =>
		if (s == "") {
			// empty parameter
			return syntax;
		};
		yield s;
	case done =>
		return done;
	};

	let (key, value) = strings::cut(tok, "=");
	// The RFC does not permit whitespace here, but whitespace is very
	// common in the wild. ¯\_(ツ)_/¯
	key = strings::trim(key);
	value = strings::trim(value);
	if (key == "" || value == "") {
		return syntax;
	};

	if (strings::hasprefix(value, "\"")) {
		value = quoted(value)?;
	};

	return (key, value);
};

fn quoted(in: str) (str | syntax) = {
	// We have only a basic implementation of quoted-string. It has a couple
	// of problems:
	//
	// 1. The RFC does not define it very well
	// 2. The parts of the RFC which are ill-defined are rarely used
	// 3. Implementing quoted-pair would require allocating a new string
	//
	// This implementation should handle most Media Types seen in practice
	// unless they're doing something weird and ill-advised with them.
	in = strings::trim(in, '"');
	if (strings::contains(in, "\\")
			|| strings::contains(in, "\r")
			|| strings::contains(in, "\n")) {
		return syntax;
	};
	return in;
};

fn typevalid(in: str) (void | syntax) = {
	if (in == "") {
		return syntax;
	};
	const miter = strings::iter(in);
	for (let rn => strings::next(&miter)) {
		if (!ascii::valid(rn) || rn == ' '
				|| ascii::iscntrl(rn)
				|| strings::contains(tspecial, rn)) {
			return syntax;
		};
	};
};

@test fn parse() void = {
	const (content_type, _) = parse("text/plain")!;
	assert(content_type == "text/plain");

	const (content_type, _) = parse("image/png")!;
	assert(content_type == "image/png");

	const (content_type, params) = parse("application/svg+xml; charset=utf-8; foo=\"bar baz\"")!;
	assert(content_type == "application/svg+xml");
	const (pk, pv) = next_param(&params)! as (str, str);
	assert(pk == "charset" && pv == "utf-8");
	const (pk, pv) = next_param(&params)! as (str, str);
	assert(pk == "foo" && pv == "bar baz");
	assert(next_param(&params) is done);

	assert(parse("") is syntax);
	assert(parse("hi") is syntax);
	assert(parse("type/") is syntax);
	assert(parse("text/ spaces ") is syntax);
	assert(parse("text/@") is syntax);
	assert(parse("/subtype") is syntax);

	const (content_type, params) = parse("text/plain;charset")!;
	assert(content_type == "text/plain");
	assert(next_param(&params) is syntax);
};
