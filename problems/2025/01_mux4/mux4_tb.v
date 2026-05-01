`timescale 1ns/1ps

module mux4_tb;

localparam N = 32;

reg  [N-1:0] in_1 = 1'b0;
reg  [N-1:0] in_2 = 1'b1;
reg  [N-1:0] in_3 = {1'b1, {(N-1){1'b0}}};
reg  [N-1:0] in_4 = {N{1'b1}};
reg  [1:0]   sel = 1'b0;
wire [N-1:0] out;

function print_test_res;
    input [1:0] sel;
    input [N-1:0] ref_val, test_val;
    begin
        if (ref_val == test_val) begin
            $display("[%t] sel=%b, out=%b, expected=%b, OK", $realtime, sel, test_val, ref_val);
            print_test_res = 1;
        end
        else begin
            $display("[%t] sel=%b, out=%b, expected=%b, FAIL", $realtime, sel, test_val, ref_val);
            print_test_res = 0;
        end
    end
endfunction

integer are_tests_ok = 1;

always begin
    #1 case (sel)
        2'b00: are_tests_ok = are_tests_ok && print_test_res(sel, out, in_1);
        2'b01: are_tests_ok = are_tests_ok && print_test_res(sel, out, in_2);
        2'b10: are_tests_ok = are_tests_ok && print_test_res(sel, out, in_3);
        2'b11: are_tests_ok = are_tests_ok && print_test_res(sel, out, in_4);
    endcase

    #1 sel = sel + 1;

    if (sel == 0) begin
        if (are_tests_ok)
            $display("[%t] All tests passed", $realtime);
        else
            $display("[%t] Some tests failed", $realtime);
        $finish;
    end
end

mux4 #(.N(N)) mux4_inst(.i_1(in_1), .i_2(in_2), .i_3(in_3), .i_4(in_4), .i_sel(sel), .o_res(out));

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
    #10000 $finish;
end

endmodule   