module EX_MEM (
    input  logic clk, rst,
    input  logic [31:0] alu_result_EX, b_EX,
    input  logic [2:0] funct3_EX,
    input  logic reg_write_EX, mem_write_EX, mem_to_reg_EX,
    input  logic [4:0] write_reg_EX,
    output logic [31:0] alu_result_MEM, b_MEM,
    output logic [2:0] funct3_MEM,
    output logic reg_write_MEM, mem_write_MEM, mem_to_reg_MEM,
    output logic [4:0] write_reg_MEM
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        alu_result_MEM <= 32'b0;
        b_MEM          <= 32'b0;
        funct3_MEM     <= 3'b0;
        reg_write_MEM  <= 1'b0;
        mem_write_MEM  <= 1'b0;
        mem_to_reg_MEM <= 1'b0;
        write_reg_MEM  <= 5'b0;
    end
    else begin
        alu_result_MEM <= alu_result_EX;
        b_MEM          <= b_EX;
        funct3_MEM     <= funct3_EX;
        reg_write_MEM  <= reg_write_EX;
        mem_write_MEM  <= mem_write_EX;
        mem_to_reg_MEM <= mem_to_reg_EX;
        write_reg_MEM  <= write_reg_EX;
    end
end

endmodule
