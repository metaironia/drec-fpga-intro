`timescale 1ns/1ps

module signext_tb;

localparam N = 12;
localparam M = 32;

reg  [N-1:0] in  = {N{1'b0}};
wire [M-1:0] out;

always begin
    #1 if (out[N-1:0] == in[N-1:0]) begin
        if (out[M-1:N] == {(M-N){in[N-1]}})
            $display("[%t] in=%b, out=%b, OK", $realtime, in, out);
        else
            $display("[%t] in=%b, out=%b, FAIL", $realtime, in, out);
        end
    #1 in = in + 1;
    if (in == 0) begin
       $display("[%t] Done", $realtime);
       $finish;
    end
end

signext #(.N(N)) signext_inst(.i_num(in), .o_signextnum(out));

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
    #10000 $finish;
end

endmodule