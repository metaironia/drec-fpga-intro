module 1R1W_mem #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
)(
    input  wire                     clk,
    input  wire [$clog2(DEPTH)-1:0] i_rd_addr,
    output wire [WIDTH-1:0]         o_rd_data,
    input  wire [$clog2(DEPTH)-1:0] i_wr_addr,
    input  wire [WIDTH-1:0]         i_wr_data,
    input  wire                     i_wr_en
);

reg [WIDTH-1:0] mem[DEPTH-1:0];

assign o_rd_data = mem[i_rd_addr];

always @(posedge clk) begin
    if (i_wr_en) begin
        mem[i_wr_addr] <= i_wr_data;
    end
end

endmodule

module sync_fifo #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst_n,

    input  wire [WIDTH-1:0] i_wr_data,
    input  wire             i_wr_en,
    output wire             o_wr_full,

    output wire [WIDTH-1:0] o_rd_data,
    input  wire             i_rd_en,
    output wire             o_rd_empty
);

localparam ADDR_WIDTH = $clog2(DEPTH);

reg [ADDR_WIDTH:0] wr_ptr;
reg [ADDR_WIDTH:0] rd_ptr;

wire [ADDR_WIDTH-1:0] wr_addr;
wire [ADDR_WIDTH-1:0] rd_addr;

assign wr_addr = wr_ptr[ADDR_WIDTH-1:0];
assign rd_addr = rd_ptr[ADDR_WIDTH-1:0];

assign o_rd_empty = (wr_ptr == rd_ptr);

assign o_wr_full = (wr_ptr[ADDR_WIDTH-1] != rd_ptr[ADDR_WIDTH] && 
                    wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= 1'b0;
        rd_ptr <= 1'b0;
    end
    else begin
        if (i_wr_en && !o_wr_full) begin
            wr_ptr <= wr_ptr + 1;
        end

        if (i_rd_en && !o_rd_empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end
end

1R1W_mem #(
    .DEPTH(DEPTH),
    .WIDTH(WIDTH)
) 1R1W_mem_inst (
    .clk(clk),
    .i_rd_addr(rd_addr),
    .o_rd_data(o_rd_data),
    .i_wr_addr(wr_addr),
    .i_wr_data(i_wr_data),
    .i_wr_en(i_wr_en && !o_wr_full)
);

endmodule