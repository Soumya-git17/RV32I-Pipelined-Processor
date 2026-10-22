module stall_unit (
    input  logic mem_to_reg_EX,
    input  logic [4:0] rd_EX, rs1_ID, rs2_ID,
    output logic stall
);

assign stall = mem_to_reg_EX && (rd_EX != 5'd0) && ((rd_EX == rs1_ID) || (rd_EX == rs2_ID));

endmodule
