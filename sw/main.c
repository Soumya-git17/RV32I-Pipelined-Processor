#define UART (*(volatile unsigned int *)0x10000000)
#define EXIT (*(volatile unsigned int *)0x10000004)

static void putc_(char c) { UART = c; }
static void puts_(const char *s) { while (*s) putc_(*s++); }

int main(void) {
    puts_("Hello World!\n");
    int a = 0, b = 1;
    for (int i = 0; i < 10; i++) { int t = a + b; a = b; b = t; }
    return a;               // fib(10) = 55, ends up in x10 (a0)
}