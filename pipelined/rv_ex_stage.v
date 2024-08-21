`include "../common/rv_configs.v"
`include "../common/rv_alu.v"
`include "../common/rv_adder.v"

module rv_ex_stage (	
	input						i_ex_clk,
	input	 					i_ex_rstn,
	output						o_ex_flush_ifid,
	// ID Stage -> EX Stage
	input		[`XLEN-1:0]		i_ex_pc,
	input		[2:0]			i_ex_func3,
	input		[`XLEN-1:0]		i_ex_immext_res,
	input		[1:0]			i_ex_is_br_jp,			// 01: branch, 10: jalr, 11: jal, 00: neither
	input						i_ex_is_load,
	input		[3:0]			i_ex_alu_ctrl,
	input						i_ex_alu_a_sel,
	input						i_ex_alu_b_sel,
	input		   				i_ex_dmem_we,
	input		[2:0]			i_ex_dmem_bytectrl,
	input		[`XLEN-1:0]		i_ex_rf_rd1,
	input		[`XLEN-1:0]		i_ex_rf_rd2,
	input		[4:0]			i_ex_rf_wa,
	input		   				i_ex_rf_we,
	input		[1:0]			i_ex_rf_wd_pre_sel,
	// EX Stage -> IF Stage
	output reg	[`XLEN-1:0]		o_ex_if_target_addr,
	// EX Stage -> MEM Stage	
	output reg					o_ex_mem_is_load,
	output reg	[`XLEN-1:0]		o_ex_mem_alu_res,
	output reg	[`XLEN-1:0]		o_ex_mem_immext_res,
	output reg	[`XLEN-1:0]		o_ex_mem_pc_plus_4,
	output reg	   				o_ex_mem_dmem_we,
	output reg	[`XLEN-1:0]		o_ex_mem_dmem_wd,
	output reg	[2:0]			o_ex_mem_dmem_bytectrl,
	output reg					o_ex_mem_rf_we,
	output reg	[4:0]			o_ex_mem_rf_wa,
	output reg	[1:0]			o_ex_mem_rf_wd_pre_sel,
	// Forwarding
	input		[`XLEN-1:0]		i_ex_rf_rd_mem,
	input		[`XLEN-1:0]		i_ex_rf_rd_wb,
	input		[1:0]			i_ex_rf_rd1_sel,
	input		[1:0]			i_ex_rf_rd2_sel
);
	wire	[`XLEN-1:0]		pc_plus_4_ex;

	reg		[`XLEN-1:0]		rf_rd_muxed [1:2];
	
	reg		[`XLEN-1:0]		alu_a;
	reg		[`XLEN-1:0]		alu_b;
	wire	[`XLEN-1:0]		alu_res_ex;

	assign o_ex_if_target_addr	= alu_res_ex;

	always @(*) begin
		case (i_ex_rf_rd1_sel)
			2'b01	: rf_rd_muxed[1] = i_ex_rf_rd_mem;
			2'b10	: rf_rd_muxed[1] = i_ex_rf_rd_wb;
			default	: rf_rd_muxed[1] = i_ex_rf_rd1;
		endcase
	end

	always @(*) begin
		case (i_ex_rf_rd2_sel)
			2'b01	: rf_rd_muxed[2] = i_ex_rf_rd_mem;
			2'b10	: rf_rd_muxed[2] = i_ex_rf_rd_wb;
			default	: rf_rd_muxed[2] = i_ex_rf_rd2;
		endcase
	end

	assign alu_a = i_ex_alu_a_sel ? i_ex_pc			: rf_rd_muxed[1];
	assign alu_b = i_ex_alu_b_sel ? rf_rd_muxed[2]	: i_ex_immext_res;

	rv_alu 
	u_rv_alu(
		.i_alu_a				(alu_a					),
		.i_alu_b				(alu_b					),
		.i_alu_ctrl				(i_ex_alu_ctrl			),
		.o_alu_res				(alu_res_ex				)
	);

	rv_branch_comp
	u_rv_branch_comp(
		.i_brcomp_a				(rf_rd_muxed[1]			),
		.i_brcomp_b				(rf_rd_muxed[2]			),
		.i_brcomp_func3_ex		(i_ex_func3				),
		.i_brcomp_is_br_jp_ex	(i_ex_is_br_jp			),
		.o_brcomp_flush_ifid	(o_ex_flush_ifid		)
	);

	rv_adder #(
		.BW_DATA				(`XLEN					)
	) u_rv_adder_pc_plus_4_ex(
		.i_adder_data1			(i_ex_pc				),
		.i_adder_data2			(32'd4					),
		.o_adder_data			(pc_plus_4_ex			)
	);

	///////////////////////////////
	// EX/MEM Pipeline Registers //
	///////////////////////////////
	
	always @(posedge i_ex_clk) begin
		if (!i_ex_rstn) begin
			o_ex_mem_dmem_we		<= 'd0;
			o_ex_mem_rf_we			<= 'd0;
			o_ex_mem_is_load		<= 'd0;
			o_ex_mem_alu_res		<= 'd0;
			o_ex_mem_pc_plus_4		<= 'd0;
			o_ex_mem_immext_res		<= 'd0;
			o_ex_mem_dmem_wd		<= 'd0;
			o_ex_mem_dmem_bytectrl	<= 'd0;
			o_ex_mem_rf_wa			<= 'd0;
			o_ex_mem_rf_wd_pre_sel	<= 'd0;
		end else begin
			o_ex_mem_dmem_we		<= i_ex_dmem_we;
			o_ex_mem_rf_we			<= i_ex_rf_we;
			o_ex_mem_is_load		<= i_ex_is_load;
			o_ex_mem_alu_res		<= alu_res_ex;
			o_ex_mem_pc_plus_4		<= pc_plus_4_ex;
			o_ex_mem_immext_res		<= i_ex_immext_res;
			o_ex_mem_dmem_wd		<= rf_rd_muxed[2];
			o_ex_mem_dmem_bytectrl	<= i_ex_dmem_bytectrl;
			o_ex_mem_rf_wa			<= i_ex_rf_wa;
			o_ex_mem_rf_wd_pre_sel	<= i_ex_rf_wd_pre_sel;
		end
	end
endmodule
