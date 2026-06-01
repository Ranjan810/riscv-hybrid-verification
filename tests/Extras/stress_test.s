.text
.global _start
_start:
    addi x1, x0, 0
    addi x2, x0, 0
    addi x3, x0, 0
    addi x4, x0, 0
    addi x5, x0, 0
    addi x6, x0, 0
    addi x7, x0, 0
    addi x8, x0, 0
    addi x9, x0, 0
    addi x10, x0, 0
    addi x11, x0, 0
    addi x12, x0, 0
    addi x13, x0, 0
    addi x14, x0, 0
    addi x15, x0, 0
    addi x16, x0, 0
    addi x17, x0, 0
    addi x18, x0, 0
    addi x19, x0, 0
    addi x20, x0, 0
    addi x21, x0, 0
    addi x22, x0, 0
    addi x23, x0, 0
    addi x24, x0, 0
    addi x25, x0, 0
    addi x26, x0, 0
    addi x27, x0, 0
    addi x28, x0, 0
    addi x29, x0, 0
    addi x30, x0, 0
    addi x1, x0, 10
    addi x2, x0, 20
    addi x3, x0, 30
    addi x4, x0, 40
    addi x5, x0, 50
    addi x31, x0, 128
    # PHASE 1: DIRECTED MICROBENCHMARKS
    sw x5, 0(x31)
    lw x1, 0(x31)
    add x2, x1, x1      
    sw x5, 4(x31)
    lw x3, 4(x31)
    sub x4, x3, x3      
    addi x1, x0, 10     
    addi x2, x0, 20     
    add x3, x1, x2      
    addi x10, x0, 4     
adv_loop:
    addi x11, x0, 1
    beq x11, x0, skip_oscillation
skip_oscillation:
    addi x10, x10, -1
    bne x10, x0, adv_loop


    # MACRO 1: cross_fwd_a_b (Dual Forwarding from EX and MEM)
    addi x10, x0, 5
    addi x11, x0, 10
    add x12, x10, x11  # x10 forwarded from MEM, x11 forwarded from EX

    # MACRO 2: cross_branch_dual_fwd (Branch evaluating using two forwarded operands)
    addi x13, x0, 5
    addi x14, x0, 5
    beq x13, x14, macro_skip_1
    macro_skip_1:

    # MACRO 3: cross_flush_stall (Mispredict Flush + Load-Use Stall in the same cycle)
    # The BEQ mispredicts. In the exact cycle it flushes, the LW triggers a load-use stall.
    addi x15, x0, 0
    beq x15, x0, macro_skip_2
    lw x16, 0(x31)     # Load instruction
    add x17, x16, x16  # Use instruction (Triggers stall exactly as BEQ flushes)
    macro_skip_2:

    # MACRO 4: JALR Coverage (Safely constrained JALR)
    addi x18, x0, 4    # Set offset to safely jump to next instruction
    jalr x0, x18, 0    # Jumps exactly to macro_skip_3
    macro_skip_3:
    
    andi x1, x2, 351
    add x4, x1, x3
    jal x21, jal_0
    add x4, x5, x4  # Speculative shadow
jal_0:
    jal x2, jal_1
    add x4, x2, x1  # Speculative shadow
jal_1:
    slli x5, x5, 4
    jal x29, jal_2
    add x2, x1, x1  # Speculative shadow
jal_2:
    jal x4, jal_3
    add x3, x1, x2  # Speculative shadow
jal_3:
    xor x5, x1, x16
    sub x4, x26, x5
    jal x3, jal_4
    add x5, x3, x14  # Speculative shadow
jal_4:
    andi x14, x1, -272
    andi x2, x2, 1
    blt x3, x4, branch_5
    add x2, x5, x5  # Speculative shadow
branch_5:
    bne x2, x4, branch_6
    add x3, x2, x4  # Speculative shadow
branch_6:
    beq x4, x14, branch_7
    add x1, x3, x4  # Speculative shadow
branch_7:
    srli x3, x3, 27
    sub x2, x4, x30
    jal x5, jal_8
    add x1, x4, x3  # Speculative shadow
jal_8:
    lw x16, 4(x31)
    beq x2, x29, branch_9
    add x5, x5, x14  # Speculative shadow
branch_9:
    sw x18, 4(x31)
    sub x1, x1, x3
    sub x30, x1, x14
    beq x4, x5, branch_10
    add x3, x4, x5  # Speculative shadow
branch_10:
    sw x5, 0(x31)
    sw x1, 0(x31)
    lw x14, 0(x31)
    jal x2, jal_11
    add x5, x11, x12  # Speculative shadow
jal_11:
    andi x4, x29, -10
    lw x5, 4(x31)
    and x4, x11, x4
    beq x4, x1, branch_12
    add x4, x3, x3  # Speculative shadow
branch_12:
    ori x3, x28, -477
    sll x15, x1, x2
    slli x1, x1, 23
    jal x4, jal_13
    add x5, x1, x3  # Speculative shadow
jal_13:
    srli x27, x3, 22
    add x23, x2, x4
    add x5, x4, x3
    bne x3, x3, branch_14
    add x1, x23, x3  # Speculative shadow
branch_14:
    jal x21, jal_15
    add x4, x7, x3  # Speculative shadow
jal_15:
    addi x4, x1, -199
    beq x3, x3, branch_16
    add x1, x1, x3  # Speculative shadow
branch_16:
    slt x4, x4, x27
    srli x3, x29, 10
    slli x2, x7, 13
    lw x5, 4(x31)
    jal x4, jal_17
    add x2, x2, x1  # Speculative shadow
jal_17:
    sub x3, x1, x11
    srl x5, x4, x5
    and x11, x2, x28
    sw x5, 0(x31)
    jal x3, jal_18
    add x4, x4, x2  # Speculative shadow
jal_18:
    jal x4, jal_19
    add x4, x5, x3  # Speculative shadow
jal_19:
    srli x3, x1, 28
    srli x1, x3, 20
    lw x3, 4(x31)
    addi x5, x3, 454
    bne x21, x3, branch_20
    add x1, x4, x5  # Speculative shadow
branch_20:
    and x5, x2, x1
    or x5, x1, x3
    lw x2, 4(x31)
    bne x22, x4, branch_21
    add x2, x5, x1  # Speculative shadow
branch_21:
    addi x2, x1, -382
    lw x3, 4(x31)
    jal x27, jal_22
    add x3, x10, x3  # Speculative shadow
jal_22:
    slli x2, x3, 19
    xor x4, x3, x25
    beq x2, x4, branch_23
    add x3, x19, x3  # Speculative shadow
branch_23:
    srli x4, x4, 2
    srl x21, x3, x1
    slti x14, x5, 324
    or x5, x3, x4
    ori x10, x3, 348
    sub x5, x2, x5
    sw x5, 0(x31)
    addi x2, x5, -169
    slti x2, x11, 388
    sub x3, x7, x2
    or x5, x1, x27
    slli x3, x3, 15
    sll x3, x3, x3
    beq x19, x19, branch_24
    add x4, x11, x5  # Speculative shadow
branch_24:
    slli x5, x4, 9
    srli x18, x2, 30
    or x12, x6, x4
    slti x4, x28, -397
    lw x3, 4(x31)
    and x4, x3, x5
    srli x1, x9, 23
    bne x5, x3, branch_25
    add x6, x1, x1  # Speculative shadow
branch_25:
    andi x3, x22, 128
    jal x1, jal_26
    add x3, x4, x2  # Speculative shadow
jal_26:
    or x28, x2, x5
    sw x2, 4(x31)
    beq x3, x3, branch_27
    add x17, x5, x1  # Speculative shadow
branch_27:
    beq x3, x20, branch_28
    add x18, x2, x5  # Speculative shadow
branch_28:
    xori x2, x1, 33
    sll x17, x2, x3
    sub x5, x28, x4
    slti x4, x3, 364
    beq x3, x5, branch_29
    add x5, x1, x1  # Speculative shadow
branch_29:
    slti x5, x2, -475
    jal x2, jal_30
    add x3, x4, x2  # Speculative shadow
jal_30:
    slti x2, x3, 390
    lw x27, 4(x31)
    add x2, x3, x1
    jal x2, jal_31
    add x5, x3, x4  # Speculative shadow
jal_31:
    ori x4, x5, 306
    jal x1, jal_32
    add x5, x27, x2  # Speculative shadow
jal_32:
    xor x5, x5, x1
    slt x3, x3, x1
    slli x30, x3, 2
    srli x4, x2, 31
    srli x4, x3, 18
    slli x28, x3, 7
    slt x5, x3, x3
    sll x4, x19, x14
    bne x6, x1, branch_33
    add x2, x2, x1  # Speculative shadow
branch_33:
    jal x1, jal_34
    add x4, x21, x1  # Speculative shadow
jal_34:
    blt x3, x1, branch_35
    add x12, x3, x2  # Speculative shadow
branch_35:
    srli x17, x2, 20
    slli x4, x4, 0
    jal x1, jal_36
    add x3, x3, x30  # Speculative shadow
jal_36:
    sub x4, x11, x4
    xor x5, x10, x9
    lw x4, 0(x31)
    add x1, x13, x2
    beq x5, x5, branch_37
    add x5, x4, x29  # Speculative shadow
branch_37:
    xor x1, x2, x28
    jal x13, jal_38
    add x5, x5, x3  # Speculative shadow
jal_38:
    sll x3, x5, x1
    slli x5, x25, 29
    ori x7, x16, -497
    xori x2, x16, -367
    slt x17, x3, x1
    addi x1, x5, 484
    ori x3, x1, 211
    addi x2, x4, 221
    slli x5, x5, 14
    sw x1, 4(x31)
    slt x3, x3, x2
    add x5, x1, x5
    xori x1, x4, 416
    andi x19, x13, -35
    or x5, x5, x5
    sub x4, x2, x4
    add x3, x4, x2
    jal x5, jal_39
    add x1, x1, x6  # Speculative shadow
jal_39:
    sw x3, 0(x31)
    jal x2, jal_40
    add x4, x5, x17  # Speculative shadow
jal_40:
    slti x1, x3, 180
    or x16, x8, x2
    and x22, x3, x4
    ori x3, x5, 34
    ori x3, x4, 59
    xori x1, x1, -80
    blt x3, x5, branch_41
    add x3, x21, x16  # Speculative shadow
branch_41:
    bne x1, x2, branch_42
    add x4, x2, x2  # Speculative shadow
branch_42:
    xori x1, x1, 225
    slt x6, x3, x4
    blt x18, x5, branch_43
    add x20, x2, x3  # Speculative shadow
branch_43:
    add x3, x1, x3
    bne x3, x4, branch_44
    add x4, x22, x4  # Speculative shadow
branch_44:
    srli x2, x2, 18
    xor x2, x4, x4
    slli x2, x2, 16
    or x5, x2, x3
    and x5, x1, x5
    addi x14, x3, 393
    srli x4, x5, 4
    or x25, x4, x4
    andi x4, x4, -262
    sll x5, x16, x2
    srl x2, x2, x3
    addi x2, x5, 402
    sub x2, x5, x14
    addi x8, x3, -386
    sll x5, x5, x5
    blt x1, x5, branch_45
    add x4, x11, x1  # Speculative shadow
branch_45:
    sw x18, 4(x31)
    blt x2, x29, branch_46
    add x23, x4, x4  # Speculative shadow
branch_46:
    beq x3, x5, branch_47
    add x26, x4, x13  # Speculative shadow
branch_47:
    andi x4, x1, -349
    blt x5, x3, branch_48
    add x3, x1, x4  # Speculative shadow
branch_48:
    srli x5, x30, 10
    xori x3, x5, 78
    jal x1, jal_49
    add x4, x2, x9  # Speculative shadow
jal_49:
    beq x5, x4, branch_50
    add x5, x1, x1  # Speculative shadow
branch_50:
    andi x9, x3, 201
    sll x1, x5, x28
    bne x30, x5, branch_51
    add x5, x2, x5  # Speculative shadow
branch_51:
    sw x3, 4(x31)
    beq x3, x8, branch_52
    add x28, x3, x23  # Speculative shadow
branch_52:
    slti x20, x1, -61
    xor x29, x5, x2
    and x24, x5, x1
    slti x5, x3, 63
    beq x4, x2, branch_53
    add x1, x27, x2  # Speculative shadow
branch_53:
    or x10, x4, x27
    lw x1, 0(x31)
    xori x4, x2, 101
    addi x17, x1, -248
    srl x3, x5, x4
    add x4, x2, x5
    slli x4, x1, 4
    lw x2, 0(x31)
    xori x2, x4, -166
    beq x2, x1, branch_54
    add x1, x5, x8  # Speculative shadow
branch_54:
    or x5, x3, x4
    slli x1, x3, 24
    ori x4, x3, 374
    add x5, x6, x2
    srli x5, x1, 19
    slt x4, x17, x4
    srli x29, x4, 4
    slti x23, x1, 134
    sll x1, x3, x5
    lw x1, 4(x31)
    slli x28, x1, 14
    bne x2, x16, branch_55
    add x3, x3, x15  # Speculative shadow
branch_55:
    srli x5, x2, 27
    sw x2, 4(x31)
    slli x3, x4, 26
    blt x5, x1, branch_56
    add x27, x3, x2  # Speculative shadow
branch_56:
    jal x15, jal_57
    add x10, x3, x2  # Speculative shadow
jal_57:
    srli x9, x1, 12
    slli x1, x2, 22
    slti x20, x16, 22
    lw x2, 4(x31)
    ori x3, x4, -88
    lw x1, 0(x31)
    add x5, x2, x4
    lw x2, 0(x31)
    sll x15, x3, x1
    bne x1, x5, branch_58
    add x5, x5, x4  # Speculative shadow
branch_58:
    sub x15, x5, x4
    slti x3, x1, -324
    jal x1, jal_59
    add x4, x5, x3  # Speculative shadow
jal_59:
    xori x1, x2, 27
    slti x4, x3, 420
    xor x5, x20, x6
    add x1, x5, x1
    addi x3, x30, 458
    slt x1, x1, x4
    jal x29, jal_60
    add x3, x13, x1  # Speculative shadow
jal_60:
    andi x1, x5, 20
    lw x3, 0(x31)
    srli x4, x16, 7
    jal x4, jal_61
    add x1, x3, x5  # Speculative shadow
jal_61:
    sub x4, x4, x2
    sub x4, x3, x3
    lw x5, 0(x31)
    slli x2, x6, 8
    and x4, x5, x19
    srli x21, x2, 30
    bne x4, x4, branch_62
    add x1, x28, x24  # Speculative shadow
branch_62:
    srli x3, x1, 3
    srl x5, x3, x1
    or x1, x3, x10
    jal x5, jal_63
    add x4, x30, x2  # Speculative shadow
jal_63:
    ori x5, x2, 421
    beq x19, x4, branch_64
    add x2, x7, x6  # Speculative shadow
branch_64:
    slt x18, x8, x4
    xor x5, x1, x5
    slt x2, x4, x3
    slt x2, x1, x15
    jal x2, jal_65
    add x1, x1, x6  # Speculative shadow
jal_65:
    bne x2, x2, branch_66
    add x23, x1, x11  # Speculative shadow
branch_66:
    blt x2, x2, branch_67
    add x1, x16, x1  # Speculative shadow
branch_67:
    addi x3, x4, 280
    xori x5, x2, -450
    blt x1, x1, branch_68
    add x5, x17, x21  # Speculative shadow
branch_68:
    ori x2, x29, 376
    jal x14, jal_69
    add x2, x6, x1  # Speculative shadow
jal_69:
    ori x4, x2, -48
    beq x4, x1, branch_70
    add x17, x2, x2  # Speculative shadow
branch_70:
    beq x5, x3, branch_71
    add x1, x1, x2  # Speculative shadow
branch_71:
    lw x27, 4(x31)
    beq x4, x1, branch_72
    add x26, x3, x4  # Speculative shadow
branch_72:
    lw x5, 4(x31)
    srli x4, x2, 27
    blt x2, x4, branch_73
    add x28, x4, x1  # Speculative shadow
branch_73:
    add x20, x14, x2
    slli x1, x4, 5
    ori x16, x25, -76
    srl x3, x4, x15
    lw x2, 4(x31)
    srli x26, x2, 10
    bne x5, x19, branch_74
    add x1, x5, x15  # Speculative shadow
branch_74:
    add x5, x1, x3
    blt x3, x4, branch_75
    add x2, x5, x30  # Speculative shadow
branch_75:
    and x8, x4, x12
    add x5, x13, x5
    add x5, x2, x1
    jal x5, jal_76
    add x12, x1, x5  # Speculative shadow
jal_76:
    lw x20, 0(x31)
    lw x5, 4(x31)
    jal x2, jal_77
    add x1, x4, x1  # Speculative shadow
jal_77:
    sw x16, 0(x31)
    slti x2, x4, 447
    lw x1, 0(x31)
    srli x5, x1, 7
    slti x4, x5, 367
    jal x2, jal_78
    add x5, x3, x1  # Speculative shadow
jal_78:
    xor x3, x5, x2
    and x5, x1, x3
    slli x1, x1, 29
    jal x13, jal_79
    add x16, x22, x4  # Speculative shadow
jal_79:
    slti x2, x17, 351
    ori x16, x1, 229
    sw x3, 4(x31)
    lw x2, 4(x31)
    andi x9, x4, 82
    blt x5, x19, branch_80
    add x6, x3, x14  # Speculative shadow
branch_80:
    or x5, x4, x28
    xori x1, x5, 361
    lw x1, 0(x31)
    srl x11, x3, x5
    bne x1, x4, branch_81
    add x1, x3, x18  # Speculative shadow
branch_81:
    xor x3, x2, x2
    jal x9, jal_82
    add x1, x24, x4  # Speculative shadow
jal_82:
    or x5, x1, x3
    blt x2, x4, branch_83
    add x2, x1, x2  # Speculative shadow
branch_83:
    lw x24, 4(x31)
    slti x2, x2, 10
    jal x1, jal_84
    add x2, x3, x1  # Speculative shadow
jal_84:
    slti x3, x6, 53
    slt x4, x5, x2
    jal x1, jal_85
    add x3, x28, x5  # Speculative shadow
jal_85:
    slt x1, x5, x21
    add x2, x18, x4
    and x3, x5, x27
    slt x5, x2, x12
    slt x1, x3, x3
    ori x1, x3, -373
    srl x3, x5, x21
    blt x3, x4, branch_86
    add x6, x5, x5  # Speculative shadow
branch_86:
    or x11, x1, x22
    addi x4, x11, 52
    jal x4, jal_87
    add x18, x5, x1  # Speculative shadow
jal_87:
    add x2, x18, x4
    srli x4, x3, 20
    srl x5, x3, x14
    bne x2, x5, branch_88
    add x2, x3, x29  # Speculative shadow
branch_88:
    blt x2, x3, branch_89
    add x3, x5, x21  # Speculative shadow
branch_89:
    jal x4, jal_90
    add x5, x4, x6  # Speculative shadow
jal_90:
    xor x3, x2, x1
    xor x4, x8, x4
    or x1, x1, x2
    srl x22, x3, x2
    sub x1, x5, x1
    slt x5, x2, x3
    bne x3, x1, branch_91
    add x2, x4, x4  # Speculative shadow
branch_91:
    jal x27, jal_92
    add x2, x3, x3  # Speculative shadow
jal_92:
    add x25, x4, x3
    bne x5, x4, branch_93
    add x3, x8, x3  # Speculative shadow
branch_93:
    bne x5, x1, branch_94
    add x2, x3, x3  # Speculative shadow
branch_94:
    bne x3, x4, branch_95
    add x3, x4, x2  # Speculative shadow
branch_95:
    add x12, x2, x3
    slli x2, x1, 25
    slli x5, x4, 26
    jal x5, jal_96
    add x4, x3, x3  # Speculative shadow
jal_96:
    lw x5, 4(x31)
    slli x2, x1, 17
    lw x2, 0(x31)
    slli x3, x4, 10
    sw x4, 0(x31)
    slti x6, x3, -457
    and x1, x1, x3
    jal x2, jal_97
    add x4, x17, x8  # Speculative shadow
jal_97:
    blt x1, x5, branch_98
    add x3, x1, x2  # Speculative shadow
branch_98:
    sw x19, 0(x31)
    lw x26, 4(x31)
    add x27, x1, x18
    sw x4, 4(x31)
    lw x7, 4(x31)
    xori x4, x2, -434
    or x3, x2, x4
    sll x3, x26, x1
    xor x3, x3, x19
    sll x2, x1, x2
    srl x1, x1, x5
    jal x18, jal_99
    add x1, x24, x4  # Speculative shadow
jal_99:
    jal x4, jal_100
    add x5, x4, x5  # Speculative shadow
jal_100:
    xor x1, x4, x1
    addi x5, x5, 236
    slt x1, x10, x28
    sw x27, 4(x31)
    jal x3, jal_101
    add x5, x1, x5  # Speculative shadow
jal_101:
    xor x1, x4, x5
    xor x30, x5, x3
    bne x3, x1, branch_102
    add x3, x2, x22  # Speculative shadow
branch_102:
    blt x2, x5, branch_103
    add x5, x5, x4  # Speculative shadow
branch_103:
    srli x3, x5, 1
    sw x1, 0(x31)
    srl x1, x17, x18
    slli x2, x17, 21
    ori x5, x2, -266
    addi x3, x5, -438
    or x2, x4, x2
    srl x3, x19, x1
    add x4, x14, x1
    blt x5, x5, branch_104
    add x8, x4, x5  # Speculative shadow
branch_104:
    srli x2, x3, 14
    lw x2, 4(x31)
    srl x28, x11, x2
    srli x26, x5, 15
    bne x1, x1, branch_105
    add x4, x5, x1  # Speculative shadow
branch_105:
    jal x1, jal_106
    add x4, x1, x1  # Speculative shadow
jal_106:
    sw x28, 4(x31)
    addi x7, x4, 300
    blt x2, x20, branch_107
    add x2, x2, x5  # Speculative shadow
branch_107:
    jal x3, jal_108
    add x5, x30, x4  # Speculative shadow
jal_108:
    slt x4, x3, x5
    lw x5, 0(x31)
    slli x5, x1, 11
    jal x1, jal_109
    add x2, x5, x3  # Speculative shadow
jal_109:
    jal x2, jal_110
    add x5, x2, x3  # Speculative shadow
jal_110:
    srl x25, x2, x2
    blt x1, x4, branch_111
    add x5, x4, x5  # Speculative shadow
branch_111:
    lw x4, 4(x31)
    lw x5, 0(x31)
    xori x11, x1, -366
    jal x4, jal_112
    add x3, x3, x5  # Speculative shadow
jal_112:
    and x2, x27, x26
    blt x5, x10, branch_113
    add x13, x1, x3  # Speculative shadow
branch_113:
    xor x4, x8, x4
    srli x3, x3, 7
    or x2, x2, x5
    srli x1, x1, 15
    xori x1, x3, 52
    blt x4, x25, branch_114
    add x2, x3, x4  # Speculative shadow
branch_114:
    and x4, x4, x1
    srli x1, x1, 26
    ori x4, x2, 423
    xori x2, x5, 20
    sub x1, x1, x3
    ori x6, x1, 390
    add x18, x25, x10
    lw x3, 0(x31)
    sll x10, x1, x5
    slli x25, x4, 9
    slli x5, x10, 7
    sw x1, 0(x31)
    slt x2, x5, x10
    jal x22, jal_115
    add x4, x1, x2  # Speculative shadow
jal_115:
    beq x16, x3, branch_116
    add x14, x4, x7  # Speculative shadow
branch_116:
    xor x5, x5, x18
    xor x30, x4, x4
    andi x5, x1, -130
    andi x8, x2, -270
    srl x19, x2, x5
    slt x5, x3, x1
    bne x5, x1, branch_117
    add x17, x24, x1  # Speculative shadow
branch_117:
    xor x17, x2, x1
    jal x4, jal_118
    add x16, x1, x3  # Speculative shadow
jal_118:
    lw x4, 0(x31)
    jal x3, jal_119
    add x5, x24, x3  # Speculative shadow
jal_119:
    add x4, x2, x2
    bne x26, x4, branch_120
    add x11, x4, x6  # Speculative shadow
branch_120:
    or x3, x3, x2
    slt x5, x3, x5
    sub x2, x3, x2
    sw x1, 0(x31)
    jal x2, jal_121
    add x5, x5, x3  # Speculative shadow
jal_121:
    sw x24, 0(x31)
    ori x1, x4, 430
    addi x2, x24, -257
    srli x1, x4, 10
    ori x1, x3, 324
    jal x4, jal_122
    add x2, x1, x1  # Speculative shadow
jal_122:
    or x4, x2, x3
    slti x29, x27, 429
    addi x1, x1, 28
    srl x1, x3, x2
    xor x3, x4, x3
    blt x1, x9, branch_123
    add x23, x17, x3  # Speculative shadow
branch_123:
    lw x8, 4(x31)
    add x5, x3, x3
    jal x2, jal_124
    add x5, x1, x8  # Speculative shadow
jal_124:
    or x4, x5, x2
    andi x1, x5, 306
    srl x2, x3, x1
    jal x25, jal_125
    add x4, x24, x4  # Speculative shadow
jal_125:
    blt x2, x1, branch_126
    add x1, x2, x5  # Speculative shadow
branch_126:
    sub x5, x4, x24
    and x2, x3, x4
    xori x3, x5, 179
    slli x4, x2, 29
    xor x2, x3, x4
    jal x3, jal_127
    add x5, x4, x16  # Speculative shadow
jal_127:
    or x25, x19, x28
    add x5, x2, x3
    lw x4, 4(x31)
    beq x5, x4, branch_128
    add x1, x1, x3  # Speculative shadow
branch_128:
    lw x1, 4(x31)
    add x1, x5, x2
    sll x2, x20, x16
    jal x3, jal_129
    add x4, x9, x2  # Speculative shadow
jal_129:
    jal x3, jal_130
    add x10, x3, x1  # Speculative shadow
jal_130:
    blt x1, x5, branch_131
    add x1, x3, x2  # Speculative shadow
branch_131:
    and x5, x5, x1
    bne x2, x2, branch_132
    add x3, x1, x17  # Speculative shadow
branch_132:
    slti x5, x4, -271
    slti x6, x5, 21
    sw x2, 4(x31)
    sll x4, x4, x1
    lw x13, 4(x31)
    sw x9, 0(x31)
    jal x17, jal_133
    add x2, x23, x17  # Speculative shadow
jal_133:
    xor x2, x1, x2
    srl x2, x23, x4
    jal x5, jal_134
    add x28, x1, x1  # Speculative shadow
jal_134:
    slli x8, x2, 17
    jal x24, jal_135
    add x2, x5, x5  # Speculative shadow
jal_135:
    andi x26, x4, -84
    add x2, x2, x3
    sub x1, x19, x4
    jal x4, jal_136
    add x3, x9, x1  # Speculative shadow
jal_136:
    ori x5, x2, -85
    andi x7, x4, -352
    slti x3, x4, 9
    or x5, x2, x4
    slli x2, x6, 26
    jal x4, jal_137
    add x3, x14, x1  # Speculative shadow
jal_137:
    srli x1, x21, 14
    beq x3, x12, branch_138
    add x5, x1, x4  # Speculative shadow
branch_138:
    andi x5, x2, -308
    or x5, x3, x24
    addi x4, x2, -340
    xori x3, x3, -321
    srli x2, x5, 17
    sub x1, x4, x2
    srl x4, x2, x5
    sub x4, x1, x3
    lw x5, 0(x31)
    srli x4, x2, 24
    blt x5, x1, branch_139
    add x5, x2, x5  # Speculative shadow
branch_139:
    slli x1, x1, 5
    or x14, x3, x4
    lw x3, 0(x31)
    xor x4, x16, x17
    xor x3, x20, x4
    slti x5, x28, -326
    or x2, x2, x3
    ori x11, x4, -440
    ori x3, x4, -405
    slli x4, x1, 24
    xor x13, x1, x6
    lw x17, 0(x31)
    or x5, x1, x4
    add x3, x3, x2
    slti x5, x2, -428
    sub x1, x2, x3
    srl x2, x1, x2
    xor x4, x4, x4
    srli x1, x4, 12
    andi x3, x2, -43
    srli x5, x11, 8
    addi x4, x30, -233
    lw x1, 4(x31)
    slt x2, x8, x4
    jal x2, jal_140
    add x18, x4, x4  # Speculative shadow
jal_140:
    blt x4, x3, branch_141
    add x4, x18, x5  # Speculative shadow
branch_141:
    addi x7, x12, -387
    xori x22, x1, 74
    jal x16, jal_142
    add x29, x3, x27  # Speculative shadow
jal_142:
    sll x2, x9, x2
    sw x2, 0(x31)
    jal x3, jal_143
    add x2, x2, x1  # Speculative shadow
jal_143:
    slt x2, x2, x1
    add x4, x2, x23
    slt x10, x13, x4
    add x25, x5, x2
    and x19, x3, x4
    lw x1, 4(x31)
    beq x2, x26, branch_144
    add x18, x4, x4  # Speculative shadow
branch_144:
    slt x4, x11, x2
    srl x2, x3, x1
    sw x3, 4(x31)
    xor x5, x2, x4
    blt x4, x3, branch_145
    add x2, x5, x5  # Speculative shadow
branch_145:
    addi x1, x19, 165
    slti x1, x1, 330
    sub x2, x1, x26
    xori x4, x1, -383
    add x4, x3, x3
    bne x1, x24, branch_146
    add x3, x4, x5  # Speculative shadow
branch_146:
    xori x1, x4, 409
    slli x4, x5, 12
    beq x2, x19, branch_147
    add x26, x3, x20  # Speculative shadow
branch_147:
    jal x3, jal_148
    add x2, x13, x1  # Speculative shadow
jal_148:
    sll x2, x1, x1
    slli x18, x4, 0
    srli x5, x1, 24
    beq x2, x4, branch_149
    add x4, x2, x5  # Speculative shadow
branch_149:
    beq x1, x2, branch_150
    add x8, x1, x2  # Speculative shadow
branch_150:
    slli x23, x2, 13
    lw x1, 0(x31)
    add x3, x12, x2
    lw x7, 4(x31)
    or x26, x3, x4
    slti x2, x5, 423
    lw x18, 4(x31)
    sw x5, 0(x31)
    slt x4, x2, x7
    sub x3, x22, x1
    slti x5, x10, 220
    bne x5, x28, branch_151
    add x18, x5, x2  # Speculative shadow
branch_151:
    srli x3, x3, 12
    add x4, x5, x25
    and x28, x3, x3
    bne x5, x1, branch_152
    add x4, x5, x2  # Speculative shadow
branch_152:
    sll x3, x5, x26
    beq x3, x3, branch_153
    add x4, x3, x1  # Speculative shadow
branch_153:
    sw x5, 4(x31)
    lw x2, 0(x31)
    lw x2, 4(x31)
    blt x5, x7, branch_154
    add x9, x4, x4  # Speculative shadow
branch_154:
    bne x2, x2, branch_155
    add x2, x5, x4  # Speculative shadow
branch_155:
    jal x21, jal_156
    add x1, x5, x1  # Speculative shadow
jal_156:
    lw x16, 0(x31)
    and x5, x3, x22
    add x4, x4, x4
    add x5, x4, x5
    ori x3, x4, 438
    slli x2, x29, 9
    blt x17, x1, branch_157
    add x4, x4, x2  # Speculative shadow
branch_157:
    blt x22, x1, branch_158
    add x2, x25, x4  # Speculative shadow
branch_158:
    slt x3, x25, x2
    jal x2, jal_159
    add x4, x5, x4  # Speculative shadow
jal_159:
    bne x2, x2, branch_160
    add x5, x4, x17  # Speculative shadow
branch_160:
    sll x3, x3, x5
    jal x5, jal_161
    add x2, x1, x4  # Speculative shadow
jal_161:
    lw x2, 4(x31)
    srli x28, x1, 5
    andi x2, x11, 332
    slt x2, x5, x16
    xor x3, x5, x1
    and x2, x3, x3
    jal x4, jal_162
    add x21, x1, x5  # Speculative shadow
jal_162:
    blt x3, x8, branch_163
    add x3, x1, x17  # Speculative shadow
branch_163:
    add x2, x1, x2
    slti x4, x21, -365
    sub x3, x5, x25
    xor x1, x22, x4
    beq x3, x3, branch_164
    add x5, x10, x2  # Speculative shadow
branch_164:
    srli x12, x1, 3
    beq x2, x1, branch_165
    add x2, x4, x11  # Speculative shadow
branch_165:
    blt x3, x3, branch_166
    add x4, x1, x4  # Speculative shadow
branch_166:
    sll x3, x1, x3
    jal x5, jal_167
    add x5, x3, x5  # Speculative shadow
jal_167:
    and x4, x3, x5
    sll x2, x2, x3
    and x4, x2, x25
    srli x2, x4, 19
    srl x2, x4, x14
    sll x2, x3, x4
    beq x12, x5, branch_168
    add x4, x7, x19  # Speculative shadow
branch_168:
    xori x8, x1, -494
    blt x2, x20, branch_169
    add x3, x5, x23  # Speculative shadow
branch_169:
    ori x5, x1, 207
    sub x2, x26, x5
    slti x5, x3, 26
    sll x30, x4, x3
    ori x1, x5, 507
    srli x3, x2, 13
    andi x1, x3, 309
    lw x2, 0(x31)
    lw x4, 4(x31)
    bne x16, x1, branch_170
    add x3, x17, x3  # Speculative shadow
branch_170:
    beq x5, x5, branch_171
    add x1, x5, x1  # Speculative shadow
branch_171:
    slt x1, x1, x4
    andi x18, x27, -145
    or x1, x5, x23
    ori x2, x4, -371
    addi x9, x3, -437
    lw x3, 0(x31)
    xori x4, x1, -412
    or x2, x3, x2
    sub x2, x4, x12
    slti x2, x5, 475
    and x3, x2, x5
    addi x19, x4, 116
    sw x1, 0(x31)
    lw x2, 4(x31)
    addi x4, x14, 244
    and x3, x2, x1
    addi x1, x12, -279
    beq x5, x4, branch_172
    add x16, x3, x4  # Speculative shadow
branch_172:
    jal x5, jal_173
    add x26, x25, x4  # Speculative shadow
jal_173:
    and x2, x5, x5
    sub x2, x20, x3
    sub x1, x2, x2
    add x5, x4, x1
    slli x1, x1, 17
    sw x4, 0(x31)
    jal x5, jal_174
    add x2, x1, x11  # Speculative shadow
jal_174:
    and x5, x18, x4
    sw x5, 4(x31)
    and x2, x6, x5
    slt x12, x13, x20
    or x8, x5, x5
    srli x2, x3, 28
    slt x5, x4, x18
    sll x23, x2, x5
    xor x5, x5, x2
    jal x5, jal_175
    add x4, x1, x4  # Speculative shadow
jal_175:
    or x21, x4, x4
    slti x1, x14, 206
    and x4, x15, x4
    slt x9, x3, x2
    beq x5, x1, branch_176
    add x1, x2, x1  # Speculative shadow
branch_176:
    srli x5, x5, 22
    sw x3, 4(x31)
    sub x3, x3, x1
    jal x5, jal_177
    add x2, x3, x2  # Speculative shadow
jal_177:
    bne x5, x13, branch_178
    add x2, x3, x3  # Speculative shadow
branch_178:
    sw x3, 0(x31)
    bne x5, x5, branch_179
    add x3, x3, x10  # Speculative shadow
branch_179:
    sw x2, 0(x31)
    slt x3, x2, x1
    beq x3, x16, branch_180
    add x2, x24, x3  # Speculative shadow
branch_180:
    lw x2, 0(x31)
    addi x1, x5, 37
    addi x3, x8, -333
    slti x6, x18, -500
    sll x3, x6, x5
    slti x3, x4, 307
    slt x5, x1, x29
    srli x1, x9, 1
    jal x1, jal_181
    add x2, x2, x3  # Speculative shadow
jal_181:
    andi x4, x2, -463
    add x1, x10, x5
    lw x4, 0(x31)
    srli x4, x3, 10
    beq x1, x3, branch_182
    add x5, x3, x26  # Speculative shadow
branch_182:
    slti x12, x3, 504
    sub x4, x4, x3
    lw x5, 0(x31)
    slt x4, x5, x5
    srli x10, x5, 4
    sll x2, x4, x3
    xori x4, x2, 371
    lw x5, 0(x31)
    and x30, x2, x1
    beq x2, x2, branch_183
    add x5, x4, x26  # Speculative shadow
branch_183:
    andi x1, x2, 474
    sll x3, x3, x1
    addi x5, x3, -358
    jal x7, jal_184
    add x5, x2, x1  # Speculative shadow
jal_184:
    xori x5, x18, -70
    addi x3, x3, 438
    add x4, x5, x1
    jal x6, jal_185
    add x7, x14, x4  # Speculative shadow
jal_185:
    xori x3, x2, 67
    lw x3, 4(x31)
    blt x2, x5, branch_186
    add x2, x2, x3  # Speculative shadow
branch_186:
    lw x1, 4(x31)
    sw x5, 4(x31)
    jal x5, jal_187
    add x2, x20, x3  # Speculative shadow
jal_187:
    bne x2, x2, branch_188
    add x4, x1, x5  # Speculative shadow
branch_188:
    slt x16, x5, x1
    xori x1, x3, -448
    addi x4, x4, -3
    sw x2, 0(x31)
    srli x1, x10, 19
    blt x22, x1, branch_189
    add x29, x3, x1  # Speculative shadow
branch_189:
    slli x2, x2, 29
    sub x15, x4, x1
    lw x3, 0(x31)
    srl x3, x3, x1
    slt x1, x3, x19
    slti x1, x5, -237
    beq x4, x1, branch_190
    add x5, x4, x1  # Speculative shadow
branch_190:
    addi x1, x26, -163
    srl x5, x2, x4
    slli x1, x4, 26
    sll x18, x2, x18
    or x3, x3, x1
    slt x4, x1, x1
    and x5, x4, x17
    and x1, x3, x3
    jal x25, jal_191
    add x2, x3, x3  # Speculative shadow
jal_191:
    beq x4, x2, branch_192
    add x7, x2, x4  # Speculative shadow
branch_192:
    addi x5, x5, 354
    slt x18, x5, x4
    xori x1, x10, -332
    sw x26, 0(x31)
    sub x3, x5, x2
    jal x4, jal_193
    add x1, x5, x2  # Speculative shadow
jal_193:
    jal x1, jal_194
    add x4, x5, x4  # Speculative shadow
jal_194:
    blt x6, x5, branch_195
    add x2, x12, x5  # Speculative shadow
branch_195:
    jal x1, jal_196
    add x3, x1, x1  # Speculative shadow
jal_196:
    sw x1, 4(x31)
    addi x3, x5, -424
    slli x1, x3, 25
    add x5, x3, x2
    jal x4, jal_197
    add x4, x1, x4  # Speculative shadow
jal_197:
    beq x23, x2, branch_198
    add x20, x1, x5  # Speculative shadow
branch_198:
end_loop:
    j end_loop