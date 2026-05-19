`timescale 1ns / 1ps

module lfsr_tb;

reg        clk    = 1'b0;
reg        rst_n  = 1'b0;
wire [7:0] lfsr_out;
reg  [7:0] initial_val;

always 
    #1 clk = ~clk;

initial begin
    repeat(3) @(posedge clk);
    rst_n <= 1'b1;

    repeat(40) @(posedge clk);
    initial_val = lfsr_out;
    @(posedge clk);
   
    $display("[%t] Initial state = %b", $realtime, initial_val);

    repeat(254) @(posedge clk);

    if (lfsr_out == initial_val) begin
        $display("[%t] Test passed", $realtime);
    end else begin
        $display("[%t] Test failed, expected = %b, ref = %b", $realtime, initial_val, lfsr_out);
    end

    $finish;
end

lfsr_8bit_fibonacci lfst_inst (
    .clk    (clk),
    .rst_n  (rst_n),
    .o_lfsr (lfsr_out)
);

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
    #10000 $finish;
end

endmodule