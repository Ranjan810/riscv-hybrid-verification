module forwarding_unit (
    input  logic [4:0] rs1_addr_ex,
    input  logic [4:0] rs2_addr_ex,
    input  logic [4:0] rd_addr_mem,
    input  logic       reg_write_mem,
    input  logic [4:0] rd_addr_wb,
    input  logic       reg_write_wb,

    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin
        if (reg_write_mem && (rd_addr_mem != 5'b0) && (rd_addr_mem == rs1_addr_ex)) begin
            forward_a = 2'b10;
        end else if (reg_write_wb && (rd_addr_wb != 5'b0) && (rd_addr_wb == rs1_addr_ex)) begin
            forward_a = 2'b01;
        end else begin
            forward_a = 2'b00;
        end
    end

    always_comb begin
        if (reg_write_mem && (rd_addr_mem != 5'b0) && (rd_addr_mem == rs2_addr_ex)) begin
            forward_b = 2'b10;
        end else if (reg_write_wb && (rd_addr_wb != 5'b0) && (rd_addr_wb == rs2_addr_ex)) begin
            forward_b = 2'b01;
        end else begin
            forward_b = 2'b00;
        end
    end

endmodule