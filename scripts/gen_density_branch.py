import os

def generate_branch_density(density_pct, total_branches=20, num_loops=50):
    asm = [
        "    .text",
        "    .global _start",
        "",
        "_start:",
        "        # Initialize baseline registers for branch conditions",
        "        addi x27, x0, 1     # Constant 1",
        "        addi x28, x0, 1     # Constant 1 (Matches x27)",
        "        addi x29, x0, 0     # Constant 0 (Differs from x27)",
        "",
        f"        addi x30, x0, {num_loops}   # Finite loop counter for CPI",
        "",
        "test_loop:"
    ]

    num_hazard = int((density_pct / 100.0) * total_branches)
    
    pattern = ['SAFE'] * total_branches
    if num_hazard > 0:
        step = total_branches / num_hazard
        for i in range(num_hazard):
            pattern[int(i * step)] = 'HAZARD'

    for i, p_type in enumerate(pattern):
        asm.append("")
        asm.append(f"        # --- Branch {i+1} : {p_type} ---")
        
        if p_type == 'SAFE':
            # Not-Taken Branch: 5 instructions execute and retire
            asm.append(f"        beq  x27, x29, target_{i}")
            asm.append(f"        addi x0, x0, 0")
            asm.append(f"        addi x0, x0, 0")
            asm.append(f"target_{i}:")
            asm.append(f"        addi x0, x0, 0")
            asm.append(f"        addi x0, x0, 0")
        else:
            # Taken Branch: 2 flushed, 5 instructions execute and retire
            asm.append(f"        beq  x27, x28, target_{i}")
            asm.append(f"        addi x0, x0, 0") # Shadow instruction (flushed)
            asm.append(f"        addi x0, x0, 0") # Shadow instruction (flushed)
            asm.append(f"target_{i}:")
            asm.append(f"        addi x0, x0, 0")
            asm.append(f"        addi x0, x0, 0")
            asm.append(f"        addi x0, x0, 0")
            asm.append(f"        addi x0, x0, 0")

    asm.extend([
        "",
        "        # Loop decrementor",
        "        addi x30, x30, -1",
        "        bne  x30, x0, test_loop",
        "",
        f"done_density_{density_pct}:",
        "        nop",
        "        nop",
        "        nop"
    ])
    
    return "\n".join(asm)

if __name__ == "__main__":
    os.makedirs("tests/density", exist_ok=True)
    
    densities = [0, 25, 50, 75, 100]
    
    for d in densities:
        asm_out = generate_branch_density(d, total_branches=20, num_loops=50)
        filename = f"tests/density/branch_{d}pct.s"
        with open(filename, "w") as f:
            f.write(asm_out)
        print(f"SUCCESS: Generated {filename}")