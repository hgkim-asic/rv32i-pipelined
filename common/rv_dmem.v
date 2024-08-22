`include "rv_configs.v"

module rv_dmem (    
    input                           i_dmem_clk,
    input                           i_dmem_rstn,
    input       [`DMEM_A_BIT-1:0]   i_dmem_a,           // byte address
    input       [`XLEN-1:0]         i_dmem_wd,
    input                           i_dmem_we,
    input       [2:0]               i_dmem_bytectrl,
    output reg  [`XLEN-1:0]         o_dmem_rd
);
    wire [`DMEM_A_BIT-3:0]  dmem_a_word = i_dmem_a[`DMEM_A_BIT-1:2]; // word address

    reg [`XLEN-1:0]         mem_array [0:`DMEM_SIZE-1];
    reg [8*128-1:0]         file_data_mif;

    initial begin
        $value$plusargs("data_mif=%s", file_data_mif);
        $readmemh(file_data_mif, mem_array);
    end


    always @(posedge i_dmem_clk) begin
        if (i_dmem_we) begin
            case (i_dmem_bytectrl)
                `DMEM_BYTECTRL_WORD : mem_array[dmem_a_word]                        <= i_dmem_wd;           // instr is 'sw'
                `DMEM_BYTECTRL_HALF : mem_array[dmem_a_word][i_dmem_a[1]*16+:16]    <= i_dmem_wd[15:0];     // instr is 'sh'
                default             : mem_array[dmem_a_word][i_dmem_a[1:0]*8+:8]    <= i_dmem_wd[7:0];      // instr is 'sb'
            endcase
        end
    end

    always @(*) begin 
        case (i_dmem_bytectrl)
            `DMEM_BYTECTRL_WORD     : o_dmem_rd = mem_array[dmem_a_word];                                                                           // instr is 'lw'
            `DMEM_BYTECTRL_HALF     : o_dmem_rd = {{16{mem_array[dmem_a_word][i_dmem_a[1]*16+15]}}, mem_array[dmem_a_word][i_dmem_a[1]*16+:16]};    // instr is 'lh'
            `DMEM_BYTECTRL_HALFU    : o_dmem_rd = {16'b0, mem_array[dmem_a_word][i_dmem_a[1]*16+:16]};                                              // instr is 'lhu'
            `DMEM_BYTECTRL_BYTE     : o_dmem_rd = {{24{mem_array[dmem_a_word][i_dmem_a[1:0]*8+7]}}, mem_array[dmem_a_word][i_dmem_a[1:0]*8+:8]};    // instr is 'lb'
            default                 : o_dmem_rd = {24'b0, mem_array[dmem_a_word][i_dmem_a[1:0]*8+:8]};                                              // instr is 'lbu'
        endcase
    end
endmodule
