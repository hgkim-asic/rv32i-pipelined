`include "rv_configs.v"

module rv_alu (	
	input		[`XLEN-1:0]		i_alu_a,
	input		[`XLEN-1:0]		i_alu_b,
	input		[3:0]			i_alu_ctrl,
//	output						o_alu_zero,
	output reg	[`XLEN-1:0]		o_alu_res
);
	always @(*) begin
		case (i_alu_ctrl)
			`SRC_ALU_CTRL_AND	: o_alu_res = i_alu_a & i_alu_b;
			`SRC_ALU_CTRL_OR	: o_alu_res = i_alu_a | i_alu_b;
			`SRC_ALU_CTRL_ADD	: o_alu_res = i_alu_a + i_alu_b;
			`SRC_ALU_CTRL_SUB	: o_alu_res = i_alu_a - i_alu_b;
			`SRC_ALU_CTRL_XOR	: o_alu_res = i_alu_a ^ i_alu_b;
			`SRC_ALU_CTRL_SLTU	: o_alu_res = i_alu_a < i_alu_b ? 32'd1 : 32'd0;
			`SRC_ALU_CTRL_SLL	: o_alu_res = i_alu_a << i_alu_b[4:0];
			`SRC_ALU_CTRL_SRA	: o_alu_res = $signed(i_alu_a) >>> $signed(i_alu_b[4:0]);
			`SRC_ALU_CTRL_SRL	: o_alu_res = i_alu_a >>> (i_alu_b[4:0]);
			`SRC_ALU_CTRL_SLT	: o_alu_res = $signed(i_alu_a) < $signed(i_alu_b) ? 32'd1 : 32'd0;
			default				: o_alu_res = `XLEN'bx;
		endcase
	end

//	assign o_alu_zero = o_alu_res == 0;
endmodule
