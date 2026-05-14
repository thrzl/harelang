// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>
//
// Darwin aarch64 signal trampoline.
//
// macOS's SYS_sigaction takes a `struct __sigaction` whose `sa_tramp`
// field holds the address of a userspace signal trampoline. The kernel
// jumps to this trampoline on signal delivery; the trampoline is then
// responsible for invoking the user's handler and finally calling
// SYS_sigreturn so the kernel restores the pre-signal context. Without
// a valid trampoline, signal handlers never return.
//
// The kernel ABI when calling the trampoline (aarch64):
//   x0 = catcher  (user's signal handler)
//   x1 = infostyle (1=NOINFO, 2=INFO; we always set SA_SIGINFO so 2)
//   x2 = signum
//   x3 = sinfo    (siginfo_t *)
//   x4 = uctx     (ucontext_t *)
//
// We must:
//   1. Call catcher(signum, sinfo, uctx) per AAPCS64
//      (x0=signum, x1=sinfo, x2=uctx).
//   2. After the handler returns, call SYS_sigreturn(uctx, infostyle) so
//      the kernel restores the pre-signal context. This call does not
//      return on success.
//
// macOS BSD syscalls on aarch64: x16 = <BSD number>, svc #0x80.
// SYS_sigreturn is BSD #184.

.text
.globl _hare_sigtramp
_hare_sigtramp:
	// Stash kernel-supplied args in callee-saved regs so they survive the
	// handler call (x0-x4 are caller-saved under AAPCS64 but
	// Hare-compiled handlers preserve x19-x28).
	mov	x19, x0              // catcher
	mov	x20, x1              // infostyle
	mov	x21, x4              // uctx

	// Set up a frame with forced 16-byte alignment. The kernel doesn't
	// guarantee a particular alignment, so save original sp and align.
	mov	x22, sp
	sub	x23, x22, #32
	and	x23, x23, #-16
	mov	sp, x23
	stp	x29, x30, [sp]
	mov	x29, sp

	// Marshal handler args: catcher(signum, sinfo, uctx)
	mov	x0, x2               // signum
	mov	x1, x3               // sinfo
	mov	x2, x4               // uctx
	blr	x19

	// Restore frame and original sp.
	ldp	x29, x30, [sp]
	mov	sp, x22

	// Tail-call SYS_sigreturn(uctx, infostyle). On success it never
	// returns. brk below catches the unexpected-return case.
	mov	x0, x21              // uctx
	mov	x1, x20              // infostyle
	mov	x16, #184            // SYS_sigreturn
	svc	#0x80

	brk	#0x1
