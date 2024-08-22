`include "../common/rv_configs.v"

module rv_mem_stage (	
	input						i_mem_clk,
	input	 					i_mem_rstn,
	// EX Stage -> MEM Stage	
	input	 					i_mem_is_load,
	input		[`XLEN-1:0]		i_mem_alu_res,
	input		[`XLEN-1:0]		i_mem_ext_imm,
	input		[`XLEN-1:0]		i_mem_pc_plus_4,
	input						i_mem_dmem_we,
	input	 	[`XLEN-1:0]		i_mem_dmem_wd,
	input		[2:0]			i_mem_dmem_bytectrl,
	input						i_mem_rf_we,
	input	 	[4:0]			i_mem_rf_wa,
	input		[1:0]			i_mem_rf_wd_pre_sel,
	// MEM Stage -> WB Stage	
	output reg 					o_mem_wb_is_load,
	output reg	[`XLEN-1:0]		o_mem_wb_dmem_rd,
	output reg					o_mem_wb_rf_we,
	output reg	[4:0]			o_mem_wb_rf_wa,
	output reg	[`XLEN-1:0]		o_mem_wb_rf_wd_pre,
	// Data memory interface	
	input 		[`XLEN-1:0]		i_mem_dmem_rd,
	output		[`XLEN-1:0]		o_mem_dmem_a,
	output	 					o_mem_dmem_we,
	output		[`XLEN-1:0]		o_mem_dmem_wd,
	output	 	[2:0]			o_mem_dmem_bytectrl,
	// Forwarding
	output reg	[`XLEN-1:0]		o_mem_rf_rd_fwd			// to EX
);
	assign o_mem_dmem_a			= i_mem_alu_res;
	assign o_mem_dmem_we		= i_mem_dmem_we;
	assign o_mem_dmem_wd		= i_mem_dmem_wd;
	assign o_mem_dmem_bytectrl	= i_mem_dmem_bytectrl;

	always @(*) begin
		case (i_mem_rf_wd_pre_sel)
			`SRC_RF_WD_EXT_IMM		: o_mem_rf_rd_fwd = i_mem_ext_imm;
			`SRC_RF_WD_PC_PLUS_4	: o_mem_rf_rd_fwd = i_mem_pc_plus_4;
			default					: o_mem_rf_rd_fwd = i_mem_alu_res;
		endcase
	end

	///////////////////////////////
	// MEM/WB Pipeline Registers //
	///////////////////////////////

	always @(posedge i_mem_clk) begin
		if (!i_mem_rstn) begin
			o_mem_wb_rf_we		<= 'd0;
			o_mem_wb_is_load	<= 'd0;
			o_mem_wb_dmem_rd	<= 'd0;
			o_mem_wb_rf_wa		<= 'd0;
			o_mem_wb_rf_wd_pre	<= 'd0;
		end else begin
			o_mem_wb_rf_we		<= i_mem_rf_we;
			o_mem_wb_is_load	<= i_mem_is_load;
			o_mem_wb_dmem_rd	<= i_mem_dmem_rd;
			o_mem_wb_rf_wa		<= i_mem_rf_wa;
			o_mem_wb_rf_wd_pre	<= o_mem_rf_rd_fwd;
		end
	end
endmodule
