`define OP_IMM 7'b0010011
`define OP     7'b0110011
`define STORE  7'b0100011
`define BRANCH 7'b1100011
`define LOAD   7'b0000011
`define JALR   7'b1100111
`define JAL    7'b1101111
`define LUI    7'b0110111
`define AUIPC  7'b0110111

`define ALU_SEL_1_SRC1 2'b00
`define ALU_SEL_1_BIMM 2'b01
`define ALU_SEL_1_JIMM 2'b10
`define ALU_SEL_1_UIMM 2'b11

`define ALU_SEL_2_SRC2 2'b00
`define ALU_SEL_2_IIMM 2'b01
`define ALU_SEL_2_SIMM 2'b10
`define ALU_SEL_2_PC   2'b11

`define WB_NEXT_PC  2'b00
`define WB_ALU_RES  2'b01
`define WB_LSU_DATA 2'b10
`define WB_UIMM     2'b11