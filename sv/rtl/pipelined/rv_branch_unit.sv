module rv_branch_unit ( 
    input   logic                   i_bu_clk,
    input   logic                   i_bu_rstn,
    // from IF Stage
    input   logic [31:0]            i_bu_instr_if,
    // from EX Stage
    input   rv_pkg::func3_branch_e  i_bu_func3_ex,
    input   logic                   i_bu_is_branch_ex,
    input   logic                   i_bu_is_jalr_ex,
    input   logic                   i_bu_pred_taken_ex,
    input   logic [XLEN-1:0]        i_bu_comp_src_ex [1:2],
    // to IF Stage
    output  rv_pkg::pc_next_sel_e   o_bu_if_pc_next_sel,
    output  logic [XLEN-1:0]        o_bu_if_pc_adder_src,
    output  logic                   o_bu_if_pred_taken,
    output  logic                   o_bu_ifid_flush
);
    ///////////////////////
    // Next PC Selectioc // 
    //////////////////////

    logic               is_branch_if;
    logic               is_jal_if;
    logic               is_taken_ex;
    logic [XLEN-1:0]    ext_imm_if;

    assign is_branch_if         = (i_bu_instr_if[6:0] == OPCODE_B);
    assign is_jal_if            = (i_bu_instr_if[6:0] == OPCODE_J);

    assign ext_imm_if           = is_branch_if  ?   {{20{i_bu_instr_if[31]}}, i_bu_instr_if[7], i_bu_instr_if[30:25], i_bu_instr_if[11:8], 1'b0}        :   // instr is 'B-type'
                                                    {{11{1'b0}}, i_bu_instr_if[31], i_bu_instr_if[19:12], i_bu_instr_if[20], i_bu_instr_if[30:21], 1'b0};   // instr is 'J-type'
    
    assign o_bu_if_pc_adder_src = (is_branch_if&&o_bu_if_pred_taken) || is_jal_if ? ext_imm_if : 32'd4;
    assign o_bu_ifid_flush      = i_bu_is_branch_ex&&(is_taken_ex^i_bu_pred_taken_ex) || i_bu_is_jalr_ex;   // miss prediction or instr is 'jalr' -> flush

    always_comb begin
        unique case(1'b1) 
            i_bu_is_branch_ex : begin
                unique case ({is_taken_ex, i_bu_pred_taken_ex})
                    2'b01   : o_bu_if_pc_next_sel = PC_NEXT_SEL_PC_PLUS_4_EX;
                    2'b10   : o_bu_if_pc_next_sel = PC_NEXT_SEL_ALU_RES_EX;
                    default : o_bu_if_pc_next_sel = PC_NEXT_SEL_PC_ADDER_RES_IF;
                endcase
            end
            i_bu_is_jalr_ex : o_bu_if_pc_next_sel = PC_NEXT_SEL_ALU_RES_EX;
            default         : o_bu_if_pc_next_sel = PC_NEXT_SEL_PC_ADDER_RES_IF;
        endcase
    end

    rv_branch_predictor
    u_rv_branch_predictor(
        .i_brp_clk          (i_bu_clk                   ),
        .i_brp_rstn         (i_bu_rstn                  ),
        .i_brp_is_taken     (is_taken_ex                ),
        .i_brp_is_branch    (i_bu_is_branch_ex          ),
        .o_brp_pred_taken   (o_bu_if_pred_taken         )
    );

    rv_branch_comparator
    u_rv_branch_comparator(
        .i_brc_src_a        (i_bu_comp_src_ex[1]        ),
        .i_brc_src_b        (i_bu_comp_src_ex[2]        ),
        .i_brc_func3        (i_bu_func3_ex              ),
        .o_brc_is_taken     (is_taken_ex                )
    );
endmodule
