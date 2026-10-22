module IF_ID (
    input  logic clk, rst, stall, flush,
    input  logic [31:0] instr_IF, pc_plus4_IF,
    output logic [31:0] instr_ID, pc_plus4_ID
);

always_ff @(posedge clk or posedge rst) begin
    if (rst || flush) begin
        instr_ID    <= 32'b0;
        pc_plus4_ID <= 32'b0;
    end
    else if (stall) begin
        instr_ID    <= instr_ID;
        pc_plus4_ID <= pc_plus4_ID;
    end
    else begin
        instr_ID    <= instr_IF;
        pc_plus4_ID <= pc_plus4_IF;
    end
end

endmodule