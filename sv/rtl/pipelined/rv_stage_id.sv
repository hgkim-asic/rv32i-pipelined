module rv_stage_id (    
    input   logic                       i_id_clk,
    input   logic                       i_id_rstn,
    input   logic                       i_id_flush,     // from Branch unit
    input   logic                       i_id_stall,     // from Hazard unit
    // Register file interface
    input   logic [XLEN-1:0]            i_id_rf_rdata [1:2],
    output  logic [4:0]                 o_id_rf_raddr [1:2],
    // from IF Stage
    input   logic [XLEN-1:0]            i_id_pc,
    input   logic [31:0]                i_id_instr,
    input   logic                       i_id_pred_taken,
    // to EX Stage
    output  logic [XLEN-1:0]            o_id_ex_pc,
    output  rv_pkg::func3_branch_e      o_id_ex_func3,
    output  logic                       o_id_ex_pred_taken,
    output  logic                       o_id_ex_is_branch,
    output  logic                       o_id_ex_is_jalr,
    output  logic                       o_id_ex_is_load,
    output  logic [XLEN-1:0]            o_id_ex_ext_imm,
    output  rv_pkg::alu_ctrl_e          o_id_ex_alu_ctrl,
    output  logic                       o_id_ex_alu_a_sel,
    output  logic                       o_id_ex_alu_b_sel,
    output  logic                       o_id_ex_dmem_wen,
    output  logic [XLEN-1:0]            o_id_ex_rf_rdata [1:2],
    output  logic [4:0]                 o_id_ex_rf_raddr [1:2],
    output  logic                       o_id_ex_rf_wen,
    output  logic [4:0]                 o_id_ex_rf_waddr,
    output  rv_pkg::rf_wdata_pre_sel_e  o_id_ex_rf_wdata_pre_sel,
    // Forwarding Path
    input   logic [XLEN-1:0]            i_id_rf_rdata_fwd_wb,       // from WB Stage
    input   logic                       i_id_rf_rdata_sel [1:2]     // from Hazard Unit
);
    logic                           is_branch_id;
    logic                           is_jalr_id;
    logic                           is_load_id;
    rv_pkg::immext_ctrl_e           immext_ctrl;
    logic [XLEN-1:0]                ext_imm_id;
    rv_pkg::alu_ctrl_e              alu_ctrl_id;
    logic                           alu_a_sel_id;
    logic                           alu_b_sel_id;
    logic                           dmem_wen_id;
    logic                           rf_wen_id;
    rv_pkg::rf_wdata_pre_sel_e      rf_wdata_pre_sel_id;

    logic [4:0]                     rf_waddr_id;
    logic [XLEN-1:0]                rf_rdata_muxed_id [1:2];

    assign rf_waddr_id          = i_id_instr[11:7];
    assign rf_rdata_muxed_id[1] = i_id_rf_rdata_sel[1] ? i_id_rf_rdata_fwd_wb : i_id_rf_rdata[1];
    assign rf_rdata_muxed_id[2] = i_id_rf_rdata_sel[2] ? i_id_rf_rdata_fwd_wb : i_id_rf_rdata[2];

    assign o_id_rf_raddr        = '{i_id_instr[19:15], i_id_instr[24:20]};

    rv_immext
    u_rv_immext(
        .i_immext_instr_31to7       (i_id_instr[31:7]       ),
        .i_immext_ctrl              (immext_ctrl            ),
        .o_immext_ext_imm           (ext_imm_id             )
    );

    rv_ctrl 
    u_rv_ctrl(
        .i_ctrl_opcode              (i_id_instr[6:0]        ),
        .i_ctrl_func3               (i_id_instr[14:12]      ),
        .i_ctrl_func7_5             (i_id_instr[30]         ),
        .o_ctrl_immext_ctrl         (immext_ctrl            ),
        .o_ctrl_is_branch           (is_branch_id           ),
        .o_ctrl_is_jalr             (is_jalr_id             ),
        .o_ctrl_is_load             (is_load_id             ),
        .o_ctrl_alu_ctrl            (alu_ctrl_id            ),
        .o_ctrl_alu_a_sel           (alu_a_sel_id           ),
        .o_ctrl_alu_b_sel           (alu_b_sel_id           ),
        .o_ctrl_dmem_wen            (dmem_wen_id            ),
        .o_ctrl_rf_wen              (rf_wen_id              ),
        .o_ctrl_rf_wdata_pre_sel    (rf_wdata_pre_sel_id    )
    );

    //////////////////////////////
    // ID/EX Pipeline Registers //
    //////////////////////////////

    always_ff @(posedge i_id_clk) begin
        if (!i_id_rstn) begin
            o_id_ex_is_branch           <= 'd0;
            o_id_ex_is_jalr             <= 'd0;
            o_id_ex_dmem_wen            <= 'd0;
            o_id_ex_rf_wen              <= 'd0;
        end else begin
            if (i_id_flush) begin
                o_id_ex_is_branch           <= 'd0;
                o_id_ex_is_jalr             <= 'd0;
                o_id_ex_dmem_wen            <= 'd0;
                o_id_ex_rf_wen              <= 'd0;
            end else if (!i_id_stall) begin
                o_id_ex_is_branch           <= is_branch_id;
                o_id_ex_is_jalr             <= is_jalr_id;
                o_id_ex_dmem_wen            <= dmem_wen_id;
                o_id_ex_rf_wen              <= rf_wen_id;
            end
        end
    end
    
    always_ff @(posedge i_id_clk) begin
        if (!i_id_stall) begin
            o_id_ex_pc                  <= i_id_pc;
            o_id_ex_func3               <= i_id_instr[14:12];
            o_id_ex_is_load             <= is_load_id;
            o_id_ex_pred_taken          <= i_id_pred_taken;
            o_id_ex_ext_imm             <= ext_imm_id;
            o_id_ex_alu_ctrl            <= alu_ctrl_id;
            o_id_ex_alu_a_sel           <= alu_a_sel_id;
            o_id_ex_alu_b_sel           <= alu_b_sel_id;
            o_id_ex_rf_waddr            <= rf_waddr_id;
            o_id_ex_rf_rdata            <= rf_rdata_muxed_id;
            o_id_ex_rf_raddr            <= o_id_rf_raddr;
            o_id_ex_rf_wdata_pre_sel    <= rf_wdata_pre_sel_id;
        end
    end
endmodule
