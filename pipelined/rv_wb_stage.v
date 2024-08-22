`include "../common/rv_configs.v"

module rv_wb_stage (    
    // MEM Stage -> WB Stage
    input                   i_wb_is_load,
    input   [`XLEN-1:0]     i_wb_dmem_rd,
    input                   i_wb_rf_we,
    input   [4:0]           i_wb_rf_wa,
    input   [`XLEN-1:0]     i_wb_rf_wd_pre,
    // Register file interface
    output                  o_wb_rf_we,
    output  [4:0]           o_wb_rf_wa,
    output  [`XLEN-1:0]     o_wb_rf_wd,
    // Forwarding
    output  [`XLEN-1:0]     o_wb_rf_rd_fwd  // to ID, EX
);
    assign o_wb_rf_we       = i_wb_rf_we;
    assign o_wb_rf_wa       = i_wb_rf_wa;
    assign o_wb_rf_wd       = i_wb_is_load ? i_wb_dmem_rd : i_wb_rf_wd_pre;
    assign o_wb_rf_rd_fwd   = o_wb_rf_wd;
endmodule
