

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
localparam BIAS = 2 ** (EXP_BITS - 1) - 1; 

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

wire is_initial_inf;
wire is_inf_after_norm;

wire [EXP_BITS-1:0] initial_exp_sum;
wire [EXP_BITS-1:0] exp_sum_after_norm;

wire [EXP_MANT_BITS:0] i_a_das;
wire [EXP_MANT_BITS:0] i_b_das;

wire is_a_nan;
wire is_b_nan;

wire [MANT_BITS:0] full_mant_a;
wire [MANT_BITS:0] full_mant_b;

assign full_mant_a = {1'b1, get_mantissa_bits(i_a_das)}; 
assign full_mant_b = {1'b1, get_mantissa_bits(i_b_das)}; 

wire [DOUBLE_MANT_SIZE-1:0] mant_mul_res;
wire [DOUBLE_MANT_SIZE-1:0] mant_mul_after_norm;
wire [MANT_BITS-1:0] mant_mul_after_round;

reg [EXP_MANT_BITS:0] num_after_round;

assign mant_mul_res = full_mant_a * full_mant_b;

// rounding towards zero
always @(*) begin
    num_after_round[EXP_MANT_BITS] = get_sign_bit(i_a) ^ get_sign_bit(i_b);
    
    if (is_a_nan || is_b_nan)
        num_after_round[EXP_MANT_BITS-1:0] = {{(EXP_BITS){1'b1}}, {(MANT_BITS-1){1'b0}}, {1'b1}}; 
    else if (is_inf_after_norm)
        num_after_round[EXP_MANT_BITS-1:0] = {{(EXP_BITS){1'b1}}, {(MANT_BITS){1'b0}}};
    else
        num_after_round[EXP_MANT_BITS-1:0] = {exp_sum_after_norm, mant_mul_after_round};
end

is_nan #(.EXP_BITS(EXP_BITS), .MANT_BITS(MANT_BITS)) is_in_a_nan_inst(.i_a(i_a),
                                                                      .o_is_nan(is_a_nan));

is_nan #(.EXP_BITS(EXP_BITS), .MANT_BITS(MANT_BITS)) is_in_b_nan_inst(.i_a(i_b),
                                                                      .o_is_nan(is_b_nan));

denormal_as_zero #(.EXP_BITS(EXP_BITS), .MANT_BITS(MANT_BITS)) get_das_in_a_inst(.i_a(i_a),
                                                                                 .o_res(i_a_das));

denormal_as_zero #(.EXP_BITS(EXP_BITS), .MANT_BITS(MANT_BITS)) get_das_in_b_inst(.i_a(i_b),
                                                                                 .o_res(i_b_das));

exponent_adder #(.EXP_BITS(EXP_BITS)) initial_exp_adder_inst(.i_exp_a(get_exponent_bits(i_a_das)),
                                                             .i_exp_b(get_exponent_bits(i_b_das)),
                                                             .o_res_exp(initial_exp_sum),
                                                             .o_is_inf(is_initial_inf));

normalize_mantissa_after_mul #(.MANT_BITS(MANT_BITS)) norm_mant_inst(.i_mant(mant_mul_res),
                                                                     .o_mant(mant_mul_after_norm),
                                                                     .o_is_shifted(is_mant_shifted_after_norm));

exponent_updater #(.EXP_BITS(EXP_BITS)) exp_updater_after_norm_inst(.i_exp_a(initial_exp_sum),
                                                                    .i_update(is_mant_shifted_after_norm),
                                                                    .i_is_inf(is_initial_inf),
                                                                    .o_res_exp(exp_sum_after_norm),
                                                                    .o_is_inf(is_inf_after_norm));

round_toward_zero #(.MANT_BITS(MANT_BITS)) round_mant_after_norm_inst(.i_mant(mant_mul_after_norm),
                                                                      .o_mant(mant_mul_after_round));

denormal_as_zero #(.EXP_BITS(EXP_BITS), .MANT_BITS(MANT_BITS)) get_das_out_inst(.i_a(num_after_round),
                                                                                .o_res(o_res));

endmodule