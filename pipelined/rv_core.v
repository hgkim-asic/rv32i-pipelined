`include "../common/rv_configs.v"
`include "../common/rv_regfile.v"

module rv_core (
    input                   i_core_clk,
    input                   i_core_rstn,
    // Instr memory interface
    input   [31:0]          i_core_imem_rd,
    output  [`XLEN-1:0]     o_core_imem_ra,
    // Data memory interface
    input   [`XLEN-1:0]     i_core_dmem_rd,
    output  [`XLEN-1:0]     o_core_dmem_a,
    output  [`XLEN-1:0]     o_core_dmem_wd,
    output                  o_core_dmem_we,
    output  [2:0]           o_core_dmem_bytectrl
);
    wire                    flush_ifid;
    wire                    stall_ifid;

    wire    [`XLEN-1:0]     target_addr;

    wire    [`XLEN-1:0]     rf_rd_fwd_mem;
    wire    [`XLEN-1:0]     rf_rd_fwd_wb;
    wire                    rf_rd1_sel_id;
    wire                    rf_rd2_sel_id;
    wire    [1:0]           rf_rd1_sel_ex;
    wire    [1:0]           rf_rd2_sel_ex;

    // Register file interface
    wire                    rf_we_core;
    wire    [4:0]           rf_wa_core;
    wire    [`XLEN-1:0]     rf_wd_core;
    wire    [4:0]           rf_ra1_core;
    wire    [4:0]           rf_ra2_core;
    wire    [`XLEN-1:0]     rf_rd1_core;
    wire    [`XLEN-1:0]     rf_rd2_core;

    // Output sigs of IF/ID pipeline regs
    wire    [`XLEN-1:0]     pc_id;
    wire    [31:0]          instr_id;

    // Output sigs of ID/EX pipeline regs
    wire    [`XLEN-1:0]     pc_ex;
    wire    [2:0]           func3_ex;
    wire    [`XLEN-1:0]     ext_imm_ex;
    wire                    is_branch_ex;
    wire                    is_jump_ex;
    wire                    is_load_ex;
    wire    [3:0]           alu_ctrl_ex;
    wire                    alu_a_sel_ex;
    wire                    alu_b_sel_ex;
    wire                    dmem_we_ex;
    wire    [`XLEN-1:0]     dmem_wd_ex;
    wire    [2:0]           dmem_bytectrl_ex;
    wire                    rf_we_ex;
    wire    [4:0]           rf_wa_ex;
    wire    [`XLEN-1:0]     rf_rd1_ex;
    wire    [`XLEN-1:0]     rf_rd2_ex;
    wire    [1:0]           rf_wd_pre_sel_ex;

    wire    [4:0]           rf_ra1_ex;
    wire    [4:0]           rf_ra2_ex;

    // Output sigs of EX/MEM pipeline regs
    wire                    is_load_mem;
    wire    [`XLEN-1:0]     alu_res_mem;
    wire    [`XLEN-1:0]     pc_plus_4_mem;
    wire    [`XLEN-1:0]     ext_imm_mem;
    wire                    dmem_we_mem;
    wire    [`XLEN-1:0]     dmem_wd_mem;
    wire    [2:0]           dmem_bytectrl_mem;
    wire    [1:0]           rf_wd_pre_sel_mem;
    wire                    rf_we_mem;
    wire    [4:0]           rf_wa_mem;

    // Output sigs of MEM/WB pipeline regs
    wire                    is_load_wb;
    wire    [`XLEN-1:0]     dmem_rd_wb;
    wire                    rf_we_wb;
    wire    [4:0]           rf_wa_wb;
    wire    [`XLEN-1:0]     rf_wd_pre_wb;

    rv_regfile
    u_rv_regfle(
        .i_rf_clk               (i_core_clk             ),
        .i_rf_rstn              (i_core_rstn            ),
        .i_rf_ra1               (rf_ra1_core            ),
        .i_rf_ra2               (rf_ra2_core            ),
        .i_rf_wd                (rf_wd_core             ),
        .i_rf_wa                (rf_wa_core             ),
        .i_rf_we                (rf_we_core             ),
        .o_rf_rd1               (rf_rd1_core            ),
        .o_rf_rd2               (rf_rd2_core            )
    );

    rv_if_stage 
    u_rv_if_stage(
        .i_if_clk               (i_core_clk             ),
        .i_if_rstn              (i_core_rstn            ),
        .i_if_flush             (flush_ifid             ),  // from EX
        .i_if_stall             (stall_ifid             ),  // from Haz
    // Instr memory interface
        .i_if_imem_rd           (i_core_imem_rd         ),
        .o_if_imem_ra           (o_core_imem_ra         ),
    // EX Stage -> IF Stage
        .i_if_target_addr       (target_addr            ),
    // IF Stage -> ID Stage
        .o_if_id_pc             (pc_id                  ),
        .o_if_id_instr          (instr_id               )
    );

    rv_id_stage 
    u_rv_id_stage(
        .i_id_clk               (i_core_clk             ),
        .i_id_rstn              (i_core_rstn            ),
        .i_id_flush             (flush_ifid             ),  // from EX
        .i_id_stall             (stall_ifid             ),  // from Haz
    // Register file interface
        .i_id_rf_rd1            (rf_rd1_core            ),
        .i_id_rf_rd2            (rf_rd2_core            ),
        .o_id_rf_ra1            (rf_ra1_core            ),
        .o_id_rf_ra2            (rf_ra2_core            ),
    // IF Stage -> ID Stage
        .i_id_pc                (pc_id                  ),
        .i_id_instr             (instr_id               ),
    // ID Stage -> EX Stage
        .o_id_ex_pc             (pc_ex                  ),
        .o_id_ex_func3          (func3_ex               ),
        .o_id_ex_ext_imm        (ext_imm_ex             ),
        .o_id_ex_is_branch      (is_branch_ex           ),
        .o_id_ex_is_jump        (is_jump_ex             ),
        .o_id_ex_is_load        (is_load_ex             ),
        .o_id_ex_alu_ctrl       (alu_ctrl_ex            ),
        .o_id_ex_alu_a_sel      (alu_a_sel_ex           ),
        .o_id_ex_alu_b_sel      (alu_b_sel_ex           ),
        .o_id_ex_dmem_we        (dmem_we_ex             ),
        .o_id_ex_dmem_bytectrl  (dmem_bytectrl_ex       ),
        .o_id_ex_rf_we          (rf_we_ex               ),
        .o_id_ex_rf_wa          (rf_wa_ex               ),
        .o_id_ex_rf_rd1         (rf_rd1_ex              ),
        .o_id_ex_rf_rd2         (rf_rd2_ex              ),
        .o_id_ex_rf_wd_pre_sel  (rf_wd_pre_sel_ex       ),
    // Forwarding
        .i_id_rf_rd_fwd_wb      (rf_rd_fwd_wb           ),  // from WB
        .i_id_rf_rd1_sel        (rf_rd1_sel_id          ),  // from Haz
        .i_id_rf_rd2_sel        (rf_rd2_sel_id          ),  // from Haz
        .o_id_ex_rf_ra1         (rf_ra1_ex              ),  // to Haz
        .o_id_ex_rf_ra2         (rf_ra2_ex              )   // to Haz
    );

    rv_ex_stage 
    u_rv_ex_stage(
        .i_ex_clk               (i_core_clk             ),
        .i_ex_rstn              (i_core_rstn            ),
        .o_ex_flush_ifid        (flush_ifid             ),
    // ID Stage -> EX Stage
        .i_ex_pc                (pc_ex                  ),
        .i_ex_func3             (func3_ex               ),
        .i_ex_ext_imm           (ext_imm_ex             ),
        .i_ex_is_branch         (is_branch_ex           ),
        .i_ex_is_jump           (is_jump_ex             ),
        .i_ex_is_load           (is_load_ex             ),
        .i_ex_alu_ctrl          (alu_ctrl_ex            ),
        .i_ex_alu_a_sel         (alu_a_sel_ex           ),
        .i_ex_alu_b_sel         (alu_b_sel_ex           ),
        .i_ex_dmem_we           (dmem_we_ex             ),
        .i_ex_dmem_bytectrl     (dmem_bytectrl_ex       ),
        .i_ex_rf_we             (rf_we_ex               ),
        .i_ex_rf_wa             (rf_wa_ex               ),
        .i_ex_rf_rd1            (rf_rd1_ex              ),
        .i_ex_rf_rd2            (rf_rd2_ex              ),
        .i_ex_rf_wd_pre_sel     (rf_wd_pre_sel_ex       ),
    // EX Stage -> IF Stage
        .o_ex_if_target_addr    (target_addr            ),
    // EX Stage -> MEM Stage
        .o_ex_mem_is_load       (is_load_mem            ),
        .o_ex_mem_alu_res       (alu_res_mem            ),
        .o_ex_mem_ext_imm       (ext_imm_mem            ),
        .o_ex_mem_pc_plus_4     (pc_plus_4_mem          ),
        .o_ex_mem_dmem_we       (dmem_we_mem            ),
        .o_ex_mem_dmem_wd       (dmem_wd_mem            ),
        .o_ex_mem_dmem_bytectrl (dmem_bytectrl_mem      ),
        .o_ex_mem_rf_wa         (rf_wa_mem              ),
        .o_ex_mem_rf_we         (rf_we_mem              ),
        .o_ex_mem_rf_wd_pre_sel (rf_wd_pre_sel_mem      ),
    // Forwarding
        .i_ex_rf_rd_fwd_mem     (rf_rd_fwd_mem          ),  // from MEM
        .i_ex_rf_rd_fwd_wb      (rf_rd_fwd_wb           ),  // from WB
        .i_ex_rf_rd1_sel        (rf_rd1_sel_ex          ),  // from Haz
        .i_ex_rf_rd2_sel        (rf_rd2_sel_ex          )   // from Haz
    );

    rv_mem_stage 
    u_rv_mem_stage(
        .i_mem_clk              (i_core_clk             ),
        .i_mem_rstn             (i_core_rstn            ),
    // Data memory interface
        .i_mem_dmem_rd          (i_core_dmem_rd         ),
        .o_mem_dmem_a           (o_core_dmem_a          ),
        .o_mem_dmem_we          (o_core_dmem_we         ),
        .o_mem_dmem_wd          (o_core_dmem_wd         ),
        .o_mem_dmem_bytectrl    (o_core_dmem_bytectrl   ),
    // EX Stage -> MEM Stage
        .i_mem_is_load          (is_load_mem            ),
        .i_mem_alu_res          (alu_res_mem            ),
        .i_mem_pc_plus_4        (pc_plus_4_mem          ),
        .i_mem_ext_imm          (ext_imm_mem            ),
        .i_mem_dmem_we          (dmem_we_mem            ),
        .i_mem_dmem_wd          (dmem_wd_mem            ),
        .i_mem_dmem_bytectrl    (dmem_bytectrl_mem      ),
        .i_mem_rf_we            (rf_we_mem              ),
        .i_mem_rf_wa            (rf_wa_mem              ),
        .i_mem_rf_wd_pre_sel    (rf_wd_pre_sel_mem      ),
    // MEM Stage -> WB Stage
        .o_mem_wb_is_load       (is_load_wb             ),
        .o_mem_wb_dmem_rd       (dmem_rd_wb             ),
        .o_mem_wb_rf_we         (rf_we_wb               ),
        .o_mem_wb_rf_wa         (rf_wa_wb               ),
        .o_mem_wb_rf_wd_pre     (rf_wd_pre_wb           ),
    // Forwarding
        .o_mem_rf_rd_fwd        (rf_rd_fwd_mem          )   // to EX
    );

    rv_wb_stage 
    u_rv_wb_stage(
    // Register file interface
        .o_wb_rf_wa             (rf_wa_core             ),
        .o_wb_rf_we             (rf_we_core             ),
        .o_wb_rf_wd             (rf_wd_core             ),
    // MEM Stage -> WB Stage
        .i_wb_is_load           (is_load_wb             ),
        .i_wb_dmem_rd           (dmem_rd_wb             ),
        .i_wb_rf_wa             (rf_wa_wb               ),
        .i_wb_rf_we             (rf_we_wb               ),
        .i_wb_rf_wd_pre         (rf_wd_pre_wb           ),
    // Forwarding
        .o_wb_rf_rd_fwd         (rf_rd_fwd_wb           )   // to ID, EX
    );

    rv_hazard_unit 
    u_rv_hazard_unit(
        .i_haz_is_load_mem      (is_load_mem            ),
        .i_haz_is_load_wb       (is_load_wb             ),
        .i_haz_rf_ra1_id        (rf_ra1_core            ),
        .i_haz_rf_ra2_id        (rf_ra2_core            ),
        .i_haz_rf_ra1_ex        (rf_ra1_ex              ),
        .i_haz_rf_ra2_ex        (rf_ra2_ex              ),
        .i_haz_rf_we_mem        (rf_we_mem              ),
        .i_haz_rf_wa_mem        (rf_wa_mem              ),
        .i_haz_rf_we_wb         (rf_we_wb               ),
        .i_haz_rf_wa_wb         (rf_wa_wb               ),
        .o_haz_rf_rd1_sel_ex    (rf_rd1_sel_ex          ),  // to EX
        .o_haz_rf_rd2_sel_ex    (rf_rd2_sel_ex          ),  // to EX
        .o_haz_rf_rd1_sel_id    (rf_rd1_sel_id          ),  // to ID
        .o_haz_rf_rd2_sel_id    (rf_rd2_sel_id          ),  // to ID
        .o_haz_stall_ifid       (stall_ifid             )   // to IF, ID
    );
endmodule
