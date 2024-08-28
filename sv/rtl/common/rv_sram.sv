module rv_spsram #( 
    parameter int unsigned  BW_DATA     = 32,
    parameter int unsigned  BW_ADDR     = 4
) ( 
    input   logic               i_spsram_clk,
    input   logic               i_spsram_rstn,
    input   logic [BW_DATA-1:0] i_spsram_data,
    input   logic [BW_ADDR-1:0] i_spsram_addr,
    input   logic               i_spsram_cen,
    input   logic               i_spsram_wen,
    input   logic               i_spsram_ren,
    output  logic [BW_DATA-1:0] o_spsram_data
    output  logic               o_spsram_data_val,
);
    logic [BW_DATA-1:0] mem_arr[0:2**BW_ADDR-1];

    always_ff @(posedge i_clk) begin
        if (!i_spsram_rstn) begin
            mem_arr                 <= '{default:0};
        end else begin
            if (i_spsram_cen && i_spsram_wen) begin
                mem_arr[i_spsram_addr]  <= i_spsram_data;
            end else begin
                mem_arr[i_spsram_addr]  <= mem_arr[i_spsram_addr];
            end
        end
    end

    assign  o_spsram_data       = mem_arr[i_spsram_addr];
    assign  o_spsram_data_val   = i_spsram_ren;
endmodule
