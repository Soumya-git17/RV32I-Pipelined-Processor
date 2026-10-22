OUTPUT_ARCH(riscv)
ENTRY(_start)
SECTIONS {
    . = 0x0;
    .text   : { *(.text.init) *(.text*) }
    .rodata : { *(.rodata*) }
    .data   : { *(.data*) *(.sdata*) }
    .bss    : { *(.bss*) *(.sbss*) *(COMMON) }
    . = ALIGN(4);
    _stack_top = 0x4000;      /* 4096 words = 16 KB, matches DEPTH=4096 */
}