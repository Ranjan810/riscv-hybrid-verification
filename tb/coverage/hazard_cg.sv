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

endmodule