module fp16add #(
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



endmodule