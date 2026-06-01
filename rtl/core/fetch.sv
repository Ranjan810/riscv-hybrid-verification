`timescale 1ns / 1ps
module fetch (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall,
    
    // Branch prediction feedback from EX stage
    input  logic        ex_branch,
    input  logic        ex_zero,          // 1 = Branch Taken, 0 = Not Taken
    input  logic [31:0] ex_pc,
    input  logic [31:0] ex_branch_addr,
    
    output logic [31:0] pc_out,
    output logic [31:0] pc_plus_4_out,
    output logic        flush_mispredict,   // Tell core to flush pipeline
    output logic        predict_taken_out
);

    logic [31:0] pc_reg;
    logic [31:0] next_pc;
    
    // 16-entry Branch Target Buffer (BTB) & 1-bit predictor
    logic        btb_valid  [15:0];
    logic [31:0] btb_target [15:0];
    
    logic [3:0] fetch_idx;
    logic [3:0] ex_idx;
    logic       predict_taken;
    logic       actual_taken;
    
    // Map PC to table index
    assign fetch_idx = pc_reg[5:2];
    assign ex_idx    = ex_pc[5:2];
    
    // Check prediction status
    assign predict_taken = btb_valid[fetch_idx];
    assign actual_taken  = ex_branch & ex_zero;
    
    // Misprediction occurs if:
    // 1. It IS a branch, and actual outcome doesn't match prediction
    // 2. It is NOT a branch, but the BTB hallucinated a jump (BTB Aliasing)
    assign flush_mispredict = (actual_taken != btb_valid[ex_idx]);

    always_comb begin
        if (flush_mispredict) begin
            // Correction: if it was actually taken, go to target. If not taken, go to PC+4.
            next_pc = actual_taken ? ex_branch_addr : (ex_pc + 4);
        end else if (predict_taken && !stall) begin
            // We predict the branch will be taken, fetch from the BTB target!
            next_pc = btb_target[fetch_idx];
        end else if (!stall) begin
            // Normal fetch sequence
            next_pc = pc_reg + 4;
        end else begin
            // Pipeline stalled
            next_pc = pc_reg;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 32'b0;
            for (int i=0; i<16; i++) begin
                btb_valid[i]  <= 1'b0;
                btb_target[i] <= 32'b0;
            end
        end else begin
            pc_reg <= next_pc;
            
            // Update BTB in real-time when a branch is evaluated in EX
            if (ex_branch) begin
                btb_valid[ex_idx] <= actual_taken;
                if (actual_taken) begin
                    btb_target[ex_idx] <= ex_branch_addr;
                end
            end else if (btb_valid[ex_idx]) begin
                // It wasn't a branch, but BTB had a valid entry here (Aliasing). Clear it!
                btb_valid[ex_idx] <= 1'b0;
            end
        end
    end
   /* 
    always @(posedge clk) begin
        if (rst_n) begin
            if (ex_branch) begin
                $display(
                    "[BRANCH_UPDATE] PC=%h EX_IDX=%0d ZERO=%0b ACTUAL=%0b TARGET=%h",
                    ex_pc,
                    ex_idx,
                    ex_zero,
                    actual_taken,
                    ex_branch_addr
                );
            end
        end
    end
    */
    assign pc_out = pc_reg;
    assign pc_plus_4_out = pc_reg + 4;
    assign predict_taken_out = predict_taken;
endmodule