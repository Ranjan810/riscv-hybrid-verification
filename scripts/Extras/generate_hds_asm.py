import sys
import os

def generate_hds_asm(density_percentage, num_pairs=20):
    asm_lines = [
        "    .text",
        "    .global _start",
        "_start:",
        "        # 1. Align Scoreboard and DUT Initial State",
        "        addi x2, x0, 192    # Hardcode memory base (0xc0) to bypass GCC linker offset",
        "        addi x4, x0, 40     # Initialize x4 to 40 (0x28) to match Scoreboard expectations",
        "        sw x0, 0(x2)        # Write 0 to data memory so lw doesn't read 'X' states",
        "        # ==========================================",
        f"        # HAZARD DENSITY: {density_percentage}%",
        "        # ==========================================",
    ]

    if density_percentage == 100:
        nops = 0
    elif density_percentage == 50:
        nops = 1
    else:
        nops = 3

    for i in range(num_pairs):
        asm_lines.append("        lw x1, 0(x2)")
        for _ in range(nops):
            asm_lines.append("        addi x0, x0, 0  # nop")
        asm_lines.append("        add x3, x1, x4")
        asm_lines.append("        # ------------------------------------------")

    asm_lines.append("end_loop:")
    asm_lines.append("        j end_loop")

    return "\n".join(asm_lines)

if __name__ == "__main__":
    density = 100
    if len(sys.argv) > 1:
        density = int(sys.argv[1])
        
    asm_out = generate_hds_asm(density)
    os.makedirs("tests", exist_ok=True)
    
    with open("tests/hds_test.s", "w") as f:
        f.write(asm_out)
        
    print(f"SUCCESS: Generated tests/hds_test.s with {density}% Load-Use hazard density.")