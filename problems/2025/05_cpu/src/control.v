`include "defs.vh"

module control (
    input  wire [31:0] i_instr_data,
    output reg  [3:0]  AluOp,
    output reg  [1:0]  AluSel1,
    output reg  [1:0]  AluSel2,
    output reg  [2:0]  CmpOp,
    output reg         branch,
    output reg  [1:0]  WBSel
    output reg         jump
);

wire [6:0] opcode  = i_instr_data[6:0];
wire [2:0] funct3  = i_instr_data[14:12];
wire [6:0] funct7  = i_instr_data[31:25];

always @(*) begin
    case (opcode)
    OP_IMM: {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {funct7[5], funct3, ALU_SEL_1_SRC1, ALU_SEL_2_IIMM, 3'b000, 1'b0, WB_ALU_RES, 1'b0};
    OP:     {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {funct7[5], funct3, ALU_SEL_1_SRC1, ALU_SEL_2_SRC2, 3'b000, 1'b0, WB_ALU_RES, 1'b0};
    STORE:  {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {4'b0000,           ALU_SEL_1_SRC1, ALU_SEL_2_SIMM, 3'b000, 1'b0, WB_ALU_RES, 1'b0};
    BRANCH: {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {4'b0001,           ALU_SEL_1_BIMM, ALU_SEL_2_PC,   funct3, 1'b1, WB_ALU_RES, 1'b0};
    LOAD:   {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {4'b0000,           ALU_SEL_1_SRC1, ALU_SEL_2_IIMM, 3'b000, 1'b0, WB_ALU_RES, 1'b0};
    JAL:    {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {4'b0000,           ALU_SEL_1_JIMM, ALU_SEL_2_PC,   3'b000, 1'b0, WB_NEXT_PC, 1'b1};
    JALR:   {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {4'b0000,           ALU_SEL_1_SRC1, ALU_SEL_2_IIMM, 3'b000, 1'b0, WB_NEXT_PC, 1'b1};
    LUI:    {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {4'b0000,           ALU_SEL_1_SRC1, ALU_SEL_2_IIMM, 3'b000, 1'b0, WB_UIMM,    1'b0};
    AUIPC:  {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {4'b0000,           ALU_SEL_1_UIMM, ALU_SEL_2_PC,   3'b000, 1'b0, WB_ALU_RES, 1'b0};

    default: {AluOp, AluSel1, AluSel2, CmpOp, branch, WBSel, jump} = {3'b111, 12'hDED};
    endcase
end

endmodule