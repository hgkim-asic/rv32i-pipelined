`include "../common/rv_configs.v"
`include "../common/rv_immext.v"

module rv_id_stage (	
	input						i_id_clk,
	input						i_id_rstn,
	input						i_id_flush,		// from EX
	input						i_id_stall,		// from Haz
	// IF Stage -> ID Stage
	input		[`XLEN-1:0]		i_id_pc,
	input		[31:0]			i_id_instr,
	// Register file interface
	input		[`XLEN-1:0]		i_id_rf_rd1,
	input		[`XLEN-1:0]		i_id_rf_rd2,
	output		[4:0]			o_id_rf_ra1,
	output		[4:0]			o_id_rf_ra2,
	// ID Stage -> EX Stage
	output reg	[`XLEN-1:0]		o_id_ex_pc,
	output reg	[2:0]			o_id_ex_func3,
	output reg	[`XLEN-1:0]		o_id_ex_immext_res,
	output reg	[1:0]			o_id_ex_is_br_jp,		// 01: branch, 10: jal, 11: jalr, 00: neither
	output reg					o_id_ex_is_load,
	output reg	[3:0]			o_id_ex_alu_ctrl,
	output reg					o_id_ex_alu_a_sel,
	output reg					o_id_ex_alu_b_sel,
	output reg					o_id_ex_dmem_we,
	output reg	[2:0]			o_id_ex_dmem_bytectrl,
	output reg					o_id_ex_rf_we,
	output reg	[4:0]			o_id_ex_rf_wa,
	output reg	[`XLEN-1:0]		o_id_ex_rf_rd1,
	output reg	[`XLEN-1:0]		o_id_ex_rf_rd2,
	output reg	[1:0]			o_id_ex_rf_wd_pre_sel,
	// Forwarding
	output reg	[4:0]			o_id_ex_rf_ra1,			// to Hazard Unit
	output reg	[4:0]			o_id_ex_rf_ra2			// to Hazard Unit
);
	wire [1:0]			is_br_jp_id;
	wire 				is_load_id;
	
	wire [2:0]			immext_ctrl;
	wire [`XLEN-1:0]	immext_res_id;
	
	wire [3:0]			alu_ctrl_id;
	wire				alu_a_sel_id;
	wire				alu_b_sel_id;
	
	wire 				dmem_we_id;
	wire [2:0]			dmem_bytectrl_id;
	
	wire 				rf_we_id;
	wire [4:0]			rf_wa_id;
	wire [1:0]			rf_wd_pre_sel_id;
	
	assign rf_wa_id		= i_id_instr[11:7];
	assign o_id_rf_ra1	= i_id_instr[19:15];
	assign o_id_rf_ra2	= i_id_instr[24:20];

	rv_ctrl 
	u_rv_ctrl(
		.i_ctrl_opcode				(i_id_instr[6:0]							),
		.i_ctrl_func3				(i_id_instr[14:12]							),
		.i_ctrl_func7_5				(i_id_instr[30]								),
		.o_ctrl_immext_ctrl			(immext_ctrl								),
		.o_ctrl_is_br_jp			(is_br_jp_id								),
		.o_ctrl_is_load				(is_load_id									),
		.o_ctrl_alu_ctrl			(alu_ctrl_id								),
		.o_ctrl_alu_a_sel			(alu_a_sel_id								),
		.o_ctrl_alu_b_sel			(alu_b_sel_id								),
		.o_ctrl_dmem_we				(dmem_we_id									),
		.o_ctrl_dmem_bytectrl		(dmem_bytectrl_id							),
		.o_ctrl_rf_we				(rf_we_id									),
		.o_ctrl_rf_wd_pre_sel		(rf_wd_pre_sel_id							)
	);

	rv_immext 
	u_rv_immext(
		.i_immext_instr_31to7		(i_id_instr[31:7]							),
		.i_immext_ctrl				(immext_ctrl								),
		.o_immext_res				(immext_res_id								)
	);

	//////////////////////////////
	// ID/EX Pipeline Registers //
	//////////////////////////////
	
	always @(posedge i_id_clk) begin
		if (!i_id_rstn) begin
			o_id_ex_pc			 	<= 'd0;	
			o_id_ex_func3			<= 'd0;
			o_id_ex_immext_res		<= 'd0;
			o_id_ex_is_br_jp		<= 'd0;
			o_id_ex_is_load			<= 'd0;
			o_id_ex_alu_ctrl 		<= 'd0;
			o_id_ex_alu_a_sel		<= 'd0;
			o_id_ex_alu_b_sel		<= 'd0;
			o_id_ex_dmem_we			<= 'd0;
			o_id_ex_dmem_bytectrl	<= 'd0;
			o_id_ex_rf_we			<= 'd0;
			o_id_ex_rf_wa 			<= 'd0;
			o_id_ex_rf_rd1			<= 'd0;
			o_id_ex_rf_rd2			<= 'd0;
			o_id_ex_rf_wd_pre_sel	<= 'd0;
			o_id_ex_rf_ra1			<= 'd0;
			o_id_ex_rf_ra2			<= 'd0;
		end else begin
			if (i_id_flush) begin
				o_id_ex_pc			 	<= 'd0;
				o_id_ex_func3			<= 'd0;
				o_id_ex_immext_res		<= 'd0;
				o_id_ex_is_br_jp		<= 'd0;
				o_id_ex_is_load			<= 'd0;
				o_id_ex_alu_ctrl 		<= 'd0;
				o_id_ex_alu_a_sel		<= 'd0;
				o_id_ex_alu_b_sel		<= 'd0;
				o_id_ex_dmem_we			<= 'd0;
				o_id_ex_dmem_bytectrl	<= 'd0;
				o_id_ex_rf_we			<= 'd0;
				o_id_ex_rf_wa 			<= 'd0;
				o_id_ex_rf_rd1			<= 'd0;
				o_id_ex_rf_rd2			<= 'd0;
				o_id_ex_rf_wd_pre_sel	<= 'd0;
				o_id_ex_rf_ra1			<= 'd0;
				o_id_ex_rf_ra2			<= 'd0;
			end else if (!i_id_stall) begin
				o_id_ex_pc			 	<= i_id_pc;
				o_id_ex_func3			<= i_id_instr[14:12];
				o_id_ex_immext_res		<= immext_res_id;
				o_id_ex_is_br_jp		<= is_br_jp_id;
				o_id_ex_is_load			<= is_load_id;
				o_id_ex_alu_ctrl 		<= alu_ctrl_id;
				o_id_ex_alu_a_sel		<= alu_a_sel_id;
				o_id_ex_alu_b_sel		<= alu_b_sel_id;
				o_id_ex_dmem_we			<= dmem_we_id;
				o_id_ex_dmem_bytectrl	<= dmem_bytectrl_id;
				o_id_ex_rf_wa 			<= rf_wa_id;
				o_id_ex_rf_we			<= rf_we_id;
				o_id_ex_rf_rd1			<= i_id_rf_rd1;
				o_id_ex_rf_rd2			<= i_id_rf_rd2;
				o_id_ex_rf_wd_pre_sel	<= rf_wd_pre_sel_id;
				o_id_ex_rf_ra1			<= o_id_rf_ra1;
				o_id_ex_rf_ra2			<= o_id_rf_ra2;
			end
		end
	end
endmodule
