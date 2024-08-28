module rv_branch_predictor (    
    input   logic   i_brp_clk,
    input   logic   i_brp_rstn,
    input   logic   i_brp_is_branch,
    input   logic   i_brp_is_taken,
    output  logic   o_brp_pred_taken
);
    typedef enum logic [1:0] {S_STR_TAKEN, S_WEA_TAKEN, S_WEA_NOT_TAKEN, S_STR_NOT_TAKEN } state_e;
    state_e c_state, n_state;

    always_ff @(posedge i_brp_clk) begin
        if(!i_brp_rstn) begin
            c_state <= S_STR_NOT_TAKEN;
        end else begin
            c_state <= n_state;
        end
    end

    always_comb begin
        unique case (c_state)
            S_STR_NOT_TAKEN : n_state = i_brp_is_branch&&i_brp_is_taken ? S_WEA_NOT_TAKEN   : S_STR_NOT_TAKEN;
            S_WEA_NOT_TAKEN : n_state = i_brp_is_branch&&i_brp_is_taken ? S_WEA_TAKEN       : S_WEA_NOT_TAKEN;
            S_WEA_TAKEN     : n_state = i_brp_is_branch&&i_brp_is_taken ? S_STR_TAKEN       : S_WEA_TAKEN;
            S_STR_TAKEN     : n_state = i_brp_is_branch&&i_brp_is_taken ? S_STR_TAKEN       : S_WEA_TAKEN;
        endcase
    end

    assign o_brp_pred_taken = (c_state == S_STR_TAKEN) || (c_state == S_WEA_TAKEN);
endmodule
