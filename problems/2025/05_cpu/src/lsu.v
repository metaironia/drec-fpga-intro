module lsu (
    input  wire [29:0] i_addr,
    input  wire [31:0] i_wr_data,
    input  wire [2:0]  i_mask,
    input  wire        i_wren,
    output reg  [31:0] o_data,
    output wire [29:0] o_mem_addr,
    output wire [31:0] o_mem_data,
    output wire        o_mem_we,
    output reg  [3:0]  o_mem_mask,
    input  wire [31:0] i_mem_data
);

assign o_mem_addr = i_addr;
assign o_mem_data = i_wr_data;
assign o_mem_we   = i_wren;

always @(*) begin
    case (i_mask)
        3'b000: o_data = {{24{i_mem_data[7]}}, i_mem_data[7:0]};
        3'b001: o_data = {{16{i_mem_data[15]}}, i_mem_data[15:0]};
        3'b010: o_data = i_mem_data;
        3'b100: o_data = {16'b0, i_mem_data[15:0]};
        3'b101: o_data = {i_mem_data[31:16], 16'b0};
        default: o_data = 32'b0;
    endcase
end

always @(*) begin
    case (i_mask)
        3'b000: o_mem_mask = 4'b0001;
        3'b001: o_mem_mask = 4'b0011;
        3'b010: o_mem_mask = 4'b1111;
        default: o_mem_mask = 4'b0000;
    endcase
end

endmodule