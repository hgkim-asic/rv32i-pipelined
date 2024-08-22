`include "../common/rv_configs.v"

module rv_branch_comp (	
	input	[`XLEN-1:0]		i_brcomp_a,
	input	[`XLEN-1:0]		i_brcomp_b,
	input 	[2:0]			i_brcomp_func3_ex,
	input					i_brcomp_is_branch_ex,
	input					i_brcomp_is_jump_ex,
	output					o_brcomp_flush_ifid	
);
	reg		take_branch;

	wire	brcomp_eq	= i_brcomp_a == i_brcomp_b;
	wire  	brcomp_lt	= $signed(i_brcomp_a) < $signed(i_brcomp_b);
	wire  	brcomp_ltu	= i_brcomp_a < i_brcomp_b;

	assign	o_brcomp_flush_ifid	= take_branch&&i_brcomp_is_branch_ex || i_brcomp_is_jump_ex;

	always @(*) begin
		case (i_brcomp_func3_ex)
			`FUNC3_BEQ	: take_branch = brcomp_eq;
			`FUNC3_BNE	: take_branch = !brcomp_eq;
			`FUNC3_BLT	: take_branch = brcomp_lt;
			`FUNC3_BGE	: take_branch = !brcomp_lt;
			`FUNC3_BLTU	: take_branch = brcomp_ltu;
			default		: take_branch = !brcomp_ltu; // bgeu
		endcase
	end

endmodule
