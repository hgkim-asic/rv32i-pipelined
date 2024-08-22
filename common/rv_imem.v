`include "rv_configs.v"

module rv_imem( 
    input   [`IMEM_A_BIT-3:0]   i_imem_ra,
    output  [`XLEN-1:0]         o_imem_rd
);
    reg [`XLEN-1:0]     mem_array [0:`IMEM_SIZE-1];
    reg [8*128-1:0]     file_text_mif;

    initial begin
        $value$plusargs("text_mif=%s", file_text_mif);
        $readmemh(file_text_mif, mem_array);
    end
    
    assign o_imem_rd = mem_array[i_imem_ra];
endmodule
