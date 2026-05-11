// IF/ID Pipeline Register
module if_id_reg (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall,
    input  logic        flush,
    input  logic [31:0] if_pc,
    input  logic [31:0] if_pc_plus_4,
    input  logic [31:0] if_instr,
    
    output logic [31:0] id_pc,
    output logic [31:0] id_pc_plus_4,
    output logic [31:0] id_instr
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_pc        <= 32'b0;
            id_pc_plus_4 <= 32'b0;
            id_instr     <= 32'b0;
        end else if (flush) begin
            id_pc        <= 32'b0;
            id_pc_plus_4 <= 32'b0;
            id_instr     <= 32'b0;
        end else if (!stall) begin
            id_pc        <= if_pc;
            id_pc_plus_4 <= if_pc_plus_4;
            id_instr     <= if_instr;
        end
    end
endmodule

// ID/EX Pipeline Register
module id_ex_reg (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flush,
    
    input  logic [31:0] id_pc,
    input  logic [31:0] id_pc_plus_4,
    input  logic [31:0] id_rs1_data,
    input  logic [31:0] id_rs2_data,
    input  logic [31:0] id_imm,
    input  logic [4:0]  id_rs1_addr,
    input  logic [4:0]  id_rs2_addr,
    input  logic [4:0]  id_rd_addr,
    
    input  logic        id_reg_write,
    input  logic        id_mem_write,
    input  logic        id_mem_read,
    input  logic        id_branch,
    input  logic        id_alu_src,
    input  logic [1:0]  id_result_src,
    input  logic [3:0]  id_alu_ctrl,

    output logic [31:0] ex_pc,
    output logic [31:0] ex_pc_plus_4,
    output logic [31:0] ex_rs1_data,
    output logic [31:0] ex_rs2_data,
    output logic [31:0] ex_imm,
    output logic [4:0]  ex_rs1_addr,
    output logic [4:0]  ex_rs2_addr,
    output logic [4:0]  ex_rd_addr,
    
    output logic        ex_reg_write,
    output logic        ex_mem_write,
    output logic        ex_mem_read,
    output logic        ex_branch,
    output logic        ex_alu_src,
    output logic [1:0]  ex_result_src,
    output logic [3:0]  ex_alu_ctrl
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_pc         <= 32'b0;
            ex_pc_plus_4  <= 32'b0;
            ex_rs1_data   <= 32'b0;
            ex_rs2_data   <= 32'b0;
            ex_imm        <= 32'b0;
            ex_rs1_addr   <= 5'b0;
            ex_rs2_addr   <= 5'b0;
            ex_rd_addr    <= 5'b0;
            ex_reg_write  <= 1'b0;
            ex_mem_write  <= 1'b0;
            ex_mem_read   <= 1'b0;
            ex_branch     <= 1'b0;
            ex_alu_src    <= 1'b0;
            ex_result_src <= 2'b0;
            ex_alu_ctrl   <= 4'b0;
        end else if (flush) begin
            ex_pc         <= 32'b0;
            ex_pc_plus_4  <= 32'b0;
            ex_rs1_data   <= 32'b0;
            ex_rs2_data   <= 32'b0;
            ex_imm        <= 32'b0;
            ex_rs1_addr   <= 5'b0;
            ex_rs2_addr   <= 5'b0;
            ex_rd_addr    <= 5'b0;
            ex_reg_write  <= 1'b0;
            ex_mem_write  <= 1'b0;
            ex_mem_read   <= 1'b0;
            ex_branch     <= 1'b0;
            ex_alu_src    <= 1'b0;
            ex_result_src <= 2'b0;
            ex_alu_ctrl   <= 4'b0;
        end else begin
            ex_pc         <= id_pc;
            ex_pc_plus_4  <= id_pc_plus_4;
            ex_rs1_data   <= id_rs1_data;
            ex_rs2_data   <= id_rs2_data;
            ex_imm        <= id_imm;
            ex_rs1_addr   <= id_rs1_addr;
            ex_rs2_addr   <= id_rs2_addr;
            ex_rd_addr    <= id_rd_addr;
            ex_reg_write  <= id_reg_write;
            ex_mem_write  <= id_mem_write;
            ex_mem_read   <= id_mem_read;
            ex_branch     <= id_branch;
            ex_alu_src    <= id_alu_src;
            ex_result_src <= id_result_src;
            ex_alu_ctrl   <= id_alu_ctrl;
        end
    end
endmodule

// EX/MEM Pipeline Register
module ex_mem_reg (
    input  logic        clk,
    input  logic        rst_n,
    
    input  logic [31:0] ex_pc_plus_4,
    input  logic [31:0] ex_alu_result,
    input  logic [31:0] ex_mem_write_data,
    input  logic [4:0]  ex_rd_addr,
    
    input  logic        ex_reg_write,
    input  logic        ex_mem_write,
    input  logic        ex_mem_read,
    input  logic [1:0]  ex_result_src,

    output logic [31:0] mem_pc_plus_4,
    output logic [31:0] mem_alu_result,
    output logic [31:0] mem_write_data,
    output logic [4:0]  mem_rd_addr,
    
    output logic        mem_reg_write,
    output logic        mem_mem_write,
    output logic        mem_mem_read,
    output logic [1:0]  mem_result_src
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_pc_plus_4  <= 32'b0;
            mem_alu_result <= 32'b0;
            mem_write_data <= 32'b0;
            mem_rd_addr    <= 5'b0;
            mem_reg_write  <= 1'b0;
            mem_mem_write  <= 1'b0;
            mem_mem_read   <= 1'b0;
            mem_result_src <= 2'b0;
        end else begin
            mem_pc_plus_4  <= ex_pc_plus_4;
            mem_alu_result <= ex_alu_result;
            mem_write_data <= ex_mem_write_data;
            mem_rd_addr    <= ex_rd_addr;
            mem_reg_write  <= ex_reg_write;
            mem_mem_write  <= ex_mem_write;
            mem_mem_read   <= ex_mem_read;
            mem_result_src <= ex_result_src;
        end
    end
endmodule

// MEM/WB Pipeline Register
module mem_wb_reg (
    input  logic        clk,
    input  logic        rst_n,
    
    input  logic [31:0] mem_pc_plus_4,
    input  logic [31:0] mem_alu_result,
    input  logic [31:0] mem_read_data,
    input  logic [4:0]  mem_rd_addr,
    
    input  logic        mem_reg_write,
    input  logic [1:0]  mem_result_src,

    output logic [31:0] wb_pc_plus_4,
    output logic [31:0] wb_alu_result,
    output logic [31:0] wb_read_data,
    output logic [4:0]  wb_rd_addr,
    
    output logic        wb_reg_write,
    output logic [1:0]  wb_result_src
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_pc_plus_4  <= 32'b0;
            wb_alu_result <= 32'b0;
            wb_read_data  <= 32'b0;
            wb_rd_addr    <= 5'b0;
            wb_reg_write  <= 1'b0;
            wb_result_src <= 2'b0;
        end else begin
            wb_pc_plus_4  <= mem_pc_plus_4;
            wb_alu_result <= mem_alu_result;
            wb_read_data  <= mem_read_data;
            wb_rd_addr    <= mem_rd_addr;
            wb_reg_write  <= mem_reg_write;
            wb_result_src <= mem_result_src;
        end
    end
endmodule