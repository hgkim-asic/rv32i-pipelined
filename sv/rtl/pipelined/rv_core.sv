module rv_core (
    input   logic                   i_core_clk,
    input   logic                   i_core_rstn,
    // Instr memory interface
    input   logic [31:0]            i_core_imem_rdata,
    output  logic [XLEN-1:0]        o_core_imem_raddr,
    // Data memory interface
    input   logic [XLEN-1:0]        i_core_dmem_rdata,
    output  logic [XLEN-1:0]        o_core_dmem_addr,
    output  logic                   o_core_dmem_wen,
    output  logic [XLEN/8-1:0]      o_core_dmem_wstrb,
    output  logic [XLEN-1:0]        o_core_dmem_wdata
);
    logic                       stall_ifid;
    logic                       flush_ifid;

    // Register file interface
    logic                       rf_wen_core;
    logic [4:0]                 rf_waddr_core;
    logic [XLEN-1:0]            rf_wdata_core;
    logic [4:0]                 rf_raddr_core [1:2];
    logic [XLEN-1:0]            rf_rdata_core [1:2];

    // Forwarding Path
    logic [XLEN-1:0]            rf_rdata_fwd_mem;
    logic [XLEN-1:0]            rf_rdata_fwd_wb;
    logic                       rf_rdata_sel_id [1:2];
    rv_pkg::rf_rdata_sel_e      rf_rdata_sel_ex [1:2];

    logic [XLEN-1:0]            rf_rdata_muxed_ex [1:2];
    logic [XLEN-1:0]            pc_adder_src_if;
    rv_pkg::pc_next_sel_e       pc_next_sel_if;

    logic [31:0]                instr_id;

    logic                       is_branch_ex;
    logic                       is_jalr_ex;
    rv_pkg::alu_ctrl_e          alu_ctrl_ex;
    logic                       alu_a_sel_ex;
    logic                       alu_b_sel_ex;
    logic [XLEN-1:0]            rf_rdata_ex [1:2];
    logic [4:0]                 rf_raddr_ex [1:2];

    logic [XLEN-1:0]            dmem_rdata_wb;
    logic [XLEN-1:0]            rf_wdata_pre_wb;

    logic                       pred_taken_if;
    logic                       pred_taken_id;
    logic                       pred_taken_ex;

    logic [XLEN-1:0]            pc_id;
    logic [XLEN-1:0]            pc_ex;

    rv_pkg::func3_branch_e      func3_ex;
    rv_pkg::func3_dmem_e        func3_mem;

    logic [XLEN-1:0]            ext_imm_ex;
    logic [XLEN-1:0]            ext_imm_mem;

    logic                       is_load_ex;
    logic                       is_load_mem;
    logic                       is_load_wb;

    logic                       dmem_wen_ex;
    logic                       dmem_wen_mem;

    logic [XLEN-1:0]            dmem_wdata_mem;
    logic [XLEN-1:0]            dmem_wdata_ex;

    logic                       rf_wen_ex;
    logic                       rf_wen_mem;
    logic                       rf_wen_wb;

    logic [4:0]                 rf_waddr_ex;
    logic [4:0]                 rf_waddr_mem;
    logic [4:0]                 rf_waddr_wb;

    rv_pkg::rf_wdata_pre_sel_e  rf_wdata_pre_sel_ex;
    rv_pkg::rf_wdata_pre_sel_e  rf_wdata_pre_sel_mem;

    logic [XLEN-1:0]            pc_plus_4_ex;
    logic [XLEN-1:0]            pc_plus_4_mem;

    logic [XLEN-1:0]            alu_res_ex;
    logic [XLEN-1:0]            alu_res_mem;

    rv_regfile
    u_rv_regfle(
        .i_rf_clk                   (i_core_clk             ),
        .i_rf_rstn                  (i_core_rstn            ),
        .i_rf_raddr                 (rf_raddr_core          ),
        .i_rf_wdata                 (rf_wdata_core          ),
        .i_rf_waddr                 (rf_waddr_core          ),
        .i_rf_wen                   (rf_wen_core            ),
        .o_rf_rdata                 (rf_rdata_core          )
    );

    rv_stage_if 
    u_rv_stage_if(
        .i_if_clk                   (i_core_clk             ),
        .i_if_rstn                  (i_core_rstn            ),
        .i_if_flush                 (flush_ifid             ),  // from Branch Unit
        .i_if_stall                 (stall_ifid             ),  // from Hazard Unit
    // Instr memory interface
        .i_if_imem_rdata            (i_core_imem_rdata      ),
        .o_if_imem_raddr            (o_core_imem_raddr      ),
    // from Branch unit
        .i_if_pc_next_sel           (pc_next_sel_if         ),
        .i_if_pc_adder_src          (pc_adder_src_if        ),
        .i_if_pred_taken            (pred_taken_if          ),
    // from EX Stage
        .i_if_pc_plus_4_ex          (pc_plus_4_ex           ),
        .i_if_alu_res_ex            (alu_res_ex             ),
    // to ID Stage
        .o_if_id_pc                 (pc_id                  ),
        .o_if_id_instr              (instr_id               ),
        .o_if_id_pred_taken         (pred_taken_id          )
    );

    rv_stage_id 
    u_rv_stage_id(
        .i_id_clk                   (i_core_clk             ),
        .i_id_rstn                  (i_core_rstn            ),
        .i_id_flush                 (flush_ifid             ),  // from Branch Unit
        .i_id_stall                 (stall_ifid             ),  // from Hazard Unit
    // Register file interface
        .i_id_rf_rdata              (rf_rdata_core          ),
        .o_id_rf_raddr              (rf_raddr_core          ),
    // from IF Stage
        .i_id_pc                    (pc_id                  ),
        .i_id_instr                 (instr_id               ),
        .i_id_pred_taken            (pred_taken_id          ),
    // to EX Stage
        .o_id_ex_pc                 (pc_ex                  ),
        .o_id_ex_ext_imm            (ext_imm_ex             ),
        .o_id_ex_func3              (func3_ex               ),  // to Branch Unit
        .o_id_ex_pred_taken         (pred_taken_ex          ),  // to Branch Unit
        .o_id_ex_is_branch          (is_branch_ex           ),  // to Branch Unit
        .o_id_ex_is_jalr            (is_jalr_ex             ),  // to Branch Unit
        .o_id_ex_is_load            (is_load_ex             ),
        .o_id_ex_alu_ctrl           (alu_ctrl_ex            ),
        .o_id_ex_alu_a_sel          (alu_a_sel_ex           ),
        .o_id_ex_alu_b_sel          (alu_b_sel_ex           ),
        .o_id_ex_dmem_wen           (dmem_wen_ex            ),
        .o_id_ex_rf_wen             (rf_wen_ex              ),
        .o_id_ex_rf_waddr           (rf_waddr_ex            ),
        .o_id_ex_rf_rdata           (rf_rdata_ex            ),
        .o_id_ex_rf_wdata_pre_sel   (rf_wdata_pre_sel_ex    ),
    // Forwarding Path
        .i_id_rf_rdata_fwd_wb       (rf_rdata_fwd_wb        ),  // from WB Stage
        .i_id_rf_rdata_sel          (rf_rdata_sel_id        ),  // from Hazard Unit
        .o_id_ex_rf_raddr           (rf_raddr_ex            )   // to Hazard Unit
    );

    rv_stage_ex 
    u_rv_stage_ex(
        .i_ex_clk                   (i_core_clk             ),
        .i_ex_rstn                  (i_core_rstn            ),
    // to IF Stage
        .o_ex_if_pc_plus_4          (pc_plus_4_ex           ),
        .o_ex_if_alu_res            (alu_res_ex             ),
    // to Branch Unit
        .o_ex_bu_rf_rdata_muxed     (rf_rdata_muxed_ex      ),
    // from ID Stage
        .i_ex_pc                    (pc_ex                  ),
        .i_ex_func3                 (func3_ex               ),
        .i_ex_is_load               (is_load_ex             ),
        .i_ex_ext_imm               (ext_imm_ex             ),
        .i_ex_alu_ctrl              (alu_ctrl_ex            ),
        .i_ex_alu_a_sel             (alu_a_sel_ex           ),
        .i_ex_alu_b_sel             (alu_b_sel_ex           ),
        .i_ex_dmem_wen              (dmem_wen_ex            ),
        .i_ex_rf_wen                (rf_wen_ex              ),
        .i_ex_rf_waddr              (rf_waddr_ex            ),
        .i_ex_rf_rdata              (rf_rdata_ex            ),
        .i_ex_rf_wdata_pre_sel      (rf_wdata_pre_sel_ex    ),
    // to MEM Stage
        .o_ex_mem_func3             (func3_mem              ),
        .o_ex_mem_is_load           (is_load_mem            ),
        .o_ex_mem_alu_res           (alu_res_mem            ),
        .o_ex_mem_ext_imm           (ext_imm_mem            ),
        .o_ex_mem_pc_plus_4         (pc_plus_4_mem          ),
        .o_ex_mem_dmem_wen          (dmem_wen_mem           ),
        .o_ex_mem_dmem_wdata        (dmem_wdata_mem         ),
        .o_ex_mem_rf_waddr          (rf_waddr_mem           ),
        .o_ex_mem_rf_wen            (rf_wen_mem             ),
        .o_ex_mem_rf_wdata_pre_sel  (rf_wdata_pre_sel_mem   ),
    // Forwarding Path
        .i_ex_rf_rdata_fwd_mem      (rf_rdata_fwd_mem       ),  // from MEM Stage
        .i_ex_rf_rdata_fwd_wb       (rf_rdata_fwd_wb        ),  // from WB Stage
        .i_ex_rf_rdata_sel          (rf_rdata_sel_ex        )   // from Hazard Unit
    );

    rv_stage_mem 
    u_rv_stage_mem(
        .i_mem_clk                  (i_core_clk             ),
        .i_mem_rstn                 (i_core_rstn            ),
    // Data memory interface
        .i_mem_dmem_rdata           (i_core_dmem_rdata      ),
        .o_mem_dmem_addr            (o_core_dmem_addr       ),
        .o_mem_dmem_wen             (o_core_dmem_wen        ),
        .o_mem_dmem_wstrb           (o_core_dmem_wstrb      ),
        .o_mem_dmem_wdata           (o_core_dmem_wdata      ),
    // from EX Stage
        .i_mem_func3                (func3_mem              ),
        .i_mem_is_load              (is_load_mem            ),
        .i_mem_alu_res              (alu_res_mem            ),
        .i_mem_pc_plus_4            (pc_plus_4_mem          ),
        .i_mem_ext_imm              (ext_imm_mem            ),
        .i_mem_dmem_wen             (dmem_wen_mem           ),
        .i_mem_dmem_wdata           (dmem_wdata_mem         ),
        .i_mem_rf_wen               (rf_wen_mem             ),
        .i_mem_rf_waddr             (rf_waddr_mem           ),
        .i_mem_rf_wdata_pre_sel     (rf_wdata_pre_sel_mem   ),
    // to WB Stage
        .o_mem_wb_is_load           (is_load_wb             ),
        .o_mem_wb_dmem_rdata        (dmem_rdata_wb          ),
        .o_mem_wb_rf_wen            (rf_wen_wb              ),
        .o_mem_wb_rf_waddr          (rf_waddr_wb            ),
        .o_mem_wb_rf_wdata_pre      (rf_wdata_pre_wb        ),
    // Forwarding Path
        .o_mem_rf_rdata_fwd         (rf_rdata_fwd_mem       )   // to EX Stage
    );

    rv_stage_wb 
    u_rv_stage_wb(
    // Register file interface
        .o_wb_rf_waddr              (rf_waddr_core          ),
        .o_wb_rf_wen                (rf_wen_core            ),
        .o_wb_rf_wdata              (rf_wdata_core          ),
    // from MEM Stage
        .i_wb_is_load               (is_load_wb             ),
        .i_wb_dmem_rdata            (dmem_rdata_wb          ),
        .i_wb_rf_waddr              (rf_waddr_wb            ),
        .i_wb_rf_wen                (rf_wen_wb              ),
        .i_wb_rf_wdata_pre          (rf_wdata_pre_wb        ),
    // Forwarding
        .o_wb_rf_rdata_fwd          (rf_rdata_fwd_wb        )   // to ID, EX Stage
    );

    rv_branch_unit 
    u_rv_branch_unit(
        .i_bu_clk                   (i_core_clk             ),
        .i_bu_rstn                  (i_core_rstn            ),
        .i_bu_instr_if              (i_core_imem_rdata      ),
        .i_bu_func3_ex              (func3_ex               ),
        .i_bu_is_branch_ex          (is_branch_ex           ),
        .i_bu_is_jalr_ex            (is_jalr_ex             ),
        .i_bu_pred_taken_ex         (pred_taken_ex          ),
        .i_bu_comp_src_ex           (rf_rdata_muxed_ex      ),
        .o_bu_if_pc_next_sel        (pc_next_sel_if         ),  // to IF Stage
        .o_bu_if_pc_adder_src       (pc_adder_src_if        ),  // to IF Stage
        .o_bu_if_pred_taken         (pred_taken_if          ),  // to IF Stage
        .o_bu_ifid_flush            (flush_ifid             )   // to IF, ID Stage
    );

    rv_hazard_unit 
    u_rv_hazard_unit(
        .i_haz_is_load_mem          (is_load_mem            ),
        .i_haz_rf_raddr_id          (rf_raddr_core          ),
        .i_haz_rf_raddr_ex          (rf_raddr_ex            ),
        .i_haz_rf_wen_mem           (rf_wen_mem             ),
        .i_haz_rf_waddr_mem         (rf_waddr_mem           ),
        .i_haz_rf_wen_wb            (rf_wen_wb              ),
        .i_haz_rf_waddr_wb          (rf_waddr_wb            ),
        .o_haz_rf_rdata_sel_id      (rf_rdata_sel_id        ),  // to ID Stage
        .o_haz_rf_rdata_sel_ex      (rf_rdata_sel_ex        ),  // to EX Stage
        .o_haz_stall_ifid           (stall_ifid             )   // to IF, ID Stage
    );
endmodule
