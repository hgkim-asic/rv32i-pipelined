module rv_dff #(
    parameter int unsigned BW_DATA  = 32,
    parameter int unsigned INIT_VAL = 0
)(  
    input   logic                   i_dff_clk,
    input   logic                   i_dff_rstn,
    input   logic                   i_dff_en,
    input   logic [BW_DATA-1:0]     i_dff_d,
    output  logic [BW_DATA-1:0]     o_dff_q
);
    always_ff @(posedge i_dff_clk) begin
        if (!i_dff_rstn) begin
            o_dff_q <= INIT_VAL;
        end else if (i_dff_en) begin
            o_dff_q <= i_dff_d;
        end
    end
endmodule
