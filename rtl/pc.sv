module pc(
    input  logic clk, rst,
    input  logic [31:0] pc_next,
    input  logic stall,
    output logic [31:0] pc_out
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) pc_out <= 32'd0;
    else if (stall) pc_out <= pc_out;
    else pc_out <= pc_next;
end

endmodule