module cpu import rv32i_pkg::*; (
    input logic clk, rst
);

// IF
logic [31:0] pc_next, pc_out, pc_plus4_IF;
logic [31:0] instr_IF;
// ID
logic [31:0] instr_ID, pc_plus4_ID;
logic [6:0]  opcode_ID;
logic [2:0]  funct3_ID;
logic [6:0]  funct7_ID;
logic [4:0]  rs1_ID, rs2_ID, rd_ID;
instr_type_t instr_type_ID;
imm_type_t   imm_type_ID;
logic [31:0] imm_ID;
logic        reg_write_ID, mem_write_ID, mem_to_reg_ID, alu_src_ID, branch_ID, jump_ID;
alu_op_t     alu_op_ID;
logic [31:0] a_ID, b_ID, a_ID_fwd, b_ID_fwd;
// EX
logic [6:0]  opcode_EX;
logic [2:0]  funct3_EX;
logic [6:0]  funct7_EX;
logic [4:0]  rs1_EX, rs2_EX, rd_EX;
logic [31:0] a_EX, b_EX, imm_EX, pc_plus4_EX, pc_EX;
logic        reg_write_EX, mem_write_EX, mem_to_reg_EX, alu_src_EX, branch_EX;
alu_op_t     alu_op_EX;
logic [1:0]  forward_a, forward_b;
logic [31:0] fwd_a_EX, fwd_b_EX, alu_in1, alu_in2;
logic [31:0] alu_raw_EX, alu_result_EX;
logic        zero;
logic        is_jal_EX, is_jalr_EX, is_auipc_EX;
logic        branch_taken;
logic [31:0] branch_jal_target, jalr_target;
// MEM
logic [31:0] alu_result_MEM, b_MEM, mem_read_data_MEM;
logic [2:0]  funct3_MEM;
logic        reg_write_MEM, mem_write_MEM, mem_to_reg_MEM;
logic [4:0]  write_reg_MEM;
// WB
logic [31:0] alu_result_WB, mem_read_data_WB, write_data;
logic        reg_write_WB, mem_to_reg_WB;
logic [4:0]  write_reg_WB;
// hazard control
logic stall, flush_IFID, flush_IDEX;


// IF stage
pc pc1 (clk, rst, pc_next, stall, pc_out);
instr_mem im1 (pc_out, instr_IF);
assign pc_plus4_IF = pc_out + 4;

IF_ID p1 (clk, rst, stall, flush_IFID, instr_IF, pc_plus4_IF, instr_ID, pc_plus4_ID);

// ID stage
instr_decoder id1 (instr_ID, opcode_ID, funct3_ID, funct7_ID, rs1_ID, rs2_ID, rd_ID, instr_type_ID, imm_type_ID);
imm_gen ig1 (instr_ID, imm_type_ID, imm_ID);
control_unit cu1 (opcode_ID, funct3_ID, funct7_ID, reg_write_ID, mem_write_ID, mem_to_reg_ID,
                alu_src_ID, alu_op_ID, branch_ID, jump_ID);
reg_file rf1 (clk, rst, reg_write_WB, rs1_ID, rs2_ID, write_reg_WB, write_data, a_ID, b_ID);
stall_unit su1 (mem_to_reg_EX, rd_EX, rs1_ID, rs2_ID, stall);

assign a_ID_fwd = (reg_write_WB && write_reg_WB != 0 && write_reg_WB == rs1_ID) ? write_data : a_ID;
assign b_ID_fwd = (reg_write_WB && write_reg_WB != 0 && write_reg_WB == rs2_ID) ? write_data : b_ID;

ID_EX p2 (clk, rst, stall, flush_IDEX, rs1_ID, rs2_ID, rd_ID, a_ID_fwd, b_ID_fwd, imm_ID,
        reg_write_ID, mem_write_ID, mem_to_reg_ID, alu_src_ID,
        branch_ID, alu_op_ID, pc_plus4_ID, opcode_ID, funct3_ID, funct7_ID,
        rs1_EX, rs2_EX, rd_EX, a_EX, b_EX, imm_EX,
        reg_write_EX, mem_write_EX, mem_to_reg_EX, alu_src_EX,
        branch_EX, alu_op_EX, pc_plus4_EX, opcode_EX, funct3_EX, funct7_EX);

// EX stage
assign pc_EX = pc_plus4_EX - 32'd4;
assign is_jal_EX   = (opcode_EX == OP_JAL);
assign is_jalr_EX  = (opcode_EX == OP_JALR);
assign is_auipc_EX = (opcode_EX == OP_AUIPC);

forwarding_unit fd1 (rs1_EX, rs2_EX, write_reg_MEM, write_reg_WB, reg_write_MEM, reg_write_WB, forward_a, forward_b);

always_comb begin
    case(forward_a)
        2'b00: fwd_a_EX = a_EX;
        2'b01: fwd_a_EX = write_data;
        2'b10: fwd_a_EX = alu_result_MEM;
        default: fwd_a_EX = 32'b0;
    endcase
    case(forward_b)
        2'b00: fwd_b_EX = b_EX;
        2'b01: fwd_b_EX = write_data;
        2'b10: fwd_b_EX = alu_result_MEM;
        default: fwd_b_EX = 32'b0;
    endcase
end

assign alu_in1 = is_auipc_EX ? pc_EX  : fwd_a_EX;
assign alu_in2 = alu_src_EX  ? imm_EX : fwd_b_EX;

alu alu1 (alu_in1, alu_in2, alu_op_EX, alu_raw_EX, zero);
assign alu_result_EX = (is_jal_EX || is_jalr_EX) ? pc_plus4_EX : alu_raw_EX;

EX_MEM p3 (clk, rst, alu_result_EX, fwd_b_EX, funct3_EX, reg_write_EX, mem_write_EX, mem_to_reg_EX, 
    rd_EX, alu_result_MEM, b_MEM, funct3_MEM, reg_write_MEM, mem_write_MEM, mem_to_reg_MEM, write_reg_MEM);


always_comb begin
    branch_taken = 1'b0;
    if (branch_EX) begin
        case (funct3_EX)
            F3_BEQ :          branch_taken = zero;
            F3_BNE:           branch_taken = ~zero;
            F3_BLT, F3_BLTU:  branch_taken =  alu_raw_EX[0];
            F3_BGE, F3_BGEU:  branch_taken = ~alu_raw_EX[0];
            default:          branch_taken = 1'b0;
        endcase
    end
end

assign branch_jal_target = pc_EX + imm_EX;
assign jalr_target = alu_raw_EX & 32'hFFFF_FFFE;

assign pc_next = is_jalr_EX ? jalr_target : (branch_taken | is_jal_EX) ? branch_jal_target : pc_plus4_IF;


assign flush_IFID = branch_taken | is_jal_EX | is_jalr_EX;
assign flush_IDEX = branch_taken | is_jal_EX | is_jalr_EX;

// MEM / WB stage
data_mem dm1 (clk, mem_write_MEM, alu_result_MEM, funct3_MEM, b_MEM, mem_read_data_MEM);

MEM_WB p4 (clk, rst, alu_result_MEM, mem_read_data_MEM, reg_write_MEM, mem_to_reg_MEM, write_reg_MEM,
        alu_result_WB, mem_read_data_WB, reg_write_WB, mem_to_reg_WB, write_reg_WB);

assign write_data = mem_to_reg_WB ? mem_read_data_WB : alu_result_WB;


// Performance counters:
logic valid_ID, valid_EX, valid_MEM, valid_WB;

assign valid_ID = (instr_ID != 32'b0);
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        valid_EX  <= 1'b0;
        valid_MEM <= 1'b0;
        valid_WB  <= 1'b0;
    end else begin
        valid_EX  <= (flush_IDEX || stall) ? 1'b0 : valid_ID;
        valid_MEM <= valid_EX;
        valid_WB  <= valid_MEM;
    end
end

// cpi
reg [31:0] cycle_count;
reg [31:0] instr_count;
logic done_flag;
always_ff @(posedge clk or posedge rst) begin
    if (rst) done_flag <= 1'b0;
    else if (mem_write_MEM && alu_result_MEM == 32'h1000_0004) done_flag <= 1'b1;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        cycle_count <= 0;
        instr_count <= 0;
    end
    else if (!done_flag) begin
        cycle_count <= cycle_count + 1;
        if(valid_WB) instr_count <= instr_count + 1;
    end
end

// stall counter
reg [31:0] stall_count;

always @(posedge clk or posedge rst) begin
    if(rst) stall_count <= 0;
    else if(stall) stall_count <= stall_count + 1;
end

// branch count
reg [31:0] branch_count;
reg [31:0] branch_taken_count;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        branch_count <= 0;
        branch_taken_count <= 0;
    end
    else begin
        if(branch_EX) branch_count <= branch_count + 1;
        if(branch_taken) branch_taken_count <= branch_taken_count + 1;
    end
end

// forward count
reg [31:0] forwardA_count;
reg [31:0] forwardB_count;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        forwardA_count <= 0;
        forwardB_count <= 0;
    end
    else begin
        if(forward_a != 2'b00) forwardA_count <= forwardA_count + 1;
        if(forward_b != 2'b00) forwardB_count <= forwardB_count + 1;
    end
end

endmodule