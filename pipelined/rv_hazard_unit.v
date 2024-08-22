`include "../common/rv_configs.v"

module rv_hazard_unit(
	input				i_haz_is_load_mem,
	input				i_haz_is_load_wb,
	input		[4:0]	i_haz_rf_ra1_id,
	input		[4:0]	i_haz_rf_ra2_id,
	input		[4:0]	i_haz_rf_ra1_ex,
	input		[4:0]	i_haz_rf_ra2_ex,
	input		[4:0]	i_haz_rf_wa_mem,
	input		[4:0]	i_haz_rf_wa_wb,
	input				i_haz_rf_we_mem,
	input				i_haz_rf_we_wb,
	output reg	[1:0] 	o_haz_rf_rd1_sel_ex,	// to EX
	output reg	[1:0] 	o_haz_rf_rd2_sel_ex,	// to EX
	output				o_haz_rf_rd1_sel_id,	// to ID
	output				o_haz_rf_rd2_sel_id,	// to ID
	output				o_haz_stall_ifid		// to IF, ID
);
	wire	[1:0]	raw_hazard [1:2];			// for rs1, rs2

	assign o_haz_stall_ifid = i_haz_is_load_mem && raw_hazard[1][0];

	assign raw_hazard[1][0]	= (i_haz_rf_ra1_ex == i_haz_rf_wa_mem)	&&	i_haz_rf_we_mem;
	assign raw_hazard[1][1] = (i_haz_rf_ra1_ex == i_haz_rf_wa_wb)	&&	i_haz_rf_we_wb;

	assign raw_hazard[2][0]	= (i_haz_rf_ra2_ex == i_haz_rf_wa_mem)	&&	i_haz_rf_we_mem;
	assign raw_hazard[2][1] = (i_haz_rf_ra2_ex == i_haz_rf_wa_wb)	&&	i_haz_rf_we_wb;

	always @(*) begin
		case (raw_hazard[1])
			2'b00 : o_haz_rf_rd1_sel_ex = `SRC_RF_RD_EX;
			2'b01 : o_haz_rf_rd1_sel_ex = `SRC_RF_RD_MEM;
			2'b10 : o_haz_rf_rd1_sel_ex = `SRC_RF_RD_WB;
			2'b11 : o_haz_rf_rd1_sel_ex = i_haz_is_load_wb ? `SRC_RF_RD_WB : `SRC_RF_RD_MEM;
		endcase
	end

	always @(*) begin
		case (raw_hazard[2])
			2'b00 : o_haz_rf_rd2_sel_ex = `SRC_RF_RD_EX;
			2'b01 : o_haz_rf_rd2_sel_ex = `SRC_RF_RD_MEM;
			2'b10 : o_haz_rf_rd2_sel_ex = `SRC_RF_RD_WB;
			2'b11 : o_haz_rf_rd2_sel_ex = i_haz_is_load_wb ? `SRC_RF_RD_WB : `SRC_RF_RD_MEM;
		endcase
	end

	assign o_haz_rf_rd1_sel_id = (i_haz_rf_ra1_id==i_haz_rf_wa_wb) && i_haz_rf_we_wb && (i_haz_rf_wa_wb != 5'b0);
	assign o_haz_rf_rd2_sel_id = (i_haz_rf_ra2_id==i_haz_rf_wa_wb) && i_haz_rf_we_wb && (i_haz_rf_wa_wb != 5'b0);
endmodule
