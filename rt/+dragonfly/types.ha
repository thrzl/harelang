// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

export type time_t = i64;
export type suseconds_t = i64;
export type dev_t = u32;
export type ino_t = u64;
export type nlink_t = u32;
export type id_t = i64; // general id, can hold gid/pid/uid_t
export type pid_t = i32;
export type uid_t = u32;
export type gid_t = u32;
export type off_t = i64;
export type blkcnt_t = i64;
export type blksize_t = i64;
export type fflags_t = u32;
export type mode_t = u16;
export type nfds_t = uint;
export type rlim_t = i64;

export type intptr_t = i64;
export type c_long = i64;

export def NGROUPS_MAX: size = 16;
export def NSIG: int = 64;

export type sigset = struct {
	__bits: [4]uint,
};

// Named "struct sigaction" in DragonFly.
export type sigact = struct {
	union {
		sa_handler: nullable *fn (_: int) void,
		sa_sigaction: nullable *fn (_: int,
			_: *siginfo, _: *opaque) void,
	},
	sa_flags: int,
	sa_mask: sigset,
};

export type kevent_t = struct {
	ident: uintptr,
	filter: i16,
	flags: u16,
	fflags: uint,
	data: intptr_t,
	udata: *opaque,
};

export type sigval = union {
	sival_int: int,
	sival_ptr: *opaque,
};

export type stack_t = struct {
	ss_sp: *opaque,
	ss_size: size,
	ss_flags: int,
};

export type pollfd = struct {
	fd: int,
	events: i16,
	revents: i16,
};

export type timespec = struct {
	tv_sec: time_t, // seconds
	tv_nsec: c_long, // and nanoseconds
};

export def UTIME_OMIT = -2;

export type timeval = struct {
	tv_sec: time_t,
	tv_usec: suseconds_t,
};

//
// Advisory file segment locking data type -
// information passed to system by user
//
// (struct flock in DragonFly)
//
export type st_flock = struct {
	l_start: off_t,			// starting offset
	l_len: off_t,			// len = 0 means until end of file
	l_pid: pid_t,			// lock owner
	l_type: i16,			// lock type: read/write, etc.
	l_whence: i16,			// type of l_start
};

export type st = struct {
	ino: ino_t,
	nlink: nlink_t,
	dev: dev_t,
	mode: mode_t,
	uid: uid_t,
	gid: gid_t,
	rdev: dev_t,
	atime: timespec,
	mtime: timespec,
	ctime: timespec,
	sz: off_t,
	blocks: blkcnt_t,
	blksz: blksize_t,
	flags: fflags_t,
};

export type dragonfly_stat = struct {
	st_ino: ino_t,			// inode's number
	st_nlink: nlink_t,		// number of hard links
	st_dev: dev_t,			// inode's device
	st_mode: mode_t,		// inode protection mode
	_: u16,				// padding
	st_uid: uid_t,			// user ID of the file's owner
	st_gid: gid_t,			// group ID of the file's owner
	st_rdev: dev_t,			// device type
	st_atim: timespec,		// time of last access
	st_mtim: timespec,		// time of last modification
	st_ctim: timespec,		// time of last file status change
	st_size: off_t,			// file size, in bytes
	st_blocks: blkcnt_t,		// blocks allocated for file
	__old_st_blksize: u32,		// old ABI compatibility only
	st_flags: u32,			// user defined flags for file
	st_gen: u32,			// file generation number
	st_lspare: i32,
	st_blksize: blksize_t,		// optimal blocksize for I/O
	st_qspare2: i64,
};

export type dragonfly_dirent = struct {
	d_fileno: ino_t,		// file number of entry
	d_namlen: u16,			// strlen(d_name)
	d_type: u8,			// file type
	_: u8,				// padding, reserved
	_: u32,				// reserved
	d_name: [255+1]u8,		// name, NUL-terminated
};

// offset of "d_name" field + namelen + padding to 8 bytes boundary
export fn DIRENT_RECLEN(namelen: u64) u64 = {
	const offsetof_d_name: u64 = 16;
	return ((offsetof_d_name + (namelen) + 1 + 7) & ~7u64);
};

export type iovec = struct {
	iov_base: nullable *opaque,	// Base address
	iov_len: size			// Length
};

export type winsize = struct {
	ws_row: u16,			// rows, in characters
	ws_col: u16,			// columns, in characters
	ws_xpixel: u16,			// horizontal size, pixels
	ws_ypixel: u16,			// vertical size, pixels
};

export type termios = struct {
	c_iflag: tcflag,		// input flags
	c_oflag: tcflag,		// output flags
	c_cflag: tcflag,		// control flags
	c_lflag: tcflag,		// local flags
	c_cc: [NCCS]cc,			// control chars
	c_ispeed: speed,		// input speed
	c_ospeed: speed,		// output speed
};

export def NCCS: size = 20;

export type speed = enum uint {
	B0	= 0,
	B50	= 50,
	B75	= 75,
	B110	= 110,
	B134	= 134,
	B150	= 150,
	B200	= 200,
	B300	= 300,
	B600	= 600,
	B1200	= 1200,
	B1800	= 1800,
	B2400	= 2400,
	B4800	= 4800,
	B9600	= 9600,
	B19200	= 19200,
	B38400	= 38400,

	B7200	= 7200,
	B14400	= 14400,
	B28800	= 28800,
	B57600	= 57600,
	B76800	= 76800,
	B115200	= 115200,
	B230400	= 230400,
	B460800	= 460800,
	B921600	= 921600,
	EXTA	= 19200,
	EXTB	= 38400,
};

export type tcflag = enum uint {
	// Input flags - software input processing
	// (c_iflag bits)
	IGNBRK  = 0x00000001,		// ignore BREAK condition
	BRKINT  = 0x00000002,		// map BREAK to SIGINTR
	IGNPAR  = 0x00000004,		// ignore (discard) parity errors
	PARMRK  = 0x00000008,		// mark parity and framing errors
	INPCK   = 0x00000010,		// enable checking of parity errors
	ISTRIP  = 0x00000020,		// strip 8th bit off chars
	INLCR   = 0x00000040,		// map NL into CR
	IGNCR   = 0x00000080,		// ignore CR
	ICRNL   = 0x00000100,		// map CR to NL (ala CRMOD)
	IXON    = 0x00000200,		// enable output flow control
	IXOFF   = 0x00000400,		// enable input flow control
	IXANY   = 0x00000800,		// any char will restart after stop
	IMAXBEL = 0x00002000,		// ring bell on input queue full

	// Output flags - software output processing
	// (c_oflag bits)
	OPOST  = 0x00000001,		// enable following output processing
	ONLCR  = 0x00000002,		// map NL to CR-NL (ala CRMOD)
	TABDLY = 0x00000004,		// tab delay mask
	TAB0   = 0x00000000,		// no tab delay and expansion
	TAB3   = 0x00000004,		// expand tabs to spaces
	ONOEOT = 0x00000008,		// discard EOT's (^D) on output
	OCRNL  = 0x00000010,		// map CR to NL on output
	ONOCR  = 0x00000020,		// no CR output at column 0
	ONLRET = 0x00000040,		// NL performs CR function

	// Control flags - hardware control of terminal
	// (c_cflag bits)
	CIGNORE    = 0x00000001,	// ignore control flags
	CSIZE      = 0x00000300,	// character size mask
	CS5        = 0x00000000,	// 5 bits (pseudo)
	CS6        = 0x00000100,	// 6 bits
	CS7        = 0x00000200,	// 7 bits
	CS8        = 0x00000300,	// 8 bits
	CSTOPB     = 0x00000400,	// send 2 stop bits
	CREAD      = 0x00000800,	// enable receiver
	PARENB     = 0x00001000,	// parity enable
	PARODD     = 0x00002000,	// odd parity, else even
	HUPCL      = 0x00004000,	// hang up on last close
	CLOCAL     = 0x00008000,	// ignore modem status lines
	CCTS_OFLOW = 0x00010000,	// CTS flow control of output
	CRTS_IFLOW = 0x00020000,	// RTS flow control of input
	CRTSCTS    = (CCTS_OFLOW | CRTS_IFLOW),
	CDTR_IFLOW = 0x00040000,	// DTR flow control of input
	CDSR_OFLOW = 0x00080000,	// DSR flow control of output
	CCAR_OFLOW = 0x00100000,	// DCD flow control of output

	// "Local" flags - dumping ground for other state
	// (c_lflag bits)
	ECHOKE     = 0x00000001,	// visual erase for line kill
	ECHOE      = 0x00000002,	// visual erase chars
	ECHOK      = 0x00000004,	// echo NL after line kill
	ECHO       = 0x00000008,	// enable echoing
	ECHONL     = 0x00000010,	// echo NL even if ECHO is off
	ECHOPRT    = 0x00000020,	// visual erase mode for hardcopy
	ECHOCTL    = 0x00000040,	// echo control chars as ^(Char)
	ISIG       = 0x00000080,	// enable signals INTR, QUIT, [D]SUSP
	ICANON     = 0x00000100,	// canonicalize input lines
	ALTWERASE  = 0x00000200,	// use alternate WERASE algorithm
	IEXTEN     = 0x00000400,	// enable DISCARD and LNEXT
	EXTPROC    = 0x00000800,	// external processing
	TOSTOP     = 0x00400000,	// stop background jobs from output
	FLUSHO     = 0x00800000,	// output being flushed (state)
	NOKERNINFO = 0x02000000,	// no kernel output from VSTATUS
	PENDIN     = 0x20000000,	// XXX: retype pending input (state)
	NOFLSH     = 0x80000000,	// don't flush after interrupt
};

export type cc = enum u8 {
	VEOF      = 0,
	VEOL      = 1,
	VEOL2     = 2,
	VERASE    = 3,
	VWERASE   = 4,
	VKILL     = 5,
	VREPRINT  = 6,
	VERASE2   = 7,
	VINTR     = 8,
	VQUIT     = 9,
	VSUSP     = 10,
	VDSUSP    = 11,
	VSTART    = 12,
	VSTOP     = 13,
	VLNEXT    = 14,
	VDISCARD  = 15,
	VMIN      = 16,
	VTIME     = 17,
	VSTATUS   = 18,
	VCHECKPT  = 19,
};


export def TIOCGWINSZ: u64 = 0x40087468;	// get window size
export def TIOCSWINSZ: u64 = 0x80087467;	// set window size
export def TIOCGETA: u64 = 0x402c7413;		// get termios struct
export def TIOCSETA: u64 = 0x802c7414;		// set termios struct
export def TIOCISPTMASTER: u64 = 0x20007455;	// is pty master
export def TIOCSPGRP: u64 = 0x80047476;		// set pgrp on tty
export def FIODNAME: u64 = 0x80106678;		// get name of device on that fildesc

// argument for ioctl FIODNAME
export type fiodname_args = struct {
	name: *opaque,
        length: uint,
};

export type rusage = struct {
	ru_utime: timeval,	// user time used
	ru_stime: timeval,	// system time used
	ru_maxrss: i64,		// max resident set size
	ru_ixrss: i64,		// integral shared memory size
	ru_idrss: i64,		// integral unshared data size
	ru_isrss: i64,		// integral unshared stack size
	ru_minflt: i64,		// page reclaims
	ru_majflt: i64,		// page faults
	ru_nswap: i64,		// swaps
	ru_inblock: i64,	// block input operations
	ru_oublock: i64,	// block output operations
	ru_msgsnd: i64,		// messages sent
	ru_msgrcv: i64,		// messages received
	ru_nsignals: i64,	// signals received
	ru_nvcsw: i64,		// voluntary context switches
	ru_nivcsw: i64,		// involuntary context switches
};

export def DT_UNKNOWN: u8 = 0;
export def DT_FIFO: u8 = 1;
export def DT_CHR: u8 = 2;
export def DT_DIR: u8 = 4;
export def DT_BLK: u8 = 6;
export def DT_REG: u8 = 8;
export def DT_LNK: u8 = 10;
export def DT_SOCK: u8 = 12;
export def DT_WHT: u8 = 14;
export def DT_DBF: u8 = 15;	// database record file

export def O_RDONLY: int   = 0x0000;	// open for reading only
export def O_WRONLY: int   = 0x0001;	// open for writing only
export def O_RDWR: int     = 0x0002;	// open for reading and writing
export def O_ACCMODE: int  = 0x0003;	// mask for above modes
export def O_NONBLOCK: int = 0x0004;	// no delay
export def O_APPEND: int   = 0x0008;	// set append mode
export def O_SHLOCK: int   = 0x0010;	// open with shared file lock
export def O_EXLOCK: int   = 0x0020;	// open with exclusive file lock
export def O_ASYNC: int    = 0x0040;	// signal pgrp when data ready
export def O_FSYNC: int    = 0x0080;	// synchronous writes
export def O_SYNC: int     = 0x0080;	// same as O_FSYNC, but POSIX
export def O_NOFOLLOW: int = 0x0100;	// don't follow symlinks
export def O_CREAT: int    = 0x0200;	// create if nonexistent
export def O_TRUNC: int    = 0x0400;	// truncate to zero length
export def O_EXCL: int     = 0x0800;	// error if already exists
export def O_NOCTTY: int   = 0x8000;	// don't assign controlling terminal

export def O_DIRECT: int  = 0x00010000;	// attempt to bypass the buffer cache
export def O_CLOEXEC: int = 0x00020000;	// atomically set FD_CLOEXEC

export def O_FBLOCKING: int    = 0x00040000; // force blocking I/O
export def O_FNONBLOCKING: int = 0x00080000; // force non-blocking I/O
export def O_FAPPEND: int =      0x00100000; // force append mode for write
export def O_FOFFSET: int =      0x00200000; // force append mode for write
export def O_FSYNCWRITE: int =   0x00400000; // force synchronous write
export def O_FASYNCWRITE: int =  0x00800000; // force asynchronous write
export def O_CLOFORK: int =	 0x01000000; // atomically set FD_CLOFORK
export def O_DIRECTORY: int =	 0x08000000; // error if not a directory

export def AT_FDCWD: int = -328243; // 0xFFFA_FDCD;
export def AT_SYMLINK_NOFOLLOW: int = 1;
export def AT_REMOVEDIR: int = 2;
export def AT_EACCESS: int = 4;
export def AT_SYMLINK_FOLLOW: int = 8;

export def S_IFMT: mode_t =  0o170000;	// type of file mask
export def S_IFIFO: mode_t = 0o010000;	// named pipe (fifo)
export def S_IFCHR: mode_t = 0o020000;	// character special
export def S_IFDIR: mode_t = 0o040000;	// directory
export def S_IFBLK: mode_t = 0o060000;	// block special
export def S_IFREG: mode_t = 0o100000;	// regular
export def S_IFLNK: mode_t = 0o120000;	// symbolic link
export def S_IFSOCK: mode_t = 0o140000;	// socket
export def S_ISVTX: mode_t = 0o0001000;	// save swapped text even after use

export def MAP_SHARED: uint = 0x0001;	// share changes
export def MAP_PRIVATE: uint = 0x0002;	// changes are private
export def MAP_FIXED: uint = 0x0010;	// map addr must be exactly as requested

export def MAP_INHERIT: uint = 0x0080;	// region is retained after exec
export def MAP_HASSEMAPHORE: uint = 0x0200; // region may contain semaphores
export def MAP_STACK: uint = 0x0400;	// region grows down, like a stack
export def MAP_NOSYNC: uint = 0x0800;	// page to but do not sync underlying file

export def MAP_FILE: uint = 0x0000;	// map from file (default)
export def MAP_ANON: uint = 0x1000;	// allocated from memory, swap space
export def MAP_VPAGETABLE: uint = 0x2000;// manage with virtualized page table


export def MAP_TRYFIXED: uint =	0x00010000; // attempt hint address, even within heap
export def MAP_NOCORE: uint = 0x00020000; // dont include these pages in a coredump
export def MAP_SIZEALIGN: uint = 0x00040000; // size is also an alignment requirement
export def MAP_32BIT: uint = 0x00080000; // allocate from 32-bit addr space only

export def PROT_NONE: uint = 0x00;	// no permissions
export def PROT_READ: uint = 0x01;	// pages can be read
export def PROT_WRITE: uint = 0x02;	// pages can be written
export def PROT_EXEC: uint = 0x04;	// pages can be executed

//
// sys/signal.h
//

export def SIGHUP: int = 1;		// hangup
export def SIGINT: int = 2;		// interrupt
export def SIGQUIT: int = 3;		// quit
export def SIGILL: int = 4;		// illegal instr. (not reset when caught)
export def SIGTRAP: int = 5;		// trace trap (not reset when caught)
export def SIGABRT: int = 6;		// abort()
export def SIGIOT: int = SIGABRT;	// compatibility
export def SIGEMT: int = 7;		// EMT instruction
export def SIGFPE: int = 8;		// floating point exception
export def SIGKILL: int = 9;		// kill (cannot be caught or ignored)
export def SIGBUS: int = 10;		// bus error
export def SIGSEGV: int = 11;		// segmentation violation
export def SIGSYS: int = 12;		// non-existent system call invoked
export def SIGPIPE: int = 13;		// write on a pipe with no one to read it
export def SIGALRM: int = 14;		// alarm clock
export def SIGTERM: int = 15;		// software termination signal from kill
export def SIGURG: int = 16;		// urgent condition on IO channel
export def SIGSTOP: int = 17;		// sendable stop signal not from tty
export def SIGTSTP: int = 18;		// stop signal from tty
export def SIGCONT: int = 19;		// continue a stopped process
export def SIGCHLD: int = 20;		// to parent on child stop or exit
export def SIGTTIN: int = 21;		// to readers pgrp upon background tty read
export def SIGTTOU: int = 22;		// like TTIN if (tp->t_local&LTOSTOP)
export def SIGIO: int = 23;		// input/output possible signal
export def SIGXCPU: int = 24;		// exceeded CPU time limit
export def SIGXFSZ: int = 25;		// exceeded file size limit
export def SIGVTALRM: int = 26;		// virtual time alarm
export def SIGPROF: int = 27;		// profiling time alarm
export def SIGWINCH: int = 28;		// window size changes
export def SIGINFO: int = 29;		// information request
export def SIGUSR1: int = 30;		// user defined signal 1
export def SIGUSR2: int = 31;		// user defined signal 2
export def SIGTHR: int = 32;		// Thread interrupt (FreeBSD-5 reserved)
export def SIGCKPT: int = 33;		// checkpoint and continue
export def SIGCKPTEXIT: int = 34;	// checkpoint and exit

export def SIG_ERR: uintptr = -1;
export def SIG_DFL: uintptr = 0;
export def SIG_IGN: uintptr = 1;
export def SIG_CATCH: uintptr = 2;
export def SIG_HOLD: uintptr = 3;

export def SA_ONSTACK: int = 0x0001;	// take signal on signal stack
export def SA_RESTART: int = 0x0002;	// restart system call on signal return
export def SA_RESETHAND: int = 0x0004;	// reset to SIG_DFL when taking signal
export def SA_NOCLDSTOP: int = 0x0008;	// do not generate SIGCHLD on child stop
export def SA_NODEFER: int = 0x0010;	// don't mask the signal we're delivering
export def SA_NOCLDWAIT: int = 0x0020;	// don't keep zombies around
export def SA_SIGINFO: int = 0x0040;	// signal handler with SA_SIGINFO args

//
// Flags for sigprocmask:
//
export def SIG_BLOCK: int = 1;		// block specified signal set
export def SIG_UNBLOCK: int = 2;	// unblock specified signal set
export def SIG_SETMASK: int = 3;	// set specified signal set

export def SIGEV_NONE: int = 0;		// No async notification
export def SIGEV_SIGNAL: int = 1;	// Generate a queued signal
export def SIGEV_THREAD: int = 2;	// Call back in a pthread
export def SIGEV_KEVENT: int = 3;	// Generate a kevent
export def MINSIGSTKSZ: int = 8192;	// minimum allowable stack
export def SIGSTKSZ: int = MINSIGSTKSZ + 32768;	// recommended stack size

export def F_DUPFD: int = 0;		// duplicate file descriptor
export def F_GETFD: int = 1;		// get file descriptor flags
export def F_SETFD: int = 2;		// set file descriptor flags
export def F_GETFL: int = 3;		// get file status flags
export def F_SETFL: int = 4;		// set file status flags
export def F_GETOWN: int = 5;		// get SIGIO/SIGURG proc/pgrp
export def F_SETOWN: int = 6;		// set SIGIO/SIGURG proc/pgrp
export def F_GETLK: int = 7;		// get record locking information
export def F_SETLK: int = 8;		// set record locking information
export def F_SETLKW: int = 9;		// F_SETLK; wait if blocked
export def F_DUP2FD: int = 10;		// duplicate file descriptor to arg
export def F_DUPFD_CLOEXEC: int = 17;	// Like F_DUPFD with FD_CLOEXEC set
export def F_DUP2FD_CLOEXEC: int = 18;	// Like F_DUP2FD with FD_CLOEXEC set
export def F_GETPATH: int = 19;		// retrieve full path to file associated with fd
export def F_MAXFD: int = 20;		// return the max open fd
export def F_DUPFD_CLOFORK: int = 21;	// Like F_DUPFD with FD_CLOFORK set
export def F_DUP2FD_CLOFORK: int = 22;	// Like F_DUP2FD with FD_CLOFORK set
export def F_DUP3FD: int = 23;		// Used for dup3()
export def F_DUP3FD_SHIFT: int = 16;	// Shift used for F_DUP3FD
export def F_RDLCK: int = 1;		// shared or read lock
export def F_UNLCK: int = 2;		// unlock
export def F_WRLCK: int = 3;		// exclusive or write lock
export def F_WAIT: int = 0x010;		// Wait until lock is granted
export def F_UNUSED020: int = 0x020;	//
export def F_POSIX: int = 0x040;	// Use POSIX semantics for lock
export def F_NOEND: int = 0x080;	// l_len = 0, internally used

export def FD_CLOEXEC: int = 1;		// close-on-exec flag

export def PRIO_MIN: int = -20;
export def PRIO_MAX: int = 20;
export def PRIO_PROCESS: int = 0;
export def PRIO_PGRP: int = 1;
export def PRIO_USER: int = 2;

export def F_OK: int = 0;
export def X_OK: int = 0x01;
export def W_OK: int = 0x02;
export def R_OK: int = 0x04;

export def CLOCK_REALTIME: int = 0;
export def CLOCK_VIRTUAL: int = 1;
export def CLOCK_PROF: int = 2;
export def CLOCK_MONOTONIC: int = 4;
export def CLOCK_UPTIME: int = 5;
export def CLOCK_UPTIME_PRECISE: int = 7;
export def CLOCK_UPTIME_FAST: int = 8;
export def CLOCK_REALTIME_PRECISE: int = 9;
export def CLOCK_REALTIME_FAST: int = 10;
export def CLOCK_MONOTONIC_PRECISE: int = 11;
export def CLOCK_MONOTONIC_FAST: int = 12;
export def CLOCK_SECOND: int = 13;
export def CLOCK_THREAD_CPUTIME_ID: int = 14;
export def CLOCK_PROCESS_CPUTIME_ID: int = 15;

export def TIMER_ABSTIME: int = 1;

export def WNOHANG: int = 1;		// don't hang in wait
export def WUNTRACED: int = 2;		// tell about stopped, untraced children
export def WCONTINUED: int = 4;		// Report a job control continued process.
export def WSTOPPED: int = WUNTRACED;
export def WNOWAIT: int = 8;
export def WEXITED: int = 16;
export def WTRAPPED: int = 32;

//
// Tokens for special values of the "pid" parameter to wait4.
//

export def WAIT_ANY: int = -1;		// any process
export def WAIT_MYPGRP: int = 0;	// any process in my process group

export def STDIN_FILENO: int = 0;
export def STDOUT_FILENO: int = 1;
export def STDERR_FILENO: int = 2;

export def SEEK_SET: int = 0;		// set file offset to offset
export def SEEK_CUR: int = 1;		// set file offset to current plus offset
export def SEEK_END: int = 2;		// set file offset to EOF plus offset

// Flock operations
export def LOCK_SH: int = 1;		// shared file lock
export def LOCK_EX: int = 2;		// exclusive file lock
export def LOCK_NB: int = 4;		// don't block when locking
export def LOCK_UN: int = 8;		// unlock file

export type rlimit = struct {
	rlim_cur: rlim_t,
	rlim_max: rlim_t,
};

export def RLIM_INFINITY: rlim_t = -1;	// no limit
export def RLIMIT_CPU: int = 0;		// cpu time in milliseconds
export def RLIMIT_FSIZE: int = 1;	// maximum file size
export def RLIMIT_DATA: int = 2;	// data size
export def RLIMIT_STACK: int = 3;	// stack size
export def RLIMIT_CORE: int = 4;	// core file size
export def RLIMIT_RSS: int = 5;		// resident set size
export def RLIMIT_MEMLOCK: int = 6;	// locked-in-memory address space
export def RLIMIT_NPROC: int = 7;	// number of processes
export def RLIMIT_NOFILE: int = 8;	// number of open files
export def RLIMIT_SBSIZE: int = 9;	// maximum size of all socket buffers
export def RLIMIT_AS: int = 10;		// standard name for address space size
export def RLIMIT_VMEM: int = RLIMIT_AS;// virtual process size (inclusive of mmap)
export def RLIMIT_POSIXLOCKS: int = 11;	// maximum number of POSIX locks per user

// howto arguments for shutdown(2), specified by Posix.1g.
export def SHUT_RD: int = 0;		// shut down the reading side
export def SHUT_WR: int = 1;		// shut down the writing side
export def SHUT_RDWR: int = 2;		// shut down both sides

// Scheduling policies
// These policy constants are notably different from linux.
export def SCHED_FIFO: int     = 1;
export def SCHED_OTHER: int    = 2;
export def SCHED_RR: int       = 3;
export type sched_param = struct {
	sched_priority: int
};

export def EVFILT_READ: int = (-1);
export def EVFILT_WRITE: int = (-2);
export def EVFILT_AIO: int = (-3);		// attached to aio requests
export def EVFILT_VNODE: int = (-4);		// attached to vnodes
export def EVFILT_PROC: int = (-5);		// attached to struct proc
export def EVFILT_SIGNAL: int = (-6);		// attached to struct proc
export def EVFILT_TIMER: int = (-7);		// timers
export def EVFILT_EXCEPT: int = (-8);		// exceptional conditions
export def EVFILT_USER: int = (-9);		// user events
export def EVFILT_FS: int = (-10);		// filesystem events

export def EVFILT_SYSCOUNT: int = 10;

export def EV_ADD: u16 = 0x0001;	// add event to kq (implies enable)
export def EV_DELETE: u16 = 0x0002;	// delete event from kq
export def EV_ENABLE: u16 = 0x0004;	// enable event
export def EV_DISABLE: u16 = 0x0008;	// disable event (not reported)
export def EV_ONESHOT: u16 = 0x0010;	// only report one occurrence
export def EV_CLEAR: u16 = 0x0020;	// clear event state after reporting
export def EV_RECEIPT: u16 = 0x0040;	// force EV_ERROR on success, data=0
export def EV_DISPATCH: u16 = 0x0080;	// disable event after reporting
export def EV_SYSFLAGS: u16 = 0xF800;	// reserved by system
export def EV_FLAG1: u16 = 0x2000;	// filter-specific flag
export def EV_HUP: u16 = 0x0800;	// complete peer disconnect
export def EV_EOF: u16 = 0x8000;	// EOF detected
export def EV_ERROR: u16 = 0x4000;	// error, data contains errno
export def EV_NODATA: u16 = 0x1000;	// EOF and no more data

export def NOTE_FFNOP: u32 = 0x00000000; // ignore input fflags
export def NOTE_FFAND: u32 = 0x40000000; // AND fflags
export def NOTE_FFOR: u32 = 0x80000000;	// OR fflags
export def NOTE_FFCOPY: u32 = 0xc0000000; // copy fflags
export def NOTE_FFCTRLMASK: u32 = 0xc0000000; // masks for operations
export def NOTE_FFLAGSMASK: u32 = 0x00ffffff; //
export def NOTE_TRIGGER: u32 = 0x01000000; // trigger for output
export def NOTE_LOWAT: u32 = 0x0001;	// low water mark
export def NOTE_OOB: u32 = 0x0002;	// OOB data on a socket
export def NOTE_DELETE: u32 = 0x0001;	// vnode was removed
export def NOTE_WRITE: u32 = 0x0002;	// data contents changed
export def NOTE_EXTEND: u32 = 0x0004;	// size increased
export def NOTE_ATTRIB: u32 = 0x0008;	// attributes changed
export def NOTE_LINK: u32 = 0x0010;	// link count changed
export def NOTE_RENAME: u32 = 0x0020;	// vnode was renamed
export def NOTE_REVOKE: u32 = 0x0040;	// vnode access was revoked
export def NOTE_EXIT: u32 = 0x80000000;	// process exited
export def NOTE_FORK: u32 = 0x40000000;	// process forked
export def NOTE_EXEC: u32 = 0x20000000;	// process exec'd
export def NOTE_PCTRLMASK: u32 = 0xf0000000; // mask for hint bits
export def NOTE_PDATAMASK: u32 = 0x000fffff; // mask for pid
export def NOTE_TRACK: u32 = 0x00000001; // follow across forks
export def NOTE_TRACKERR: u32 = 0x00000002; // could not track child
export def NOTE_CHILD: u32 = 0x00000004; // am a child process
export def NOTE_SIGNAL: u32 = 0x08000000; //
export def NOTE_OLDAPI: u32 = 0x04000000; // select/poll note
export def NOTE_HUPONLY: u32 = 0x02000000; // select/poll note
