    .text
    .global _start

_start:

        # ==========================================
        # Initialization
        # ==========================================

        addi x10, x0, 192      # Memory base (0xC0)
        addi x12, x0, 40       # Operand for Benchmark A
        sw   x0, 0(x10)        # Initialize memory

        addi x30, x0, 100

test_loop:

        # ==========================================
        # BENCHMARK A: Load-Use Hazard
        # ==========================================

        lw   x11, 0(x10)
        add  x13, x11, x12

        # Isolation padding
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # ==========================================
        # BENCHMARK B: Enhanced Forwarding Chain
        # ==========================================

        addi x21, x0, 10
        addi x22, x0, 20

        # Initial consumer
        add  x23, x21, x22

        # Forwarding chain
        add  x24, x23, x22
        add  x25, x24, x23

        # Isolation padding
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        addi x30, x30, -1
        bne  x30, x0, test_loop

done_AB:
        nop
        nop
        nop