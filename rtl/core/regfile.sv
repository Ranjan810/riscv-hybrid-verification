`timescale 1ns / 1ps
module regfile (
    input  logic        clk,
    input  logic        reg_write,
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] write_data,
    
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    logic [31:0] registers [31:0] = '{default: 32'b0};

    // Synchronous write
    always_ff @(posedge clk) begin
        if (reg_write && rd_addr != 5'b0) begin
            registers[rd_addr] <= write_data;
        end
    end

    // Asynchronous read with internal forwarding (read-after-write hazard fix)
    always_comb begin
        if (rs1_addr == 5'b0) begin
            rs1_data = 32'b0;
        end else if (reg_write && (rs1_addr == rd_addr)) begin
            rs1_data = write_data;
        end else begin
            rs1_data = registers[rs1_addr];
        end
    end

    always_comb begin
        if (rs2_addr == 5'b0) begin
            rs2_data = 32'b0;
        end else if (reg_write && (rs2_addr == rd_addr)) begin
            rs2_data = write_data;
        end else begin
            rs2_data = registers[rs2_addr];
        end
    end

endmodule