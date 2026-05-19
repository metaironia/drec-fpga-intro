module lfsr_16bit_fibonacci (
    input  wire        clk,
    input  wire        rst_n,
    output reg  [15:0] o_lfsr
);

wire fb;
assign fb = o_lfsr[0] ^ o_lfsr[2] ^ o_lfsr[3] ^ o_lfsr[5];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        o_lfsr <= 1'b1; 
    else
        o_lfsr <= {fb, o_lfsr[15:1]};
end

endmodule