`include "rv_configs.v"

module rv_immext (  
    input       [31:7]      i_immext_instr_31to7,
    input       [2:0]       i_immext_ctrl,
    output reg  [`XLEN-1:0] o_immext_ext_imm
);
    always @(*) begin 
        case (i_immext_ctrl)
            `IMMEXT_CTRL_I  : o_immext_ext_imm = {{20{i_immext_instr_31to7[31]}}, i_immext_instr_31to7[31:20]};
            `IMMEXT_CTRL_S  : o_immext_ext_imm = {{20{i_immext_instr_31to7[31]}}, i_immext_instr_31to7[31:25], i_immext_instr_31to7[11:7]};
            `IMMEXT_CTRL_B  : o_immext_ext_imm = {{20{i_immext_instr_31to7[31]}}, i_immext_instr_31to7[7], i_immext_instr_31to7[30:25], i_immext_instr_31to7[11:8], 1'b0};
            `IMMEXT_CTRL_J  : o_immext_ext_imm = {{11{1'b0}}, i_immext_instr_31to7[31], i_immext_instr_31to7[19:12], i_immext_instr_31to7[20], i_immext_instr_31to7[30:21], 1'b0};
            default         : o_immext_ext_imm = {i_immext_instr_31to7[31:12], 12'b0};  // u-type
        endcase
    end
endmodule
