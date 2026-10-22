module instr_mem #(
    parameter int DEPTH = 4096   // words (16 KB)
)(
    input  logic [31:0] addr,
    output logic [31:0] instr
);

localparam int AW = $clog2(DEPTH);
logic [31:0] rom [0:DEPTH-1];
string prog_file;

initial begin
    for (int i = 0; i < DEPTH; i++) rom[i] = 32'h0000_0013;   // fill NOP
    if (!$value$plusargs("PROG=%s", prog_file)) prog_file = "programs/prog.mem";
    $readmemh(prog_file, rom);
end

always_comb begin
    instr = rom[addr[AW+1:2]];
end

endmodule