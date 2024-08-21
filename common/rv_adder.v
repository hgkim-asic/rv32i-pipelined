`ifndef RV_ADDER
`define	RV_ADDER

module rv_adder #(	
	parameter	BW_DATA	= 32
)(	
	input	[BW_DATA-1:0]	i_adder_data1,
	input	[BW_DATA-1:0]	i_adder_data2,
	output	[BW_DATA-1:0]	o_adder_data
);
	assign o_adder_data = i_adder_data1 + i_adder_data2;
endmodule
`endif
