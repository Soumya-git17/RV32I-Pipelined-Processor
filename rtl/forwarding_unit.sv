module forwarding_unit (
    input  logic [4:0] ID_EX_rs,
    input  logic [4:0] ID_EX_rt,
    input  logic [4:0] EX_MEM_rd,
    input  logic [4:0] MEM_WB_rd,
    input  logic EX_MEM_reg_write,
    input  logic MEM_WB_reg_write,
    output logic [1:0] forwardA,
    output logic [1:0] forwardB
);

always_comb begin
    if ((EX_MEM_reg_write == 1'b1) && (EX_MEM_rd != 5'd0) && (EX_MEM_rd == ID_EX_rs)) forwardA = 2'b10;
    else if ((MEM_WB_reg_write == 1'b1) && (MEM_WB_rd != 5'd0) && (MEM_WB_rd == ID_EX_rs)) forwardA = 2'b01;
    else forwardA = 2'b00;

    if ((EX_MEM_reg_write == 1'b1) && (EX_MEM_rd != 5'd0) && (EX_MEM_rd == ID_EX_rt)) forwardB = 2'b10;
    else if ((MEM_WB_reg_write == 1'b1) && (MEM_WB_rd != 5'd0) && (MEM_WB_rd == ID_EX_rt)) forwardB = 2'b01;
    else forwardB = 2'b00;
end

endmodule