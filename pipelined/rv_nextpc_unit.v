`include "../common/rv_configs.v"

module rv_nextpc_unit (	
	input 		[2:0]	i_npc_func3_ex,
	input		[1:0]	i_npc_is_br_jp_ex,
	input 				i_npc_alu_zero,
	output reg	[1:0]	o_npc_pc_next_sel,
	output				o_npc_flush_ifid
);
	wire	is_jump;
	wire	is_branch;
	reg		take_branch;

	assign is_branch		= i_npc_is_br_jp_ex == 2'b01;
	assign is_jump			= i_npc_is_br_jp_ex[1];			// instr is 'jalr' or 'jalr'

	assign o_npc_flush_ifid	= take_branch&&is_branch || is_jump;

	always @(*) begin
		case (i_npc_func3_ex)
			`FUNC3_BEQ	: take_branch = i_npc_alu_zero;
			`FUNC3_BNE	: take_branch = !i_npc_alu_zero;
			`FUNC3_BLT	: take_branch = !i_npc_alu_zero;
			`FUNC3_BGE	: take_branch = i_npc_alu_zero;
			`FUNC3_BLTU	: take_branch = !i_npc_alu_zero;
			default		: take_branch = i_npc_alu_zero;
		endcase
	end

	always @(*) begin
		case (i_npc_is_br_jp_ex)
			2'b00 : o_npc_pc_next_sel = `SRC_PC_NEXT_PC_PLUS_4;
			2'b01 : o_npc_pc_next_sel = take_branch ? `SRC_PC_NEXT_PC_PLUS_IMM : `SRC_PC_NEXT_PC_PLUS_4;
			2'b11 : o_npc_pc_next_sel = `SRC_PC_NEXT_PC_PLUS_IMM;
			2'b10 : o_npc_pc_next_sel = `SRC_PC_NEXT_ALU_RES;
		endcase
	end
endmodule
