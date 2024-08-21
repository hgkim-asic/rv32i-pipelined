module rv_dff #(
	parameter	BW_DATA		= 32,
	parameter	INIT_VAL	= 0
)(	
	input						i_dff_clk,
	input		  				i_dff_rstn,
	input		  				i_dff_en,
	input		[BW_DATA-1:0]	i_dff_d,
	output reg	[BW_DATA-1:0]	o_dff_q
);
	always @(posedge i_dff_clk) begin
		if (!i_dff_rstn) begin
			o_dff_q <= INIT_VAL;
		end else if (i_dff_en) begin
			o_dff_q <= i_dff_d;
		end
	end
endmodule
