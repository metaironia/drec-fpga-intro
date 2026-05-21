module reg_file #(
    parameter REG_NUM  = 32,
    parameter REG_SIZE = 32
)(
    input  wire                 clk,

    input  wire  [REG_ADDR-1:0] i_rd_addr1,
    output wire  [REG_SIZE-1:0] o_rd_data1,
    input  wire  [REG_ADDR-1:0] i_rd_addr2,
    output wire  [REG_SIZE-1:0] o_rd_data2,

    input  wire  [REG_ADDR-1:0] i_wr_addr,
    input  wire  [REG_SIZE-1:0] i_wr_data,
    input  wire                 i_wr_en
);

localparam REG_ADDR = $clog2(REG_NUM);

reg [REG_SIZE-1:0] r[REG_NUM-1:0];

assign o_rd_data1 = r[i_rd_addr1];
assign o_rd_data2 = r[i_rd_addr2];

always @(posedge clk) begin
    if (i_wr_en && (i_wr_addr != 0)) begin
        r[i_wr_addr] <= i_wr_data;
    end
end

endmodule