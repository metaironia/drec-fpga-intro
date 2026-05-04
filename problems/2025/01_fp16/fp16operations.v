module exponent_adder #(
    parameter EXP_BITS = 5
)(
    input wire [EXP_BITS-1:0] i_exp_a,
    input wire [EXP_BITS-1:0] i_exp_b,
    output reg [EXP_BITS-1:0] o_res_exp,
    output reg o_is_inf
);

reg [EXP_BITS:0] tmp_exp;

always @(*) begin
    tmp_exp = i_exp_a + i_exp_b;
    if (tmp_exp[EXP_BITS] >= {(EXP_BITS-1){1'b1}}) begin
        o_is_inf = 1'b1;
        o_res_exp = {EXP_BITS{1'b1}};
    end
    else begin
        o_is_inf = 1'b0;
        o_res_exp = tmp_exp[EXP_BITS-1:0];
    end
end

endmodule

module exponent_updater #(
    parameter EXP_BITS = 5
)(
    input wire [EXP_BITS-1:0] i_exp_a,
    input wire i_update,
    input wire i_is_inf,
    output reg [EXP_BITS-1:0] o_res_exp,
    output reg o_is_inf
);

wire exp_adder_is_inf;
wire [EXP_BITS-1:0] exp_adder_res_exp;

reg [EXP_BITS-1:0] one = {{(EXP_BITS-1){1'b0}}, 1'b1};

always @(*) begin
    if (!i_update) begin
        o_is_inf = i_is_inf;
        o_res_exp = i_exp_a;
    end
    else begin
        o_is_inf = exp_adder_is_inf;
        o_res_exp = exp_adder_res_exp;
    end
end

exponent_adder #(.EXP_BITS(EXP_BITS)) exp_adder(.i_exp_a(i_exp_a), .i_exp_b(one),
                                                .o_res_exp(exp_adder_res_exp), .o_is_inf(exp_adder_is_inf));

endmodule

module denormal_as_zero #(
    parameter EXP_BITS = 5,
    parameter MANT_BITS = 10
)(
    input  wire [EXP_MANT_BITS:0] i_a,
    output reg  [EXP_MANT_BITS:0] o_res
);

localparam EXP_MANT_BITS = EXP_BITS + MANT_BITS;

always @(*) begin
    if (!(|i_a[EXP_MANT_BITS-1:MANT_BITS]))
        o_res = {i_a[EXP_MANT_BITS:MANT_BITS], {MANT_BITS{1'b1}}};
end

endmodule

module normalize_mantissa_after_mul #(
    parameter MANT_BITS = 10
)(
    input wire [((EXP_BITS+1)*2)-1:0] i_mant,
    output reg [((EXP_BITS+1)*2)-1:0] o_mant,
    output reg o_is_shifted
);

always @(*) begin
    if (i_mant[((EXP_BITS+1)*2)-1] == 1'b1) begin
        o_mant = i_mant >> 1;
        o_is_shifted = 1'b1;
    end
    else begin
        o_mant = i_mant;
        o_is_shifted = 1'b0;
    end
end

endmodule