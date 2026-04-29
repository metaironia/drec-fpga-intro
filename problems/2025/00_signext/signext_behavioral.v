module signext #(
    parameter N = 12,
    parameter M = 32
)(
    input  wire [N-1:0] i_num,
    output wire [M-1:0] o_signextnum
);

assign o_signextnum = {{(M - N){i_num[N-1]}}, i_num[N-1:0]};

endmodule