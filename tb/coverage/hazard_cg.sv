`timescale 1ns / 1ps
module hazard_cg (
    input logic clk,
    input logic rst_n,
    
    // Core Signals
    input logic [1:0] forward_a,
    input logic [1:0] forward_b,
    input logic stall,
    input logic is_branch,
    input logic branch_taken,
    input logic is_jal,
    input logic is_jalr,
    
    // Branch Predictor State
    input logic bht_prediction,
    
    // Hazard classification flags
    input logic hazard_h1_ex_ex,
    input logic hazard_h2_mem_ex,
    input logic hazard_h3_load_use,
    input logic hazard_h4_branch_flush,
    input logic hazard_h5_mispredict
);

    covergroup cg_hazards @(posedge clk);
        
        // Coverage Goals & Closure Strategy
        option.goal = 100;
        option.name = "Pipeline_Hazard_Coverage";

        // =======================================================
        // 1. DATA HAZARD COVERPOINTS
        // =======================================================
        
        cp_h1_ex_ex: coverpoint hazard_h1_ex_ex { bins hit = {1}; }
        cp_h2_mem_ex: coverpoint hazard_h2_mem_ex { bins hit = {1}; }
        cp_load_use: coverpoint hazard_h3_load_use { bins hit = {1}; }
        
        cp_forward_a: coverpoint forward_a {
            bins normal   = {2'b00};
            bins from_wb  = {2'b01};
            bins from_mem = {2'b10};
            illegal_bins invalid = {2'b11};
        }
        
        cp_forward_b: coverpoint forward_b {
            bins normal   = {2'b00};
            bins from_wb  = {2'b01};
            bins from_mem = {2'b10};
            illegal_bins invalid = {2'b11}; 
        }

        // =======================================================
        // 2. CONTROL HAZARD COVERPOINTS
        // =======================================================
        
        cp_branch_eval: coverpoint is_branch {
            bins taken     = {1} iff (branch_taken == 1'b1);
            bins not_taken = {1} iff (branch_taken == 1'b0);
        }
        
        cp_jumps: coverpoint {is_jal, is_jalr} {
            bins jal_hit  = {2'b10};
            bins jalr_hit = {2'b01};
        }

        cp_mispredict: coverpoint hazard_h5_mispredict { bins hit = {1}; }

        // =======================================================
        // 3. TRANSITION & STATE DYNAMICS
        // =======================================================
        
        cp_bht_transitions: coverpoint bht_prediction {
            bins taken_to_taken = (1 => 1);
            bins taken_to_nt    = (1 => 0);
            bins nt_to_taken    = (0 => 1);
            bins nt_to_nt       = (0 => 0);
        }

        // =======================================================
        // 4. MAXIMUM DEPTH CROSS COVERAGE
        // =======================================================
        
        // Stalls and Forwarding Overlap
        cross_stall_fwd_a: cross cp_load_use, cp_forward_a;
        cross_stall_fwd_b: cross cp_load_use, cp_forward_b;
        
        // Simultaneous Dual Forwarding
        cross_fwd_a_b: cross cp_forward_a, cp_forward_b {
            ignore_bins no_fwd = binsof(cp_forward_a.normal) || binsof(cp_forward_b.normal);
        }

        // Branch/Jump overlapping with Forwarding (using bypassed data for resolution)
        cross_branch_dual_fwd: cross cp_branch_eval, cp_forward_a, cp_forward_b {
            ignore_bins no_fwd = binsof(cp_forward_a.normal) || binsof(cp_forward_b.normal);
        }
        cross_jump_fwd_a: cross cp_jumps, cp_forward_a;

        // Mispredicts overlapping with Data Hazards
        cross_mispredict_fwd_a: cross cp_mispredict, cp_forward_a;
        cross_mispredict_fwd_b: cross cp_mispredict, cp_forward_b;
        
        // Flush + Stall Collision
        cross_flush_stall: cross cp_mispredict, cp_load_use;

    endgroup

    // Instantiate the covergroup
    cg_hazards hazard_inst;

    initial begin 
        hazard_inst = new(); 
    end
    //Coverage Details
 /*   final begin

        $display("\n");
        $display("========================================");
        $display("PER COVERPOINT COVERAGE");
        $display("========================================");

        $display("H1 EX-EX           : %0.2f%%",
                hazard_inst.cp_h1_ex_ex.get_coverage());

        $display("H2 MEM-EX          : %0.2f%%",
                hazard_inst.cp_h2_mem_ex.get_coverage());

        $display("Load Use           : %0.2f%%",
                hazard_inst.cp_load_use.get_coverage());

        $display("Forward A          : %0.2f%%",
                hazard_inst.cp_forward_a.get_coverage());

        $display("Forward B          : %0.2f%%",
                hazard_inst.cp_forward_b.get_coverage());

        $display("Branch Eval        : %0.2f%%",
                hazard_inst.cp_branch_eval.get_coverage());

        $display("Jumps              : %0.2f%%",
                hazard_inst.cp_jumps.get_coverage());

        $display("Mispredict         : %0.2f%%",
                hazard_inst.cp_mispredict.get_coverage());

        $display("BHT Transitions    : %0.2f%%",
                hazard_inst.cp_bht_transitions.get_coverage());

        $display("========================================");

        $display("Cross Stall Fwd A  : %0.2f%%",
                hazard_inst.cross_stall_fwd_a.get_coverage());

        $display("Cross Stall Fwd B  : %0.2f%%",
                hazard_inst.cross_stall_fwd_b.get_coverage());

        $display("Cross Fwd A B      : %0.2f%%",
                hazard_inst.cross_fwd_a_b.get_coverage());

        $display("Branch Dual Fwd    : %0.2f%%",
                hazard_inst.cross_branch_dual_fwd.get_coverage());

        $display("Jump Fwd A         : %0.2f%%",
                hazard_inst.cross_jump_fwd_a.get_coverage());

        $display("Mispredict Fwd A   : %0.2f%%",
                hazard_inst.cross_mispredict_fwd_a.get_coverage());

        $display("Mispredict Fwd B   : %0.2f%%",
                hazard_inst.cross_mispredict_fwd_b.get_coverage());

        $display("Flush Stall        : %0.2f%%",
                hazard_inst.cross_flush_stall.get_coverage());

        $display("========================================");
    end
   
    integer jal_count;
    integer jalr_count;

    initial begin
        jal_count  = 0;
        jalr_count = 0;
    end
    integer tt_count;  // 1 -> 1
    integer tn_count;  // 1 -> 0
    integer nt_count;  // 0 -> 1
    integer nn_count;  // 0 -> 0

    logic prev_bht;

    initial begin
        tt_count = 0;
        tn_count = 0;
        nt_count = 0;
        nn_count = 0;
        prev_bht = 0;
    end
    //Debugging Signals
    always @(posedge clk) begin
        if (rst_n) begin

            if (prev_bht == 1'b1 && bht_prediction == 1'b1)
                tt_count++;

            else if (prev_bht == 1'b1 && bht_prediction == 1'b0)
                tn_count++;

            else if (prev_bht == 1'b0 && bht_prediction == 1'b1)
                nt_count++;

            else if (prev_bht == 1'b0 && bht_prediction == 1'b0)
                nn_count++;

            prev_bht <= bht_prediction;
        end
    end
    
    
    always @(posedge clk) begin
        if (is_jal)
            jal_count++;

        if (is_jalr)
            jalr_count++;
    end
    /*
    always @(posedge clk) begin
        if (is_branch) begin
            $display(
                "[BRANCH_CROSS] FA=%b FB=%b TAKEN=%b",
                forward_a,
                forward_b,
                branch_taken
            );
        end
    end
    
    
    always @(posedge clk) begin
        if (hazard_h3_load_use || hazard_h5_mispredict) begin
            $display(
                "[FLUSH_STALL_DEBUG] LU=%0b MP=%0b",
                hazard_h3_load_use,
                hazard_h5_mispredict
            );
        end
    end
    
    always @(posedge clk) begin
        if (hazard_h3_load_use)
            $display("[LOAD_USE_SEEN] Time=%0t", $time);
    end
    /*
    final begin
        $display("========================================");
        $display("JAL Count  = %0d", jal_count);
        $display("JALR Count = %0d", jalr_count);
        $display("========================================");
        $display("========================================");
        $display("BHT TRANSITION COUNTS");
        $display("========================================");
        $display("1 -> 1 : %0d", tt_count);
        $display("1 -> 0 : %0d", tn_count);
        $display("0 -> 1 : %0d", nt_count);
        $display("0 -> 0 : %0d", nn_count);
        $display("========================================");
    end

    */
endmodule