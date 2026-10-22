# 5-Stage Pipelined RV32I CPU (SystemVerilog)

A 5-stage pipelined RISC-V RV32I processor with hazard handling and built-in performance counters. It runs hand-assembled test programs and bare-metal C compiled with the RISC-V GCC toolchain, and is simulated with Verilator.

## Features

- Full RV32I base integer ISA: ALU ops, shifts, loads and stores (byte, halfword, word), branches, JAL, JALR, LUI, AUIPC
- Classic 5-stage pipeline: IF, ID, EX, MEM, WB
- Data forwarding from MEM and WB into EX, plus a WB-to-ID register file bypass
- Load-use hazard detection with a 1-cycle stall
- Branches and jumps resolved in EX, with flush of the two wrong-path instructions
- Performance counters: cycles, retired instructions (valid-bit based), CPI, stalls, forwarding events, branches and taken branches
- Memory-mapped console output and program exit code (tohost style)
- Self-checking C test program (primes, bubble sort, Game of Life)

## Directory layout

```
rtl/   SystemVerilog sources (cpu, pipeline registers, ALU, control, memories, ...)
tb/    cpu_tb.sv testbench
sw/    start.S, link.ld, main.c, build.sh
programs/  .mem images (program2, program3, prog)
Makefile
```

## Modules

| File | Purpose |
|---|---|
| `rv32i_pkg.sv` | Opcode, funct, ALU-op and immediate-type enums, field positions |
| `cpu.sv` | Top level: wires the stages, forwarding, branch resolution, counters |
| `pc.sv` | Program counter, holds on stall |
| `instr_mem.sv` | Instruction ROM, loaded with `$readmemh`, NOP-filled |
| `IF_ID.sv`, `ID_EX.sv`, `EX_MEM.sv`, `MEM_WB.sv` | Pipeline registers |
| `instr_decoder.sv`, `imm_gen.sv` | Field extraction and immediate generation |
| `control_unit.sv` | Control signals; illegal instructions disable all side effects |
| `reg_file.sv` | 32x32 register file, x0 hardwired to zero |
| `alu.sv` | Arithmetic, logic, shift, compare |
| `forwarding_unit.sv`, `stall_unit.sv` | Hazard handling |
| `data_mem.sv` | Byte-addressable data RAM, preloaded from the program image |

## Pipeline behavior

**Forwarding.** The EX stage takes operands from the register file output, the MEM stage result, or the WB result. A WB-to-ID bypass covers the case where an instruction in WB writes a register being read in ID.

**Load-use stall.** If an instruction in EX is a load and the instruction in ID reads its destination, the PC and IF/ID hold for one cycle and a bubble enters EX. The loaded value then arrives via the WB bypass.

**Branches and jumps.** All control flow is resolved in EX.
- Branch conditions reuse the ALU: BEQ/BNE use `zero`, BLT/BLTU/BGE/BGEU use the SLT/SLTU result bit.
- Branch and JAL target: `pc + imm`. JALR target: `(rs1 + imm) & ~1`.
- JAL and JALR write `pc + 4` to `rd`; AUIPC uses the PC as ALU operand A.
- A taken branch or any jump costs 2 cycles (IF/ID and ID/EX are flushed). Not-taken branches cost nothing.

## Memory map

Instruction and data memories are separate (Harvard), 4096 words (16 KB) each. The same program image is loaded into both so that C string literals and initialized globals can be read as data.

| Address | Meaning |
|---|---|
| `0x0000_0000` onward | Program image, data, stack (`_stack_top = 0x4000`) |
| `0x1000_0000` | Console: a store prints the low byte as a character (testbench) |
| `0x1000_0004` | Exit: a store ends the simulation; the value is the exit code |

The console and exit addresses are decoded in the testbench. Because `data_mem` ignores the upper address bits, those stores also land in `data_mem` words 0 and 1, which is harmless.

## Build and run

Requirements: Verilator 5.x, GTKWave (optional), RISC-V GCC (`riscv64-unknown-elf-gcc` or equivalent).

Hand-written programs:
```bash
make run PROG=programs/program2.mem
make run PROG=programs/program3.mem
make wave          # open cpu_tb.vcd
make clean
```

C programs:
```bash
bash sw/build.sh                      # compiles sw/main.c to programs/prog.mem
make run PROG=programs/prog.mem
```

The compile flags are `-march=rv32i -mabi=ilp32 -O1 -nostdlib -nostartfiles -ffreestanding -fno-builtin -fno-tree-loop-distribute-patterns`. There is no M extension, so avoid `*`, `/` and `%` in C.

## Tests

| Program | Covers |
|---|---|
| `program2.mem` | SLT/SLTU, SRA/SRL/SLL, LB/LBU/LH/LHU, SB/SH, all six branch types, JALR |
| `program3.mem` | Forwarding, load-use stall, branch loop, JAL flush, LUI, AUIPC |
| `prog.mem` (C) | Prime sieve, bubble sort, Game of Life (8x8 glider); exit code 25 means all self-checks passed |

All of the above pass with the expected register values and console output.

## Performance (C benchmark, `prog.mem`)

| Metric | Value |
|---|---|
| Cycles | 57,014 |
| Retired instructions | 43,110 |
| CPI | 1.32 |
| Load-use stalls | 2,846 |
| Branches / taken | 8,985 / 3,799 |
| Forwarding events | 23,009 |

Instructions are counted at WB using a valid bit, so flushed instructions and bubbles are excluded. Counters freeze when the exit write is seen.

## Known limitations

- No M extension, CSRs, `ecall`/`ebreak`, interrupts or `fence` (FENCE and SYSTEM are treated as NOPs)
- No misaligned access support; misaligned halfword/word stores are ignored
- Taken branches and jumps cost 2 cycles (no branch prediction)
- LUI, AUIPC and JAL can cause occasional false load-use stalls because their immediate bits overlap the rs1/rs2 fields
- Output ports `jump_ID` and `instr_type_ID` are unused

## Future work

- Static backward-taken branch prediction, then a 2-bit predictor with BTB
- Use `instr_type` to remove false stalls
- M extension, CSRs and timer interrupts
- Official rv32ui compliance tests
- Memory-mapped keyboard and timer for a text-mode Tetris
- FPGA port with UART and LEDs