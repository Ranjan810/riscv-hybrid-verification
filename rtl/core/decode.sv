module decode (
    input  logic [31:0] instr,
    
    output logic [4:0]  rs1_addr,
    output logic [4:0]  rs2_addr,
    output logic [4:0]  rd_addr,
    output logic [31:0] imm,
    
    output logic        reg_write,
    output logic        mem_write,
    output logic        mem_read,
    output logic        branch,
    output logic        alu_src,
    output logic [1:0]  result_src,
    output logic [3:0]  alu_ctrl
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode   = instr[6:0];
    assign rd_addr  = instr[11:7];
    assign funct3   = instr[14:12];
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign funct7   = instr[31:25];

    always_comb begin
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        branch     = 1'b0;
        alu_src    = 1'b0;
        result_src = 2'b00;
        alu_ctrl   = 4'b0000;
        imm        = 32'b0;

        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1'b1;
                if (funct3 == 3'b000 && funct7 == 7'b0100000) begin
                    alu_ctrl = 4'b0001; // SUB
                end else if (funct3 == 3'b111) begin
                    alu_ctrl = 4'b0010; // AND
                end else if (funct3 == 3'b110) begin
                    alu_ctrl = 4'b0011; // OR
                end else begin
                    alu_ctrl = 4'b0000; // ADD
                end
            end
            
            7'b0010011: begin // I-type
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm       = {{20{instr[31]}}, instr[31:20]};
                if (funct3 == 3'b111) begin
                    alu_ctrl = 4'b0010; // ANDI
                end else if (funct3 == 3'b110) begin
                    alu_ctrl = 4'b0011; // ORI
                end else begin
                    alu_ctrl = 4'b0000; // ADDI
                end
            end
            
            7'b0000011: begin // Load
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                result_src = 2'b01;
                imm        = {{20{instr[31]}}, instr[31:20]};
                alu_ctrl   = 4'b0000; 
            end
            
            7'b0100011: begin // Store
                mem_write = 1'b1;
                alu_src   = 1'b1;
                imm       = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                alu_ctrl  = 4'b0000; 
            end
            
            7'b1100011: begin // Branch
                branch   = 1'b1;
                imm      = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
                alu_ctrl = 4'b0001; // SUB to compare
            end
            
            default: ; 
        endcase
    end

endmodule