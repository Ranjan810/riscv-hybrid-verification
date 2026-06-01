    .text
    .global _start

_start:

        addi x10, x0, 192
        addi x12, x0, 40
        sw   x0, 0(x10)

        addi x30, x0, 20

test_loop:

        # ==========================================
        # A : Load Use Hazard
        # ==========================================

        lw   x11, 0(x10)
        add  x13, x11, x12

        addi x0, x0, 0
        addi x0, x0, 0

        # ==========================================
        # B : Enhanced Forwarding
        # ==========================================

        addi x21, x0, 10
        addi x22, x0, 20

        add  x23, x21, x22
        add  x24, x23, x22
        add  x25, x24, x23

        addi x0, x0, 0

        # ==========================================
        # C : Branch Flush Recovery
        # ==========================================

        addi x26, x0, 1
        beq  x26, x26, flush_target

        addi x0, x0, 0

flush_target:
        addi x0, x0, 0

        # ==========================================
        # D : Predictor Training Pattern
        # ==========================================

        addi x27, x0, 1
        addi x28, x0, 1

        beq  x27, x28, d_taken_1
        nop
d_taken_1:

        beq  x27, x28, d_taken_2
        nop
d_taken_2:

        addi x28, x0, 2

        beq  x27, x28, d_nt_1
d_nt_1:

        beq  x27, x28, d_nt_2
d_nt_2:

        # ==========================================
        # E : JAL + JALR Verification
        # ==========================================

        jal  x1, jal_target
        addi x5, x0, 99
jal_target:
        addi x6, x0, 1

        la   x7, jalr_target
        jalr x8, x7, 0
        addi x9, x0, 99
jalr_target:
        addi x10, x0, 1

        addi x30, x30, -1
        bne  x30, x0, test_loop

done_ABCDE:
        nop
        nop
        nop