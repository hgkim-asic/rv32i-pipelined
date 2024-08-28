module rv_dmem (    
    input   logic                       i_dmem_clk,
    input   logic                       i_dmem_rstn,
    input   logic [DMEM_ADDR_BIT-3:0]   i_dmem_addr,
    input   logic                       i_dmem_wen,
    input   logic [XLEN/8-1:0]          i_dmem_wstrb,   // write strobe
    input   logic [XLEN-1:0]            i_dmem_wdata,
    output  logic [XLEN-1:0]            o_dmem_rdata
);
    logic [8*128-1:0]   file_data_mif;
    logic [XLEN-1:0]    mem_array [0:DMEM_SIZE-1];

    initial begin
        $value$plusargs("data_mif=%s", file_data_mif);
    end

    always_ff @(posedge i_dmem_clk) begin
        if(!i_dmem_rstn) begin
            $readmemh(file_data_mif, mem_array);
        end else if (i_dmem_wen) begin
            for (int i=0; i<4; i++) begin
                mem_array[i_dmem_addr][8*i+:8] <= i_dmem_wstrb[i] ? i_dmem_wdata[8*i+:8] : mem_array[i_dmem_addr][8*i+:8];
            end
        end
    end

    assign o_dmem_rdata = mem_array[i_dmem_addr];
endmodule
