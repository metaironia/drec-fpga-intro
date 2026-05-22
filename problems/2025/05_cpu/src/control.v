`include "defs.vh"

module control_unit (
    input  wire [31:0] i_instr_data,
    output reg  [3:0]  o_alu_op,
    output reg  [1:0]  o_alu_sel1,
    output reg  [1:0]  o_alu_sel2,
    output reg  [2:0]  o_cmp_op,
    output reg         o_branch,
    output reg  [1:0]  o_wbsel,
    output reg         o_jump,
    output wire        o_regfile_wren,
    output wire        o_lsu_wren
);

wire [6:0] opcode  = i_instr_data[6:0];
wire [2:0] funct3  = i_instr_data[14:12];
wire [6:0] funct7  = i_instr_data[31:25];

assign o_regfile_wren = (opcode != `STORE) && (opcode != `BRANCH);
assign o_lsu_wren     = (opcode == `STORE);

always @(*) begin
    case (opcode)
    `OP_IMM: {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {1'b0,      funct3, `ALU_SEL_1_SRC1, `ALU_SEL_2_IIMM, 3'b000, 1'b0, `WB_ALU_RES,  1'b0};
    `OP:     {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {funct7[5], funct3, `ALU_SEL_1_SRC1, `ALU_SEL_2_SRC2, 3'b000, 1'b0, `WB_ALU_RES,  1'b0};
    `STORE:  {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {4'b0000,           `ALU_SEL_1_SRC1, `ALU_SEL_2_SIMM, 3'b000, 1'b0, `WB_ALU_RES,  1'b0};
    `BRANCH: {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {4'b0000,           `ALU_SEL_1_BIMM, `ALU_SEL_2_PC,   funct3, 1'b1, `WB_ALU_RES,  1'b0};
    `LOAD:   {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {4'b0000,           `ALU_SEL_1_SRC1, `ALU_SEL_2_IIMM, 3'b000, 1'b0, `WB_LSU_DATA, 1'b0};
    `JAL:    {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {4'b0000,           `ALU_SEL_1_JIMM, `ALU_SEL_2_PC,   3'b000, 1'b0, `WB_NEXT_PC,  1'b1};
    `JALR:   {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {4'b0000,           `ALU_SEL_1_SRC1, `ALU_SEL_2_IIMM, 3'b000, 1'b0, `WB_NEXT_PC,  1'b1};
    `LUI:    {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {4'b0000,           `ALU_SEL_1_SRC1, `ALU_SEL_2_IIMM, 3'b000, 1'b0, `WB_UIMM,     1'b0};
    `AUIPC:  {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {4'b0000,           `ALU_SEL_1_UIMM, `ALU_SEL_2_PC,   3'b000, 1'b0, `WB_ALU_RES,  1'b0};

    default: {o_alu_op, o_alu_sel1, o_alu_sel2, o_cmp_op, o_branch, o_wbsel, o_jump} = {3'b111, 12'hDED};
    endcase
end

endmodule