`include "../common/rv_configs.v"

module rv_ctrl(
	input		[6:0]	i_ctrl_opcode,
	input		[2:0]	i_ctrl_func3,
	input				i_ctrl_func7_5,
	output reg	[2:0]	o_ctrl_immext_ctrl,
	output				o_ctrl_is_branch,
	output				o_ctrl_is_jump,
	output				o_ctrl_is_load,
	output reg	[3:0]	o_ctrl_alu_ctrl,
	output				o_ctrl_alu_a_sel,
	output				o_ctrl_alu_b_sel,
	output				o_ctrl_dmem_we,
	output reg	[2:0]	o_ctrl_dmem_bytectrl,
	output				o_ctrl_rf_we,
	output reg	[1:0]	o_ctrl_rf_wd_pre_sel
);
	reg		illegal_instr;

	always @(*) begin
		case (i_ctrl_opcode)
			`INSTR_S_TYPE,
			`INSTR_B_TYPE,
			`INSTR_U_TYPE_LUI,
			`INSTR_U_TYPE_AUIPC,
			`INSTR_J_TYPE,
			`INSTR_I_TYPE_LOAD,
			`INSTR_I_TYPE_JALR,
			`INSTR_R_TYPE,
			`INSTR_I_TYPE_ALU,
			`INSTR_I_TYPE_E		: illegal_instr = 1'b0;
			default				: illegal_instr = 1'b1;
		endcase
	end

	assign o_ctrl_is_load	= (i_ctrl_opcode == `INSTR_I_TYPE_LOAD);
	assign o_ctrl_is_branch	= (i_ctrl_opcode == `INSTR_B_TYPE);
	assign o_ctrl_is_jump	= (i_ctrl_opcode == `INSTR_J_TYPE) || (i_ctrl_opcode == `INSTR_I_TYPE_JALR);

	assign o_ctrl_alu_a_sel = (i_ctrl_opcode == `INSTR_U_TYPE_AUIPC) || (i_ctrl_opcode == `INSTR_J_TYPE) || (i_ctrl_opcode == `INSTR_B_TYPE);	// 1 ? select 'pc'	: select 'rs1'
	assign o_ctrl_alu_b_sel = (i_ctrl_opcode == `INSTR_R_TYPE);																					// 1 ? select 'rs2' : select 'imm'

	assign o_ctrl_dmem_we	= !illegal_instr ? (i_ctrl_opcode[6:4] == 3'b010)	: 1'b0; 	// instr is 'S-type'
	assign o_ctrl_rf_we		= !illegal_instr ? (i_ctrl_opcode[5:2] != 4'b1000)	: 1'b0;		// instr is neither 'S-type' nor 'B-type'

	always @(*) begin
		case (i_ctrl_opcode)
			`INSTR_I_TYPE_JALR,
			`INSTR_J_TYPE		: o_ctrl_rf_wd_pre_sel = `SRC_RF_WD_PC_PLUS_4;		// instr is 'jal' or 'jalr'	
			`INSTR_U_TYPE_LUI	: o_ctrl_rf_wd_pre_sel = `SRC_RF_WD_EXT_IMM;		// instr is 'lui'	
			default				: o_ctrl_rf_wd_pre_sel = `SRC_RF_WD_ALU_RES;		// instr is 'R-type' or 'I_alu-type' or 'auipc'
		endcase
	end

	always @(*) begin
		case (i_ctrl_opcode)
			`INSTR_U_TYPE_LUI,
			`INSTR_U_TYPE_AUIPC	: o_ctrl_immext_ctrl = `IMMEXT_CTRL_U;	// instr is 'U-type'
			`INSTR_S_TYPE		: o_ctrl_immext_ctrl = `IMMEXT_CTRL_S;	// instr is 'S-type'
			`INSTR_B_TYPE	 	: o_ctrl_immext_ctrl = `IMMEXT_CTRL_B;	// instr is 'B-type'
			`INSTR_J_TYPE	 	: o_ctrl_immext_ctrl = `IMMEXT_CTRL_J;	// instr is 'J-type'
			default				: o_ctrl_immext_ctrl = `IMMEXT_CTRL_I;	// instr is 'I-type'
		endcase
	end

	always @(*) begin
		case (i_ctrl_func3)
			3'h0	: o_ctrl_dmem_bytectrl = `DMEM_BYTECTRL_BYTE;
			3'h1	: o_ctrl_dmem_bytectrl = `DMEM_BYTECTRL_HALF;
			3'h2	: o_ctrl_dmem_bytectrl = `DMEM_BYTECTRL_WORD;
			3'h4	: o_ctrl_dmem_bytectrl = `DMEM_BYTECTRL_BYTEU;
			default	: o_ctrl_dmem_bytectrl = `DMEM_BYTECTRL_HALFU;
		endcase
	end

	always @(*) begin
		case (i_ctrl_opcode)
			`INSTR_R_TYPE,
			`INSTR_I_TYPE_ALU : begin
				case (i_ctrl_func3)
					 3'h0		: o_ctrl_alu_ctrl = (i_ctrl_opcode[5] && i_ctrl_func7_5) ? `SRC_ALU_CTRL_SUB : `SRC_ALU_CTRL_ADD;
					 3'h1		: o_ctrl_alu_ctrl = `SRC_ALU_CTRL_SLL;
					 3'h2		: o_ctrl_alu_ctrl = `SRC_ALU_CTRL_SLT;
					 3'h3		: o_ctrl_alu_ctrl = `SRC_ALU_CTRL_SLTU;
					 3'h4		: o_ctrl_alu_ctrl = `SRC_ALU_CTRL_XOR;
					 3'h5		: o_ctrl_alu_ctrl = i_ctrl_func7_5 ? `SRC_ALU_CTRL_SRA : `SRC_ALU_CTRL_SRL;
					 3'h6		: o_ctrl_alu_ctrl = `SRC_ALU_CTRL_OR;
					 3'h7		: o_ctrl_alu_ctrl = `SRC_ALU_CTRL_AND;
				endcase
			end
			default : o_ctrl_alu_ctrl = `SRC_ALU_CTRL_ADD;
		endcase
	end

`ifdef DEBUG
	reg	[8*128-1:0]	DEBUG_INSTR_ID;
	always @(*) begin
		case (i_ctrl_opcode)
			`INSTR_R_TYPE	: begin
				case (i_ctrl_func3)
					3'h0	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "SUB" : "ADD";
					3'h4 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "UNDEFINED" : "XOR";
					3'h6 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "UNDEFINED" : "OR";
					3'h7 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "UNDEFINED" : "AND";
					3'h1 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "UNDEFINED" : "SLL";
					3'h5 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "SRA" : "SRL";
					3'h2 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "UNDEFINED" : "SLT";
					3'h3 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "UNDEFINED" : "SLTU";
				endcase
			end
			`INSTR_I_TYPE_ALU : begin
				case (i_ctrl_func3)
					3'h0	: DEBUG_INSTR_ID = "ADDI";
					3'h4 	: DEBUG_INSTR_ID = "XORI";
					3'h6 	: DEBUG_INSTR_ID = "ORI";
					3'h7 	: DEBUG_INSTR_ID = "ANDI";
					3'h1 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "UNDEFINED" : "SLLI";
					3'h5 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "SRAI" : "SRLI";
					3'h2 	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "UNDEFINED" : "SLTI";
					default	: DEBUG_INSTR_ID = i_ctrl_func7_5 ? "UNDEFINED" : "SLTIU";
				endcase
			end
			`INSTR_I_TYPE_LOAD : begin
				case (i_ctrl_func3)
					3'h0	: DEBUG_INSTR_ID = "LB";
					3'h1 	: DEBUG_INSTR_ID = "LH";
					3'h2 	: DEBUG_INSTR_ID = "LW";
					3'h4 	: DEBUG_INSTR_ID = "LBU";
					3'h5 	: DEBUG_INSTR_ID = "LHU";
					default	: DEBUG_INSTR_ID = "UNDEFINED";
				endcase
			end
			`INSTR_I_TYPE_JALR : DEBUG_INSTR_ID = i_ctrl_func3==3'h0 ? "JALR" : "UNDEFINED";
			`INSTR_S_TYPE : begin
				case (i_ctrl_func3)
					3'h0	: DEBUG_INSTR_ID = "SB";
					3'h1 	: DEBUG_INSTR_ID = "SH";
					3'h2 	: DEBUG_INSTR_ID = "SW";
					default	: DEBUG_INSTR_ID = "UNDEFINED";
				endcase
			end
			`INSTR_B_TYPE : begin
				case (i_ctrl_func3)
					3'h0	: DEBUG_INSTR_ID = "BEQ";
					3'h1 	: DEBUG_INSTR_ID = "BNE";
					3'h4 	: DEBUG_INSTR_ID = "BLT";
					3'h5 	: DEBUG_INSTR_ID = "BGE";
					3'h6 	: DEBUG_INSTR_ID = "BLTU";
					3'h7 	: DEBUG_INSTR_ID = "BGEU";
					default	: DEBUG_INSTR_ID = "UNDEFINED";
				endcase
			end
			`INSTR_J_TYPE		: DEBUG_INSTR_ID = "JAL";
			`INSTR_U_TYPE_LUI	: DEBUG_INSTR_ID = "LUI";
			`INSTR_U_TYPE_AUIPC	: DEBUG_INSTR_ID = "AUIPC";
			`INSTR_I_TYPE_E		: DEBUG_INSTR_ID = i_ctrl_func3==3'h0 ? "E" : "UNDEFINED";
			default				: DEBUG_INSTR_ID = "UNDEFINED";
		endcase
	end
`endif
endmodule 
