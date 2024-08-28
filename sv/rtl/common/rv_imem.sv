module rv_imem( 
    input   logic [IMEM_ADDR_BIT-3:0]   i_imem_raddr,
    output  logic [XLEN-1:0]            o_imem_rdata
);
    logic [XLEN-1:0]    mem_array [0:IMEM_SIZE-1];
    logic [8*128-1:0]   file_text_mif;

    initial begin
        $value$plusargs("text_mif=%s", file_text_mif);
        $readmemh(file_text_mif, mem_array);
    end
    
    assign o_imem_rdata = mem_array[i_imem_raddr];
endmodule
