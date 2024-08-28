module rv_stage_if (    
    input   logic                   i_if_clk,
    input   logic                   i_if_rstn,
    input   logic                   i_if_flush,         // from Branch unit
    input   logic                   i_if_stall,         // from Hazard Unit
    // Instr memory interface
    input   logic [XLEN-1:0]        i_if_imem_rdata,
    output  logic [XLEN-1:0]        o_if_imem_raddr,
    // from Branch Unit
    input   logic [XLEN-1:0]        i_if_pc_adder_src,
    input   rv_pkg::pc_next_sel_e   i_if_pc_next_sel,
    input   logic                   i_if_pred_taken,
    // from EX Stage
    input   logic [XLEN-1:0]        i_if_pc_plus_4_ex,
    input   logic [XLEN-1:0]        i_if_alu_res_ex,
    // to ID Stage
    output  logic [XLEN-1:0]        o_if_id_pc,
    output  logic [31:0]            o_if_id_instr,
    output  logic                   o_if_id_pred_taken
);
    logic [XLEN-1:0]        pc_if;
    logic [XLEN-1:0]        pc_next;
    logic [XLEN-1:0]        pc_adder_res;

    assign o_if_imem_raddr  = pc_if;

    always_comb begin
        unique case (i_if_pc_next_sel)
            PC_NEXT_SEL_ALU_RES_EX      : pc_next = i_if_alu_res_ex;
            PC_NEXT_SEL_PC_PLUS_4_EX    : pc_next = i_if_pc_plus_4_ex;
            default                     : pc_next = pc_adder_res;
        endcase
    end

    rv_dff #(
        .BW_DATA                (XLEN                           ),
        .INIT_VAL               (INIT_PC                        )
    ) u_pc(
        .i_dff_clk              (i_if_clk                       ),
        .i_dff_rstn             (i_if_rstn                      ),
        .i_dff_en               (!i_if_stall                    ),
        .i_dff_d                (pc_next                        ),
        .o_dff_q                (pc_if                          )
    );

    rv_adder #(
        .BW_DATA                (XLEN                           )
    ) u_rv_adder_pc_if(
        .i_adder_data           ('{pc_if, i_if_pc_adder_src}    ),
        .o_adder_data           (pc_adder_res                   )
    );

    //////////////////////////////
    // IF/ID Pipeline Registers //
    //////////////////////////////
    
    always_ff @(posedge i_if_clk) begin
        if (!i_if_rstn) begin
            o_if_id_instr       <= 'd0;
        end else begin
            if (i_if_flush) begin
                o_if_id_instr       <= 'd0;
            end else if (!i_if_stall) begin
                o_if_id_instr       <= i_if_imem_rdata;
            end
        end
    end

    always_ff @(posedge i_if_clk) begin
        if (!i_if_stall) begin
            o_if_id_pc          <= pc_if;
            o_if_id_pred_taken  <= i_if_pred_taken;
        end
    end
endmodule
