module ID_EX import rv32i_pkg::*; (
    input  logic clk, rst, stall, flush,
    input  logic [4:0] rs1_ID, rs2_ID, rd_ID,
    input  logic [31:0] a_ID, b_ID,
    input  logic [31:0] imm_ID,
    input  logic reg_write_ID, mem_write_ID, mem_to_reg_ID, alu_src_ID, branch_ID,
    input  alu_op_t alu_op_ID,
    input  logic [31:0] pc_plus4_ID,
    input  logic [6:0] opcode_ID,
    input  logic [2:0] funct3_ID,
    input  logic [6:0] funct7_ID,
    output logic [4:0] rs1_EX, rs2_EX, rd_EX,
    output logic [31:0] a_EX, b_EX,
    output logic [31:0] imm_EX,
    output logic reg_write_EX, mem_write_EX, mem_to_reg_EX, alu_src_EX, branch_EX,
    output alu_op_t alu_op_EX,
    output logic [31:0] pc_plus4_EX,
    output logic [6:0] opcode_EX,
    output logic [2:0] funct3_EX,
    output logic [6:0] funct7_EX
);

always_ff @(posedge clk or posedge rst) begin
    if (rst || flush || stall) begin
        rs1_EX <= 5'b0;
        rs2_EX <= 5'b0;
        rd_EX <= 5'b0;
        a_EX <= 32'b0;
        b_EX <= 32'b0;
        imm_EX <= 32'b0;
        reg_write_EX <= 1'b0;
        mem_write_EX <= 1'b0;
        mem_to_reg_EX <= 1'b0;
        alu_src_EX <= 1'b0;
        branch_EX <= 1'b0;
        alu_op_EX <= ALU_ADD;
        pc_plus4_EX <= 32'b0;
        opcode_EX <= 7'b0;
        funct3_EX <= 3'b0;
        funct7_EX <= 7'b0;
    end
    else begin
        rs1_EX <= rs1_ID;
        rs2_EX <= rs2_ID;
        rd_EX <= rd_ID;
        a_EX <= a_ID;
        b_EX <= b_ID;
        imm_EX <= imm_ID;
        reg_write_EX <= reg_write_ID;
        mem_write_EX <= mem_write_ID;
        mem_to_reg_EX <= mem_to_reg_ID;
        alu_src_EX <= alu_src_ID;
        branch_EX <= branch_ID;
        alu_op_EX <= alu_op_ID;
        pc_plus4_EX <= pc_plus4_ID;
        opcode_EX <= opcode_ID;
        funct3_EX <= funct3_ID;
        funct7_EX <= funct7_ID;
    end
end

endmodule