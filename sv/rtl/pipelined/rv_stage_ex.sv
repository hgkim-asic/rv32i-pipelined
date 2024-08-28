module rv_stage_ex (    
    input   logic                       i_ex_clk,
    input   logic                       i_ex_rstn,
    // to IF Stage
    output  logic [XLEN-1:0]            o_ex_if_pc_plus_4,
    output  logic [XLEN-1:0]            o_ex_if_alu_res,
    // to Branch Unit
    output  logic [XLEN-1:0]            o_ex_bu_rf_rdata_muxed [1:2],
    // from ID Stage
    input   logic [XLEN-1:0]            i_ex_pc,
    input   rv_pkg::func3_branch_e      i_ex_func3,
    input   logic                       i_ex_is_load,
    input   logic [XLEN-1:0]            i_ex_ext_imm,
    input   rv_pkg::alu_ctrl_e          i_ex_alu_ctrl,
    input   logic                       i_ex_alu_a_sel,
    input   logic                       i_ex_alu_b_sel,
    input   logic                       i_ex_dmem_wen,
    input   logic [XLEN-1:0]            i_ex_rf_rdata [1:2],
    input   logic [4:0]                 i_ex_rf_waddr,
    input   logic                       i_ex_rf_wen,
    input   rv_pkg::rf_wdata_pre_sel_e  i_ex_rf_wdata_pre_sel,
    // to MEM Stage         
    output  rv_pkg::func3_dmem_e        o_ex_mem_func3,
    output  logic                       o_ex_mem_is_load,
    output  logic [XLEN-1:0]            o_ex_mem_alu_res,
    output  logic [XLEN-1:0]            o_ex_mem_ext_imm,
    output  logic [XLEN-1:0]            o_ex_mem_pc_plus_4,
    output  logic                       o_ex_mem_dmem_wen,
    output  logic [XLEN-1:0]            o_ex_mem_dmem_wdata,
    output  logic                       o_ex_mem_rf_wen,
    output  logic [4:0]                 o_ex_mem_rf_waddr,
    output  rv_pkg::rf_wdata_pre_sel_e  o_ex_mem_rf_wdata_pre_sel,
    // Forwarding Path
    input   logic [XLEN-1:0]            i_ex_rf_rdata_fwd_mem,
    input   logic [XLEN-1:0]            i_ex_rf_rdata_fwd_wb,
    input   rv_pkg::rf_rdata_sel_e      i_ex_rf_rdata_sel [1:2]
);
    logic [XLEN-1:0]    alu_a; 
    logic [XLEN-1:0]    alu_b; 
    logic [XLEN-1:0]    alu_res_ex;
    logic [XLEN-1:0]    pc_plus_4_ex;

    logic [XLEN-1:0]    rf_rdata_muxed_ex [1:2];

    assign alu_a = i_ex_alu_a_sel ? i_ex_pc                 : rf_rdata_muxed_ex[1];
    assign alu_b = i_ex_alu_b_sel ? rf_rdata_muxed_ex[2]    : i_ex_ext_imm;

    assign o_ex_if_pc_plus_4        = pc_plus_4_ex;
    assign o_ex_if_alu_res          = alu_res_ex;
    assign o_ex_bu_rf_rdata_muxed   = rf_rdata_muxed_ex;

    for (genvar i=1; i<=2; i++) begin
        always_comb begin
            unique case (i_ex_rf_rdata_sel[i])
                RF_RDATA_SEL_EX_MEM : rf_rdata_muxed_ex[i] = i_ex_rf_rdata_fwd_mem;
                RF_RDATA_SEL_EX_WB  : rf_rdata_muxed_ex[i] = i_ex_rf_rdata_fwd_wb;
                default             : rf_rdata_muxed_ex[i] = i_ex_rf_rdata[i];
            endcase
        end
    end

    rv_alu
    u_rv_alu(
        .i_alu_a                    (alu_a                  ),
        .i_alu_b                    (alu_b                  ),
        .i_alu_ctrl                 (i_ex_alu_ctrl          ),
        .o_alu_res                  (alu_res_ex             )
    );

    rv_adder #(
        .BW_DATA                    (XLEN                   )
    ) u_rv_adder_pc_plus_4_ex(
        .i_adder_data               ('{i_ex_pc, 32'd4}      ),
        .o_adder_data               (pc_plus_4_ex           )
    );

    ///////////////////////////////
    // EX/MEM Pipeline Registers //
    ///////////////////////////////

    always_ff @(posedge i_ex_clk) begin
        if (!i_ex_rstn) begin
            o_ex_mem_dmem_wen           <= 'd0;
            o_ex_mem_rf_wen             <= 'd0;
        end else begin
            o_ex_mem_dmem_wen           <= i_ex_dmem_wen;
            o_ex_mem_rf_wen             <= i_ex_rf_wen;
        end
    end
    
    always_ff @(posedge i_ex_clk) begin
        o_ex_mem_func3              <= i_ex_func3;
        o_ex_mem_is_load            <= i_ex_is_load;
        o_ex_mem_alu_res            <= alu_res_ex;
        o_ex_mem_ext_imm            <= i_ex_ext_imm;
        o_ex_mem_pc_plus_4          <= pc_plus_4_ex;
        o_ex_mem_dmem_wdata         <= rf_rdata_muxed_ex[2];
        o_ex_mem_rf_waddr           <= i_ex_rf_waddr;
        o_ex_mem_rf_wdata_pre_sel   <= i_ex_rf_wdata_pre_sel;
    end
endmodule
