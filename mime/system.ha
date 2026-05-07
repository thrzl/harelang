// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use bufio;
use encoding::utf8;
use fs;
use io;
use os;
use strings;

@init fn init() void = {
	// Done in a separate function so we can discard errors here
	_ = load_systemdb();
};

fn load_systemdb() (void | fs::error | io::error | utf8::invalid | nomem) = {
	const file = os::open(SYSTEM_DB)?;
	defer io::close(file)!;

	let sc = bufio::newscanner(file);
	defer bufio::finish(&sc);

	for (let line => bufio::scan_line(&sc)?) {
		line = strings::trim(line);
		if (strings::hasprefix(line, "#") || len(line) == 0) {
			continue;
		};

		const (mime, exts) = strings::cut(line, "\t");
		exts = strings::trim(exts);
		if (len(exts) == 0) {
			continue;
		};
		mime = strings::trim(mime);

		mime = strings::dup(mime)?;

		let entry = match (alloc(mimetype { mime = mime, exts = [] })) {
		case let mt: *mimetype =>
			yield mt;
		case nomem =>
			// We intentionally free on the error path here
			// instead of having a `defer if (err)` block above.
			// Once the mimetype is allocated, the mimetype_free
			// function will take care of freeing the duplicated
			// mime string. So freeing both the mimetype and the
			// mime string on error would be a double-free.
			free(mime);
			return nomem;
		};
		let err = false;
		defer if (err) mimetype_free(entry);

		const tok = strings::tokenize(exts, " ");
		for (let ext => strings::next_token(&tok)) {
			ext = match(strings::dup(ext)) {
			case let s: str =>
				yield s;
			case nomem =>
				err = true;
				return nomem;
			};
			match (append(entry.exts, ext)) {
			case void => void;
			case nomem =>
				// This case is similar to the comment above.
				free(ext);
				err = true;
				return nomem;
			};
		};
		match (register_heap(entry)) {
		case void => void;
		case nomem =>
			err = true;
			return nomem;
		};
	};
};

fn register_heap(mime: *mimetype) (void | nomem) = {
	let i = len(heap_db);
	append(heap_db, mime)?;
	for (i < len(heap_db); i += 1) {
		hashtable_insert(heap_db[i])?;
	};
};
