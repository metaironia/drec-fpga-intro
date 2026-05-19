module lfsr_8bit_fibonacci (
    input  wire        clk,
    input  wire        rst_n,
    output reg  [7:0]  o_lfsr
);

wire fb;
assign fb = o_lfsr[0] ^ o_lfsr[2] ^ o_lfsr[3] ^ o_lfsr[4];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        o_lfsr <= 8'b1; 
    else
        o_lfsr <= {fb, o_lfsr[7:1]};
end

endmodule