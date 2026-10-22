module control_unit import rv32i_pkg::*; (
    input  opcode_t opcode,
    input  funct3_t funct3,
    input  funct7_t funct7,
    output logic reg_write,              // write to regfile
    output logic mem_write,              // write to data_mem
    output logic mem_to_reg,             // 1 = memory data , 0 = alu result
    output logic alu_src,                // 1 = immediate, 0 = rs2 register
    output alu_op_t alu_op,              // ALU operation code
    output logic branch,                 // branch instruction
    output logic jump                    // JAL or JALR
);

logic illegal;

always_comb begin
    reg_write  = 1'b0;
    mem_write  = 1'b0;
    mem_to_reg = 1'b0;
    alu_src    = 1'b0;
    alu_op     = ALU_ADD;
    branch     = 1'b0;
    jump       = 1'b0;
    illegal    = 1'b0;
    case (opcode)
        OP_OP : begin
            reg_write = 1'b1;
            case(funct3)
                F3_ADD_SUB  : begin
                    case (funct7)
                        F7_BASE : alu_op  = ALU_ADD;
                        F7_ALT  : alu_op  = ALU_SUB;
                        default : illegal = 1'b1;
                    endcase
                end
                F3_AND      : begin if (funct7 == F7_BASE) alu_op = ALU_AND;  else illegal = 1'b1; end
                F3_OR       : begin if (funct7 == F7_BASE) alu_op = ALU_OR;   else illegal = 1'b1; end
                F3_XOR      : begin if (funct7 == F7_BASE) alu_op = ALU_XOR;  else illegal = 1'b1; end
                F3_SLT      : begin if (funct7 == F7_BASE) alu_op = ALU_SLT;  else illegal = 1'b1; end
                F3_SLTU     : begin if (funct7 == F7_BASE) alu_op = ALU_SLTU; else illegal = 1'b1; end
                F3_SLL      : begin if (funct7 == F7_BASE) alu_op = ALU_SLL;  else illegal = 1'b1; end
                F3_SRX      : begin
                    case (funct7)
                        F7_BASE : alu_op = ALU_SRL;
                        F7_ALT  : alu_op = ALU_SRA;
                        default : illegal = 1'b1;
                    endcase
                end
                default : illegal = 1'b1;
            endcase
        end
        OP_OP_IMM : begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            case(funct3)
                F3_ADD_SUB : alu_op = ALU_ADD;
                F3_AND  : alu_op = ALU_AND;
                F3_OR   : alu_op = ALU_OR;
                F3_XOR  : alu_op = ALU_XOR;
                F3_SLT  : alu_op = ALU_SLT;
                F3_SLTU : alu_op = ALU_SLTU;
                F3_SLL  : begin if (funct7 == F7_BASE) alu_op = ALU_SLL; else illegal = 1'b1; end
                F3_SRX  : begin
                    case (funct7)
                        F7_BASE : alu_op = ALU_SRL;
                        F7_ALT  : alu_op = ALU_SRA;
                        default : illegal = 1'b1;
                    endcase
                end
                default : illegal = 1'b1;
            endcase
        end
        OP_LUI : begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_op = ALU_COPY_B;
        end
        OP_AUIPC: begin
            reg_write = 1'b1;
            alu_src   = 1'b1;
            alu_op    = ALU_ADD;
        end
        OP_LOAD : begin
            reg_write   = 1'b1;
            mem_to_reg  = 1'b1;
            alu_src     = 1'b1;
            alu_op      = ALU_ADD;
            case (funct3)
                F3_LB, F3_LH, F3_LBU, F3_LHU, F3_LW : ;
                default : illegal = 1'b1; 
            endcase
        end
        OP_STORE : begin
            mem_write = 1'b1;
            alu_src = 1'b1;
            alu_op = ALU_ADD;
            case (funct3)
                F3_SB, F3_SH, F3_SW : ;
                default : illegal = 1'b1;
            endcase
        end
        OP_BRANCH : begin
            case (funct3)
                F3_BEQ,  F3_BNE  : begin branch = 1'b1; alu_op = ALU_SUB;  end
                F3_BLT,  F3_BGE  : begin branch = 1'b1; alu_op = ALU_SLT;  end
                F3_BLTU, F3_BGEU : begin branch = 1'b1; alu_op = ALU_SLTU; end
                default          : illegal = 1'b1;
            endcase
        end
        OP_JAL : begin
            reg_write = 1'b1;
            jump      = 1'b1; 
        end
        OP_JALR: begin
            if (funct3 == 3'b000) begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_ADD;
                jump      = 1'b1;
            end
            else illegal = 1'b1;
        end
        OP_MISC_MEM, OP_SYSTEM : ;
        default: illegal   = 1'b1;
    endcase
    if (illegal) begin
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
    end
end

endmodule