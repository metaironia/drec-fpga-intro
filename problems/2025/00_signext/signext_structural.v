module signext_onebit(
    input  wire i_bit,
    output wire o_bit
);

assign o_bit = i_bit;

endmodule

module signext #(
    parameter N = 12,
    parameter M = 32
)(
    input  wire [N-1:0] i_num,
    output wire [M-1:0] o_signextnum
);

generate
    genvar i;
    for (i = 0; i < M; i = i + 1) begin : gen_signext
        if (i < N)
            signext_onebit signext_lo_inst(.i_bit(i_num[i]), .o_bit(o_signextnum[i]));
        else
            signext_onebit signext_lo_inst(.i_bit(i_num[N-1]), .o_bit(o_signextnum[i]));
    end
endgenerate

endmodule