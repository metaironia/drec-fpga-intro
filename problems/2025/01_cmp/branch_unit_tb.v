`timescale 1ns/1ps

module branch_unit_tb;

localparam N = 32;

reg  [N-1:0] in_a   = 1'b0;
reg  [N-1:0] in_b   = 1'b0; 
reg  [2:0]   cmp_op = 3'b0;

reg  test_ref;
wire taken;

function [N-1:0] beq;
    input [N-1:0] a, b;
    begin
        beq = (a == b);
    end
endfunction

function [N-1:0] bne;
    input [N-1:0] a, b;
    begin
        bne = (a != b);
    end
endfunction

function [N-1:0] blt;
    input [N-1:0] a, b;

    begin
        blt = ($signed(a) < $signed(b));
    end
endfunction

function [N-1:0] bge;
    input [N-1:0] a, b;
    begin
        bge = ($signed(a) >= $signed(b));
    end
endfunction

function [N-1:0] bltu;
    input [N-1:0] a, b;
    begin
        bltu = (a < b);
    end
endfunction

function [N-1:0] bgeu;
    input [N-1:0] a, b;
    begin
        bgeu = (a >= b);
    end
endfunction

function print_test_res;
    input ref_val, test_val;
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
    input [3:0]   cmp_op;
    begin
        $display("[%t] cmp_op=%b, a=%b, b=%b", $realtime, cmp_op, a, b);
    end
endtask

integer are_tests_ok = 1;

localparam first_checkpoint_value = {1'b1, 7'b0};
localparam second_checkpoint_value = 0 - {1'b1, 7'b0};

// in_a and in_b can only be in the range 0, ..., first_checkpoint_value, second_checkpoint_value, ..., N(0'b1}
always begin
    #1 case (cmp_op)
        3'b000: test_ref = beq(in_a, in_b);
        3'b001: test_ref = bne(in_a, in_b);
        3'b010: test_ref = blt(in_a, in_b);
        3'b011: test_ref = bge(in_a, in_b); 
        3'b100: test_ref = bltu(in_a, in_b); 
        3'b101: test_ref = bgeu(in_a, in_b);
        default: test_ref = 666;
    endcase
    print_curr_test(in_a, in_b, cmp_op);
    are_tests_ok = are_tests_ok && print_test_res(test_ref, taken);
    
    #1 in_b = in_b + 1;

    if (in_b == first_checkpoint_value + 1)
        in_b = second_checkpoint_value;

    if (in_b == 0) begin
        in_a = in_a + 1;

        if (in_a == first_checkpoint_value + 1)
            in_a = second_checkpoint_value;
    end

    if (in_a == 0 && in_b == 0)
        cmp_op = cmp_op + 1;

    if (in_a == 0 && in_b == 0 && cmp_op == 3'b110) begin
        if (are_tests_ok)
            $display("[%t] All tests passed", $realtime);
        else
            $display("[%t] Some tests failed", $realtime);
        $finish;
    end
end

branch_unit #(.N(N)) branch_unit_inst(.i_a(in_a), .i_b(in_b), .i_cmp_op(cmp_op), .o_taken(taken));

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
    #10000000000000 $finish;
end

endmodule   