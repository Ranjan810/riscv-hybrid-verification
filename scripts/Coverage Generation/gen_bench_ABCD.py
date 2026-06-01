import os

def generate_bench_abcd(num_loops=20):

    asm = [
        "    .text",
        "    .global _start",
        "",
        "_start:",
        "",
        "        addi x10, x0, 192",
        "        addi x12, x0, 40",
        "        sw   x0, 0(x10)",
        "",
        f"        addi x30, x0, {num_loops}",
        "",
        "test_loop:"
    ]

    asm.extend([

        "",
        "        # ==========================================",
        "        # A : Load Use Hazard",
        "        # ==========================================",
        "",
        "        lw   x11, 0(x10)",
        "        add  x13, x11, x12",
        "",
        "        addi x0, x0, 0",
        "        addi x0, x0, 0",

        "",
        "        # ==========================================",
        "        # B : Enhanced Forwarding",
        "        # ==========================================",
        "",
        "        addi x21, x0, 10",
        "        addi x22, x0, 20",
        "",
        "        add  x23, x21, x22",
        "        add  x24, x23, x22",
        "        add  x25, x24, x23",
        "",
        "        addi x0, x0, 0",

        "",
        "        # ==========================================",
        "        # C : Branch Flush Recovery",
        "        # ==========================================",
        "",
        "        addi x26, x0, 1",
        "        beq  x26, x26, flush_target",
        "",
        "        addi x0, x0, 0",
        "",
        "flush_target:",
        "        addi x0, x0, 0",

        "",
        "        # ==========================================",
        "        # D : Predictor Training Pattern",
        "        # ==========================================",
        "",
        "        addi x27, x0, 1",
        "        addi x28, x0, 1",

        "",
        "        # Taken",
        "        beq  x27, x28, d_taken_1",
        "        nop",
        "d_taken_1:",

        "",
        "        # Taken again",
        "        beq  x27, x28, d_taken_2",
        "        nop",
        "d_taken_2:",

        "",
        "        addi x28, x0, 2",

        "",
        "        # Not Taken",
        "        beq  x27, x28, d_nt_1",
        "d_nt_1:",

        "",
        "        # Not Taken again",
        "        beq  x27, x28, d_nt_2",
        "d_nt_2:",

        "",
        "        addi x30, x30, -1",
        "        bne  x30, x0, test_loop",

        "",
        "done_ABCD:",
        "        nop",
        "        nop",
        "        nop"
    ])

    return "\n".join(asm)


if __name__ == "__main__":

    os.makedirs("tests", exist_ok=True)

    with open("tests/bench_ABCD.s", "w") as f:
        f.write(generate_bench_abcd())

    print("SUCCESS: Generated tests/bench_ABCD.s")