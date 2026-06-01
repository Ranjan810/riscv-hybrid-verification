import os

def generate_bench_a(num_loops=100):
    asm_lines = [
        "    .text",
        "    .global _start",
        "",
        "_start:",
        "        # Benchmark A - Load Use Hazard",
        "",
        "        addi x10, x0, 192",
        "        addi x12, x0, 40",
        "        sw   x0, 0(x10)",
        "",
        f"        addi x30, x0, {num_loops}",
        "",
        "loop_A:",
        "",
        "        lw   x11, 0(x10)",
        "        add  x13, x11, x12",
        "",
        "        addi x0, x0, 0",
        "        addi x0, x0, 0",
        "        addi x0, x0, 0",
        "",
        "        addi x30, x30, -1",
        "        bne  x30, x0, loop_A",
        "",
        "done_A:",
        "        nop",
        "        nop",
        "        nop",
    ]

    return "\n".join(asm_lines)

if __name__ == "__main__":
    asm_out = generate_bench_a()

    os.makedirs("tests", exist_ok=True)

    with open("tests/bench_A.s", "w") as f:
        f.write(asm_out)

    print("SUCCESS: Generated tests/bench_A.s")