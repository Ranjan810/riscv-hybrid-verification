`timescale 1ns / 1ps
module execute (
    input  logic [31:0] pc,
    input  logic [31:0] reg1_data,
    input  logic [31:0] reg2_data,
    input  logic [31:0] imm,
    input  logic [31:0] fwd_mem_data,
    input  logic [31:0] fwd_wb_data,
    input  logic [1:0]  forward_a,
    input  logic [1:0]  forward_b,
    input  logic        alu_src,
    input  logic [3:0]  alu_ctrl,

    output logic [31:0] alu_result,
    output logic [31:0] mem_write_data,
    output logic [31:0] branch_addr,
    output logic        zero
);

    logic [31:0] src_a;
    logic [31:0] src_b_reg;
    logic [31:0] src_b;

    // --- Forwarding Multiplexers ---
    always_comb begin
        case (forward_a)
            2'b00: src_a = reg1_data;
            2'b01: src_a = fwd_wb_data;
            2'b10: src_a = fwd_mem_data;
            default: src_a = reg1_data;
        endcase
    end

    always_comb begin
        case (forward_b)
            2'b00: src_b_reg = reg2_data;
            2'b01: src_b_reg = fwd_wb_data;
            2'b10: src_b_reg = fwd_mem_data;
            default: src_b_reg = reg2_data;
        endcase
    end

    assign src_b = alu_src ? imm : src_b_reg;
    assign mem_write_data = src_b_reg; 

    // --- Branch Target Calculation ---
    // JALR (1100) uses register source A. All other branches/JAL use PC.
    assign branch_addr = (alu_ctrl == 4'b1100) ? ((src_a + imm) & 32'hFFFFFFFE) : (pc + imm);

    // --- ALU Math & Branch Condition Evaluation ---
    always_comb begin
        alu_result = 32'b0;
        zero       = 1'b0; // Overloaded to mean "take_branch"

        case (alu_ctrl)
            // Arithmetic & Logical
            4'b0000: alu_result = src_a + src_b;                       // ADD / ADDI
            4'b0001: alu_result = src_a - src_b;                       // SUB
            4'b0010: alu_result = src_a & src_b;                       // AND / ANDI
            4'b0011: alu_result = src_a | src_b;                       // OR / ORI
            4'b0100: alu_result = src_a ^ src_b;                       // XOR / XORI
            4'b0101: alu_result = $signed(src_a) < $signed(src_b) ? 32'd1 : 32'd0; // SLT / SLTI
            4'b0110: alu_result = src_a << src_b[4:0];                 // SLL / SLLI
            4'b0111: alu_result = src_a >> src_b[4:0];                 // SRL / SRLI
            
            // Control Flow (Branch / Jump Evaluation)
            4'b1000: zero = (src_a == src_b);                          // BEQ
            4'b1001: zero = (src_a != src_b);                          // BNE
            4'b1010: zero = ($signed(src_a) < $signed(src_b));         // BLT
            4'b1011: zero = 1'b1;                                      // JAL (Always jump)
            4'b1100: zero = 1'b1;                                      // JALR (Always jump)
            
            default: alu_result = 32'b0;
        endcase

        // For standard arithmetic, set the zero flag normally
        if (alu_ctrl < 4'b1000) begin
            zero = (alu_result == 32'b0);
        end
    end

endmodule