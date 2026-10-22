module instr_decoder import rv32i_pkg::*; (
    input  logic [31:0] instr,
    output logic [6:0]  opcode,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output rv32i_pkg::instr_type_t instr_type,
    output rv32i_pkg::imm_type_t imm_type
);

assign opcode  = instr[OPCODE_MSB : OPCODE_LSB];
assign rs1     = instr[RS1_MSB : RS1_LSB];
assign rs2     = instr[RS2_MSB : RS2_LSB];
assign rd      = instr[RD_MSB : RD_LSB];
assign funct3  = instr[FUNCT3_MSB : FUNCT3_LSB];
assign funct7  = instr[FUNCT7_MSB : FUNCT7_LSB];

always_comb begin
    instr_type = TYPE_OTHER;
    imm_type   = IMM_I;
    case (opcode)
        OP_OP:                       begin instr_type = TYPE_R; imm_type = IMM_I; end
        OP_OP_IMM, OP_LOAD, OP_JALR: begin instr_type = TYPE_I; imm_type = IMM_I; end
        OP_STORE:                    begin instr_type = TYPE_S; imm_type = IMM_S; end
        OP_BRANCH:                   begin instr_type = TYPE_B; imm_type = IMM_B; end
        OP_LUI, OP_AUIPC:            begin instr_type = TYPE_U; imm_type = IMM_U; end
        OP_JAL:                      begin instr_type = TYPE_J; imm_type = IMM_J; end
        default:                     begin instr_type = TYPE_OTHER; imm_type = IMM_I; end
    endcase
end

endmodule