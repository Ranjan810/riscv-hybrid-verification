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
    assign branch_addr = pc + imm;

    always_comb begin
        case (alu_ctrl)
            4'b0000: alu_result = src_a + src_b;
            4'b0001: alu_result = src_a - src_b;
            4'b0010: alu_result = src_a & src_b;
            4'b0011: alu_result = src_a | src_b;
            default: alu_result = 32'b0;
        endcase
    end

    assign zero = (alu_result == 32'b0);

endmodule