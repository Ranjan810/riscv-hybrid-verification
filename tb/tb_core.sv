`timescale 1ns/1ps
module tb_core (); // NO INPUTS! It is a top-level testbench now.


    logic clk;
    logic rst_n;

    // Clock Generation (100 MHz)
    always #5 clk = ~clk;

    // Reset Generation
    initial begin
        clk = 0;
        rst_n = 0;
        #20 rst_n = 1;
        #100000 
        $display("\n========================================");
        $display("FINAL COVERAGE REPORT");
        $display("========================================");
        $display("Total Functional Coverage: %0.2f%%", $get_coverage());
        $display("========================================\n");
        
        $finish; // Release reset after 20ns
    end
    
    logic [31:0] instr_addr;
    logic [31:0] instr_in;

    // Simulated 4KB Instruction Memory
    logic [31:0] imem [0:2047];

    // Load the stress test
    initial begin
        $readmemh("stress_test.hex", imem);
    end

    assign instr_in = imem[instr_addr[11:2]];

    core u_core (
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_in),
        .instr_addr(instr_addr)
    );

    // =======================================================
    // SCOREBOARD BINDING (Snooping core.sv signals)
    // =======================================================
    scoreboard u_scoreboard (
        .clk(clk),
        .rst_n(rst_n),
        .dut_id_pc(u_core.id_pc),
        .dut_id_instr(u_core.id_instr),
        .dut_stall(u_core.stall),
        .dut_flush_mispredict(u_core.flush_mispredict),
        .dut_wb_valid(u_core.wb_valid),
        .dut_wb_reg_write(u_core.wb_reg_write),
        .dut_wb_rd(u_core.wb_rd_addr),
        .dut_wb_data(u_core.wb_result)
    );

    // =======================================================
    // SVA BINDING
    // =======================================================
    bind core hazard_sva u_hazard_sva (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .flush_mispredict(flush_mispredict),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .is_branch(ex_branch),
        .branch_taken(flush_mispredict),
        .if_pc(if_pc),                   
        .id_instr(id_instr), 
        .reg_x0(32'b0), // Placeholder 
        .expected_branch_target(ex_branch_addr), 
        .if_valid(if_valid),
        .id_valid(id_valid),
        .hazard_h1_ex_ex(hazard_h1_ex_ex),
        .hazard_h2_mem_ex(hazard_h2_mem_ex),
        .hazard_h3_load_use(hazard_h3_load_use),
        .hazard_h4_branch_flush(hazard_h4_branch_flush),
        .hazard_h5_mispredict(hazard_h5_mispredict)
    );

    // =======================================================
    // COVERAGE BINDING
    // =======================================================
    bind core hazard_cg u_hazard_cg (
        .clk(clk),
        .rst_n(rst_n),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .stall(stall),
        .is_branch(ex_branch),
        .branch_taken(flush_mispredict),
        .is_jal(1'b0),  // Placeholder
        .is_jalr(1'b0), // Placeholder
        .bht_prediction(1'b0), // Placeholder
        .hazard_h1_ex_ex(hazard_h1_ex_ex),
        .hazard_h2_mem_ex(hazard_h2_mem_ex),
        .hazard_h3_load_use(hazard_h3_load_use),
        .hazard_h4_branch_flush(hazard_h4_branch_flush),
        .hazard_h5_mispredict(hazard_h5_mispredict)
    );

endmodule