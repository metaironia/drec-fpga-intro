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

wire [31:0] u_imm = {i_instr_data[31:12], 12'b0};
wire [31:0] b_imm = {{20{i_instr_data[31]}}, i_instr_data[7], i_instr_data[30:25], i_instr_data[11:6], 1'b0};
wire [31:0] j_imm = {{12{i_instr_data[31]}}, i_instr_data[19:12], i_instr_data[20], i_instr_data[30:21], 1'b0};

wire [31:0] i_imm = {{20{i_instr_data[31]}}, i_instr_data[31:20]};
wire [31:0] s_imm = {{20{i_instr_data[31]}}, i_instr_data[31:25], i_instr_data[11:7]};

wire [4:0] rs1 = i_instr_data[19:15];
wire [4:0] rs1 = i_instr_data[24:20];
wire [4:0] rd  = i_instr_data[11:7];

wire [31:0] src1;
wire [31:0] src2;
wire [31:0] dst;

wire [31:0] sel1_2alu;
wire [31:0] sel2_2alu;
wire [31:0] alu_res;

reg  [29:0] pc;
wire [29:0] pc_inc = pc + 1'b1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pc <= 0;
    else if (is_branch_taken)
        pc <= alu_res[31:2];
    else
        pc <= pc_inc;
end

wire [3:0] control2alu_op;
wire [1:0] control2sel1;
wire [1:0] control2sel2;
wire [2:0] control2cmp_op;
wire       control_is_instr_branch;
wire [1:0] control2wbsel;
wire       control_is_instr_uncond_jump;
wire       control2regfile_wren;

wire is_branch_taken_after_cmp;

wire is_branch_taken = (is_branch_taken_after_cmp && control_is_instr_branch) ||
                       control_is_instr_uncond_jump;

wire [31:0] wb2regfile;

wire [2:0] ld_st_mask = i_instr_data[14:12];
wire       control2lsu_wren;

control_unit control (
    .i_instr_data  (i_instr_data                ),
    .o_alu_op      (control2alu_op              ),
    .o_alu_sel1    (control2sel1                ),
    .o_alu_sel2    (control2sel2                ),
    .o_cmp_op      (control2cmp_op              ),
    .o_branch      (control_is_instr_branch     ),
    .o_wbsel       (control2wbsel               ),
    .o_jump        (control_is_instr_uncond_jump),
    .o_regfile_wren(control2regfile_wren        ),
    .o_lsu_wren    (control2lsu_wren            )
);

mux4 mux_sel_1 (
    .i_1  (src1        ),
    .i_2  (b_imm       ),
    .i_3  (j_imm       ),
    .i_4  (u_imm       ),
    .i_sel(control2sel1),
    .o_res(sel1_2alu   )
);

mux4 mux_sel_2 (
    .i_1  (src2        ),
    .i_2  (i_imm       ),
    .i_3  (s_imm       ),
    .i_4  ({pc, 2'b00} ),
    .i_sel(control2sel1),
    .o_res(sel1_2alu   )
);

reg_file reg_file_inst (
    .clk       (clk                 ),
    .i_rd_addr1(rs1                 ),
    .o_rd_data1(src1                ),
    .i_rd_addr2(rs2                 ),
    .o_rd_data2(src2                ),
    .i_wr_addr (rd                  ),
    .i_wr_data (wb2regfile          ),
    .i_wr_en   (control2regfile_wren)
);

alu alu_inst (
    .i_a  (sel1_2alu     ),
    .i_b  (sel2_2alu     ),
    .i_op (control2alu_op),
    .o_res(alu_res       )
);

branch_unit cmp (
    .i_a     (src1                     ),
    .i_b     (src2                     ),
    .i_cmp_op(control2cmp_op           ),
    .o_taken (is_branch_taken_after_cmp)
);

mux4 mux_wbsel (
    .i_1  ({pc_inc, 2'b00}),
    .i_2  (alu_res        ),
    .i_3  (lsu_data       ),
    .i_4  (u_imm          ),
    .i_sel(control2wbsel  ),
    .o_res(wb2regfile     )
);

lsu lsu_inst (
    .i_addr    (alu_res[31:2]   ),
    .i_wr_data (src2            ),
    .i_mask    (ld_st_mask      ),
    .i_wren    (control2lsu_wren),
    .o_data    (lsu_data        ),
    .o_mem_addr(o_mem_addr      ),
    .o_mem_data(o_mem_data      ),
    .o_mem_we  (o_mem_we        ),
    .o_mem_mask(o_mem_mask      ),
    .i_mem_data(i_mem_data      )
);

endmodule