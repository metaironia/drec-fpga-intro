

module fp16mul #(
    parameter EXP_BITS = 5,
    parameter MANT_BITS = 10
)(
    input  wire [EXP_MANT_BITS:0] i_a,
    input  wire [EXP_MANT_BITS:0] i_b,
    output reg  [EXP_MANT_BITS:0] o_res
);

localparam EXP_MANT_BITS = EXP_BITS + MANT_BITS;

function get_sign_bit;
    input [EXP_MANT_BITS:0] fp_16;
    begin
        get_sign_bit = fp16[EXP_MANT_BITS];
    end
endfunction

function get_exponent_bits;
    input [EXP_MANT_BITS:0] fp_16;
    begin
        get_exponent_bits = fp16[EXP_MANT_BITS-1:MANT_BITS];
    end
endfunction

function get_mantissa_bits;
    input [EXP_MANT_BITS:0] fp_16;
    begin
        get_mantissa_bits = fp16[MANT_BITS-1:0];
    end
endfunction

assign o_res[EXP_MANT_BITS] = get_sign_bit(i_a) ^ get_sign_bit(i_b);

wire is_initial_inf;
wire is_inf_after_norm;

wire initial_exp_sum;
wire exp_sum_after_norm;

reg [2*(MANT_BITS+1)-1:0] mant_mul_res;

wire [MANT_BITS:0] full_mant_a;
wire [MANT_BITS:0] full_mant_b; 

assign full_mant_a = {1'b1, get_mantissa_bits(i_a)}; 
assign full_mant_b = {1'b1, get_mantissa_bits(i_b)}; 

// rounding towards zero
always @(*) begin
    mant_mul_res = full_mant_a * full_mant_b;
    if (mant_mul_res[2*(MANT_BITS+1)-1] == 1'b1)
        o_res[MANT_BITS:0] = mant_mul_res[2*(MANT_BITS+1)-2:2*(MANT_BITS+1)-1];

end

exponent_adder #(.EXP_BITS(EXP_BITS)) initial_exp_adder_inst(.i_exp_a(get_exponent_bits(i_a)),
                                                             .i_exp_b(get_exponent_bits(i_b)),
                                                             .o_res_exp(initial_exp_sum),
                                                             .o_is_inf(is_initial_inf))

normalize_mantissa_after_mul #(.MANT_BITS(MANT_BITS)) norm_mant_inst(.i_mant(mant_mul_res),
                                                                     .o_mant(mant_mul_after_norm),
                                                                     .o_is_shifted(is_mant_shifted_after_norm)));

exponent_updater #(.EXP_BITS(EXP_BITS)) exp_updater_after_norm_inst(.i_exp_a(initial_exp_sum),
                                                                    .i_update(mant_mul_res[2*(MANT_BITS+1)-1]),
                                                                    .i_is_inf(is_initial_inf),
                                                                    .o_res_exp(exp_sum_after_norm),
                                                                    .o_is_inf(is_inf_after_norm));


endmodule