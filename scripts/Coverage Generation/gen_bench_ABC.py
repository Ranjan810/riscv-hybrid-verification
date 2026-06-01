import os

def generate_bench_abc(num_loops=20):

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

    # =========================================================
    # A + B + C benchmark body
    # =========================================================

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
        "        addi x0, x0, 0",
        "",
        "        # ==========================================",
        "        # C : Branch Flush Recovery",
        "        # ==========================================",
        "",
        "        addi x26, x0, 1",
        "",
        "        # Always taken branch",
        "        beq  x26, x26, flush_target",
        "",
        "        add  x0, x0, x0",
        "",
        "flush_target:",
        "        addi x0, x0, 0",
        "",
        "        addi x30, x30, -1",
        "        bne  x30, x0, test_loop",
        "",
        "done_ABC:",
        "        nop",
        "        nop",
        "        nop",
    ])

    return '\n'.join(asm)


if __name__ == '__main__':

    os.makedirs('tests', exist_ok=True)

    with open('tests/bench_ABC.s', 'w') as f:
        f.write(generate_bench_abc())

    print('SUCCESS: Generated tests/bench_ABC.s')