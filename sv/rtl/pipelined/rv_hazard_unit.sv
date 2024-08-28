module rv_hazard_unit(
    input   logic                   i_haz_is_load_mem,
    input   logic [4:0]             i_haz_rf_raddr_id [1:2],
    input   logic [4:0]             i_haz_rf_raddr_ex [1:2],
    input   logic [4:0]             i_haz_rf_waddr_mem,
    input   logic [4:0]             i_haz_rf_waddr_wb,
    input   logic                   i_haz_rf_wen_mem,
    input   logic                   i_haz_rf_wen_wb,
    output  logic                   o_haz_rf_rdata_sel_id [1:2],    // to ID Stage
    output  rv_pkg::rf_rdata_sel_e  o_haz_rf_rdata_sel_ex [1:2],    // to EX Stage
    output  logic                   o_haz_stall_ifid                // to IF, ID Stage
);
    logic   [1:0]   raw_hazard [1:2];   // for rs1, rs2

    assign o_haz_stall_ifid = i_haz_is_load_mem && raw_hazard[1][0];

    for (genvar i=1; i<=2; i++) begin
        assign raw_hazard[i][0]         = (i_haz_rf_raddr_ex[i] == i_haz_rf_waddr_mem)  && i_haz_rf_wen_mem && (i_haz_rf_waddr_mem  != 5'd0);
        assign raw_hazard[i][1]         = (i_haz_rf_raddr_ex[i] == i_haz_rf_waddr_wb)   && i_haz_rf_wen_wb  && (i_haz_rf_waddr_wb   != 5'd0);

        assign o_haz_rf_rdata_sel_id[i] = (i_haz_rf_raddr_id[i] == i_haz_rf_waddr_wb)   && i_haz_rf_wen_wb  && (i_haz_rf_waddr_wb   != 5'd0);

        always_comb begin
            unique case (raw_hazard[i])
                2'b00   : o_haz_rf_rdata_sel_ex[i] = RF_RDATA_SEL_EX_ID;
                2'b10   : o_haz_rf_rdata_sel_ex[i] = RF_RDATA_SEL_EX_WB;
                default : o_haz_rf_rdata_sel_ex[i] = RF_RDATA_SEL_EX_MEM;
            endcase
        end
    end
endmodule
