module alu import rv32i_pkg::*; (
    input  logic [31:0] src_a, src_b,
    input  alu_op_t alu_op,
    output logic [31:0] result,
    output logic zero
);

assign zero = (result == 32'b0);

always_comb begin
    case(alu_op)
        ALU_ADD:    result = src_a + src_b;
        ALU_SUB:    result = src_a - src_b;
        ALU_AND:    result = src_a & src_b;
        ALU_OR :    result = src_a | src_b;
        ALU_XOR:    result = src_a ^ src_b;
        ALU_SLT:    result = ($signed(src_a) < $signed(src_b)) ? 32'd1 : 32'd0;
        ALU_SLTU:   result = (src_a < src_b) ? 32'd1 : 32'd0;
        ALU_SLL:    result = src_a << src_b[4:0];
        ALU_SRL:    result = src_a >> src_b[4:0];
        ALU_SRA:    result = $signed(src_a) >>> src_b[4:0];
        ALU_COPY_B: result = src_b;
        default:    result = 32'b0;
    endcase
end

endmodule