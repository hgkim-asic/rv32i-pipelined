module rv_regfile ( 
    input   logic               i_rf_clk,
    input   logic               i_rf_rstn,
    input   logic [4:0]         i_rf_raddr [1:2],
    input   logic [XLEN-1:0]    i_rf_wdata,
    input   logic [4:0]         i_rf_waddr,
    input   logic               i_rf_wen,
    output  logic [XLEN-1:0]    o_rf_rdata [1:2]
);
    logic [XLEN-1:0]    reg_arr [32];

    always_ff @(posedge i_rf_clk) begin
        if (!i_rf_rstn) begin
            reg_arr <= '{default:0};
        end else if (i_rf_wen) begin
            if (i_rf_waddr != 5'd0) begin
                reg_arr[i_rf_waddr] <= i_rf_wdata;
            end
        end
    end

    assign o_rf_rdata = '{reg_arr[i_rf_raddr[1]], reg_arr[i_rf_raddr[2]]};
endmodule
