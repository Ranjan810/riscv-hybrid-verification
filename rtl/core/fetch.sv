module fetch (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall,
    input  logic        pc_src,
    input  logic [31:0] branch_addr,
    
    output logic [31:0] pc_out,
    output logic [31:0] pc_plus_4_out
);

    logic [31:0] pc_reg;

    assign pc_plus_4_out = pc_reg + 32'd4;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 32'b0;
        end else if (!stall) begin
            if (pc_src) begin
                pc_reg <= branch_addr;
            end else begin
                pc_reg <= pc_plus_4_out;
            end
        end
    end

    assign pc_out = pc_reg;

endmodule