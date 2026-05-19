module mux4 #(
    parameter N = 32
)(
    input  wire [N-1:0] i_1,
    input  wire [N-1:0] i_2,
    input  wire [N-1:0] i_3,
    input  wire [N-1:0] i_4,
    input  wire [1:0]   i_sel,
    output reg  [N-1:0] o_res
);

always @(*) begin
    case (i_sel)
        2'b00: o_res = i_1;
        2'b01: o_res = i_2;
        2'b10: o_res = i_3;
        2'b11: o_res = i_4; 
    endcase
end
    
endmodule