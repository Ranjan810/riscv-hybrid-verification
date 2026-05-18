module hazard_sva (
    input logic clk,
    input logic rst_n,
    
    // Core Signals
    input logic stall,
    input logic flush_mispredict,
    input logic [1:0] forward_a,
    input logic [1:0] forward_b,
    
    // Hazard classification flags (from core.sv)
    input logic hazard_h1_ex_ex,
    input logic hazard_h2_mem_ex,
    input logic hazard_h3_load_use,
    input logic hazard_h4_branch_flush,
    input logic hazard_h5_mispredict
);

    // Ensure assertions only run when out of reset
    default clocking cb @(posedge clk); endclocking
    // Removed unsupported default disable iff here.

    // --- 1. Forwarding Assertions (H1 & H2) ---
    
    // If an EX-EX RAW hazard is flagged (H1), either forward_a or forward_b MUST be 2'b10 (MEM stage bypass)
    property p_forward_h1;
        disable iff (!rst_n)
        hazard_h1_ex_ex |-> (forward_a == 2'b10) || (forward_b == 2'b10);
    endproperty
    assert_h1: assert property (p_forward_h1) else $error("SVA FAILED: H1 (EX-EX) hazard missed by forwarding unit!");

    // If a MEM-EX RAW hazard is flagged (H2), either forward_a or forward_b MUST be 2'b01 (WB stage bypass)
    property p_forward_h2;
        disable iff (!rst_n)
        hazard_h2_mem_ex |-> (forward_a == 2'b01) || (forward_b == 2'b01);
    endproperty
    assert_h2: assert property (p_forward_h2) else $error("SVA FAILED: H2 (MEM-EX) hazard missed by forwarding unit!");

    // --- 2. Stall Assertions (H3) ---
    
    // If a Load-Use hazard is flagged (H3), the stall signal MUST go high.
    property p_stall_h3;
        disable iff (!rst_n)
        hazard_h3_load_use |-> stall;
    endproperty
    assert_h3: assert property (p_stall_h3) else $error("SVA FAILED: Load-Use hazard did not trigger stall!");

    // --- 3. Flush Assertions (H5) ---
    
    // If a misprediction is flagged (H5), the flush signal MUST go high.
    property p_flush_h5;
        disable iff (!rst_n)
        hazard_h5_mispredict |-> flush_mispredict;
    endproperty
    assert_h5: assert property (p_flush_h5) else $error("SVA FAILED: Misprediction did not trigger pipeline flush!");

endmodule