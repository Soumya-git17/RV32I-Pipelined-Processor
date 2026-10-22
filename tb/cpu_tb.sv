module cpu_tb;

logic clk, rst;
integer i;
real CPI;
int hits = 0;

cpu dut(clk, rst);

initial clk = 0;
always #5 clk = ~clk;

logic done = 0;
logic [31:0] exit_code;

always @(posedge clk) begin
    if (dut.mem_write_MEM && dut.alu_result_MEM == 32'h1000_0004) begin
        exit_code <= dut.b_MEM;
        done      <= 1'b1;
    end
end

initial begin
    $dumpfile("cpu_tb.vcd");
    $dumpvars(0, cpu_tb);
    rst = 1;
    #12;
    rst = 0;
end

initial begin
    #10000000;
    $display("\nTIMEOUT: PC = %0d", dut.pc_out);
    $finish;
end

always @(posedge clk)
    if (dut.mem_write_MEM && dut.alu_result_MEM == 32'h1000_0000)
        $write("%c", dut.b_MEM[7:0]);


initial begin
    wait (rst == 0);
    wait (done);
    repeat (5) @(posedge clk);
    @(negedge clk);

    $display("\nProgram Finished, exit code = %0d", exit_code);
    $display("\nFinal Register Values");
    for (i = 0; i < 32; i = i + 1)
        $display("x%-2d = %0d (0x%08h)", i, dut.rf1.regfile[i], dut.rf1.regfile[i]);

    CPI = (dut.instr_count != 0) ? (dut.cycle_count * 1.0 / dut.instr_count) : 0.0;

    $display("\nPerformance:");
    $display("-------");
    $display("Total Cycles      = %0d", dut.cycle_count);
    $display("Instructions      = %0d", dut.instr_count);
    $display("CPI               = %0f", CPI);
    $display("-------");
    $display("Pipeline Stalls   = %0d", dut.stall_count);
    $display("-------");
    $display("ForwardA events   = %0d", dut.forwardA_count);
    $display("ForwardB events   = %0d", dut.forwardB_count);
    $display("Total Forwarding  = %0d", dut.forwardA_count + dut.forwardB_count);
    $display("-------");
    $display("Branch count      = %0d", dut.branch_count);
    $display("Taken branches    = %0d", dut.branch_taken_count);
    $finish;
end

endmodule