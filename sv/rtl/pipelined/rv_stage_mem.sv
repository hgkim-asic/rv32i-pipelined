module rv_stage_mem (   
    input   logic                       i_mem_clk,
    input   logic                       i_mem_rstn,
    // Data memory interface            
    input   logic [XLEN-1:0]            i_mem_dmem_rdata,
    output  logic [XLEN-1:0]            o_mem_dmem_addr,
    output  logic                       o_mem_dmem_wen,
    output  logic [XLEN/8-1:0]          o_mem_dmem_wstrb, // write strobe
    output  logic [XLEN-1:0]            o_mem_dmem_wdata,
    // from EX Stage
    input   logic                       i_mem_is_load,
    input   rv_pkg::func3_dmem_e        i_mem_func3,
    input   logic [XLEN-1:0]            i_mem_alu_res,
    input   logic [XLEN-1:0]            i_mem_ext_imm,
    input   logic [XLEN-1:0]            i_mem_pc_plus_4,
    input   logic                       i_mem_dmem_wen,
    input   logic [XLEN-1:0]            i_mem_dmem_wdata,
    input   logic                       i_mem_rf_wen,
    input   logic [4:0]                 i_mem_rf_waddr,
    input   rv_pkg::rf_wdata_pre_sel_e  i_mem_rf_wdata_pre_sel,
    // to WB Stage  
    output  logic                       o_mem_wb_is_load,
    output  logic [XLEN-1:0]            o_mem_wb_dmem_rdata,
    output  logic                       o_mem_wb_rf_wen,
    output  logic [4:0]                 o_mem_wb_rf_waddr,
    output  logic [XLEN-1:0]            o_mem_wb_rf_wdata_pre,
    // Forwarding Path
    output  logic [XLEN-1:0]            o_mem_rf_rdata_fwd      // to EX Stage
);
    //////////////////////////
    // load store interface //
    //////////////////////////

    logic   [XLEN-1:0]          dmem_rdata_proc;    // processed dmem read data
    logic   [1:0]               byte_offset;

    assign  byte_offset         = i_mem_alu_res[1:0];
    assign  o_mem_dmem_addr     = i_mem_alu_res;
    assign  o_mem_dmem_wen      = i_mem_dmem_wen;
    assign  o_mem_dmem_wdata    = i_mem_dmem_wdata << (byte_offset*8);

    always_comb begin
        unique case (i_mem_func3)
            FUNC3_DMEM_BYTE     : dmem_rdata_proc = { {24{i_mem_dmem_rdata[8*byte_offset+7]}}   ,i_mem_dmem_rdata[8*byte_offset+:8]  }; // 'lb'
            FUNC3_DMEM_BYTEU    : dmem_rdata_proc = { 24'b0                                     ,i_mem_dmem_rdata[8*byte_offset+:8]  }; // 'lbu'
            FUNC3_DMEM_HALF     : dmem_rdata_proc = { {16{i_mem_dmem_rdata[8*byte_offset+15]}}  ,i_mem_dmem_rdata[8*byte_offset+:16] }; // 'lh'
            FUNC3_DMEM_HALFU    : dmem_rdata_proc = { 16'b0                                     ,i_mem_dmem_rdata[8*byte_offset+:16] }; // 'lhu'
            default             : dmem_rdata_proc = i_mem_dmem_rdata;                                                                   // 'lw'
        endcase
    end

    always_comb begin
        case (i_mem_func3)
            FUNC3_DMEM_BYTE     : o_mem_dmem_wstrb = 4'b0001 << byte_offset;    // 'sb'
            FUNC3_DMEM_HALF     : o_mem_dmem_wstrb = 4'b0011 << byte_offset;    // 'sh'
            default             : o_mem_dmem_wstrb = 4'b1111;                   // 'sw'
        endcase
    end

    always_comb begin
        unique case (i_mem_rf_wdata_pre_sel)
            RF_WDATA_EXT_IMM    : o_mem_rf_rdata_fwd = i_mem_ext_imm;
            RF_WDATA_PC_PLUS_4  : o_mem_rf_rdata_fwd = i_mem_pc_plus_4;
            default             : o_mem_rf_rdata_fwd = i_mem_alu_res;
        endcase
    end

    ///////////////////////////////
    // MEM/WB Pipeline Registers //
    ///////////////////////////////

    always_ff @(posedge i_mem_clk) begin
        if (!i_mem_rstn) begin
            o_mem_wb_rf_wen         <= 'd0;
        end else begin
            o_mem_wb_rf_wen         <= i_mem_rf_wen;
        end
    end

    always_ff @(posedge i_mem_clk) begin
        o_mem_wb_is_load        <= i_mem_is_load;
        o_mem_wb_dmem_rdata     <= dmem_rdata_proc;
        o_mem_wb_rf_waddr       <= i_mem_rf_waddr;
        o_mem_wb_rf_wdata_pre   <= o_mem_rf_rdata_fwd;
    end
endmodule
