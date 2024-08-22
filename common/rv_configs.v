`ifndef RV_CONFIGS
`define RV_CONFIGS

`define DEBUG

`define XLEN                    32

`define INIT_PC                 0

`define IMEM_A_BIT              20
`define DMEM_A_BIT              20
`define IMEM_SIZE               2**(`IMEM_A_BIT-2)
`define DMEM_SIZE               2**(`DMEM_A_BIT-2)

`define SRC_RF_WD_ALU_RES       2'd0
`define SRC_RF_WD_EXT_IMM       2'd1
`define SRC_RF_WD_PC_PLUS_4     2'd2

`define INSTR_R_TYPE            7'b0110011
`define INSTR_B_TYPE            7'b1100011
`define INSTR_I_TYPE_ALU        7'b0010011
`define INSTR_I_TYPE_LOAD       7'b0000011
`define INSTR_I_TYPE_JALR       7'b1100111
`define INSTR_I_TYPE_E          7'b1110011
`define INSTR_S_TYPE            7'b0100011
`define INSTR_J_TYPE            7'b1101111
`define INSTR_U_TYPE_LUI        7'b0110111
`define INSTR_U_TYPE_AUIPC      7'b0010111

`define SRC_ALU_CTRL_ADD        4'd0
`define SRC_ALU_CTRL_SUB        4'd1
`define SRC_ALU_CTRL_XOR        4'd2
`define SRC_ALU_CTRL_OR         4'd3
`define SRC_ALU_CTRL_AND        4'd4
`define SRC_ALU_CTRL_SLL        4'd5
`define SRC_ALU_CTRL_SRL        4'd6
`define SRC_ALU_CTRL_SRA        4'd7
`define SRC_ALU_CTRL_SLT        4'd8
`define SRC_ALU_CTRL_SLTU       4'd9

`define IMMEXT_CTRL_U           3'd0
`define IMMEXT_CTRL_S           3'd1
`define IMMEXT_CTRL_B           3'd2
`define IMMEXT_CTRL_J           3'd3
`define IMMEXT_CTRL_I           3'd4

`define DMEM_BYTECTRL_WORD      3'd0
`define DMEM_BYTECTRL_BYTE      3'd1
`define DMEM_BYTECTRL_BYTEU     3'd2
`define DMEM_BYTECTRL_HALF      3'd3
`define DMEM_BYTECTRL_HALFU     3'd4

`define SRC_RF_RD_EX            2'd0
`define SRC_RF_RD_MEM           2'd1
`define SRC_RF_RD_WB            2'd2

`define FUNC3_BEQ               3'h0
`define FUNC3_BNE               3'h1
`define FUNC3_BLT               3'h4
`define FUNC3_BGE               3'h5
`define FUNC3_BLTU              3'h6
`define FUNC3_BGEU              3'h7
`endif

