`include "../common/rv_configs.v"
`include "../common/rv_imem.v"
`include "../common/rv_dmem.v"

module rv_top (
	input						i_top_clk,
	input						i_top_rstn,
	output reg [`XLEN-1:0]		o_top_dmem_a,
	output reg					o_top_dmem_we,
	output reg [`XLEN-1:0]		o_top_dmem_wd
);
	wire	[`XLEN-1:0]		imem_ra;
	wire	[31:0]			imem_rd;

	wire					dmem_we;
	wire	[2:0]			dmem_bytectrl;
	wire	[`XLEN-1:0]		dmem_a;
	wire	[`XLEN-1:0]		dmem_wd;
	wire	[`XLEN-1:0]		dmem_rd;

	assign o_top_dmem_we	= dmem_we;
	assign o_top_dmem_a		= dmem_a;
	assign o_top_dmem_wd	= dmem_wd;

	rv_imem 
	u_rv_imem(
		.i_imem_ra				(imem_ra[`IMEM_A_BIT-1:2]	),
		.o_imem_rd				(imem_rd					)
	);

	rv_dmem 
	u_rv_dmem(
		.i_dmem_clk				(i_top_clk					),
		.i_dmem_rstn			(i_top_rstn					),
		.i_dmem_a				(dmem_a[`DMEM_A_BIT-1:0]	),
		.i_dmem_wd				(dmem_wd					),
		.i_dmem_we				(dmem_we					),
		.i_dmem_bytectrl		(dmem_bytectrl				),
		.o_dmem_rd				(dmem_rd					)
	);

	rv_core 
	u_rv_core(
		.i_core_clk				(i_top_clk					),
		.i_core_rstn			(i_top_rstn					),

	// Instr memory interface
		.i_core_imem_rd			(imem_rd					),
		.o_core_imem_ra			(imem_ra					),

	// Data memory interface
		.i_core_dmem_rd			(dmem_rd					),
		.o_core_dmem_a			(dmem_a						),
		.o_core_dmem_wd			(dmem_wd					),
		.o_core_dmem_we			(dmem_we					),
		.o_core_dmem_bytectrl	(dmem_bytectrl				)
	);
endmodule
