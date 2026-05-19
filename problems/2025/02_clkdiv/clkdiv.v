module clkdiv #(
    parameter F0 = 50000000,
    parameter F1 = 9600
)(
    input  clk,
    input  rst_n,
    output o_new_clk
);

localparam DIV_FACTOR = (F0 + (F1 / 2)) / F1;

localparam CNT_WIDTH = $clog2(DIV_FACTOR);

reg [CNT_WIDTH-1:0] cnt;

assign o_new_clk = (cnt == DIV_FACTOR - 1);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt <= 1'b0;
    else if (cnt == DIV_FACTOR - 1)
        cnt <= 1'b0;
    else
        cnt <= cnt + 1'b1;
end

endmodule