`include "../common/rv_configs.v"

module rv_branch_comp (	
	input	[`XLEN-1:0]		i_brcomp_a,
	input	[`XLEN-1:0]		i_brcomp_b,
	input 	[2:0]			i_brcomp_func3_ex,
	input	[1:0]			i_brcomp_is_br_jp_ex,
	output					o_brcomp_flush_ifid	
);
	reg		take_branch;

	wire	is_jump		= i_brcomp_is_br_jp_ex[1];			// instr is 'jalr' or 'jalr'
	wire	is_branch	= i_brcomp_is_br_jp_ex == 2'b01;

	assign	o_brcomp_flush_ifid	= take_branch&&is_branch || is_jump;

	always @(*) begin
		case (i_brcomp_func3_ex)
			`FUNC3_BEQ	: take_branch = i_brcomp_a == i_brcomp_b;
			`FUNC3_BNE	: take_branch = i_brcomp_a != i_brcomp_b;
			`FUNC3_BLT	: take_branch = $signed(i_brcomp_a) < $signed(i_brcomp_b);
			`FUNC3_BGE	: take_branch = $signed(i_brcomp_a) >= $signed(i_brcomp_b);
			`FUNC3_BLTU	: take_branch = i_brcomp_a < i_brcomp_b;
			default		: take_branch = i_brcomp_a >= i_brcomp_b; // bgeu
		endcase
	end

endmodule
