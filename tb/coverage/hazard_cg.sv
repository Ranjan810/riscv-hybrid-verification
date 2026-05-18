module hazard_cg (
    input logic clk,
    input logic rst_n,
    
    input logic [1:0] forward_a,
    input logic [1:0] forward_b,
    input logic stall,
    input logic hazard_h1_ex_ex,
    input logic hazard_h2_mem_ex,
    input logic hazard_h3_load_use,
    input logic hazard_h4_branch_flush,
    input logic hazard_h5_mispredict
);

    

    // 1. Did we hit every type of hazard?
    cp_h1: cover property (@(posedge clk) disable iff (!rst_n) hazard_h1_ex_ex);
    cp_h2: cover property (@(posedge clk) disable iff (!rst_n) hazard_h2_mem_ex);
    cp_h3: cover property (@(posedge clk) disable iff (!rst_n) hazard_h3_load_use);
    cp_h4: cover property (@(posedge clk) disable iff (!rst_n) hazard_h4_branch_flush);
    cp_h5: cover property (@(posedge clk) disable iff (!rst_n) hazard_h5_mispredict);

    // 2. Did the forwarding multiplexers use all their paths?
    cp_fwd_a_wb:  cover property (@(posedge clk) disable iff (!rst_n) forward_a == 2'b01);
    cp_fwd_a_mem: cover property (@(posedge clk) disable iff (!rst_n) forward_a == 2'b10);
    cp_fwd_b_wb:  cover property (@(posedge clk) disable iff (!rst_n) forward_b == 2'b01);
    cp_fwd_b_mem: cover property (@(posedge clk) disable iff (!rst_n) forward_b == 2'b10);

    // 3. CROSS COVERAGE: Did we test overlapping scenarios?
    // Example: Did we ever have a stall happen at the exact same time as a MEM bypass?
    cross_stall_fwd_a_mem: cover property (@(posedge clk) disable iff (!rst_n) (hazard_h3_load_use && (forward_a == 2'b10)));
    cross_stall_fwd_b_mem: cover property (@(posedge clk) disable iff (!rst_n) (hazard_h3_load_use && (forward_b == 2'b10)));

endmodule