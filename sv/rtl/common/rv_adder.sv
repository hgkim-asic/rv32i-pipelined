module rv_adder #(  
    parameter int unsigned  BW_DATA = 32
)(  
    input   logic [BW_DATA-1:0] i_adder_data [0:1],
    output  logic [BW_DATA-1:0] o_adder_data
);
    assign o_adder_data = i_adder_data[0] + i_adder_data[1];
endmodule
