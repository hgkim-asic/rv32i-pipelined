module rv_branch_comparator (
    input   rv_pkg::func3_branch_e  i_brc_func3,
    input   logic [XLEN-1:0]        i_brc_src_a,
    input   logic [XLEN-1:0]        i_brc_src_b,
    output  logic                   o_brc_is_taken
); 
    logic comp_res_eq;
    logic comp_res_lt;
    logic comp_res_ltu;

    assign comp_res_eq  = i_brc_src_a == i_brc_src_b;
    assign comp_res_lt  = $signed(i_brc_src_a) < $signed(i_brc_src_b);
    assign comp_res_ltu = i_brc_src_a < i_brc_src_b;

    always_comb begin
        unique case (i_brc_func3)
            FUNC3_BEQ   : o_brc_is_taken = comp_res_eq;
            FUNC3_BNE   : o_brc_is_taken = !comp_res_eq;
            FUNC3_BLT   : o_brc_is_taken = comp_res_lt;
            FUNC3_BGE   : o_brc_is_taken = !comp_res_lt;
            FUNC3_BLTU  : o_brc_is_taken = comp_res_ltu;
            default     : o_brc_is_taken = !comp_res_ltu; // bgeu
        endcase
    end
endmodule
