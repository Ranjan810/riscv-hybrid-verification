module memory (
    input  logic        clk,
    input  logic        mem_write,
    input  logic        mem_read,
    input  logic [31:0] alu_result,
    input  logic [31:0] write_data,
    
    output logic [31:0] read_data
);

    // 1024 x 32-bit Data Memory (4KB)
    logic [31:0] dmem [0:1023];

    always_ff @(posedge clk) begin
        if (mem_write) begin
            // Word-aligned write (ignoring bottom 2 bits of address)
            dmem[alu_result[11:2]] <= write_data;
        end
    end

    // Asynchronous read
    assign read_data = mem_read ? dmem[alu_result[11:2]] : 32'b0;

endmodule