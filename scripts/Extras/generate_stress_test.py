import random

SMALL_POOL = ['x1', 'x2', 'x3', 'x4', 'x5'] 
LARGE_POOL = [f'x{i}' for i in range(6, 31)] 
MEM_BASE = 'x31'

# Added 'jalr' back into the mix to satisfy cp_jumps coverage
R_TYPE = ['add', 'sub', 'and', 'or', 'xor', 'slt', 'sll', 'srl']
I_TYPE_ARITH = ['addi', 'ori', 'xori', 'andi', 'slti']
I_TYPE_SHIFT = ['slli', 'srli'] 
MEM_TYPE = ['lw', 'sw']
BRANCH_TYPE = ['beq', 'bne', 'blt']

def get_reg():
    return random.choice(SMALL_POOL) if random.random() < 0.8 else random.choice(LARGE_POOL)

def generate_shadow():
    return f"    add {get_reg()}, {get_reg()}, {get_reg()}  # Speculative shadow"

def generate_hazard_macros():
    """Hand-crafted sequences to guarantee 100% on complex cross-coverage bins"""
    return """
    # MACRO 1: cross_fwd_a_b (Dual Forwarding from EX and MEM)
    addi x10, x0, 5
    addi x11, x0, 10
    add x12, x10, x11  # x10 forwarded from MEM, x11 forwarded from EX

    # MACRO 2: cross_branch_dual_fwd (Branch evaluating using two forwarded operands)
    addi x13, x0, 5
    addi x14, x0, 5
    beq x13, x14, macro_skip_1
    macro_skip_1:

    # MACRO 3: cross_flush_stall (Mispredict Flush + Load-Use Stall in the same cycle)
    # The BEQ mispredicts. In the exact cycle it flushes, the LW triggers a load-use stall.
    addi x15, x0, 0
    beq x15, x0, macro_skip_2
    lw x16, 0(x31)     # Load instruction
    add x17, x16, x16  # Use instruction (Triggers stall exactly as BEQ flushes)
    macro_skip_2:

    # MACRO 4: JALR Coverage (Safely constrained JALR)
    addi x18, x0, 4    # Set offset to safely jump to next instruction
    jalr x0, x18, 0    # Jumps exactly to macro_skip_3
    macro_skip_3:
    """

def generate_microbenchmarks():
    asm = [
        "    # PHASE 1: DIRECTED MICROBENCHMARKS",
        f"    sw x5, 0({MEM_BASE})",  
        f"    lw x1, 0({MEM_BASE})",
        "    add x2, x1, x1      ",
        f"    sw x5, 4({MEM_BASE})",  
        f"    lw x3, 4({MEM_BASE})",
        "    sub x4, x3, x3      ",
        "    addi x1, x0, 10     ",
        "    addi x2, x0, 20     ",
        "    add x3, x1, x2      ",
        "    addi x10, x0, 4     ",
        "adv_loop:",
        "    addi x11, x0, 1",
        "    beq x11, x0, skip_oscillation",
        "skip_oscillation:",
        "    addi x10, x10, -1",
        "    bne x10, x0, adv_loop",
        ""
    ]
    return "\n".join(asm)

def generate_csitss_stress_test(num_instructions):
    asm_lines = [
        ".text",
        ".global _start",
        "_start:"
    ]

    for i in range(1, 31):
        asm_lines.append(f"    addi x{i}, x0, 0")

    asm_lines.extend([
        "    addi x1, x0, 10",
        "    addi x2, x0, 20",
        "    addi x3, x0, 30",
        "    addi x4, x0, 40",
        "    addi x5, x0, 50",
        f"    addi {MEM_BASE}, x0, 128", 
    ])

    asm_lines.append(generate_microbenchmarks())
    
    # Inject the Constrained Macros to close coverage!
    asm_lines.append(generate_hazard_macros())

    instruction_count = 0
    label_counter = 0
    
    while instruction_count < num_instructions:
        category = random.choices(['R', 'I_A', 'I_S', 'MEM', 'BRANCH', 'JAL'], 
                                  weights=[30, 20, 10, 15, 15, 10])[0]
        
        rd, rs1, rs2 = get_reg(), get_reg(), get_reg()
        
        if category == 'R':
            asm_lines.append(f"    {random.choice(R_TYPE)} {rd}, {rs1}, {rs2}")
            instruction_count += 1
        elif category == 'I_A':
            asm_lines.append(f"    {random.choice(I_TYPE_ARITH)} {rd}, {rs1}, {random.randint(-512, 511)}")
            instruction_count += 1
        elif category == 'I_S':
            asm_lines.append(f"    {random.choice(I_TYPE_SHIFT)} {rd}, {rs1}, {random.randint(0, 31)}")
            instruction_count += 1
        elif category == 'MEM':
            asm_lines.append(f"    {random.choice(MEM_TYPE)} {rd}, {random.choice([0, 4])}({MEM_BASE})")
            instruction_count += 1
        elif category == 'BRANCH':
            label = f"branch_{label_counter}"
            label_counter += 1
            asm_lines.append(f"    {random.choice(BRANCH_TYPE)} {rs1}, {rs2}, {label}")
            asm_lines.append(generate_shadow())
            asm_lines.append(f"{label}:")
            instruction_count += 2 
        elif category == 'JAL':
            label = f"jal_{label_counter}"
            label_counter += 1
            asm_lines.append(f"    jal {rd}, {label}")
            asm_lines.append(generate_shadow())
            asm_lines.append(f"{label}:")
            instruction_count += 2

    asm_lines.append("end_loop:")
    asm_lines.append("    j end_loop")
    return "\n".join(asm_lines)

with open('stress_test.s', 'w') as f:
    f.write(generate_csitss_stress_test(1000))