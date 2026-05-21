`timescale 1ns/1ps

module tb;

reg clk   = 1'b0;
reg rst_n = 1'b0;

always begin
    #1 clk <= ~clk;
end

initial begin
    repeat (3) @(posedge clk);
    rst_n <= 1'b1;
end

wire       o_vld;
wire [7:0] o_data;
reg        i_rx;

uart_rx #(
    .FREQ(1000000),
    .RATE(115200)
)
uart_rx (
    .clk        (clk    ),
    .rst_n      (rst_n  ),
    .i_rx       (i_rx   ),
    .o_data     (o_data ),
    .o_vld      (o_vld  )
);

wire [7:0] TEST_VAL = 8'b10101100;

initial begin
    i_rx = 1'b1;
    repeat (100) @(posedge clk);
    i_rx = 1'b0;
    repeat (8) @(posedge clk);
    for (integer i = 0; i < 8; i = i + 1) begin
        i_rx = TEST_VAL[i];
        repeat (8) @(posedge clk);
    end
    i_rx = 1'b1;
    @(posedge o_vld);

    if (o_data != TEST_VAL)
        $display("[%t] Test failed, o_data = %b, expected = %b", $time, o_data, TEST_VAL);
    else
        $display("[%t] Test passed, o_data = %b, expected = %b", $time, o_data, TEST_VAL);
end

initial begin
    $dumpvars;
    #1000000 $finish;
end

endmodule