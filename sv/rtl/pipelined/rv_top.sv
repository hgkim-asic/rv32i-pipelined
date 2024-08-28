`include "rv_pkg.sv"

import rv_pkg::*;
module rv_top (
    input   logic               i_top_clk,
    input   logic               i_top_rstn,
    output  logic [XLEN-1:0]    o_top_dmem_addr,
    output  logic               o_top_dmem_wen,
    output  logic [XLEN-1:0]    o_top_dmem_wdata
);
    logic [XLEN-1:0]        imem_raddr;
    logic [31:0]            imem_rdata;

    logic [XLEN-1:0]        dmem_rdata;
    logic [XLEN-1:0]        dmem_addr;
    logic                   dmem_wen;
    logic [XLEN/8-1:0]      dmem_wstrb;
    logic [XLEN-1:0]        dmem_wdata;

    assign o_top_dmem_addr  = dmem_addr;
    assign o_top_dmem_wen   = dmem_wen;
    assign o_top_dmem_wdata = dmem_wdata;

    rv_imem
    u_rv_imem(
        .i_imem_raddr               (imem_raddr[IMEM_ADDR_BIT-1:2]  ),
        .o_imem_rdata               (imem_rdata                     )
    );

    rv_dmem 
    u_rv_dmem(
        .i_dmem_clk                 (i_top_clk                      ),
        .i_dmem_rstn                (i_top_rstn                     ),
        .i_dmem_addr                (dmem_addr[DMEM_ADDR_BIT-1:2]   ),
        .i_dmem_wen                 (dmem_wen                       ),
        .i_dmem_wstrb               (dmem_wstrb                     ),
        .i_dmem_wdata               (dmem_wdata                     ),
        .o_dmem_rdata               (dmem_rdata                     )
    );

    rv_core
    u_rv_core(
        .i_core_clk                 (i_top_clk                      ),
        .i_core_rstn                (i_top_rstn                     ),
    // Instr memory interface
        .i_core_imem_rdata          (imem_rdata                     ),
        .o_core_imem_raddr          (imem_raddr                     ),
    // Data memory interface
        .i_core_dmem_rdata          (dmem_rdata                     ),
        .o_core_dmem_addr           (dmem_addr                      ),
        .o_core_dmem_wen            (dmem_wen                       ),
        .o_core_dmem_wstrb          (dmem_wstrb                     ),
        .o_core_dmem_wdata          (dmem_wdata                     )
    );
endmodule
