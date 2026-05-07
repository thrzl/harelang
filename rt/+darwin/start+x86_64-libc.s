.text
.global _start
_start:
	xor %rbp, %rbp
	and $-16, %rsp
	leaq -8(%rsi), %rdi
	call _rt.start_darwin

# @func-libc.s is concatenated into rt_s by the platform Makefile;
# no .include needed here.