// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use io;
use rt;
use time;

// Events bitfield for the events and revents field of [[pollfd]].
export type event = enum i16 {
	POLLIN = 0x0001,	// any readable data available
	POLLPRI = 0x0002,	// OOB/Urgent readable data
	POLLOUT = 0x0004,	// file descriptor is writeable
	POLLERR = 0x0008,	// some poll error occured
	POLLHUP = 0x0010,	// file descriptor has "hung up"
	POLLNVAL = 0x0020,	// requested events "invalid"
	POLLRDNORM = 0x0040,	// non-OOB/URG data available
	POLLWRNORM = POLLOUT,	// no write type differentiation
	POLLRDBAND = 0x0080,	// OOB/Urgent readable data
	POLLWRBAND = 0x0100,	// OOB/Urgent data can be written
};

// A single file descriptor to be polled.
export type pollfd = struct {
	fd: io::file,		// which file descriptor to poll
	events: i16,		// events we are interested in
	revents: i16,		// events found on return
};

// Pass this [[time::duration]] to [[poll]] to cause it to wait indefinitely for
// the next event.
// Called INFTIM in DragonFly.
export def INDEF: time::duration = -1;

// Pass this [[time::duration]] to [[poll]] to cause it to return immediately if
// no events are available.
export def NONBLOCK: time::duration = 0;

// Polls for the desired events on a slice of [[pollfd]]s, blocking until an
// event is available, or the timeout expires. Set the timeout to [[INDEF]] to
// block forever, or [[NONBLOCK]] to return immediately if no events are
// available. Returns the number of [[pollfd]] items which have events, i.e.
// those which have revents set to a nonzero value.
export fn poll(
	fds: []pollfd,
	timeout: time::duration = INDEF,
) (uint | error) = {
	let ts = time::duration_to_timespec(timeout);
	let ts = if (timeout == INDEF) null else &ts;
	match (rt::ppoll(fds: *[*]pollfd: *[*]rt::pollfd, len(fds): rt::nfds_t, ts, null)) {
	case let err: rt::errno =>
		return errors::errno(err);
	case let n: int =>
		return n: uint;
	};
};
