module rv_immext (  
    input   logic [31:7]            i_immext_instr_31to7,
    input   rv_pkg::immext_ctrl_e   i_immext_ctrl,
    output  logic [XLEN-1:0]        o_immext_ext_imm
);
    logic [31:7] instr_31to7;
    assign instr_31to7 = i_immext_instr_31to7;

    always_comb begin 
        unique case (i_immext_ctrl)
            IMMEXT_CTRL_I   : o_immext_ext_imm = {{20{instr_31to7[31]}}, instr_31to7[31:20]};
            IMMEXT_CTRL_S   : o_immext_ext_imm = {{20{instr_31to7[31]}}, instr_31to7[31:25], instr_31to7[11:7]};
            IMMEXT_CTRL_B   : o_immext_ext_imm = {{20{instr_31to7[31]}}, instr_31to7[7], instr_31to7[30:25], instr_31to7[11:8], 1'b0};
//          IMMEXT_CTRL_J   : o_immext_ext_imm = {{11{1'b0}}, instr_31to7[31], instr_31to7[19:12], instr_31to7[20], instr_31to7[30:21], 1'b0}; // instr 'jal' is handled in 'IF' Stage
            default         : o_immext_ext_imm = {instr_31to7[31:12], 12'b0};   // u-type
        endcase
    end
endmodule
