.section .text.init
.globl _start
.globl _halt
_start:
    la   sp, _stack_top
    call main
    li   t0, 0x10000004
    sw   a0, 0(t0)
_halt:
    j    _halt