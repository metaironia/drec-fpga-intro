module fpga_top(
    input  wire CLK,
    input  wire RSTN,
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire  [3:0] anodes;
wire  [7:0] segments;

wire [15:0] lfsr_val;

wire clk1hz;

clkdiv #(.F0(50000000), .F1(1)) clk1hz_inst(
    .clk      (CLK   ),
    .rst_n    (rst_n ),
    .o_new_clk(clk1hz)
);

lfsr_16bit_fibonacci lfsr(
    .clk   (clk1hz  ),
    .rst_n (rst_n   ),
    .o_lfsr(lfsr_val)
);

hex_display hex_display(
    .clk       (CLK     ),
    .rst_n     (rst_n   ),
    .i_data    (lfsr_val),
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
