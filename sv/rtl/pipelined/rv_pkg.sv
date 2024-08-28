package rv_pkg;
    parameter int unsigned XLEN             = 32;
    parameter int unsigned INIT_PC          = 0;
    parameter int unsigned IMEM_ADDR_BIT    = 16;
    parameter int unsigned DMEM_ADDR_BIT    = 16;
    parameter int unsigned IMEM_SIZE        = 2**(IMEM_ADDR_BIT-2);
    parameter int unsigned DMEM_SIZE        = 2**(DMEM_ADDR_BIT-2);
    
    enum logic [2:0] {
        FUNC3_ALU_OP_ADD_SUB    = 3'h0,
        FUNC3_ALU_OP_XOR        = 3'h4,
        FUNC3_ALU_OP_OR         = 3'h6,
        FUNC3_ALU_OP_AND        = 3'h7,
        FUNC3_ALU_OP_SLL        = 3'h1,
        FUNC3_ALU_OP_SRL_SRA    = 3'h5,
        FUNC3_ALU_OP_SLT        = 3'h2,
        FUNC3_ALU_OP_SLTU       = 3'h3
    } func3_alu_op_e;

    typedef enum logic [2:0] {
        FUNC3_BEQ       = 3'h0,
        FUNC3_BNE       = 3'h1,
        FUNC3_BLT       = 3'h4,
        FUNC3_BGE       = 3'h5,
        FUNC3_BLTU      = 3'h6,
        FUNC3_BGEU      = 3'h7
    } func3_branch_e;

    typedef enum logic[2:0] {
        FUNC3_DMEM_BYTE     = 3'd0,
        FUNC3_DMEM_HALF     = 3'd1,
        FUNC3_DMEM_WORD     = 3'd2,
        FUNC3_DMEM_BYTEU    = 3'd4,
        FUNC3_DMEM_HALFU    = 3'd5
    } func3_dmem_e;

    typedef enum logic [1:0] {
        PC_NEXT_SEL_PC_ADDER_RES_IF = 2'd0,
        PC_NEXT_SEL_PC_PLUS_4_EX    = 2'd1,
        PC_NEXT_SEL_ALU_RES_EX      = 2'd2
    } pc_next_sel_e;

    typedef enum logic [1:0] {
        RF_WDATA_ALU_RES    = 2'd0,
        RF_WDATA_EXT_IMM    = 2'd1,
        RF_WDATA_PC_PLUS_4  = 2'd2
    } rf_wdata_pre_sel_e;

    typedef enum logic [3:0] {
        ALU_CTRL_ADD    = 4'd0,
        ALU_CTRL_SUB    = 4'd1,
        ALU_CTRL_XOR    = 4'd2,
        ALU_CTRL_OR     = 4'd3,
        ALU_CTRL_AND    = 4'd4,
        ALU_CTRL_SLL    = 4'd5,
        ALU_CTRL_SRL    = 4'd6,
        ALU_CTRL_SRA    = 4'd7,
        ALU_CTRL_SLT    = 4'd8,
        ALU_CTRL_SLTU   = 4'd9
    } alu_ctrl_e;

    typedef enum logic[2:0] {
        IMMEXT_CTRL_U   = 3'd0,
        IMMEXT_CTRL_S   = 3'd1,
        IMMEXT_CTRL_B   = 3'd2,
        IMMEXT_CTRL_J   = 3'd3,
        IMMEXT_CTRL_I   = 3'd4
    } immext_ctrl_e;

    typedef enum logic [1:0] {
        RF_RDATA_SEL_EX_ID  = 2'd0,
        RF_RDATA_SEL_EX_MEM = 2'd1,
        RF_RDATA_SEL_EX_WB  = 2'd2
    } rf_rdata_sel_e;

    typedef enum logic [6:0] {
        OPCODE_R        = 7'b0110011,
        OPCODE_B        = 7'b1100011,
        OPCODE_I_ALU    = 7'b0010011,
        OPCODE_I_LOAD   = 7'b0000011,
        OPCODE_I_JALR   = 7'b1100111,
        OPCODE_I_SYSTEM = 7'b1110011,
        OPCODE_S        = 7'b0100011,
        OPCODE_J        = 7'b1101111,
        OPCODE_U_LUI    = 7'b0110111,
        OPCODE_U_AUIPC  = 7'b0010111
    } opcode_e;
endpackage
