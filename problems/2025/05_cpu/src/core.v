module core (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [31:0]  i_instr_data,
    output wire [29:0]  o_instr_addr,
    output wire [29:0]  o_mem_addr,
    output wire [31:0]  o_mem_data,
    output wire         o_mem_we,
    output wire [3:0]   o_mem_mask,
    input  wire [31:0]  i_mem_data
);



endmodule