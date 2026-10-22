TOP = cpu_tb

RTL = rtl/rv32i_pkg.sv rtl/alu.sv rtl/control_unit.sv rtl/data_mem.sv rtl/EX_MEM.sv rtl/forwarding_unit.sv \
	rtl/ID_EX.sv rtl/imm_gen.sv rtl/IF_ID.sv rtl/instr_decoder.sv rtl/instr_mem.sv rtl/MEM_WB.sv rtl/pc.sv \
	rtl/reg_file.sv rtl/stall_unit.sv rtl/cpu.sv 

TB = tb/cpu_tb.sv

SRCS = $(RTL) $(TB)

PROG = programs/program3.mem

.PHONY: build run clean wave

build: 
	verilator --binary --timing --trace -j 0 -Wno-fatal \
	--top-module $(TOP) $(SRCS)

run:
	./obj_dir/V$(TOP) +PROG=$(PROG)

clean:
	rm -rf obj_dir *.vcd

wave:
	gtkwave cpu_tb.vcd