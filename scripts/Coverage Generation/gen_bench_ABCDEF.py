import os

def generate_bench_abcdef(num_loops=20):

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
        "        beq  x27, x28, d_taken_1",
        "        nop",
        "d_taken_1:",

        "",
        "        beq  x27, x28, d_taken_2",
        "        nop",
        "d_taken_2:",

        "",
        "        addi x28, x0, 2",

        "",
        "        beq  x27, x28, d_nt_1",
        "d_nt_1:",

        "",
        "        beq  x27, x28, d_nt_2",
        "d_nt_2:",

        "",
        "        # ==========================================",
        "        # E : JAL + JALR Verification",
        "        # ==========================================",
        "",

        "        jal  x1, jal_target",

        "        addi x5, x0, 99",

        "jal_target:",
        "        addi x6, x0, 1",

        "",
        "        la   x7, jalr_target",
        "        jalr x8, x7, 0",

        "        addi x9, x0, 99",

        "jalr_target:",
        "        addi x10, x0, 1",

        "",
        "        # ==========================================",
        "        # F : Branch Dual Forwarding",
        "        # ==========================================",
        "",
        "        addi x1, x0, 5",
        "        addi x2, x0, 5",
        "",
        "        add  x3, x1, x2",
        "        add  x4, x3, x2",
        "",
        "        beq  x4, x3, f_target_1",
        "        nop",
        "f_target_1:",
        "",
        "        add  x5, x4, x3",
        "        add  x6, x5, x4",
        "",
        "        bne  x6, x5, f_target_2",
        "        nop",
        "f_target_2:",
        "",
        "        add  x7, x6, x5",
        "        add  x8, x7, x6",
        "",
        "        beq  x8, x8, f_target_3",
        "        nop",
        "f_target_3:",
        "",

        
        "        addi x30, x30, -1",
        "        bne  x30, x0, test_loop",

        "",
        
        "done_ABCDEF:",
        "        nop",
        "        nop",
        "        nop"
    ])

    return '\n'.join(asm)


if __name__ == '__main__':

    os.makedirs('tests', exist_ok=True)

    with open('tests/bench_ABCDEF.s', 'w') as f:
        f.write(generate_bench_abcdef())

    print('SUCCESS: Generated tests/bench_ABCDEF.s')