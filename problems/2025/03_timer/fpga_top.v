module fpga_top(
    input  wire CLK,
    input  wire RSTN,
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

localparam CNT_MAX = 600;

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire  [3:0] anodes;
wire  [7:0] segments;

wire clk10hz;
wire [15:0] cnt;

clkdiv #(.F0(50000000), .F1(10)) clk10hz_inst(
    .clk      (CLK    ),
    .rst_n    (rst_n  ),
    .o_new_clk(clk10hz)
);

counter #(.CNT_MAX(CNT_MAX)) cnt_to_600 (
    .clk        (clk10hz),
    .rst_n      (rst_n  ),
    .o_count_res(cnt    )
);

hex_display hex_display(
    .clk       (CLK     ),
    .rst_n     (rst_n   ),
    .i_data    (cnt     ),
    .o_anodes  (anodes  ),
    .o_segments(segments)
);

ctrl_74hc595 ctrl(
    .clk    (CLK               ),
    .rst_n  (rst_n             ),
    .i_data ({segments, anodes}),
    .o_stcp (STCP              ),
    .o_shcp (SHCP              ),
    .o_ds   (DS                ),
    .o_oe   (OE                )
);

endmodule
