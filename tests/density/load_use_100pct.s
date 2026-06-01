    .text
    .global _start

_start:
        # Initialize base states
        addi x10, x0, 192   # Memory base (0xc0)
        addi x12, x0, 40    # Operand
        sw   x0, 0(x10)     # Clear memory

        addi x30, x0, 50   # Finite loop counter for CPI

test_loop:

        # --- Pair 1 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 2 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 3 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 4 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 5 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 6 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 7 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 8 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 9 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 10 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 11 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 12 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 13 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 14 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 15 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 16 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 17 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 18 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 19 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Pair 20 : HAZARD ---
        lw   x11, 0(x10)
        add  x13, x11, x12
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

        # Loop decrementor
        addi x30, x30, -1
        bne  x30, x0, test_loop

done_density_100:
        nop
        nop
        nop