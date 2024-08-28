module rv_stage_wb (    
    // Register file interface
    output  logic               o_wb_rf_wen,
    output  logic [4:0]         o_wb_rf_waddr,
    output  logic [XLEN-1:0]    o_wb_rf_wdata,
    // from MEM Stage
    input   logic               i_wb_is_load,
    input   logic [XLEN-1:0]    i_wb_dmem_rdata,
    input   logic               i_wb_rf_wen,
    input   logic [4:0]         i_wb_rf_waddr,
    input   logic [XLEN-1:0]    i_wb_rf_wdata_pre,
    // Forwarding Path
    output  logic [XLEN-1:0]    o_wb_rf_rdata_fwd   // to ID, EX Stage
);
    assign o_wb_rf_wen          = i_wb_rf_wen;
    assign o_wb_rf_waddr        = i_wb_rf_waddr;
    assign o_wb_rf_wdata        = i_wb_is_load  ? i_wb_dmem_rdata : i_wb_rf_wdata_pre;

    assign o_wb_rf_rdata_fwd    = o_wb_rf_wdata;
endmodule
