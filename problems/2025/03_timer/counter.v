module counter #(
    parameter CNT_MAX = 600
)(
    input  wire        clk,
	input  wire  	   rst_n,
    output reg  [15:0] o_count_res
);

reg [3:0] counter;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		o_count_res <= CNT_MAX;
		counter <= 1'b0;
	end
	else if (o_count_res == 0) begin
		o_count_res <= CNT_MAX;
		counter <= 1'b0;
	end
	else begin
		if (counter == 4'd9) begin
			o_count_res <= o_count_res - 15'd10;
			counter <= 1'b0;
		end
		else
			counter <= counter + 1'b1;
	end
end

endmodule