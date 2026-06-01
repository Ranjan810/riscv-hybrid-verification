import os

def generate_forwarding_stress(num_loops=50):
    asm = [
        "    .text",
        "    .global _start",
        "",
        "_start:",
        "        # Initialize base states and registers to avoid X propagation",
        "        addi x10, x0, 192   # Memory base for lw/sw",
        "        addi x1, x0, 1",
        "        addi x2, x0, 2",
        "        addi x3, x0, 3",
        "        addi x4, x0, 4",
        "        addi x7, x0, 7",
        "        sw   x0, 0(x10)     # Clear memory at base",
        "",
        f"        addi x30, x0, {num_loops}   # Finite loop counter",
        "",
        "test_loop:"
    ]

    # Section 1: rs1 Forwarding (Targets M3 - EX-EX Blindness)
    asm.extend([
        "        # --- Section 1: rs1 EX-EX Forwarding Chains ---",
        "        add  x5, x1, x2",
        "        add  x6, x5, x3",
        "        add  x8, x6, x4",
        "        nop",
        "        nop"
    ])

    # Section 2: rs2 Forwarding (Targets M5, M7 - rs2 Blindness)
    asm.extend([
        "        # --- Section 2: rs2 Forwarding ---",
        "        add  x5, x1, x2",
        "        add  x6, x3, x5",
        "        add  x8, x4, x6",
        "        nop",
        "        nop"
    ])

    # Section 3: Dual Operand Forwarding (Targets M5, M7 simultaneous)
    asm.extend([
        "        # --- Section 3: Dual Operand Forwarding ---",
        "        add  x5, x1, x2",
        "        add  x6, x3, x4",
        "        add  x8, x5, x6",
        "        nop",
        "        nop"
    ])

    # Section 4: Priority Conflict (Targets M8 - Priority Inverted)
    asm.extend([
        "        # --- Section 4: Simultaneous MEM/WB Priority Conflict ---",
        "        add  x5, x1, x2",
        "        add  x5, x5, x3",
        "        add  x6, x5, x4",  # x5 from MEM must take priority over x5 from WB
        "        nop",
        "        nop"
    ])

    # Section 5: Comparator Corner Cases (Targets M9 - rd+1 Compare)
    asm.extend([
        "        # --- Section 5: rd+1 Comparator Trap ---",
        "        lw   x5, 0(x10)",
        "        add  x6, x5, x7",
        "        lw   x5, 0(x10)",
        "        add  x6, x6, x7",
        "        lw   x5, 0(x10)",
        "        add  x6, x6, x5",
        "        nop",
        "        nop"
    ])

    # End sequence (No JAL, falls through to 0x00000000 memory)
    asm.extend([
        "",
        "        # Loop decrementor",
        "        addi x30, x30, -1",
        "        bne  x30, x0, test_loop",
        "",
        "done_stress:",
        "        nop",
        "        nop",
        "        nop",
        "        nop"
    ])
    
    return "\n".join(asm)

if __name__ == "__main__":
    os.makedirs("tests/stress", exist_ok=True)
    
    asm_out = generate_forwarding_stress(num_loops=50)
    filename_s = "tests/stress/forwarding_stress.s"
    
    with open(filename_s, "w") as f:
        f.write(asm_out)
        
    print(f"SUCCESS: Generated {filename_s}")