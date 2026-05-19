module hazard_sva (
    input logic clk,
    input logic rst_n,
    
    // Core Control Signals
    input logic stall,
    input logic flush_mispredict,
    input logic [1:0] forward_a,
    input logic [1:0] forward_b,
    input logic is_branch,
    input logic branch_taken,
    
    // Core Architectural State
    input logic [31:0] if_pc,
    input logic [31:0] id_instr,
    input logic [31:0] reg_x0,
    input logic [31:0] expected_branch_target, 
    
    // Pipeline Valid Bits
    input logic if_valid,
    input logic id_valid,
    
    // Hazard classification flags
    input logic hazard_h1_ex_ex,
    input logic hazard_h2_mem_ex,
    input logic hazard_h3_load_use,
    input logic hazard_h4_branch_flush,
    input logic hazard_h5_mispredict
);

    // Global reset mask
    default clocking cb @(posedge clk); endclocking
    default disable iff (!rst_n);

    // =======================================================
    // 1. DATA HAZARDS: FORWARDING (Positive & Negative)
    // =======================================================
    
    // POSITIVE: If EX-EX RAW hazard (H1), MUST bypass from MEM (10)
    property p_forward_h1;
        hazard_h1_ex_ex |-> (forward_a == 2'b10) || (forward_b == 2'b10);
    endproperty
    assert_h1: assert property (p_forward_h1) else $error("SVA FAILED: H1 missed by forwarding unit!");

    // POSITIVE: If MEM-EX RAW hazard (H2), MUST bypass from WB (01)
    property p_forward_h2;
        hazard_h2_mem_ex |-> (forward_a == 2'b01) || (forward_b == 2'b01);
    endproperty
    assert_h2: assert property (p_forward_h2) else $error("SVA FAILED: H2 missed by forwarding unit!");

    // NEGATIVE: No spontaneous forwarding on port A
    property p_no_false_forward_a;
        !(hazard_h1_ex_ex || hazard_h2_mem_ex) |-> (forward_a == 2'b00);
    endproperty
    assert_no_false_fwd_a: assert property (p_no_false_forward_a) else $error("SVA FAILED: False forwarding triggered on A!");

    // NEGATIVE: No spontaneous forwarding on port B
    property p_no_false_forward_b;
        !(hazard_h1_ex_ex || hazard_h2_mem_ex) |-> (forward_b == 2'b00);
    endproperty
    assert_no_false_fwd_b: assert property (p_no_false_forward_b) else $error("SVA FAILED: False forwarding triggered on B!");

    // =======================================================
    // 2. DATA HAZARDS: STALLING
    // =======================================================
    
    // SIGNAL CHECK: Load-Use hazard must trigger the stall wire immediately.
    property p_stall_trigger;
        hazard_h3_load_use |-> stall;
    endproperty
    assert_stall_trig: assert property (p_stall_trigger);

    // ARCHITECTURAL CHECK: If stall is high, the PC must freeze on the NEXT cycle.
    property p_stall_freezes_pc;
        stall |=> (if_pc == $past(if_pc));
    endproperty
    assert_stall_pc: assert property (p_stall_freezes_pc) else $error("ARCH FAILED: Stall did not freeze the PC!");

    // ARCHITECTURAL CHECK: If stall is high, the instruction in Decode must be preserved.
    property p_stall_freezes_instr;
        stall |=> (id_instr == $past(id_instr));
    endproperty
    assert_stall_instr: assert property (p_stall_freezes_instr) else $error("ARCH FAILED: Stall dropped the Decode instruction!");

    // =======================================================
    // 3. CONTROL HAZARDS: ARCHITECTURAL FLUSH & RECOVERY
    // =======================================================
    
    // SIGNAL CHECK: Mispredict must trigger the flush wire immediately.
    property p_flush_trigger;
        hazard_h5_mispredict |-> flush_mispredict;
    endproperty
    assert_flush_trig: assert property (p_flush_trigger);

    // ARCHITECTURAL CHECK: Flush must clear the Decode valid bit in the next cycle
    property p_flush_invalidation;
        flush_mispredict |=> (id_valid == 1'b0);
    endproperty
    assert_flush_arch: assert property (p_flush_invalidation) else $error("ARCH FAILED: Flush did not clear the ID valid bit!");

    // ARCHITECTURAL CHECK: PC must become the EXACT expected target, not just PC+4
    property p_branch_exact_target;
        (is_branch && branch_taken) |=> (if_pc == expected_branch_target);
    endproperty
    assert_branch_redirect: assert property (p_branch_exact_target) else $error("ARCH FAILED: PC redirected to incorrect target!");

    // TEMPORAL CHECK: Pipeline must recover fetch exactly 2 cycles after a mispredict
    property p_mispredict_recovery_latency;
        hazard_h5_mispredict |=> ##1 (if_valid == 1'b1);
    endproperty
    assert_recovery_latency: assert property (p_mispredict_recovery_latency) else $error("TEMPORAL FAILED: Pipeline failed to recover fetch within 2 cycles!");

    // =======================================================
    // 4. ARCHITECTURAL INVARIANTS
    // =======================================================
    
    // INVARIANT: reg_x0 must ALWAYS be zero
    property p_x0_zero;
        reg_x0 == 32'h00000000;
    endproperty
    assert_x0_hardwired: assert property (p_x0_zero) else $error("CRITICAL ARCH FAILED: x0 is not zero!");

endmodule