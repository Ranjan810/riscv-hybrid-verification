module core (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_in, 
    output logic [31:0] instr_addr
);

    logic [31:0] if_pc, if_pc_plus_4;
    logic        stall, pc_src;

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
    assign pc_src      = ex_branch & ex_zero;
    assign flush_if_id = pc_src;
    assign flush_id_ex = pc_src | stall;

    fetch u_fetch (
        .clk(clk), .rst_n(rst_n), .stall(stall), .pc_src(pc_src), .branch_addr(ex_branch_addr),
        .pc_out(if_pc), .pc_plus_4_out(if_pc_plus_4)
    );

    if_id_reg u_if_id (
        .clk(clk), .rst_n(rst_n), .stall(stall), .flush(flush_if_id),
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
        .clk(clk), .reg_write(wb_reg_write),
        .rs1_addr(id_rs1_addr), .rs2_addr(id_rs2_addr), .rd_addr(wb_rd_addr), .write_data(wb_result),
        .rs1_data(id_rs1_data), .rs2_data(id_rs2_data)
    );

    id_ex_reg u_id_ex (
        .clk(clk), .rst_n(rst_n), .flush(flush_id_ex),
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
        .ex_pc_plus_4(ex_pc_plus_4), .ex_alu_result(ex_alu_result), .ex_mem_write_data(ex_mem_write_data), .ex_rd_addr(ex_rd_addr),
        .ex_reg_write(ex_reg_write), .ex_mem_write(ex_mem_write), .ex_mem_read(ex_mem_read), .ex_result_src(ex_result_src),
        .mem_pc_plus_4(mem_pc_plus_4), .mem_alu_result(mem_alu_result), .mem_write_data(mem_write_data), .mem_rd_addr(mem_rd_addr),
        .mem_reg_write(mem_reg_write), .mem_mem_write(mem_mem_write), .mem_mem_read(mem_mem_read), .mem_result_src(mem_result_src)
    );

    memory u_memory (
        .clk(clk), .mem_write(mem_mem_write), .mem_read(mem_mem_read),
        .alu_result(mem_alu_result), .write_data(mem_write_data),
        .read_data(mem_read_data)
    );

    mem_wb_reg u_mem_wb (
        .clk(clk), .rst_n(rst_n),
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

endmodule