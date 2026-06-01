import os

def generate_load_use_density(density_pct, total_pairs=20, num_loops=50):
    asm = [
        "    .text",
        "    .global _start",
        "",
        "_start:",
        "        # Initialize base states",
        "        addi x10, x0, 192   # Memory base (0xc0)",
        "        addi x12, x0, 40    # Operand",
        "        sw   x0, 0(x10)     # Clear memory",
        "",
        f"        addi x30, x0, {num_loops}   # Finite loop counter for CPI",
        "",
        "test_loop:"
    ]

    num_hazard = int((density_pct / 100.0) * total_pairs)
    
    pattern = ['SAFE'] * total_pairs
    if num_hazard > 0:
        step = total_pairs / num_hazard
        for i in range(num_hazard):
            pattern[int(i * step)] = 'HAZARD'

    for i, p_type in enumerate(pattern):
        asm.append("")
        asm.append(f"        # --- Pair {i+1} : {p_type} ---")
        
        if p_type == 'SAFE':
            # 5 Instructions: NOPs separate the dependency
            asm.append(f"        lw   x11, 0(x10)")
            asm.append(f"        addi x0, x0, 0")
            asm.append(f"        addi x0, x0, 0")
            asm.append(f"        add  x13, x11, x12")
            asm.append(f"        addi x0, x0, 0")
        else:
            # 5 Instructions: Dependency is immediate, NOPs shifted to the end
            asm.append(f"        lw   x11, 0(x10)")
            asm.append(f"        add  x13, x11, x12")
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
        asm_out = generate_load_use_density(d, total_pairs=20, num_loops=50)
        filename = f"tests/density/load_use_{d}pct.s"
        with open(filename, "w") as f:
            f.write(asm_out)
        print(f"SUCCESS: Generated {filename}")