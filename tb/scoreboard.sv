module scoreboard (
    input logic clk,
    input logic rst_n,
    
    // Snoop ID Stage (To see what enters)
    input logic [31:0] dut_id_pc,
    input logic [31:0] dut_id_instr,
    
    // Snoop Control (To stay in sync)
    input logic dut_stall,
    input logic dut_flush_mispredict,
    
    // Snoop WB Stage (To check the math)
    input logic        dut_wb_valid,
    input logic        dut_wb_reg_write,
    input logic [4:0]  dut_wb_rd,
    input logic [31:0] dut_wb_data
);

    // ==========================================
    // 1. SHADOW PIPELINE TRACKER
    // ==========================================
    logic [31:0] ex_instr, mem_instr, wb_instr;
    logic [31:0] ex_pc, mem_pc, wb_pc;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_instr <= 32'h00000013; mem_instr <= 32'h00000013; wb_instr <= 32'h00000013; // NOPs
            ex_pc <= 0; mem_pc <= 0; wb_pc <= 0;
        end else begin
            // ID -> EX (Accounts for stalls and flushes)
            if (dut_flush_mispredict || dut_stall) begin
                ex_instr <= 32'h00000013; 
                ex_pc    <= 32'h0;
            end else begin
                ex_instr <= dut_id_instr;
                ex_pc    <= dut_id_pc;
            end

            // EX -> MEM -> WB
            mem_instr <= ex_instr;
            mem_pc    <= ex_pc;
            wb_instr  <= mem_instr;
            wb_pc     <= mem_pc;
        end
    end

    // ==========================================
    // 2. GOLDEN REFERENCE STATE
    // ==========================================
    logic [31:0] golden_reg [0:31];
    logic [31:0] golden_mem [int]; // Associative array maps any random memory address safely

    initial begin
        for (int i=0; i<32; i++) golden_reg[i] = 32'h0;
        // Matches the Python initialization
        golden_reg[1] = 10; golden_reg[2] = 20; golden_reg[3] = 30;
        golden_reg[4] = 40; golden_reg[5] = 50;
    end

    // ==========================================
    // 3. SCOREBOARD EXECUTION & COMPARISON
    // ==========================================
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [4:0]  rd, rs1, rs2;
    logic [31:0] imm_i, imm_s;
    logic [31:0] expected_data, expected_addr;
    logic        expected_write;

    always_ff @(posedge clk) begin
        if (rst_n && dut_wb_valid) begin
            opcode = wb_instr[6:0];
            funct3 = wb_instr[14:12];
            funct7 = wb_instr[31:25];
            rd     = wb_instr[11:7];
            rs1    = wb_instr[19:15];
            rs2    = wb_instr[24:20];
            
            imm_i  = {{20{wb_instr[31]}}, wb_instr[31:20]};
            imm_s  = {{20{wb_instr[31]}}, wb_instr[31:25], wb_instr[11:7]};
            
            expected_write = 1'b0;
            expected_data  = 32'h0;

            if (wb_instr != 32'h00000013 && wb_instr != 32'h0) begin
                case (opcode)
                    7'b0110011: begin // R-Type
                        expected_write = 1'b1;
                        case (funct3)
                            3'b000: expected_data = (funct7 == 7'b0100000) ? (golden_reg[rs1] - golden_reg[rs2]) : (golden_reg[rs1] + golden_reg[rs2]);
                            3'b111: expected_data = golden_reg[rs1] & golden_reg[rs2];
                            3'b110: expected_data = golden_reg[rs1] | golden_reg[rs2];
                            3'b100: expected_data = golden_reg[rs1] ^ golden_reg[rs2];
                            3'b010: expected_data = ($signed(golden_reg[rs1]) < $signed(golden_reg[rs2])) ? 1 : 0;
                            3'b011: expected_data = (golden_reg[rs1] < golden_reg[rs2]) ? 1 : 0;
                            3'b001: expected_data = golden_reg[rs1] << golden_reg[rs2][4:0];
                            3'b101: expected_data = (funct7 == 7'b0100000) ? ($signed(golden_reg[rs1]) >>> golden_reg[rs2][4:0]) : (golden_reg[rs1] >> golden_reg[rs2][4:0]);
                        endcase
                    end
                    7'b0010011: begin // I-Type
                        expected_write = 1'b1;
                        case (funct3)
                            3'b000: expected_data = golden_reg[rs1] + imm_i;
                            3'b111: expected_data = golden_reg[rs1] & imm_i;
                            3'b110: expected_data = golden_reg[rs1] | imm_i;
                            3'b100: expected_data = golden_reg[rs1] ^ imm_i;
                            3'b010: expected_data = ($signed(golden_reg[rs1]) < $signed(imm_i)) ? 1 : 0;
                            3'b011: expected_data = (golden_reg[rs1] < imm_i) ? 1 : 0;
                            3'b001: expected_data = golden_reg[rs1] << imm_i[4:0];
                            3'b101: expected_data = (funct7 == 7'b0100000) ? ($signed(golden_reg[rs1]) >>> imm_i[4:0]) : (golden_reg[rs1] >> imm_i[4:0]);
                        endcase
                    end
                    7'b0000011: begin // LW
                        expected_write = 1'b1;
                        expected_addr = golden_reg[rs1] + imm_i;
                        expected_data = golden_mem.exists(expected_addr) ? golden_mem[expected_addr] : 32'h0;
                    end
                    7'b0100011: begin // SW
                        expected_addr = golden_reg[rs1] + imm_s;
                        golden_mem[expected_addr] = golden_reg[rs2];
                    end
                    7'b1101111, 7'b1100111: begin // JAL, JALR
                        expected_write = 1'b1;
                        expected_data  = wb_pc + 4;
                    end
                endcase
            end

            // 4. THE COMPARISON
            if (expected_write && rd != 0) begin
                golden_reg[rd] = expected_data;
                if (!dut_wb_reg_write) 
                    $error("SCOREBOARD FAILED! PC: %h | DUT missed write to x%0d", wb_pc, rd);
                else if (dut_wb_data !== expected_data) 
                    $error("SCOREBOARD MISMATCH! PC: %h | Reg: x%0d | Expected: %h | DUT Got: %h", wb_pc, rd, expected_data, dut_wb_data);
                else
                    $display("MATCH: PC %h -> x%0d = %h", wb_pc, rd, expected_data);
            end else if (dut_wb_reg_write && dut_wb_rd != 0) begin
                $error("SCOREBOARD FAILED! PC: %h | DUT illegally wrote %h to x%0d", wb_pc, dut_wb_data, dut_wb_rd);
            end
        end
    end
endmodule