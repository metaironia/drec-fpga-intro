module branch_unit #(
    parameter N = 32
)(
    input  wire [N-1:0] i_a,
    input  wire [N-1:0] i_b,
    input  wire [2:0]   i_cmp_op,
    output reg          o_taken
);

always @(*) begin
    case (i_cmp_op)
        3'b000: o_taken  = (i_a == i_b);
        3'b001: o_taken  = (i_a != i_b);
        3'b010: o_taken  = ($signed(i_a) < $signed(i_b));
        3'b011: o_taken  = ($signed(i_a) >= $signed(i_b));
        3'b100: o_taken  = i_a < i_b;
        3'b101: o_taken  = i_a >= i_b;
        default: o_taken = 0;
    endcase
end
    
endmodule