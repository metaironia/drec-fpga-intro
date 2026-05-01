module alu #(
    parameter N = 32
)(
    input  wire [N-1:0] i_a,
    input  wire [N-1:0] i_b,
    input  wire [4:0]   i_op,
    output reg  [N-1:0] o_res
);

localparam [N-1:0] one = {{(N-1){1'b0}}, {1'b1}};
localparam [N-1:0] zero = {N{1'b0}};

always @(*) begin
    case (i_op)
        4'b0000: o_res = i_a + i_b;
        4'b0001: o_res = i_a - i_b;
        4'b0010: o_res = i_a << i_b[4:0];
        4'b0011: o_res = ($signed(i_a) < $signed(i_b)) ? one : zero; 
        4'b0100: o_res = (i_a < i_b) ? one : zero; 
        4'b0101: o_res = i_a ^ i_b;
        4'b0110: o_res = i_a >> i_b[4:0];
        4'b0111: o_res = $signed(i_a) >>> i_b[4:0];
        4'b1000: o_res = i_a | i_b;
        4'b1001: o_res = i_a & i_b;
        default: o_res = zero;
    endcase
end
    
endmodule