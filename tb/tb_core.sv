module tb_core (
    input logic clk,
    input logic rst_n
);

    logic [31:0] instr_addr;
    logic [31:0] instr_in;

    // Simulated 4KB Instruction Memory
    logic [31:0] imem [0:1023];

    // Load the compiled machine code into memory before starting
    initial begin
        $readmemh("tests/test.hex", imem);
    end

    // Word-aligned instruction fetch
    assign instr_in = imem[instr_addr[11:2]];

    // Instantiate your 5-stage core
    core u_core (
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_in),
        .instr_addr(instr_addr)
    );

    bind core hazard_sva u_hazard_sva (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .flush_mispredict(flush_mispredict),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .hazard_h1_ex_ex(hazard_h1_ex_ex),
        .hazard_h2_mem_ex(hazard_h2_mem_ex),
        .hazard_h3_load_use(hazard_h3_load_use),
        .hazard_h4_branch_flush(hazard_h4_branch_flush),
        .hazard_h5_mispredict(hazard_h5_mispredict)
    );

    
    bind core hazard_sva u_hazard_sva (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .flush_mispredict(flush_mispredict),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .if_pc(id_pc),           // NEW: Pass the PC state
        .id_instr(id_instr),     // NEW: Pass the Decode state
        .hazard_h1_ex_ex(hazard_h1_ex_ex),
        .hazard_h2_mem_ex(hazard_h2_mem_ex),
        .hazard_h3_load_use(hazard_h3_load_use),
        .hazard_h4_branch_flush(hazard_h4_branch_flush),
        .hazard_h5_mispredict(hazard_h5_mispredict)
    );
endmodule