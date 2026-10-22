module data_mem import rv32i_pkg::*; #(
    parameter int DEPTH = 4096
)(
    input  logic clk, mem_write,
    input  logic [31:0] addr,
    input  logic [2:0]  funct3,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

localparam int AW = $clog2(DEPTH);
logic [31:0] mem [0:DEPTH-1];
logic [31:0] selected_word;
logic [7:0]  selected_byte;
logic [15:0] selected_half;

initial begin
    for (int i = 0 ; i < DEPTH ; i = i + 1) mem[i] = 32'b0;
end

string prog_file;
initial begin
    for (int i = 0 ; i < DEPTH ; i = i + 1) mem[i] = 32'b0;
    if (!$value$plusargs("PROG=%s", prog_file))
        prog_file = "programs/prog.mem";
    $readmemh(prog_file, mem);
end

always_ff @(posedge clk) begin
    if (mem_write) begin
        case (funct3)
            F3_SB: mem[addr[AW+1:2]][8*addr[1:0] +: 8] <= write_data[7:0];
            F3_SH: if (addr[0] == 1'b0) mem[addr[AW+1:2]][16*addr[1] +: 16] <= write_data[15:0];
            F3_SW: if (addr[1:0] == 2'b00) mem[addr[AW+1:2]] <= write_data;
            default: ;
        endcase
    end
end

always_comb begin
    selected_word = mem[addr[AW+1:2]];
    selected_byte = selected_word[8*addr[1:0] +: 8];
    selected_half = selected_word[16*addr[1] +: 16];
    read_data = '0;
    case (funct3)
        F3_LB:   read_data = {{24{selected_byte[7]}}, selected_byte};
        F3_LH:   read_data = {{16{selected_half[15]}}, selected_half};
        F3_LW:   read_data = selected_word;
        F3_LBU:  read_data = {24'b0, selected_byte};
        F3_LHU:  read_data = {16'b0, selected_half};
        default: read_data = 32'b0;
    endcase 
end

endmodule
