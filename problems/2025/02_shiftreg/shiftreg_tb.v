`timescale 1ns/1ps

module tb_shift_reg;

localparam DATA_WIDTH = 8;

localparam INIT_VAL_WIDTH = 16;

reg [INIT_VAL_WIDTH-1:0] init_val = 16'b1011001000101011;

reg                   clk   = 1'b0;
reg                   rst_n = 1'b0;
reg                   i_ld  = 1'b0;
reg                   i_en  = 1'b0;
reg                   i_lsb = 1'b0;
reg  [DATA_WIDTH-1:0] i_data;
wire                  o_res;

always 
    #1 clk = ~clk;

integer counter = 0;

initial begin
    rst_n  = 1'b0;
    i_ld   = 1'b0;
    i_en   = 1'b0;
    i_data = 1'b0;

    repeat (3) @(posedge clk);

    rst_n = 1'b1;

    @(posedge clk);
    i_data = init_val[INIT_VAL_WIDTH-1-:DATA_WIDTH];
    i_ld   = 1'b1;
    @(posedge clk);
    i_ld = 1'b0;

    i_en = 1'b1;
    for (integer i = INIT_VAL_WIDTH-DATA_WIDTH; i != 0; i = i - 1) begin
        if (o_res == init_val[i+DATA_WIDTH-1])
            $display("[%t] Shift test passed (i_ld = 0), cycle %d | o_res = %b, expected = %b", $time, counter, o_res, init_val[i+DATA_WIDTH-1]);
        else
            $display("[%t] Shift test failed (i_ld = 0), cycle %d | o_res = %b, expected = %b", $time, counter, o_res, init_val[i+DATA_WIDTH-1]);
        i_lsb = init_val[i];
        @(posedge clk);        
        counter = counter + 1;
    end

    @(posedge clk);
    i_data = init_val[DATA_WIDTH-1:0];
    i_ld   = 1'b1;
    @(posedge clk);

    for (integer i = 0; i < DATA_WIDTH; i = i + 1) begin
        @(posedge clk);
        if (o_res == init_val[DATA_WIDTH-1])
            $display("[%t] Load test passed (i_ld = 1), cycle %d | o_res = %b, expected = %b", $time, i+1, o_res, init_val[DATA_WIDTH-1]);
        else
            $display("[%t] Load test failed (i_ld = 1), cycle %d | o_res = %b, expected = %b", $time, i+1, o_res, init_val[DATA_WIDTH-1]);
    end
    
    i_ld = 1'b0;
    i_en = 1'b0;

    @(posedge clk);

    for (integer i = 0; i < DATA_WIDTH; i = i + 1) begin
        @(posedge clk);
        if (o_res == init_val[DATA_WIDTH-2])
            $display("[%t] Hold test passed (i_en = 0), cycle %d | o_res = %b, expected = %b", $time, i+1, o_res, init_val[DATA_WIDTH-2]);
        else
            $display("[%t] Hold test failed (i_en = 0), cycle %d | o_res = %b, expected = %b", $time, i+1, o_res, init_val[DATA_WIDTH-2]);
    end
end

initial begin
    $dumpvars;
    $display("[%t] Start", $realtime);
    #10000 $finish;
end

shift_reg #(.DATA_WIDTH(DATA_WIDTH)) shift_reg_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_ld(i_ld),
    .i_lsb(i_lsb),
    .i_en(i_en),
    .i_data(i_data),
    .o_res(o_res)
);

endmodule