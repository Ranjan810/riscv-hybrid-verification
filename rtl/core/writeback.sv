module writeback (
    input  logic [31:0] alu_result,
    input  logic [31:0] read_data,
    input  logic [31:0] pc_plus_4,
    input  logic [1:0]  result_src,
    
    output logic [31:0] result
);

    always_comb begin
        case (result_src)
            2'b00: result = alu_result;
            2'b01: result = read_data;
            2'b10: result = pc_plus_4;
            default: result = alu_result;
        endcase
    end

endmodule