    .text
    .global _start

_start:
        # Initialize baseline registers for branch conditions
        addi x27, x0, 1     # Constant 1
        addi x28, x0, 1     # Constant 1 (Matches x27)
        addi x29, x0, 0     # Constant 0 (Differs from x27)

        addi x30, x0, 50   # Finite loop counter for CPI

test_loop:

        # --- Branch 1 : SAFE ---
        beq  x27, x29, target_0
        addi x0, x0, 0
        addi x0, x0, 0
target_0:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 2 : SAFE ---
        beq  x27, x29, target_1
        addi x0, x0, 0
        addi x0, x0, 0
target_1:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 3 : SAFE ---
        beq  x27, x29, target_2
        addi x0, x0, 0
        addi x0, x0, 0
target_2:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 4 : SAFE ---
        beq  x27, x29, target_3
        addi x0, x0, 0
        addi x0, x0, 0
target_3:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 5 : SAFE ---
        beq  x27, x29, target_4
        addi x0, x0, 0
        addi x0, x0, 0
target_4:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 6 : SAFE ---
        beq  x27, x29, target_5
        addi x0, x0, 0
        addi x0, x0, 0
target_5:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 7 : SAFE ---
        beq  x27, x29, target_6
        addi x0, x0, 0
        addi x0, x0, 0
target_6:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 8 : SAFE ---
        beq  x27, x29, target_7
        addi x0, x0, 0
        addi x0, x0, 0
target_7:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 9 : SAFE ---
        beq  x27, x29, target_8
        addi x0, x0, 0
        addi x0, x0, 0
target_8:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 10 : SAFE ---
        beq  x27, x29, target_9
        addi x0, x0, 0
        addi x0, x0, 0
target_9:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 11 : SAFE ---
        beq  x27, x29, target_10
        addi x0, x0, 0
        addi x0, x0, 0
target_10:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 12 : SAFE ---
        beq  x27, x29, target_11
        addi x0, x0, 0
        addi x0, x0, 0
target_11:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 13 : SAFE ---
        beq  x27, x29, target_12
        addi x0, x0, 0
        addi x0, x0, 0
target_12:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 14 : SAFE ---
        beq  x27, x29, target_13
        addi x0, x0, 0
        addi x0, x0, 0
target_13:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 15 : SAFE ---
        beq  x27, x29, target_14
        addi x0, x0, 0
        addi x0, x0, 0
target_14:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 16 : SAFE ---
        beq  x27, x29, target_15
        addi x0, x0, 0
        addi x0, x0, 0
target_15:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 17 : SAFE ---
        beq  x27, x29, target_16
        addi x0, x0, 0
        addi x0, x0, 0
target_16:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 18 : SAFE ---
        beq  x27, x29, target_17
        addi x0, x0, 0
        addi x0, x0, 0
target_17:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 19 : SAFE ---
        beq  x27, x29, target_18
        addi x0, x0, 0
        addi x0, x0, 0
target_18:
        addi x0, x0, 0
        addi x0, x0, 0

        # --- Branch 20 : SAFE ---
        beq  x27, x29, target_19
        addi x0, x0, 0
        addi x0, x0, 0
target_19:
        addi x0, x0, 0
        addi x0, x0, 0

        # Loop decrementor
        addi x30, x30, -1
        bne  x30, x0, test_loop

done_density_0:
        nop
        nop
        nop