module fpga_top(
    input  wire CLK,
    input  wire RSTN,

    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE,
    input  wire RXD
);

localparam RATE = 2_000_000;

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire [7:0] rx_data;
wire       rx_vld;

reg [15:0] hex_data;

always @(posedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        hex_data <= 16'hDEAD;
    end else if (rx_vld) begin
        hex_data <= {hex_data[7:0], rx_data};
    end
end

uart_rx #(
    .FREQ       (50_000_000),
    .RATE       (      RATE)
) u_uart_rx (
    .clk        (CLK    ),
    .rst_n      (rst_n  ),
    .i_rx       (RXD    ),
    .o_data     (rx_data),
    .o_vld      (rx_vld )
);

wire  [3:0] anodes;
wire  [7:0] segments;

hex_display hex_display(
    .clk       (CLK     ),
    .rst_n     (rst_n   ),
    .i_data    (hex_data), 
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
