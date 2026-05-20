module fp16mul #(
    parameter EXP_BITS = 5,
    parameter MANT_BITS = 10
)(
    input  wire [EXP_MANT_BITS:0] i_a,
    input  wire [EXP_MANT_BITS:0] i_b,
    output wire [EXP_MANT_BITS:0] o_res
);

localparam EXP_MANT_BITS = EXP_BITS + MANT_BITS;
localparam DOUBLE_MANT_SIZE = (MANT_BITS + 1) * 2;

function get_sign_bit;
    input [EXP_MANT_BITS:0] fp16;
    begin
        get_sign_bit = fp16[EXP_MANT_BITS];
    end
endfunction

function [EXP_BITS-1:0] get_exponent_bits;
    input [EXP_MANT_BITS:0] fp16;
    begin
        get_exponent_bits = fp16[EXP_MANT_BITS-1:MANT_BITS];
    end
endfunction

function [MANT_BITS-1:0] get_mantissa_bits;
    input [EXP_MANT_BITS:0] fp16;
    begin
        get_mantissa_bits = fp16[MANT_BITS-1:0];
    end
endfunction

wire              should_swap;
wire [EXP_BITS:0] exp_diff;


exp_difference exp_difference_inst(
    .i_exp_a(get_exponent_bits(i_a)),
    .i_exp_b(get_exponent_bits(i_b)),
    .o_is_a_lt_b(should_swap),
    .o_exp_diff(exp_diff)
);

sign_magnitude_adder mant_adder_inst(
    

);

endmodule

module exp_difference #(
    parameter EXP_BITS = 5
)(
    input  wire [EXP_BITS-1:0] i_exp_a,
    input  wire [EXP_BITS-1:0] i_exp_b,
    output wire                o_is_a_lt_b,
    output wire [EXP_BITS:0]   o_exp_diff
)

assign o_is_a_lt_b = i_exp_a < i_exp_b; 
assign o_exp_diff = o_is_a_lt_b 
                      ? (i_exp_b - i_exp_a) 
                      : (i_exp_a - i_exp_b);

endmodule

module swap_operands#(
    parameter EXP_BITS = 5,
    parameter MANT_BITS = 10
)(
    input  wire [EXP_MANT_BITS:0] i_a,
    input  wire [EXP_MANT_BITS:0] i_b,
    input  wire                   
    output wire [EXP_MANT_BITS:0] o_res
);