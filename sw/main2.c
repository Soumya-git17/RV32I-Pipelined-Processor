#define UART (*(volatile unsigned int *)0x10000000)

static void putc_(char c) { UART = c; }
static void puts_(const char *s) { while (*s) putc_(*s++); }

static void print_uint(unsigned int n) {
    static const unsigned int p10[10] = {
        1000000000u, 100000000u, 10000000u, 1000000u, 100000u,
        10000u, 1000u, 100u, 10u, 1u
    };
    int started = 0;
    for (int i = 0; i < 10; i++) {
        char d = '0';
        while (n >= p10[i]) { n -= p10[i]; d++; }
        if (d != '0' || started || i == 9) { putc_(d); started = 1; }
    }
}

/* ---------- 1. prime sieve ---------- */
static unsigned char sieve[128];

static int primes(void) {
    int count = 0;
    puts_("Primes < 100:\n");
    for (int i = 2; i < 100; i++) {
        if (!sieve[i]) {
            print_uint(i); putc_(' ');
            count++;
            for (int j = i + i; j < 100; j += i) sieve[j] = 1;
        }
    }
    puts_("\ncount = "); print_uint(count); putc_('\n');
    return count;
}

/* ---------- 2. bubble sort ---------- */
static int arr[10] = {42, 7, 99, 3, 56, 18, 1, 73, 25, 64};

static int sort_test(void) {
    puts_("Before: ");
    for (int i = 0; i < 10; i++) { print_uint(arr[i]); putc_(' '); }
    putc_('\n');

    for (int i = 0; i < 9; i++)
        for (int j = 0; j < 9 - i; j++)
            if (arr[j] > arr[j + 1]) {
                int t = arr[j]; arr[j] = arr[j + 1]; arr[j + 1] = t;
            }

    puts_("After:  ");
    for (int i = 0; i < 10; i++) { print_uint(arr[i]); putc_(' '); }
    putc_('\n');

    for (int i = 0; i < 9; i++) if (arr[i] > arr[i + 1]) return 0;
    return 1;
}

/* ---------- 3. Game of Life, 8x8 wrapping grid ---------- */
static unsigned char g[64], nx[64];

static void show(int gen) {
    puts_("Gen "); print_uint(gen); putc_('\n');
    for (int y = 0; y < 8; y++) {
        for (int x = 0; x < 8; x++) putc_(g[(y << 3) | x] ? '#' : '.');
        putc_('\n');
    }
}

static void step(void) {
    for (int y = 0; y < 8; y++)
        for (int x = 0; x < 8; x++) {
            int n = 0;
            for (int dy = -1; dy <= 1; dy++)
                for (int dx = -1; dx <= 1; dx++)
                    if (dx || dy)
                        n += g[(((y + dy) & 7) << 3) | ((x + dx) & 7)];
            int alive = g[(y << 3) | x];
            nx[(y << 3) | x] = (n == 3) || (alive && n == 2);
        }
    for (int i = 0; i < 64; i++) g[i] = nx[i];
}

static int life(void) {
    g[(0 << 3) | 1] = 1;   /* glider */
    g[(1 << 3) | 2] = 1;
    g[(2 << 3) | 0] = 1;
    g[(2 << 3) | 1] = 1;
    g[(2 << 3) | 2] = 1;
    for (int gen = 0; gen < 4; gen++) { show(gen); step(); }
    int cells = 0;
    for (int i = 0; i < 64; i++) cells += g[i];
    return cells;           /* a glider always has 5 cells */
}

int main(void) {
    int p = primes();
    int ok = sort_test();
    int c = life();
    puts_("done\n");
    /* 25 primes, sorted ok, 5 cells -> exit code 25 + 0 */
    return (p == 25 && ok && c == 5) ? p : 99;
}