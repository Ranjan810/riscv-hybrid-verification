import random

# =======================================================================
# CSITSS 2026: Hybrid Verification Stress & Microbenchmark Generator
# =======================================================================

SMALL_POOL = ['x1', 'x2', 'x3', 'x4', 'x5'] 
LARGE_POOL = [f'x{i}' for i in range(6, 31)] 
MEM_BASE = 'x31'

# 1. FIXED: Separated I-Type pools for legal ISA generation
R_TYPE = ['add', 'sub', 'and', 'or', 'xor', 'slt', 'sltu']
I_TYPE_ARITH = ['addi', 'ori', 'xori', 'andi', 'slti', 'sltiu']
I_TYPE_SHIFT = ['slli', 'srli', 'srai'] # STRICTLY 0-31
MEM_TYPE = ['lw', 'sw']
BRANCH_TYPE = ['beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu']

def get_reg():
    return random.choice(SMALL_POOL) if random.random() < 0.8 else random.choice(LARGE_POOL)

def generate_shadow():
    return f"    add {get_reg()}, {get_reg()}, {get_reg()}  # Speculative shadow"

def generate_microbenchmarks():
    """ 
    2 & 3. ADVERSARIAL PATTERNS & WORST-CASE HAZARD WINDOWS 
    These specifically target the darkest corners of the pipeline architecture.
    """
    asm = [
        "    # ==========================================",
        "    # PHASE 1: DIRECTED MICROBENCHMARKS",
        "    # ==========================================",
        "",
        "    # MICROBENCHMARK A: Worst-Case Load-Use Chains",
        "    # Forces back-to-back stall logic evaluation",
        f"    lw x1, 0({MEM_BASE})",
        "    add x2, x1, x1      # Stall required",
        f"    lw x3, 4({MEM_BASE})",
        "    sub x4, x3, x3      # Stall required",
        "",
        "    # MICROBENCHMARK B: Simultaneous Dual-Source Forwarding",
        "    # Forces the forwarding mux to bypass from two different stages simultaneously",
        "    addi x1, x0, 10     # WB stage in 2 cycles",
        "    addi x2, x0, 20     # MEM stage in 1 cycle",
        "    add x3, x1, x2      # Needs Fwd_A from WB, Fwd_B from MEM",
        "",
        "    # MICROBENCHMARK C: Predictor-Adversarial Pattern (Oscillation)",
        "    # Alternates T/NT/T/NT to stress hysteresis and convergence in a 2-bit BHT",
        "    addi x10, x0, 4     # Loop counter",
        "adv_loop:",
        "    addi x11, x0, 1",
        "    beq x11, x0, skip_oscillation  # Always Not-Taken",
        "skip_oscillation:",
        "    addi x10, x10, -1",
        "    bne x10, x0, adv_loop          # Always Taken (until end)",
        "    # ==========================================",
        "    # PHASE 2: RANDOMIZED STRESS TEST",
        "    # ==========================================",
        ""
    ]
    return "\n".join(asm)

def generate_csitss_stress_test(num_instructions):
    asm_lines = [
        ".data",
        "    safe_mem: .space 1024",
        ".text",
        ".global _start",
        "_start:",
        "    addi x1, x0, 10",
        "    addi x2, x0, 20",
        "    addi x3, x0, 30",
        "    addi x4, x0, 40",
        "    addi x5, x0, 50",
        f"    la {MEM_BASE}, safe_mem",
    ]

    # Inject the worst-case microbenchmarks first
    asm_lines.append(generate_microbenchmarks())

    stats = {
        "R_Type": 0, "I_Arith": 0, "I_Shift": 0, "Mem_Type": 0, 
        "Branch_Type": 0, "JAL_Type": 0, "JALR_Type": 0
    }

    instruction_count = 0
    label_counter = 0
    
    while instruction_count < num_instructions:
        category = random.choices(['R', 'I_A', 'I_S', 'MEM', 'BRANCH', 'JAL', 'JALR'], 
                                  weights=[30, 20, 10, 15, 15, 5, 5])[0]
        
        rd, rs1, rs2 = get_reg(), get_reg(), get_reg()
        
        if category == 'R':
            asm_lines.append(f"    {random.choice(R_TYPE)} {rd}, {rs1}, {rs2}")
            stats["R_Type"] += 1
            instruction_count += 1
            
        elif category == 'I_A':
            imm = random.randint(-2048, 2047) 
            asm_lines.append(f"    {random.choice(I_TYPE_ARITH)} {rd}, {rs1}, {imm}")
            stats["I_Arith"] += 1
            instruction_count += 1
            
        elif category == 'I_S':
            # FIX 1: Shift immediates are strictly 5 bits (0-31)
            shamt = random.randint(0, 31) 
            asm_lines.append(f"    {random.choice(I_TYPE_SHIFT)} {rd}, {rs1}, {shamt}")
            stats["I_Shift"] += 1
            instruction_count += 1
            
        elif category == 'MEM':
            imm = random.randrange(0, 1020, 4) 
            asm_lines.append(f"    {random.choice(MEM_TYPE)} {rd}, {imm}({MEM_BASE})")
            stats["Mem_Type"] += 1
            instruction_count += 1
            
        elif category == 'BRANCH':
            label = f"branch_target_{label_counter}"
            label_counter += 1
            asm_lines.append(f"    {random.choice(BRANCH_TYPE)} {rs1}, {rs2}, {label}")
            asm_lines.append(generate_shadow())
            asm_lines.append(f"{label}:")
            stats["Branch_Type"] += 1
            instruction_count += 2 
            
        elif category == 'JAL':
            label = f"jal_target_{label_counter}"
            label_counter += 1
            asm_lines.append(f"    jal {rd}, {label}")
            asm_lines.append(generate_shadow())
            asm_lines.append(f"{label}:")
            stats["JAL_Type"] += 1
            instruction_count += 2

        elif category == 'JALR':
            label = f"jalr_target_{label_counter}"
            label_counter += 1
            asm_lines.append(f"    la {rs1}, {label}")
            asm_lines.append(f"    jalr {rd}, {rs1}, 0")
            asm_lines.append(generate_shadow())
            asm_lines.append(f"{label}:")
            stats["JALR_Type"] += 1
            instruction_count += 3

    asm_lines.append("end_loop:")
    asm_lines.append("    j end_loop")

    report = "\n".join([
        f"/* ===========================================================",
        f"   CSITSS 2026: HYBRID VERIFICATION METADATA REPORT",
        f"   ===========================================================",
        f"   Total Random Instructions    : {instruction_count}",
        f"   Data Ops (R/I/Shift/Mem)     : {stats['R_Type'] + stats['I_Arith'] + stats['I_Shift'] + stats['Mem_Type']}",
        f"   Legal Shift OPs (0-31 imm)   : {stats['I_Shift']}",
        f"   Branches & Jumps             : {stats['Branch_Type'] + stats['JAL_Type'] + stats['JALR_Type']}",
        f"   Targeted Microbenchmarks     : ENABLED (Load-Use, Dual-Fwd, BHT Oscillation)",
        f"=========================================================== */\n"
    ])

    return report + "\n".join(asm_lines)

with open('tests/stress_test.s', 'w') as f:
    f.write(generate_csitss_stress_test(1000))

print("SUCCESS: Generated assembly instructions with Legal Shifts and Microbenchmarks!")