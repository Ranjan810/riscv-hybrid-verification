`timescale 1ns / 1ps
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
            7'b0110011: begin // R-type (Arith/Logical/Shift)
                reg_write = 1'b1;
                if (funct7 == 7'b0100000 && funct3 == 3'b000) alu_ctrl = 4'b0001; // SUB
                else if (funct3 == 3'b000) alu_ctrl = 4'b0000; // ADD
                else if (funct3 == 3'b100) alu_ctrl = 4'b0100; // XOR
                else if (funct3 == 3'b010) alu_ctrl = 4'b0101; // SLT
                else if (funct3 == 3'b001) alu_ctrl = 4'b0110; // SLL
                else if (funct3 == 3'b101) alu_ctrl = 4'b0111; // SRL
                else if (funct3 == 3'b111) alu_ctrl = 4'b0010; // AND
                else if (funct3 == 3'b110) alu_ctrl = 4'b0011; // OR
            end
            
            7'b0010011: begin // I-type (Arith/Logical/Shift)
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm       = {{20{instr[31]}}, instr[31:20]};
                if (funct3 == 3'b000) alu_ctrl = 4'b0000;      // ADDI
                else if (funct3 == 3'b100) alu_ctrl = 4'b0100; // XORI
                else if (funct3 == 3'b010) alu_ctrl = 4'b0101; // SLTI
                else if (funct3 == 3'b001) alu_ctrl = 4'b0110; // SLLI
                else if (funct3 == 3'b101) alu_ctrl = 4'b0111; // SRLI
                else if (funct3 == 3'b111) alu_ctrl = 4'b0010; // ANDI
                else if (funct3 == 3'b110) alu_ctrl = 4'b0011; // ORI
            end
            
            7'b1100011: begin
                branch = 1'b1;

                imm = {{19{instr[31]}},
                    instr[31],
                    instr[7],
                    instr[30:25],
                    instr[11:8],
                    1'b0};

                if (funct3 == 3'b000) alu_ctrl = 4'b1000;
                else if (funct3 == 3'b001) alu_ctrl = 4'b1001;
                else if (funct3 == 3'b100) alu_ctrl = 4'b1010;
            end

            7'b1101111: begin // JAL (J-type)
                reg_write  = 1'b1;
                branch     = 1'b1;
                result_src = 2'b10; // Save PC+4 to rd
                imm        = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
                alu_ctrl   = 4'b1011; // Unconditional Jump
            end

            7'b1100111: begin // JALR (I-type)
                reg_write  = 1'b1;
                branch     = 1'b1;
                result_src = 2'b10; // Save PC+4 to rd
                imm        = {{20{instr[31]}}, instr[31:20]};
                alu_ctrl   = 4'b1100; // Jump Register (Base + Offset)
            end
            
            7'b0000011: begin // Load
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                result_src = 2'b01;
                imm        = {{20{instr[31]}}, instr[31:20]};
                alu_ctrl   = 4'b0000; // ADD for address calc
            end
            
            7'b0100011: begin // Store
                mem_write = 1'b1;
                alu_src   = 1'b1;
                imm       = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                alu_ctrl  = 4'b0000; // ADD for address calc
            end
            
            default: ; 
        endcase
    end

endmodule