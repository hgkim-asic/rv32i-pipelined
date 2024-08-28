module rv_alu ( 
    input   logic [XLEN-1:0]    i_alu_a,
    input   logic [XLEN-1:0]    i_alu_b,
    input   rv_pkg::alu_ctrl_e  i_alu_ctrl,
//  output  logic               o_alu_zero,     // Branch decision is handled in 'Branch Comparator'
    output  logic [XLEN-1:0]    o_alu_res
);
    always_comb begin
        unique case (i_alu_ctrl)
            ALU_CTRL_AND    : o_alu_res = i_alu_a & i_alu_b;
            ALU_CTRL_OR     : o_alu_res = i_alu_a | i_alu_b;
            ALU_CTRL_ADD    : o_alu_res = i_alu_a + i_alu_b;
            ALU_CTRL_SUB    : o_alu_res = i_alu_a - i_alu_b;
            ALU_CTRL_XOR    : o_alu_res = i_alu_a ^ i_alu_b;
            ALU_CTRL_SLTU   : o_alu_res = i_alu_a < i_alu_b ? 32'd1 : 32'd0;
            ALU_CTRL_SLL    : o_alu_res = i_alu_a << i_alu_b[4:0];
            ALU_CTRL_SRA    : o_alu_res = $signed(i_alu_a) >>> $signed(i_alu_b[4:0]);
            ALU_CTRL_SRL    : o_alu_res = i_alu_a >>> (i_alu_b[4:0]);
            default         : o_alu_res = $signed(i_alu_a) < $signed(i_alu_b) ? 32'd1 : 32'd0; // slt
        endcase
    end

//  assign o_alu_zero = o_alu_res == 0;
endmodule
