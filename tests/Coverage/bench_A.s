    .text
    .global _start

_start:
        # Benchmark A - Load Use Hazard

        addi x10, x0, 192
        addi x12, x0, 40
        sw   x0, 0(x10)

        addi x30, x0, 100

loop_A:

        lw   x11, 0(x10)
        add  x13, x11, x12

        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        addi x30, x30, -1
        bne  x30, x0, loop_A

done_A:
        nop
        nop
        nop