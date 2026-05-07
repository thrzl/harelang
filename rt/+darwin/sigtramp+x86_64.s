// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>
//
// Darwin x86_64 signal trampoline.
//
// macOS's SYS_sigaction takes a `struct __sigaction` whose `sa_tramp`
// field holds the address of a userspace signal trampoline. The kernel
// jumps to this trampoline on signal delivery; the trampoline is then
// responsible for invoking the user's handler and finally calling
// SYS_sigreturn so the kernel restores the pre-signal context. Without
// a valid trampoline, signal handlers never return.
//
// The kernel ABI when calling the trampoline (x86_64):
//   %rdi = catcher  (user's signal handler)
//   %rsi = infostyle (1=NOINFO, 2=INFO; we always set SA_SIGINFO so 2)
//   %rdx = signum
//   %rcx = sinfo    (siginfo_t *)
//   %r8  = uctx     (ucontext_t *)
//
// We must:
//   1. Call catcher(signum, sinfo, uctx) per System V AMD64 ABI
//      (rdi=signum, rsi=sinfo, rdx=uctx).
//   2. After the handler returns, call SYS_sigreturn(uctx, infostyle) so
//      the kernel restores the pre-signal context. This call does not
//      return on success.
//
// macOS BSD syscalls are invoked with rax = 0x2000000 | <BSD number>;
// SYS_sigreturn is BSD #184, so 0x20000B8.

.text
.globl _hare_sigtramp
_hare_sigtramp:
	// Stash kernel-supplied args in callee-saved regs so they survive the
	// handler call (rdi/rsi/r8 are caller-saved under System V AMD64 but
	// Hare-compiled handlers preserve r12-r15).
	movq %rdi, %r12              // catcher
	movq %rsi, %r13              // infostyle
	movq %r8,  %r14              // uctx

	// Align stack to 16 before the call. The kernel doesn't guarantee a
	// particular alignment, so set up a frame and force-align.
	pushq %rbp
	movq  %rsp, %rbp
	andq  $-16, %rsp

	// Marshal handler args: catcher(signum, sinfo, uctx)
	movq %rdx, %rdi              // signum
	movq %rcx, %rsi              // sinfo
	movq %r8,  %rdx              // uctx
	callq *%r12

	// Restore stack pointer.
	movq %rbp, %rsp
	popq %rbp

	// Tail-call SYS_sigreturn(uctx, infostyle). On success it never
	// returns. ud2 below catches the unexpected-return case.
	movq %r14, %rdi              // uctx
	movq %r13, %rsi              // infostyle
	movq $0x20000B8, %rax        // SYS_sigreturn = 184 + macOS BSD prefix
	syscall

	ud2
