// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

use errors;
use rt;
use time;
use unix;

// Requests that [[sig::ALRM]] is delivered to the calling process in (about)
// "sec" seconds. Returns the number of seconds until the previously scheduled
// alarm, or zero if none was scheduled.
export fn alarm(sec: uint) uint = {
	return rt::alarm(sec);
};

// Configures a new signal handler, returning the old details (which can be
// passed to [[restore]] to restore its behavior).
export fn handle(
	signum: sig,
	handler: *handler,
	flags: flag = flag::NONE,
	mask: nullable *sigset = null,
) sigaction = {
	flags |= rt::SA_SIGINFO: flag;
	let mask = match (mask) {
	case null =>
		yield newsigset();
	case let set: *sigset =>
		yield *set;
	};

	let new = rt::sigact {
		sa_sigaction = handler: *fn(_: int,
			_: *rt::siginfo, _: *opaque) void,
		sa_mask = mask,
		sa_flags = flags,
	};
	let old = rt::sigact {
		sa_sigaction = null: *fn(_: int,
			_: *rt::siginfo, _: *opaque) void,
		...
	};
	match (rt::sigaction(signum, &new, &old)) {
	case rt::errno =>
		abort("sigaction failed (invalid signal?)");
	case int => void;
	};
	return old;
};

// Restores previous signal behavior following [[handle]].
export fn restore(signum: sig, action: *sigaction) void = {
	match (rt::sigaction(signum, action: *rt::sigact, null)) {
	case rt::errno =>
		abort("sigaction failed (invalid signal?)");
	case int => void;
	};
};

// Unregisters signal handlers for the specified signal.
export fn reset(signum: sig) void = {
	handle(signum, rt::SIG_DFL: *handler);
};

// Unregisters all signal handlers.
export fn resetall() void = {
	// sig::KILL and sig::STOP deliberately omitted; see sigaction(2)
	reset(sig::HUP);
	reset(sig::INT);
	reset(sig::QUIT);
	reset(sig::ILL);
	reset(sig::TRAP);
	reset(sig::ABRT);
	reset(sig::EMT);
	reset(sig::FPE);
	reset(sig::BUS);
	reset(sig::SEGV);
	reset(sig::SYS);
	reset(sig::PIPE);
	reset(sig::ALRM);
	reset(sig::TERM);
	reset(sig::URG);
	reset(sig::TSTP);
	reset(sig::CONT);
	reset(sig::CHLD);
	reset(sig::TTIN);
	reset(sig::TTOU);
	reset(sig::IO);
	reset(sig::XCPU);
	reset(sig::XFSZ);
	reset(sig::VTALRM);
	reset(sig::PROF);
	reset(sig::WINCH);
	reset(sig::INFO);
	reset(sig::USR1);
	reset(sig::USR2);
	reset(sig::THR);
};

// Prevents given signal from arriving to the current process.
// One common use case is to ignore SIGCHLD to avoid zombie child processes.
export fn ignore(signum: sig) void = {
	handle(signum, rt::SIG_IGN: *handler);
};

// Adds the given list of signals to the process's current signal mask,
// returning the old signal mask. This is a convenience function around
// [[setprocmask]].
export fn block(signals: sig...) sigset = {
	let new = newsigset(signals...);
	return setprocmask(how::BLOCK, &new);
};

// Removes the given list of signals from the process's current signal mask,
// returning the old signal mask. This is a convenience function around
// [[setprocmask]].
export fn unblock(signals: sig...) sigset = {
	let new = newsigset(signals...);
	return setprocmask(how::UNBLOCK, &new);
};

// Sets the process's signal mask, returning the previous mask.
export fn setprocmask(how: how, mask: *sigset) sigset = {
	let old = sigset { ... };
	rt::sigprocmask(how, mask: *rt::sigset, &old)!;
	return old;
};

// Gets the current process's signal mask.
export fn getprocmask() sigset = {
	let old = sigset { ... };
	rt::sigprocmask(how::SETMASK, null, &old)!;
	return old;
};

// Defines the modes of operation for [[setprocmask]].
export type how = enum int {
	// Adds the given set of signals to the current mask.
	BLOCK = rt::SIG_BLOCK,
	// Removes the given set of signals from the current mask.
	UNBLOCK = rt::SIG_UNBLOCK,
	// Sets the process mask to the given set.
	SETMASK = rt::SIG_SETMASK,
};

export type sigaction = rt::sigact;

export type sigset = rt::sigset;

// Creates a new signal set filled in with the provided signals (or empty if
// none are provided).
export fn newsigset(items: sig...) sigset = {
	let set = sigset { ... };
	rt::sigemptyset(&set);
	sigset_add(&set, items...);
	return set;
};

// Sets a [[sigset]] to empty.
export fn sigset_empty(set: *sigset) void = {
	rt::sigemptyset(set: *rt::sigset);
};

// Adds signals to a [[sigset]].
export fn sigset_add(set: *sigset, items: sig...) void = {
	for (let i = 0z; i < len(items); i += 1) {
		rt::sigaddset(set: *rt::sigset, items[i])!;
	};
};

// Removes signals from a [[sigset]].
export fn sigset_del(set: *sigset, items: sig...) void = {
	for (let i = 0z; i < len(items); i += 1) {
		rt::sigdelset(set: *rt::sigset, items[i])!;
	};
};

// Adds all platform-defined signals to a [[sigset]].
export fn sigset_fill(set: *sigset) void = {
	rt::sigfillset(set: *rt::sigset)!;
};

// Returns true if the given signal is a member of this [[sigset]].
export fn sigset_member(set: *sigset, item: sig) bool = {
	return rt::sigismember(set: *rt::sigset, item)!;
};

// Waits for a signal among the given [[sigset]] to be delivered, then returns
// the signal number.
//
// If a signal is received while waiting, [[errors::interrupted]] is returned.
// Most consumers of this function will likely wish to block all signals and
// handle them exclusively through [[wait]] et al, in which case this error
// cannot occur.
//
// See also [[waitinfo]] and [[timedwait]].
export fn wait(set: *sigset) (sig | errors::interrupted) = {
	let signal = 0i;
	match (rt::sigwait(set: *rt::sigset, &signal)) {
	case let err: rt::errno =>
		assert(err == rt::EINTR);
		return errors::interrupted;
	case void =>
		return signal: sig;
	};
};

// Waits for a signal among the given [[sigset]] to be delivered, then returns
// the corresponding [[siginfo]] data.
//
// See notes on [[wait]] regarding the [[errors::interrupted]] case.
//
// This function is designed to provide the portable subset of the semantics of
// sigwaitinfo(3) as defined by POSIX.1-2008. To access the complete siginfo_t
// structure provided by the underlying platform, use [[rt::sigwaitinfo]] and
// [[rt::siginfo_t]] directly.
//
// Note that this function is not supported on OpenBSD.
export fn waitinfo(set: *sigset) (siginfo | errors::interrupted) = {
	let info = rt::siginfo {
		si_addr = null: *opaque,
		si_value = rt::sigval { ... },
		...
	};
	match (rt::sigwaitinfo(set: *rt::sigset, &info)) {
	case let err: rt::errno =>
		assert(err == rt::EINTR);
		return errors::interrupted;
	case int =>
		return *(&info: *siginfo);
	};
};

// Waits for a signal among the given [[sigset]] to be delivered, then returns
// the corresponding [[siginfo]] data.
//
// Returns a [[siginfo]] if a signal is successfully processed through this
// function, or [[errors::again]] if the timeout expired. See notes on [[wait]]
// regarding the [[errors::interrupted]] case.
//
// This function is designed to provide the portable subset of the semantics of
// sigtimedwait(3) as defined by POSIX.1-2008. To access the complete siginfo_t
// structure provided by the underlying platform, use [[rt::sigtimedwait]] and
// [[rt::siginfo_t]] directly.
//
// Note that this function is not supported on OpenBSD.
export fn timedwait(
	set: *sigset,
	timeout: time::duration,
) (siginfo | errors::interrupted | errors::again) = {
	let info = rt::siginfo {
		si_addr = null: *opaque,
		si_value = rt::sigval { ... },
		...
	};
	let to = time::duration_to_timeval(timeout);
	match (rt::sigwaitinfo(set: *rt::sigset, &info)) {
	case let err: rt::errno =>
		switch (err) {
		case rt::EINTR =>
			return errors::interrupted;
		case rt::EAGAIN =>
			return errors::again;
		case => abort();
		};
	case int =>
		return *(&info: *siginfo);
	};
};

// Provides additional information about signal deliveries. Only the members
// defined by POSIX are available here; cast to [[rt::siginfo]] to access
// non-portable members.
export type siginfo = union {
	struct {
		// The signal number being delivered.
		signo: sig,
		// The errno, if any, associated with this signal. See
		// [[errors::errno]] to convert to a Hare-native error.
		errno: rt::errno,
		// The signal code, if any.
		code: code,
		// Process ID of the sender.
		pid: unix::pid,
		// Real user ID of the sending process.
		uid: unix::uid,
		// Exit value or signal.
		status: int,
		// Address of the faulting instruction.
		addr: *opaque,
	},
	// Pads the structure out to the length used by the kernel; do not use.
	_si_pad: [128 - 3 * size(int)]u8,
};

// A code indicating why a signal was sent.
export type code = enum int {
	USER = 0, // Sent by kill(2)
	QUEUE = -1, // Sent by sigqueue(2)
	TIMER = -2, // Generated by expiration of a timer (timer_settime(2))
	ASYNCIO = -3, // Generated by completion of an asynchronous I/O signal
	MESQ = -4, // Generated by arrival of a message on an empty queue

	ILLOPC = 1, // sig::ILL: Illegal opcode
	ILLOPN = 2, // sig::ILL: Illegal operand
	ILLADR = 3, // sig::ILL: Illegal addressing mode
	ILLTRP = 4, // sig::ILL: Illegal trap
	PRVOPC = 5, // sig::ILL: Privileged opcode
	PRVREG = 6, // sig::ILL: Privileged register
	COPROC = 7, // sig::ILL: Coprocessor error
	BADSTK = 8, // sig::ILL: Internal stack error

	INTOVF = 1, // sig::FPE: Integer overflow
	INTDIV = 2, // sig::FPE: Integer divide by zero
	FLTDIV = 3, // sig::FPE: Floating-point divide by zero
	FLTOVF = 4, // sig::FPE: Floating-point overflow
	FLTUND = 5, // sig::FPE: Floating-point underflow
	FLTRES = 6, // sig::FPE: Floating-point inexact result
	FLTINV = 7, // sig::FPE: Invalid floating-point operation
	FLTSUB = 8, // sig::FPE: Subscript out of range

	MAPERR = 1, // sig::SEGV: Address not mapped to object
	ACCERR = 2, // sig::SEGV: Invalid permissions for mapped object

	ADRALN = 1, // sig::BUS: Invalid address alignment
	ADRERR = 2, // sig::BUS: Nonexistent physical address
	OBJERR = 3, // sig::BUS: Object-specific hardware error

	BRKPT = 1, // sig::TRAP: Process breakpoint
	TRACE = 2, // sig::TRAP: Process trace trap

	EXITED = 1, // sig::CHLD: Child has exited
	KILLED = 2, // sig::CHLD: Child terminated abnormally without a core file
	DUMPED = 3, // sig::CHLD: Child terminated abnormally with a core file
	TRAPPED = 4, // sig::CHLD: Traced child has trapped
	STOPPED = 5, // sig::CHLD: Child has stopped
	CONTINUED = 6, // sig::CHLD: Stopped child has continued

	IN = 1, // sig::IO: Data input available
	OUT = 2, // sig::IO: Output buffers available
	MSG = 3, // sig::IO: Input message available
	ERR = 4, // sig::IO: I/O error
	PRI = 5, // sig::IO: High priority input available
	HUP = 6, // sig::IO: Device disconnected
};

// Flags used to configure the behavior of a signal handler.
export type flag = enum int {
	NONE = 0,
	// For use with sig::CHLD. Prevents notifications when child processes
	// stop (e.g. via sig::STOP) or resume (i.e. sig::CONT).
	NOCLDSTOP = rt::SA_NOCLDSTOP,
	// For use with sig::CHLD. Do not transform children into zombies when
	// they terminate. Note that POSIX leaves the delivery of sig::CHLD
	// unspecified when this flag is present; some systems will still
	// deliver a signal and others may not.
	NOCLDWAIT = rt::SA_NOCLDWAIT,
	// Uses an alternate stack when handling this signal. See
	// [[setaltstack]] and [[getaltstack]] for details.
	ONSTACK = rt::SA_ONSTACK,
	// Do not add the signal to the signal mask while executing the signal
	// handler. This can cause the same signal to be delivered again during
	// the execution of the signal handler.
	NODEFER = rt::SA_NODEFER,
	// Restore the signal handler to the default behavior upon entering the
	// signal handler.
	RESETHAND = rt::SA_RESETHAND,
	// Makes certain system calls restartable across signals. See signal(7)
	// or similar documentation for your local system for details.
	RESTART = rt::SA_RESTART,
};

// All possible signals.
export type sig = enum int {
	HUP = rt::SIGHUP, // Hangup.
	INT = rt::SIGINT, // Terminal interrupt.
	QUIT = rt::SIGQUIT, // Terminal quit.
	ILL = rt::SIGILL, // Illegal instruction.
	TRAP = rt::SIGTRAP, // Trace/breakpoint trap.
	ABRT = rt::SIGABRT, // Process abort.
	IOT = rt::SIGIOT, // Synonym for ABRT, provided for compatibility.
	EMT = rt::SIGEMT, // Emulate instruction executed.
	FPE = rt::SIGFPE, // Erroneous arithmetic operation.
	KILL = rt::SIGKILL, // Kill (cannot be caught or ignored).
	BUS = rt::SIGBUS, // Access to an undefined portion of a memory object.
	SEGV = rt::SIGSEGV, // Invalid memory reference.
	SYS = rt::SIGSYS, // Bad system call.
	PIPE = rt::SIGPIPE, // Write on a pipe with no one to read it.
	ALRM = rt::SIGALRM, // Alarm clock.
	TERM = rt::SIGTERM, // Termination.
	URG = rt::SIGURG, // High bandwidth data is available at a socket.
	STOP = rt::SIGSTOP, // Stop executing (cannot be caught or ignored).
	TSTP = rt::SIGTSTP, // Terminal stop.
	CONT = rt::SIGCONT, // Continue executing, if stopped.
	CHLD = rt::SIGCHLD, // Child process terminated, stopped, or continued.
	TTIN = rt::SIGTTIN, // Background process attempting read.
	TTOU = rt::SIGTTOU, // Background process attempting write.
	IO = rt::SIGIO, // I/O now possible.
	XCPU = rt::SIGXCPU, // CPU time limit exceeded.
	XFSZ = rt::SIGXFSZ, // File size limit exceeded.
	VTALRM = rt::SIGVTALRM, // Virtual timer expired.
	PROF = rt::SIGPROF, // Profiling timer expired.
	WINCH = rt::SIGWINCH, // Window resize.
	INFO = rt::SIGINFO, // Status request from keyboard.
	USR1 = rt::SIGUSR1, // User-defined signal 1.
	USR2 = rt::SIGUSR2, // User-defined signal 2.
	THR = rt::SIGTHR, // Thread interrupt.
};

// Returns the human friendly name of a given signal.
export fn signame(sig: sig) const str = {
	switch (sig) {
	case sig::HUP =>
		return "SIGHUP";
	case sig::INT =>
		return "SIGINT";
	case sig::QUIT =>
		return "SIGQUIT";
	case sig::ILL =>
		return "SIGILL";
	case sig::TRAP =>
		return "SIGTRAP";
	case sig::ABRT =>
		return "SIGABRT";
	case sig::EMT =>
		return "SIGEMT";
	case sig::FPE =>
		return "SIGFPE";
	case sig::KILL =>
		return "SIGKILL";
	case sig::BUS =>
		return "SIGBUS";
	case sig::SEGV =>
		return "SIGSEGV";
	case sig::SYS =>
		return "SIGSYS";
	case sig::PIPE =>
		return "SIGPIPE";
	case sig::ALRM =>
		return "SIGALRM";
	case sig::TERM =>
		return "SIGTERM";
	case sig::URG =>
		return "SIGURG";
	case sig::STOP =>
		return "SIGSTOP";
	case sig::TSTP =>
		return "SIGTSTP";
	case sig::CONT =>
		return "SIGCONT";
	case sig::CHLD =>
		return "SIGCHLD";
	case sig::TTIN =>
		return "SIGTTIN";
	case sig::TTOU =>
		return "SIGTTOU";
	case sig::IO =>
		return "SIGIO";
	case sig::XCPU =>
		return "SIGXCPU";
	case sig::XFSZ =>
		return "SIGXFSZ";
	case sig::VTALRM =>
		return "SIGVTALRM";
	case sig::PROF =>
		return "SIGPROF";
	case sig::WINCH =>
		return "SIGWINCH";
	case sig::INFO =>
		return "SIGINFO";
	case sig::USR1 =>
		return "SIGUSR1";
	case sig::USR2 =>
		return "SIGUSR2";
	case sig::THR =>
		return "SIGTHR";
	};
};
