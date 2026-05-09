module round_toward_zero #(
    parameter MANT_BITS = 10
)(
    input  wire [DOUBLE_MANT_SIZE-1:0] i_mant,
    output reg  [MANT_BITS-1:0]        o_mant
);

localparam DOUBLE_MANT_SIZE = (MANT_BITS + 1) * 2;

always @(*) begin
    o_mant = i_mant[DOUBLE_MANT_SIZE-3:MANT_BITS];
end 

endmodule

module is_nan #(
    parameter EXP_BITS = 5,
    parameter MANT_BITS = 10
)(
    input  wire [EXP_MANT_BITS:0] i_a,
    output reg                    o_is_nan
);

localparam EXP_MANT_BITS = EXP_BITS + MANT_BITS;

always @(*) begin
    o_is_nan = &i_a[EXP_MANT_BITS-1:MANT_BITS] & |i_a[MANT_BITS-1:0];
end

endmodule

module exponent_adder #(
    parameter EXP_BITS = 5
)(
    input  wire [EXP_BITS-1:0] i_exp_a,
    input  wire [EXP_BITS-1:0] i_exp_b,
    output reg  [EXP_BITS-1:0] o_res_exp,
    output reg                 o_is_inf
);

reg [EXP_BITS:0] tmp_exp;

wire [EXP_BITS-2:0] bias;
wire [EXP_BITS:0] three_biases;

assign bias = {(EXP_BITS-1){1'b1}};
assign three_biases = bias * 3;
// TODO biases
always @(*) begin
    tmp_exp = i_exp_a + i_exp_b;
    if (tmp_exp < bias) begin
        o_is_inf = 1'b0;
        o_res_exp = 1'b0;
    end
    if (tmp_exp > three_biases) begin
        o_is_inf = 1'b1;
        o_res_exp = {EXP_BITS{1'b1}};
    end
    else begin
        o_is_inf = 1'b0;
        o_res_exp = tmp_exp - bias;
    end
end

endmodule

module exponent_updater #(
    parameter EXP_BITS = 5
)(
    input  wire [EXP_BITS-1:0] i_exp_a,
    input  wire                i_update,
    input  wire                i_is_inf,
    output reg  [EXP_BITS-1:0] o_res_exp,
    output reg                 o_is_inf
);

reg [EXP_BITS-1:0] one = {{(EXP_BITS-1){1'b0}}, 1'b1};

always @(*) begin
    if (!i_update || i_is_inf) begin
        o_is_inf = i_is_inf;
        o_res_exp = i_exp_a;
    end
    else if (!i_is_inf) begin
        o_res_exp = i_exp_a + 1'b1;
        if (&o_res_exp[EXP_BITS-1:0])
            o_is_inf = 1'b1;
        else
            o_is_inf = 1'b0;
    end
end

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
        o_res = {i_a[EXP_MANT_BITS], {(EXP_MANT_BITS){1'b0}}};
    else
        o_res = i_a;
end

endmodule

module normalize_mantissa_after_mul #(
    parameter MANT_BITS = 10
)(
    input wire [DOUBLE_MANT_SIZE-1:0] i_mant,
    output reg [DOUBLE_MANT_SIZE-1:0] o_mant,
    output reg o_is_shifted
);

localparam DOUBLE_MANT_SIZE = (MANT_BITS + 1) * 2;

always @(*) begin
    if (i_mant[DOUBLE_MANT_SIZE-1] == 1'b1) begin
        o_mant = i_mant >> 1;
        o_is_shifted = 1'b1;
    end
    else begin
        o_mant = i_mant;
        o_is_shifted = 1'b0;
    end
end

endmodule