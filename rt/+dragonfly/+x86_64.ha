// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

export type siginfo = struct {
	si_signo: int,			// signal number
	si_errno: int,			// errno association
	si_code: int,			// signal code
	si_pid: pid_t,			// sending process
	si_uid: uid_t,			// sender's ruid
	si_status: int,			// exit value
	si_addr: *opaque,		// faulting instruction
	si_value: sigval,		// signal value
	si_band: i64,			// band event for SIGPOLL
	__spare__: [7]int,		// gimme some slack
};

export type ucontext_t = struct {
	uc_sigmask: sigset,
	uc_mcontext: mcontext,
	uc_link: *ucontext_t,
	uc_stack: stack_t,
	uc_cofunc: nullable *fn (_: *ucontext_t, _: *opaque) void,
	uc_arg: *opaque,
	__spare__: [4]int,
};

export type mcontext = struct {
	mc_onstack: u64,
	mc_rdi: u64,
	mc_rsi: u64,
	mc_rdx: u64,
	mc_rcx: u64,
	mc_r8: u64,
	mc_r9: u64,
	mc_rax: u64,
	mc_rbx: u64,
	mc_rbp: u64,
	mc_r10: u64,
	mc_r11: u64,
	mc_r12: u64,
	mc_r13: u64,
	mc_r14: u64,
	mc_r15: u64,
	mc_xflags: u64,
	mc_trapno: u64,
	mc_addr: u64,
	mc_flags: u64,
	mc_err: u64,
	mc_rip: u64,
	mc_cs: u64,
	mc_rflags: u64,
	mc_rsp: u64,
	mc_ss: u64,

	mc_len: uint,
	mc_fpformat: uint,
	mc_ownedfp: uint,
	mc_reserved: uint,
	mc_unused: [8]uint,

	mc_fpregs: [256]int,
};
