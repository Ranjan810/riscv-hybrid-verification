.section .text
.globl _start

_start:
    # 1. Initialization
    addi x1, x0, 5      # x1 = 5
    addi x2, x0, 10     # x2 = 10
    
    # 2. Data Hazard (RAW)
    # This ADD needs x1 and x2 immediately after they are written.
    # Your Forwarding Unit must catch this and bypass the registers!
    add  x3, x1, x2     # x3 = 15
    
    # 3. Control Hazard
    # This branch will jump back to the start, forcing the BTB to guess
    # and the pipeline to flush if it mispredicts.
    beq  x0, x0, _start