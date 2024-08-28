module rv_ctrl (
    input   rv_pkg::opcode_e                i_ctrl_opcode,
    input   rv_pkg::func3_branch_e          i_ctrl_func3,
    input   logic                           i_ctrl_func7_5,
    output  rv_pkg::immext_ctrl_e           o_ctrl_immext_ctrl,
    output  logic                           o_ctrl_is_branch,
    output  logic                           o_ctrl_is_jalr,
    output  logic                           o_ctrl_is_load,
    output  rv_pkg::alu_ctrl_e              o_ctrl_alu_ctrl,
    output  logic                           o_ctrl_alu_a_sel,
    output  logic                           o_ctrl_alu_b_sel,
    output  logic                           o_ctrl_dmem_wen,
    output  logic                           o_ctrl_rf_wen,
    output  rv_pkg::rf_wdata_pre_sel_e      o_ctrl_rf_wdata_pre_sel
);
    assign o_ctrl_is_branch = (i_ctrl_opcode == OPCODE_B);
    assign o_ctrl_is_jalr   = (i_ctrl_opcode == OPCODE_I_JALR);
    assign o_ctrl_is_load   = (i_ctrl_opcode == OPCODE_I_LOAD);

    assign o_ctrl_alu_a_sel = (i_ctrl_opcode == OPCODE_U_AUIPC) || (i_ctrl_opcode == OPCODE_B); // selects 'pc' when asserted
    assign o_ctrl_alu_b_sel = (i_ctrl_opcode == OPCODE_R);                                      // selects 'rs2' when asserted

    assign o_ctrl_dmem_wen  = (i_ctrl_opcode[6:4] == 3'b010);       // instr is 'S-type'
    assign o_ctrl_rf_wen    = (i_ctrl_opcode[5:2] != 4'b1000);      // instr is neither 'S-type' nor 'B-type'

    always_comb begin
        unique case (i_ctrl_opcode)
            OPCODE_I_JALR,
            OPCODE_J        : o_ctrl_rf_wdata_pre_sel = RF_WDATA_PC_PLUS_4;
            OPCODE_U_LUI    : o_ctrl_rf_wdata_pre_sel = RF_WDATA_EXT_IMM;   
            default         : o_ctrl_rf_wdata_pre_sel = RF_WDATA_ALU_RES;   // instr is 'R-type' or 'I_ALU-type' or 'auipc'
        endcase
    end

    always_comb begin
        unique case (i_ctrl_opcode)
            OPCODE_U_LUI,
            OPCODE_U_AUIPC  : o_ctrl_immext_ctrl = IMMEXT_CTRL_U;
            OPCODE_S        : o_ctrl_immext_ctrl = IMMEXT_CTRL_S;
            OPCODE_B        : o_ctrl_immext_ctrl = IMMEXT_CTRL_B;
            default         : o_ctrl_immext_ctrl = IMMEXT_CTRL_I;   // instr is 'I-type'
        endcase
    end

    always_comb begin
        unique case (i_ctrl_opcode)
            OPCODE_R,
            OPCODE_I_ALU : begin
                unique case (i_ctrl_func3)
                     FUNC3_ALU_OP_ADD_SUB   : o_ctrl_alu_ctrl = i_ctrl_opcode[5]&&i_ctrl_func7_5 ? ALU_CTRL_SUB : ALU_CTRL_ADD;
                     FUNC3_ALU_OP_SLL       : o_ctrl_alu_ctrl = ALU_CTRL_SLL;
                     FUNC3_ALU_OP_SLT       : o_ctrl_alu_ctrl = ALU_CTRL_SLT;
                     FUNC3_ALU_OP_SLTU      : o_ctrl_alu_ctrl = ALU_CTRL_SLTU;
                     FUNC3_ALU_OP_XOR       : o_ctrl_alu_ctrl = ALU_CTRL_XOR;
                     FUNC3_ALU_OP_SRL_SRA   : o_ctrl_alu_ctrl = i_ctrl_func7_5 ? ALU_CTRL_SRA : ALU_CTRL_SRL;
                     FUNC3_ALU_OP_OR        : o_ctrl_alu_ctrl = ALU_CTRL_OR;
                     FUNC3_ALU_OP_AND       : o_ctrl_alu_ctrl = ALU_CTRL_AND;
                endcase
            end
            default : o_ctrl_alu_ctrl = ALU_CTRL_ADD;
        endcase
    end

`define DEBUG
`ifdef  DEBUG
    reg [8*128-1:0] DEBUG_INSTR_ID;
    always_comb begin
        unique case (i_ctrl_opcode)
            OPCODE_R        : begin
                unique case (i_ctrl_func3)
                    FUNC3_ALU_OP_ADD_SUB    : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "SUB"       : "ADD";
                    FUNC3_ALU_OP_XOR        : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "ILLEGAL"   : "XOR";
                    FUNC3_ALU_OP_OR         : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "ILLEGAL"   : "OR";
                    FUNC3_ALU_OP_AND        : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "ILLEGAL"   : "AND";
                    FUNC3_ALU_OP_SLL        : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "ILLEGAL"   : "SLL";
                    FUNC3_ALU_OP_SRL_SRA    : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "SRA"       : "SRL";
                    FUNC3_ALU_OP_SLT        : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "ILLEGAL"   : "SLT";
                    FUNC3_ALU_OP_SLTU       : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "ILLEGAL"   : "SLTU";
                endcase
            end
            OPCODE_I_ALU    : begin
                unique case (i_ctrl_func3)
                    FUNC3_ALU_OP_ADD_SUB    : DEBUG_INSTR_ID = "ADDI";
                    FUNC3_ALU_OP_XOR        : DEBUG_INSTR_ID = "XORI";
                    FUNC3_ALU_OP_OR         : DEBUG_INSTR_ID = "ORI";
                    FUNC3_ALU_OP_AND        : DEBUG_INSTR_ID = "ANDI";
                    FUNC3_ALU_OP_SLL        : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "ILLEGAL"   : "SLLI";
                    FUNC3_ALU_OP_SRL_SRA    : DEBUG_INSTR_ID = i_ctrl_func7_5 ? "SRAI"      : "SRLI";
                    FUNC3_ALU_OP_SLT        : DEBUG_INSTR_ID = "SLTI";
                    FUNC3_ALU_OP_SLTU       : DEBUG_INSTR_ID = "SLTIU";
                endcase
            end
            OPCODE_I_LOAD   : begin
                unique case (i_ctrl_func3)
                    FUNC3_DMEM_BYTE     : DEBUG_INSTR_ID = "LB";
                    FUNC3_DMEM_HALF     : DEBUG_INSTR_ID = "LH";
                    FUNC3_DMEM_WORD     : DEBUG_INSTR_ID = "LW";
                    FUNC3_DMEM_BYTEU    : DEBUG_INSTR_ID = "LBU";
                    FUNC3_DMEM_HALFU    : DEBUG_INSTR_ID = "LHU";
                    default             : DEBUG_INSTR_ID = "ILLEGAL";
                endcase
            end
            OPCODE_I_JALR   : DEBUG_INSTR_ID = i_ctrl_func3==3'h0 ? "JALR" : "ILLEGAL";
            OPCODE_S        : begin
                unique case (i_ctrl_func3)
                    FUNC3_DMEM_BYTE : DEBUG_INSTR_ID = "SB";
                    FUNC3_DMEM_HALF : DEBUG_INSTR_ID = "SH";
                    FUNC3_DMEM_WORD : DEBUG_INSTR_ID = "SW";
                    default         : DEBUG_INSTR_ID = "ILLEGAL";
                endcase
            end
            OPCODE_B : begin
                unique case (i_ctrl_func3)
                    FUNC3_BEQ   : DEBUG_INSTR_ID = "BEQ";
                    FUNC3_BNE   : DEBUG_INSTR_ID = "BNE";
                    FUNC3_BLT   : DEBUG_INSTR_ID = "BLT";
                    FUNC3_BGE   : DEBUG_INSTR_ID = "BGE";
                    FUNC3_BLTU  : DEBUG_INSTR_ID = "BLTU";
                    FUNC3_BGEU  : DEBUG_INSTR_ID = "BGEU";
                    default     : DEBUG_INSTR_ID = "ILLEGAL";
                endcase
            end
            OPCODE_J        : DEBUG_INSTR_ID = "JAL";
            OPCODE_U_LUI    : DEBUG_INSTR_ID = "LUI";
            OPCODE_U_AUIPC  : DEBUG_INSTR_ID = "AUIPC";
            OPCODE_I_SYSTEM : DEBUG_INSTR_ID = i_ctrl_func3==3'h0 ? "SYSTEM" : "ILLEGAL";
            default         : DEBUG_INSTR_ID = "ILLEGAL";
        endcase
    end
`endif
endmodule 
