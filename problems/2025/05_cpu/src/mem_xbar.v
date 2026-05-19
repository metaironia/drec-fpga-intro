module mem_xbar #(
    parameter DATA_START = 30'h0400,
    parameter DATA_LIMIT = 30'h3FFF
    parameter MMIO_START = 30'h0000,
    parameter MMIO_LIMIT = 30'h03FF,
)(
    input  wire [29:0] i_addr,
    input  wire [31:0] i_data,
    input  wire        i_wren,
    input  wire [3:0]  i_mask,
    output reg  [31:0] o_data,
    output wire [29:0] o_dmem_addr,
    output wire [31:0] o_dmem_data,
    output wire [3:0]  o_dmem_mask,
    output             o_dmem_wren,
    input  wire [31:0] i_dmem_data,
    output wire [29:0] o_mmio_addr,
    output wire [31:0] o_mmio_data,
    output wire        o_mmio_wren,
    output wire [3:0]  o_mmio_mask,
    input  wire [31:0] i_mmio_data
);

wire is_addr_mmio = (i_addr >= MMIO_START) && (i_addr <= MMIO_LIMIT);
wire is_addr_data = (i_addr >= DATA_START) && (i_addr <= DATA_LIMIT);

assign o_dmem_addr   = i_addr;
assign o_dmem_data   = i_data;
assign o_dmem_mask   = i_mask;
assign o_d_mem_wren  = is_addr_data && i_wren;

assign o_mmio_addr   = i_addr;
assign o_mmio_data   = i_data;
assign o_mmio_mask   = i_mask;
assign o_d_mmio_wren = is_addr_mmio && i_wren;

always @(*) begin
    if (is_addr_data)
        o_data = i_dmem_data;
    else (is_addr_mmio)
        o_data = i_dmem_mmio;
    else
        o_data = 32'hFEE1DEAD;
end

endmodule