`include "../common/rv_configs.v"
`include "../common/rv_adder.v"
`include "../common/rv_dff.v"

module rv_if_stage (	
	input						i_if_clk,
	input						i_if_rstn,
	input						i_if_flush,		// from EX
	input						i_if_stall,		// from Haz
	// Instr memory interface
	input	 	[`XLEN-1:0]		i_if_imem_rd,
	output		[`XLEN-1:0]		o_if_imem_ra,
	// EX Stage -> IF Stage
	input		[`XLEN-1:0]		i_if_target_addr,
	// IF Stage -> ID Stage
	output reg	[`XLEN-1:0]		o_if_id_pc,
	output reg	[31:0]			o_if_id_instr
);
	wire 	[31:0]			instr_if;
	wire	[`XLEN-1:0]		pc_if;
	wire	[`XLEN-1:0]		pc_next;
	wire 	[`XLEN-1:0]		pc_plus_4_if;

	assign	o_if_imem_ra	= pc_if;
	assign	instr_if		= i_if_imem_rd;
	assign	pc_next 		= i_if_flush ? i_if_target_addr : pc_plus_4_if;

	rv_dff #(
		.BW_DATA				(`XLEN						),
		.INIT_VAL				(`INIT_PC					)
	) u_pc(
		.i_dff_clk				(i_if_clk					),
		.i_dff_rstn				(i_if_rstn					),
		.i_dff_en				(!i_if_stall				),
		.i_dff_d				(pc_next					),
		.o_dff_q				(pc_if						)
	);

	rv_adder #(
		.BW_DATA				(`XLEN						)
	) u_rv_adder_pc_plus_4_id(
		.i_adder_data1			(pc_if						),
		.i_adder_data2			(32'd4						),
		.o_adder_data			(pc_plus_4_if				)
	);

	//////////////////////////////
	// IF/ID Pipeline Registers //
	//////////////////////////////
	
	always @(posedge i_if_clk) begin
		if (!i_if_rstn) begin
			o_if_id_instr	<= 'd0;
			o_if_id_pc		<= 'd0;
		end else begin
			if (i_if_flush) begin
				o_if_id_instr	<= 'd0;
				o_if_id_pc		<= 'd0;
			end else if (!i_if_stall) begin
				o_if_id_instr	<= instr_if;
				o_if_id_pc		<= pc_if;
			end
		end
	end
endmodule
