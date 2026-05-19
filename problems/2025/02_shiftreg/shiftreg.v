module shift_reg #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  i_ld,
    input  wire                  i_lsb,
    input  wire                  i_en,
    input  wire [DATA_WIDTH-1:0] i_data,
    output wire                  o_res
);

reg [DATA_WIDTH-1:0] shift_reg;

assign o_res = shift_reg[7];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        shift_reg <= 1'b0;
    else if (i_ld)
        shift_reg <= i_data;
    else if (i_en)
        shift_reg <= {shift_reg[DATA_WIDTH-2:0], i_lsb};
end

endmodule