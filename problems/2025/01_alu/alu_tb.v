`timescale 1ns/1ps

module alu_tb;

localparam N = 32;

reg  [N-1:0] in_a   = {N{1'b0}};
reg  [N-1:0] in_b   = {N{1'b0}}; 
reg  [4:0]   alu_op = 4'b0;
reg  [N-1:0] test_ref;
wire [N-1:0] out;

localparam [N-1:0] one = {{(N-1){1'b0}}, {1'b1}};
localparam [N-1:0] zero = {N{1'b0}};

function [N-1:0] add;
    input [N-1:0] a, b;
    begin
        add = a + b;
    end
endfunction

function [N-1:0] sub;
    input [N-1:0] a, b;
    begin
        sub = a - b;
    end
endfunction

function [N-1:0] sll;
    input [N-1:0] a;
    input [4:0]   b;
    begin
        sll = a << b;
    end
endfunction

function [N-1:0] slt;
    input [N-1:0] a, b;
    begin
        slt = ($signed(a) < $signed(b)) ? one : zero;
    end
endfunction

function [N-1:0] sltu;
    input [N-1:0] a, b;
    begin
        sltu = (a < b) ? one : zero;
    end
endfunction

function [N-1:0] xor_f;
    input [N-1:0] a, b;
    begin
        xor_f = a ^ b;
    end
endfunction

function [N-1:0] srl;
    input [N-1:0] a;
    input [4:0]   b;
    begin
        srl = a >> b;
    end
endfunction

function [N-1:0] sra;
    input [N-1:0] a;
    input [4:0]   b;
    begin
        sra = $signed(a) >>> b;
    end
endfunction

function [N-1:0] or_f;
    input [N-1:0] a, b;
    begin
        or_f = a | b;
    end
endfunction

function [N-1:0] and_f;
    input [N-1:0] a, b;
    begin
        and_f = a & b;
    end
endfunction

function print_test_res;
    input [N-1:0] ref_val, test_val;
    begin
        if (ref_val == test_val) begin
            $display("[%t] ref_val=%b, test_val=%b, OK", $realtime, ref_val, test_val);
            print_test_res = 1;
        end
        else begin
            $display("[%t] ref_val=%b, test_val=%b, FAIL", $realtime, ref_val, test_val);
            print_test_res = 0;
        end
    end
endfunction

task print_curr_test;
    input [N-1:0] a, b;
    input [4:0]   op;
    begin
        $display("[%t] alu_op=%b, a=%b, b=%b", $realtime, op, a, b);
    end
endtask

integer are_tests_ok = 1;

localparam first_checkpoint_value = {1'b1, 7'b0};
localparam second_checkpoint_value = 0 - {1'b1, 7'b0};


// in_a and in_b can only be in the range 0, ..., first_checkpoint_value, second_checkpoint_value, ..., N(0'b1}
always begin
    #1 case (alu_op)
        4'b0000: test_ref = add(in_a, in_b);
        4'b0001: test_ref = sub(in_a, in_b);
        4'b0010: test_ref = sll(in_a, in_b);
        4'b0011: test_ref = slt(in_a, in_b); 
        4'b0100: test_ref = sltu(in_a, in_b); 
        4'b0101: test_ref = xor_f(in_a, in_b);
        4'b0110: test_ref = srl(in_a, in_b);
        4'b0111: test_ref = sra(in_a, in_b);
        4'b1000: test_ref = or_f(in_a, in_b);
        4'b1001: test_ref = and_f(in_a, in_b);
        default: test_ref = 0;
    endcase
    print_curr_test(in_a, in_b, alu_op);
    are_tests_ok = are_tests_ok && print_test_res(test_ref, out);
    
    #1 in_b = in_b + 1;

    if (in_b == first_checkpoint_value + 1)
        in_b = second_checkpoint_value;

    if (in_b == 0) begin
        in_a = in_a + 1;

        if (in_a == first_checkpoint_value + 1)
            in_a = second_checkpoint_value;
    end

    if (in_a == 0 && in_b == 0)
        alu_op = alu_op + 1;

    if (in_a == 0 && in_b == 0 && alu_op == 4'b1010) begin
        if (are_tests_ok)
            $display("[%t] All tests passed", $realtime);
        else
            $display("[%t] Some tests failed", $realtime);
        $finish;
    end
end

alu #(.N(N)) alu_inst(.i_a(in_a), .i_b(in_b), .i_op(alu_op), .o_res(out));

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
    #10000000000000 $finish;
end

endmodule   