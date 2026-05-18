module core (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_in, 
    output logic [31:0] instr_addr
);

    logic        if_valid, id_valid, ex_valid, mem_valid, wb_valid;
    logic [31:0] if_pc, if_pc_plus_4;
    logic        stall, flush_mispredict;

    logic [31:0] id_pc, id_pc_plus_4, id_instr;
    logic [4:0]  id_rs1_addr, id_rs2_addr, id_rd_addr;
    logic [31:0] id_imm, id_rs1_data, id_rs2_data;
    logic        id_reg_write, id_mem_write, id_mem_read, id_branch, id_alu_src;
    logic [1:0]  id_result_src;
    logic [3:0]  id_alu_ctrl;

    logic [31:0] ex_pc, ex_pc_plus_4, ex_rs1_data, ex_rs2_data, ex_imm;
    logic [4:0]  ex_rs1_addr, ex_rs2_addr, ex_rd_addr;
    logic        ex_reg_write, ex_mem_write, ex_mem_read, ex_branch, ex_alu_src;
    logic [1:0]  ex_result_src;
    logic [3:0]  ex_alu_ctrl;
    logic [31:0] ex_alu_result, ex_mem_write_data, ex_branch_addr;
    logic        ex_zero;

    logic [31:0] mem_pc_plus_4, mem_alu_result, mem_write_data, mem_read_data;
    logic [4:0]  mem_rd_addr;
    logic        mem_reg_write, mem_mem_write, mem_mem_read;
    logic [1:0]  mem_result_src;

    logic [31:0] wb_pc_plus_4, wb_alu_result, wb_read_data, wb_result;
    logic [4:0]  wb_rd_addr;
    logic        wb_reg_write;
    logic [1:0]  wb_result_src;

    logic [1:0]  forward_a, forward_b;
    logic        flush_if_id, flush_id_ex;

    assign instr_addr  = if_pc;
    assign if_valid    = 1'b1; // Fetch stage is always valid unless flushed in the pipe register
    
    assign flush_if_id = flush_mispredict;
    assign flush_id_ex = flush_mispredict | stall;

    fetch u_fetch (
        .clk(clk), .rst_n(rst_n), .stall(stall),
        .ex_branch(ex_branch), .ex_zero(ex_zero), 
        .ex_pc(ex_pc), .ex_branch_addr(ex_branch_addr),
        .pc_out(if_pc), .pc_plus_4_out(if_pc_plus_4),
        .flush_mispredict(flush_mispredict)
    );

    if_id_reg u_if_id (
        .clk(clk), .rst_n(rst_n), .stall(stall), .flush(flush_if_id),
        .if_valid(if_valid), .id_valid(id_valid), // Valid routing
        .if_pc(if_pc), .if_pc_plus_4(if_pc_plus_4), .if_instr(instr_in),
        .id_pc(id_pc), .id_pc_plus_4(id_pc_plus_4), .id_instr(id_instr)
    );

    decode u_decode (
        .instr(id_instr),
        .rs1_addr(id_rs1_addr), .rs2_addr(id_rs2_addr), .rd_addr(id_rd_addr), .imm(id_imm),
        .reg_write(id_reg_write), .mem_write(id_mem_write), .mem_read(id_mem_read),
        .branch(id_branch), .alu_src(id_alu_src), .result_src(id_result_src), .alu_ctrl(id_alu_ctrl)
    );

    regfile u_regfile (
        .clk(clk), .reg_write(wb_reg_write & wb_valid), // Guarded by valid bit
        .rs1_addr(id_rs1_addr), .rs2_addr(id_rs2_addr), .rd_addr(wb_rd_addr), .write_data(wb_result),
        .rs1_data(id_rs1_data), .rs2_data(id_rs2_data)
    );

    id_ex_reg u_id_ex (
        .clk(clk), .rst_n(rst_n), .flush(flush_id_ex),
        .id_valid(id_valid), .ex_valid(ex_valid), // Valid routing
        .id_pc(id_pc), .id_pc_plus_4(id_pc_plus_4), .id_rs1_data(id_rs1_data), .id_rs2_data(id_rs2_data),
        .id_imm(id_imm), .id_rs1_addr(id_rs1_addr), .id_rs2_addr(id_rs2_addr), .id_rd_addr(id_rd_addr),
        .id_reg_write(id_reg_write), .id_mem_write(id_mem_write), .id_mem_read(id_mem_read),
        .id_branch(id_branch), .id_alu_src(id_alu_src), .id_result_src(id_result_src), .id_alu_ctrl(id_alu_ctrl),
        .ex_pc(ex_pc), .ex_pc_plus_4(ex_pc_plus_4), .ex_rs1_data(ex_rs1_data), .ex_rs2_data(ex_rs2_data),
        .ex_imm(ex_imm), .ex_rs1_addr(ex_rs1_addr), .ex_rs2_addr(ex_rs2_addr), .ex_rd_addr(ex_rd_addr),
        .ex_reg_write(ex_reg_write), .ex_mem_write(ex_mem_write), .ex_mem_read(ex_mem_read),
        .ex_branch(ex_branch), .ex_alu_src(ex_alu_src), .ex_result_src(ex_result_src), .ex_alu_ctrl(ex_alu_ctrl)
    );

    execute u_execute (
        .pc(ex_pc), .reg1_data(ex_rs1_data), .reg2_data(ex_rs2_data), .imm(ex_imm),
        .fwd_mem_data(mem_alu_result), .fwd_wb_data(wb_result),
        .forward_a(forward_a), .forward_b(forward_b), .alu_src(ex_alu_src), .alu_ctrl(ex_alu_ctrl),
        .alu_result(ex_alu_result), .mem_write_data(ex_mem_write_data), .branch_addr(ex_branch_addr), .zero(ex_zero)
    );

    ex_mem_reg u_ex_mem (
        .clk(clk), .rst_n(rst_n),
        .ex_valid(ex_valid), .mem_valid(mem_valid), // Valid routing
        .ex_pc_plus_4(ex_pc_plus_4), .ex_alu_result(ex_alu_result), .ex_mem_write_data(ex_mem_write_data), .ex_rd_addr(ex_rd_addr),
        .ex_reg_write(ex_reg_write), .ex_mem_write(ex_mem_write), .ex_mem_read(ex_mem_read), .ex_result_src(ex_result_src),
        .mem_pc_plus_4(mem_pc_plus_4), .mem_alu_result(mem_alu_result), .mem_write_data(mem_write_data), .mem_rd_addr(mem_rd_addr),
        .mem_reg_write(mem_reg_write), .mem_mem_write(mem_mem_write), .mem_mem_read(mem_mem_read), .mem_result_src(mem_result_src)
    );

    memory u_memory (
        .clk(clk), .mem_write(mem_mem_write & mem_valid), // Guarded by valid bit
        .mem_read(mem_mem_read),
        .alu_result(mem_alu_result), .write_data(mem_write_data),
        .read_data(mem_read_data)
    );

    mem_wb_reg u_mem_wb (
        .clk(clk), .rst_n(rst_n),
        .mem_valid(mem_valid), .wb_valid(wb_valid), // Valid routing
        .mem_pc_plus_4(mem_pc_plus_4), .mem_alu_result(mem_alu_result), .mem_read_data(mem_read_data), .mem_rd_addr(mem_rd_addr),
        .mem_reg_write(mem_reg_write), .mem_result_src(mem_result_src),
        .wb_pc_plus_4(wb_pc_plus_4), .wb_alu_result(wb_alu_result), .wb_read_data(wb_read_data), .wb_rd_addr(wb_rd_addr),
        .wb_reg_write(wb_reg_write), .wb_result_src(wb_result_src)
    );

    writeback u_writeback (
        .alu_result(wb_alu_result), .read_data(wb_read_data), .pc_plus_4(wb_pc_plus_4), .result_src(wb_result_src),
        .result(wb_result)
    );

    forwarding_unit u_forwarding (
        .rs1_addr_ex(ex_rs1_addr), .rs2_addr_ex(ex_rs2_addr),
        .rd_addr_mem(mem_rd_addr), .reg_write_mem(mem_reg_write),
        .rd_addr_wb(wb_rd_addr), .reg_write_wb(wb_reg_write),
        .forward_a(forward_a), .forward_b(forward_b)
    );

    stall_unit u_stall (
        .rs1_addr_id(id_rs1_addr), .rs2_addr_id(id_rs2_addr),
        .rd_addr_ex(ex_rd_addr), .mem_read_ex(ex_mem_read),
        .stall(stall)
    );

    // --- Performance Counters ---
    logic [31:0] cycle_count;
    logic [31:0] instr_retired;
    logic [31:0] stall_count;
    logic [31:0] branch_flush_count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_count        <= 32'b0;
            instr_retired      <= 32'b0;
            stall_count        <= 32'b0;
            branch_flush_count <= 32'b0;
        end else begin
            cycle_count <= cycle_count + 1;
            
            if (stall) stall_count <= stall_count + 1;
            if (flush_mispredict) branch_flush_count <= branch_flush_count + 1;
            
            // Replaced pc_plus_4 hack with proper valid bit logic
            if (wb_valid) begin
                instr_retired <= instr_retired + 1;
            end
        end
    end

    // --- Formal Hazard Classification Layer ---
    // These signals serve as explicit hooks for the SVA and Coverage environment.
    logic hazard_h1_ex_ex;
    logic hazard_h2_mem_ex;
    logic hazard_h3_load_use;
    logic hazard_h4_branch_flush;
    logic hazard_h5_mispredict;

    // H1: EX-EX RAW (Data comes from MEM stage forwarding to EX)
    assign hazard_h1_ex_ex = (forward_a == 2'b10) | (forward_b == 2'b10);
    
    // H2: MEM-EX RAW (Data comes from WB stage forwarding to EX)
    assign hazard_h2_mem_ex = (forward_a == 2'b01) | (forward_b == 2'b01);
    
    // H3: Load-Use Hazard
    assign hazard_h3_load_use = stall;
    
    // H4: Branch Instruction Detected
    assign hazard_h4_branch_flush = ex_branch & ex_valid;
    
    // H5: Misprediction Recovery (Actual Pipeline Flush)
    assign hazard_h5_mispredict = flush_mispredict;

endmodule