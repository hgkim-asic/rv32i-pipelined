`include "rv_configs.v"

module rv_regfile ( 
    input                   i_rf_clk,
    input                   i_rf_rstn,
    input   [4:0]           i_rf_ra1,
    input   [4:0]           i_rf_ra2,
    input   [`XLEN-1:0]     i_rf_wd,
    input   [4:0]           i_rf_wa,
    input                   i_rf_we,
    output  [`XLEN-1:0]     o_rf_rd1,
    output  [`XLEN-1:0]     o_rf_rd2
);
    reg [`XLEN-1:0] reg_arr [0:31];

    integer i;
    always @(posedge i_rf_clk) begin
        if (!i_rf_rstn) begin
            for (i=0; i<32; i=i+1) begin
                reg_arr[i] <= `XLEN'd0;
            end
        end else if (i_rf_we) begin
            if (i_rf_wa != 5'd0) begin
                reg_arr[i_rf_wa] <= i_rf_wd;
            end
        end
    end

    assign o_rf_rd1 = reg_arr[i_rf_ra1];
    assign o_rf_rd2 = reg_arr[i_rf_ra2];
endmodule
