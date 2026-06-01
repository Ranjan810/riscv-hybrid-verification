`timescale 1ns / 1ps

module tb_core (); 

    logic clk;
    logic rst_n;

    // Clock Generation (100 MHz)
    always #5 clk = ~clk;

    // Reset Generation & Fallback Watchdog
    initial begin
        clk = 0;
        rst_n = 0;
        #20 rst_n = 1;
        
        #500000; 
        $display("\n========================================");
        $display("WATCHDOG TIMEOUT: Simulation forcibly ended!");
        $display("========================================\n");
        $finish;
    end
    
    logic [31:0] instr_addr;
    logic [31:0] instr_in;

    // Simulated 4KB Instruction Memory
    logic [31:0] imem [0:2047];

    integer i;
    initial begin
        // PRE-ZERO THE MEMORY
        for (i = 0; i < 2048; i = i + 1) begin
            imem[i] = 32'h00000000;
        end
        
        // MUTATION BASELINE: 100% Load-Use Hazard Density
        
        $readmemh("tests/stress/forwarding_stress.hex", imem);
    end

    assign instr_in = imem[instr_addr[11:2]];

    core u_core (
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_in),
        .instr_addr(instr_addr)
    );

    // =======================================================
    // MUTATION METRICS MEASUREMENT INFRASTRUCTURE
    // =======================================================
    integer total_cycles = 0;
    integer retired_instrs = 0;
    integer total_stalls = 0;
    integer end_sim_counter = 0;

    real cpi = 0.0;

    always @(posedge clk) begin
        if (rst_n) begin

            total_cycles++;

            if (u_core.wb_valid) begin
                retired_instrs++;
            end

            // TRACK STALLS: Crucial for verifying stall-logic mutants (M1, M2)
            if (u_core.stall) begin
                total_stalls++;
            end

            // End-of-program detection
            if (u_core.id_instr == 32'h00000000 && retired_instrs > 0) begin
                end_sim_counter++;
            end
            else begin
                end_sim_counter = 0;
            end

            if (end_sim_counter > 5 && total_cycles > 50) begin
                
                if (retired_instrs == 0) begin
                    cpi = 0.0;
                end else begin
                    cpi = real'(total_cycles) / real'(retired_instrs);
                end

                $display("\n========================================");
                $display("MUTATION EXECUTION SUMMARY");
                $display("========================================");
                $display("Total Active Cycles   : %0d", total_cycles);
                $display("Retired Instructions  : %0d", retired_instrs);
                $display("Calculated CPI        : %0.3f", cpi);
                $display("----------------------------------------");
                $display("Total Stalls Inserted : %0d", total_stalls);
                $display("========================================\n");

                $finish;
            end
        end
    end

    // SCOREBOARD BINDING 
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

    // SVA BINDING
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
        .reg_x0(32'b0), 
        .expected_branch_target(ex_branch_addr), 
        .if_valid(if_valid),
        .id_valid(id_valid),
        .hazard_h1_ex_ex(hazard_h1_ex_ex),
        .hazard_h2_mem_ex(hazard_h2_mem_ex),
        .hazard_h3_load_use(hazard_h3_load_use),
        .hazard_h4_branch_flush(hazard_h4_branch_flush),
        .hazard_h5_mispredict(hazard_h5_mispredict)
    );

    // COVERAGE BINDING (Muted displays for clean output)
    bind core hazard_cg u_hazard_cg (
        .clk(clk),
        .rst_n(rst_n),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .stall(stall),
        .is_branch(ex_branch),
        .branch_taken(branch_taken_v),
        .is_jal(is_jal_v),  
        .is_jalr(is_jalr_v), 
        .bht_prediction(bht_prediction_v), 
        .hazard_h1_ex_ex(hazard_h1_ex_ex),
        .hazard_h2_mem_ex(hazard_h2_mem_ex),
        .hazard_h3_load_use(hazard_h3_load_use),
        .hazard_h4_branch_flush(hazard_h4_branch_flush),
        .hazard_h5_mispredict(hazard_h5_mispredict)
    );

endmodule