module stall_unit (
    input  logic [4:0] rs1_addr_id,
    input  logic [4:0] rs2_addr_id,
    input  logic [4:0] rd_addr_ex,
    input  logic       mem_read_ex,

    output logic       stall
);

    always_comb begin
        if (mem_read_ex && (rd_addr_ex != 5'b0) && 
           ((rd_addr_ex == rs1_addr_id) || (rd_addr_ex == rs2_addr_id))) begin
            stall = 1'b1;
        end else begin
            stall = 1'b0;
        end
    end

endmodule