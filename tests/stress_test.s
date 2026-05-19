/* ===========================================================
   CSITSS 2026: HYBRID VERIFICATION METADATA REPORT
   ===========================================================
   Total Random Instructions    : 1000
   Data Ops (R/I/Shift/Mem)     : 598
   Legal Shift OPs (0-31 imm)   : 89
   Branches & Jumps             : 186
   Targeted Microbenchmarks     : ENABLED (Load-Use, Dual-Fwd, BHT Oscillation)
=========================================================== */
.data
    safe_mem: .space 1024
.text
.global _start
_start:
    addi x1, x0, 10
    addi x2, x0, 20
    addi x3, x0, 30
    addi x4, x0, 40
    addi x5, x0, 50
    la x31, safe_mem
    # ==========================================
    # PHASE 1: DIRECTED MICROBENCHMARKS
    # ==========================================

    # MICROBENCHMARK A: Worst-Case Load-Use Chains
    # Forces back-to-back stall logic evaluation
    lw x1, 0(x31)
    add x2, x1, x1      # Stall required
    lw x3, 4(x31)
    sub x4, x3, x3      # Stall required

    # MICROBENCHMARK B: Simultaneous Dual-Source Forwarding
    # Forces the forwarding mux to bypass from two different stages simultaneously
    addi x1, x0, 10     # WB stage in 2 cycles
    addi x2, x0, 20     # MEM stage in 1 cycle
    add x3, x1, x2      # Needs Fwd_A from WB, Fwd_B from MEM

    # MICROBENCHMARK C: Predictor-Adversarial Pattern (Oscillation)
    # Alternates T/NT/T/NT to stress hysteresis and convergence in a 2-bit BHT
    addi x10, x0, 4     # Loop counter
adv_loop:
    addi x11, x0, 1
    beq x11, x0, skip_oscillation  # Always Not-Taken
skip_oscillation:
    addi x10, x10, -1
    bne x10, x0, adv_loop          # Always Taken (until end)
    # ==========================================
    # PHASE 2: RANDOMIZED STRESS TEST
    # ==========================================

    bltu x5, x1, branch_target_0
    add x1, x1, x1  # Speculative shadow
branch_target_0:
    sltu x5, x5, x5
    or x6, x2, x11
    add x1, x2, x5
    blt x17, x3, branch_target_1
    add x5, x1, x17  # Speculative shadow
branch_target_1:
    slti x1, x2, -1730
    sltu x5, x2, x9
    sltiu x4, x2, 780
    srai x3, x3, 20
    sw x4, 952(x31)
    bne x12, x3, branch_target_2
    add x30, x4, x14  # Speculative shadow
branch_target_2:
    slli x29, x9, 10
    srli x5, x23, 15
    and x4, x1, x4
    sub x1, x3, x3
    add x2, x25, x20
    sw x4, 304(x31)
    lw x15, 52(x31)
    sw x4, 524(x31)
    lw x4, 492(x31)
    or x13, x1, x5
    xor x3, x1, x9
    xor x1, x1, x19
    bgeu x3, x2, branch_target_3
    add x3, x2, x1  # Speculative shadow
branch_target_3:
    slli x5, x2, 2
    lw x3, 224(x31)
    lw x3, 588(x31)
    bgeu x5, x1, branch_target_4
    add x24, x5, x5  # Speculative shadow
branch_target_4:
    sw x3, 996(x31)
    or x30, x30, x1
    bge x18, x1, branch_target_5
    add x5, x5, x5  # Speculative shadow
branch_target_5:
    add x4, x5, x4
    or x2, x10, x2
    xor x5, x2, x5
    andi x29, x19, -836
    la x5, jalr_target_6
    jalr x5, x5, 0
    add x2, x3, x1  # Speculative shadow
jalr_target_6:
    slti x3, x4, -1442
    sw x5, 796(x31)
    lw x3, 488(x31)
    jal x2, jal_target_7
    add x4, x3, x4  # Speculative shadow
jal_target_7:
    xor x2, x2, x20
    or x27, x3, x2
    jal x1, jal_target_8
    add x4, x5, x4  # Speculative shadow
jal_target_8:
    srli x2, x3, 17
    srli x4, x2, 31
    sltu x3, x3, x3
    sub x4, x3, x2
    slt x1, x2, x2
    lw x4, 724(x31)
    and x3, x1, x3
    sw x2, 412(x31)
    beq x4, x1, branch_target_9
    add x15, x7, x5  # Speculative shadow
branch_target_9:
    srai x3, x3, 26
    add x3, x2, x5
    andi x4, x20, -1003
    ori x12, x16, 451
    beq x16, x4, branch_target_10
    add x4, x1, x1  # Speculative shadow
branch_target_10:
    jal x5, jal_target_11
    add x1, x2, x2  # Speculative shadow
jal_target_11:
    sltiu x1, x5, -1626
    slt x5, x4, x24
    la x4, jalr_target_12
    jalr x23, x4, 0
    add x4, x2, x15  # Speculative shadow
jalr_target_12:
    sub x5, x1, x3
    jal x3, jal_target_13
    add x2, x2, x5  # Speculative shadow
jal_target_13:
    bltu x2, x3, branch_target_14
    add x2, x1, x4  # Speculative shadow
branch_target_14:
    add x18, x4, x3
    bgeu x4, x22, branch_target_15
    add x2, x3, x3  # Speculative shadow
branch_target_15:
    and x3, x2, x23
    bge x22, x22, branch_target_16
    add x5, x6, x2  # Speculative shadow
branch_target_16:
    lw x26, 792(x31)
    or x1, x1, x14
    bltu x2, x4, branch_target_17
    add x2, x28, x2  # Speculative shadow
branch_target_17:
    la x2, jalr_target_18
    jalr x2, x2, 0
    add x3, x2, x5  # Speculative shadow
jalr_target_18:
    sltiu x4, x9, -1478
    bgeu x5, x5, branch_target_19
    add x3, x3, x4  # Speculative shadow
branch_target_19:
    la x2, jalr_target_20
    jalr x5, x2, 0
    add x3, x4, x3  # Speculative shadow
jalr_target_20:
    sub x1, x3, x1
    lw x5, 636(x31)
    srli x2, x3, 28
    beq x2, x1, branch_target_21
    add x1, x6, x2  # Speculative shadow
branch_target_21:
    bltu x18, x2, branch_target_22
    add x5, x4, x2  # Speculative shadow
branch_target_22:
    slli x2, x13, 28
    xori x1, x2, 231
    bltu x5, x2, branch_target_23
    add x2, x5, x3  # Speculative shadow
branch_target_23:
    addi x4, x4, 1028
    ori x2, x3, -163
    slt x4, x3, x1
    xori x1, x3, -1588
    sltu x3, x1, x5
    sw x4, 476(x31)
    xor x9, x13, x2
    and x3, x2, x3
    slti x12, x11, -1710
    ori x2, x5, 476
    andi x5, x22, -32
    or x3, x2, x1
    sltu x2, x20, x2
    sltiu x21, x5, -198
    bltu x3, x4, branch_target_24
    add x4, x28, x5  # Speculative shadow
branch_target_24:
    sltu x12, x3, x3
    bltu x28, x5, branch_target_25
    add x5, x6, x1  # Speculative shadow
branch_target_25:
    bgeu x1, x2, branch_target_26
    add x5, x2, x2  # Speculative shadow
branch_target_26:
    sw x1, 364(x31)
    or x4, x5, x24
    xor x4, x26, x3
    slli x3, x6, 3
    xor x21, x4, x5
    bne x2, x2, branch_target_27
    add x6, x26, x2  # Speculative shadow
branch_target_27:
    beq x2, x5, branch_target_28
    add x2, x10, x27  # Speculative shadow
branch_target_28:
    bgeu x10, x2, branch_target_29
    add x4, x3, x1  # Speculative shadow
branch_target_29:
    slti x4, x1, 1001
    la x1, jalr_target_30
    jalr x3, x1, 0
    add x1, x2, x5  # Speculative shadow
jalr_target_30:
    xori x2, x5, 811
    bge x2, x3, branch_target_31
    add x15, x1, x8  # Speculative shadow
branch_target_31:
    lw x1, 244(x31)
    la x5, jalr_target_32
    jalr x4, x5, 0
    add x3, x2, x4  # Speculative shadow
jalr_target_32:
    srli x5, x2, 0
    sltiu x9, x1, 837
    slli x1, x23, 16
    slli x2, x30, 18
    jal x4, jal_target_33
    add x4, x1, x1  # Speculative shadow
jal_target_33:
    sltiu x20, x5, 398
    or x10, x3, x2
    add x3, x5, x1
    slt x4, x24, x5
    add x1, x2, x21
    srli x27, x2, 19
    xor x1, x18, x1
    sub x23, x5, x30
    or x3, x3, x1
    srai x5, x3, 12
    sltiu x2, x3, -1403
    lw x1, 344(x31)
    sltu x5, x2, x1
    la x3, jalr_target_34
    jalr x4, x3, 0
    add x4, x5, x1  # Speculative shadow
jalr_target_34:
    xor x1, x4, x12
    slt x5, x3, x3
    or x5, x5, x5
    blt x1, x30, branch_target_35
    add x16, x1, x24  # Speculative shadow
branch_target_35:
    or x12, x3, x3
    slt x2, x3, x1
    sltiu x1, x3, -773
    xor x27, x4, x4
    add x3, x5, x2
    ori x3, x3, -221
    la x2, jalr_target_36
    jalr x4, x2, 0
    add x2, x1, x5  # Speculative shadow
jalr_target_36:
    or x5, x3, x2
    bge x3, x5, branch_target_37
    add x4, x3, x4  # Speculative shadow
branch_target_37:
    sltu x18, x15, x3
    xor x1, x5, x30
    xori x4, x4, 1916
    bgeu x2, x5, branch_target_38
    add x3, x1, x3  # Speculative shadow
branch_target_38:
    slt x4, x1, x1
    sw x3, 292(x31)
    sw x7, 64(x31)
    and x3, x1, x1
    slti x1, x1, -1566
    srli x3, x2, 23
    slli x2, x3, 11
    sw x5, 596(x31)
    addi x30, x3, -281
    jal x2, jal_target_39
    add x8, x2, x10  # Speculative shadow
jal_target_39:
    srai x4, x5, 28
    xori x1, x1, -1483
    jal x1, jal_target_40
    add x5, x2, x1  # Speculative shadow
jal_target_40:
    xori x1, x4, 183
    bgeu x3, x2, branch_target_41
    add x2, x2, x1  # Speculative shadow
branch_target_41:
    and x3, x3, x4
    ori x2, x3, 314
    and x26, x5, x9
    slli x26, x4, 14
    lw x27, 32(x31)
    bge x29, x1, branch_target_42
    add x7, x1, x4  # Speculative shadow
branch_target_42:
    lw x2, 1008(x31)
    sw x1, 1016(x31)
    xor x26, x2, x3
    andi x5, x1, -142
    sw x2, 756(x31)
    sw x4, 80(x31)
    bne x5, x29, branch_target_43
    add x1, x4, x1  # Speculative shadow
branch_target_43:
    slli x23, x5, 23
    jal x24, jal_target_44
    add x3, x3, x5  # Speculative shadow
jal_target_44:
    slt x3, x10, x2
    lw x4, 692(x31)
    lw x4, 64(x31)
    slt x2, x4, x2
    la x1, jalr_target_45
    jalr x2, x1, 0
    add x5, x27, x4  # Speculative shadow
jalr_target_45:
    lw x1, 612(x31)
    ori x4, x4, 172
    srli x2, x29, 0
    and x3, x4, x5
    blt x3, x3, branch_target_46
    add x1, x4, x2  # Speculative shadow
branch_target_46:
    bltu x5, x5, branch_target_47
    add x3, x5, x2  # Speculative shadow
branch_target_47:
    srli x5, x21, 8
    or x29, x23, x2
    add x1, x1, x12
    addi x18, x15, -1110
    xori x3, x23, 1268
    sltu x2, x4, x2
    bltu x5, x19, branch_target_48
    add x1, x4, x1  # Speculative shadow
branch_target_48:
    addi x2, x11, 185
    xor x4, x1, x2
    lw x4, 568(x31)
    srai x4, x5, 28
    sub x3, x2, x21
    bgeu x3, x5, branch_target_49
    add x1, x4, x7  # Speculative shadow
branch_target_49:
    slt x17, x5, x25
    add x2, x13, x16
    xori x17, x4, 1995
    srli x22, x5, 2
    beq x4, x3, branch_target_50
    add x17, x1, x4  # Speculative shadow
branch_target_50:
    sltu x4, x1, x27
    bne x2, x1, branch_target_51
    add x5, x27, x3  # Speculative shadow
branch_target_51:
    jal x1, jal_target_52
    add x28, x3, x3  # Speculative shadow
jal_target_52:
    addi x4, x5, 711
    slti x3, x5, -1198
    srai x2, x1, 14
    addi x5, x3, -1628
    srai x25, x2, 16
    addi x30, x1, 1892
    add x4, x1, x2
    or x7, x2, x2
    andi x4, x2, 555
    lw x4, 336(x31)
    sltu x1, x3, x23
    xor x3, x3, x5
    bne x5, x3, branch_target_53
    add x19, x5, x4  # Speculative shadow
branch_target_53:
    sltu x1, x23, x17
    andi x4, x1, -1661
    la x5, jalr_target_54
    jalr x5, x5, 0
    add x5, x2, x1  # Speculative shadow
jalr_target_54:
    lw x1, 464(x31)
    lw x5, 0(x31)
    slti x2, x4, -1318
    beq x30, x3, branch_target_55
    add x4, x5, x4  # Speculative shadow
branch_target_55:
    slti x5, x30, -201
    add x3, x10, x1
    add x1, x24, x4
    and x2, x4, x5
    sub x1, x4, x3
    ori x1, x1, -226
    andi x2, x5, -1234
    sltu x1, x4, x28
    bge x3, x4, branch_target_56
    add x1, x5, x1  # Speculative shadow
branch_target_56:
    slt x5, x21, x18
    blt x2, x4, branch_target_57
    add x5, x2, x2  # Speculative shadow
branch_target_57:
    xori x3, x4, -584
    srai x14, x4, 25
    bne x1, x2, branch_target_58
    add x3, x5, x4  # Speculative shadow
branch_target_58:
    slti x3, x5, -152
    lw x18, 216(x31)
    addi x5, x1, 1705
    xori x3, x2, -1618
    and x1, x15, x4
    or x5, x25, x5
    slti x4, x3, 692
    slti x4, x1, -1448
    srai x3, x10, 3
    slti x5, x24, 327
    addi x4, x5, 1936
    sw x5, 748(x31)
    srli x4, x5, 7
    jal x5, jal_target_59
    add x28, x3, x1  # Speculative shadow
jal_target_59:
    bgeu x1, x5, branch_target_60
    add x4, x12, x15  # Speculative shadow
branch_target_60:
    sltiu x10, x1, -32
    la x1, jalr_target_61
    jalr x1, x1, 0
    add x29, x4, x4  # Speculative shadow
jalr_target_61:
    lw x5, 204(x31)
    bltu x2, x4, branch_target_62
    add x4, x5, x2  # Speculative shadow
branch_target_62:
    slli x17, x2, 26
    slt x4, x4, x3
    srai x3, x3, 12
    sltiu x3, x4, -652
    slt x1, x2, x11
    addi x1, x2, 1171
    sltiu x4, x3, 787
    sw x3, 112(x31)
    sub x5, x3, x21
    blt x5, x5, branch_target_63
    add x2, x2, x1  # Speculative shadow
branch_target_63:
    and x14, x4, x2
    slt x3, x12, x2
    jal x3, jal_target_64
    add x3, x3, x4  # Speculative shadow
jal_target_64:
    sltu x3, x4, x4
    lw x4, 372(x31)
    sw x3, 744(x31)
    blt x5, x8, branch_target_65
    add x2, x2, x1  # Speculative shadow
branch_target_65:
    add x4, x2, x1
    bge x3, x27, branch_target_66
    add x6, x3, x3  # Speculative shadow
branch_target_66:
    xori x1, x5, -1836
    xor x26, x1, x4
    xori x4, x3, -318
    lw x1, 876(x31)
    slli x3, x5, 21
    sw x5, 304(x31)
    slti x14, x11, -400
    la x5, jalr_target_67
    jalr x1, x5, 0
    add x5, x2, x2  # Speculative shadow
jalr_target_67:
    srai x1, x4, 12
    slli x22, x2, 10
    xor x5, x5, x4
    srli x2, x5, 5
    ori x1, x12, 337
    add x4, x3, x1
    slli x5, x4, 30
    srai x4, x4, 6
    ori x4, x3, 786
    or x12, x2, x5
    sub x3, x1, x1
    beq x1, x2, branch_target_68
    add x3, x3, x2  # Speculative shadow
branch_target_68:
    xor x5, x2, x2
    sltiu x4, x2, 1221
    slti x1, x4, -553
    ori x16, x3, 1417
    lw x4, 40(x31)
    sltu x3, x5, x5
    srai x5, x1, 8
    bltu x3, x3, branch_target_69
    add x27, x3, x20  # Speculative shadow
branch_target_69:
    sw x3, 716(x31)
    xor x20, x4, x5
    and x5, x16, x4
    beq x23, x5, branch_target_70
    add x28, x3, x1  # Speculative shadow
branch_target_70:
    add x4, x2, x4
    add x5, x1, x1
    sw x2, 796(x31)
    slti x5, x1, -775
    la x3, jalr_target_71
    jalr x4, x3, 0
    add x4, x3, x1  # Speculative shadow
jalr_target_71:
    xor x1, x4, x2
    sub x5, x5, x4
    and x4, x18, x4
    sltu x5, x22, x4
    jal x1, jal_target_72
    add x8, x2, x5  # Speculative shadow
jal_target_72:
    slti x4, x1, -1154
    and x1, x4, x2
    jal x5, jal_target_73
    add x3, x5, x4  # Speculative shadow
jal_target_73:
    sub x5, x3, x2
    sw x1, 1008(x31)
    or x1, x3, x3
    srli x2, x3, 29
    jal x9, jal_target_74
    add x25, x10, x3  # Speculative shadow
jal_target_74:
    andi x4, x3, -1082
    sltu x2, x2, x5
    ori x5, x5, -1745
    jal x5, jal_target_75
    add x1, x4, x4  # Speculative shadow
jal_target_75:
    addi x2, x2, 2024
    and x4, x3, x27
    or x2, x15, x2
    sltiu x1, x5, 1958
    sltiu x5, x4, -1340
    bgeu x5, x3, branch_target_76
    add x5, x4, x5  # Speculative shadow
branch_target_76:
    sub x14, x5, x16
    slli x27, x1, 24
    add x1, x16, x2
    ori x27, x4, -665
    xor x2, x2, x3
    add x5, x17, x26
    xori x1, x1, -2013
    bltu x2, x1, branch_target_77
    add x4, x1, x1  # Speculative shadow
branch_target_77:
    sltiu x4, x2, -1785
    or x3, x2, x3
    xori x2, x29, 135
    la x3, jalr_target_78
    jalr x2, x3, 0
    add x23, x4, x4  # Speculative shadow
jalr_target_78:
    sltu x2, x1, x4
    bne x27, x5, branch_target_79
    add x4, x11, x3  # Speculative shadow
branch_target_79:
    slli x7, x3, 1
    bgeu x5, x4, branch_target_80
    add x4, x1, x5  # Speculative shadow
branch_target_80:
    slti x5, x5, -303
    la x5, jalr_target_81
    jalr x4, x5, 0
    add x5, x13, x5  # Speculative shadow
jalr_target_81:
    lw x1, 844(x31)
    sltu x24, x19, x5
    beq x5, x3, branch_target_82
    add x3, x3, x1  # Speculative shadow
branch_target_82:
    slt x5, x2, x19
    lw x23, 424(x31)
    srai x30, x1, 13
    lw x5, 680(x31)
    jal x3, jal_target_83
    add x4, x4, x1  # Speculative shadow
jal_target_83:
    andi x1, x5, 377
    xor x5, x29, x1
    jal x25, jal_target_84
    add x5, x2, x2  # Speculative shadow
jal_target_84:
    lw x1, 716(x31)
    xor x1, x2, x20
    slt x24, x2, x3
    jal x5, jal_target_85
    add x5, x4, x3  # Speculative shadow
jal_target_85:
    sub x21, x4, x5
    srli x24, x7, 18
    lw x3, 684(x31)
    xori x1, x1, -1469
    or x4, x5, x19
    blt x1, x2, branch_target_86
    add x1, x1, x3  # Speculative shadow
branch_target_86:
    srai x3, x5, 17
    srli x3, x4, 1
    slli x5, x3, 12
    la x1, jalr_target_87
    jalr x2, x1, 0
    add x30, x13, x1  # Speculative shadow
jalr_target_87:
    add x1, x1, x2
    la x2, jalr_target_88
    jalr x4, x2, 0
    add x23, x3, x3  # Speculative shadow
jalr_target_88:
    jal x3, jal_target_89
    add x16, x5, x2  # Speculative shadow
jal_target_89:
    slli x2, x30, 15
    bltu x4, x4, branch_target_90
    add x1, x18, x5  # Speculative shadow
branch_target_90:
    ori x4, x3, -1964
    sltiu x5, x13, 727
    xor x29, x7, x2
    sltiu x4, x1, -1692
    la x4, jalr_target_91
    jalr x2, x4, 0
    add x4, x1, x4  # Speculative shadow
jalr_target_91:
    sw x3, 364(x31)
    bge x4, x12, branch_target_92
    add x5, x5, x5  # Speculative shadow
branch_target_92:
    addi x3, x5, 1520
    lw x4, 228(x31)
    or x27, x2, x4
    slti x3, x2, -1955
    slt x4, x3, x2
    slti x4, x3, 1927
    slti x5, x6, -771
    sltu x4, x3, x2
    andi x1, x6, -442
    slli x5, x27, 24
    bge x3, x26, branch_target_93
    add x3, x2, x1  # Speculative shadow
branch_target_93:
    lw x4, 160(x31)
    slt x1, x1, x5
    slt x1, x10, x2
    lw x3, 644(x31)
    lw x9, 152(x31)
    add x5, x1, x4
    jal x4, jal_target_94
    add x1, x7, x4  # Speculative shadow
jal_target_94:
    xor x2, x2, x3
    sw x4, 676(x31)
    addi x4, x6, 319
    la x5, jalr_target_95
    jalr x4, x5, 0
    add x2, x8, x4  # Speculative shadow
jalr_target_95:
    or x2, x2, x3
    bgeu x1, x3, branch_target_96
    add x3, x4, x1  # Speculative shadow
branch_target_96:
    sltiu x13, x8, 1996
    andi x5, x17, -1715
    jal x1, jal_target_97
    add x4, x26, x2  # Speculative shadow
jal_target_97:
    sltu x2, x5, x1
    xori x4, x10, 1589
    srai x4, x2, 23
    bgeu x2, x4, branch_target_98
    add x5, x2, x22  # Speculative shadow
branch_target_98:
    andi x5, x5, -1091
    sw x5, 392(x31)
    bne x11, x2, branch_target_99
    add x6, x5, x12  # Speculative shadow
branch_target_99:
    bltu x1, x17, branch_target_100
    add x17, x28, x5  # Speculative shadow
branch_target_100:
    sltu x4, x2, x1
    slti x12, x3, -519
    and x3, x1, x4
    ori x5, x4, -1890
    or x4, x2, x4
    srai x3, x2, 11
    bge x24, x2, branch_target_101
    add x27, x1, x3  # Speculative shadow
branch_target_101:
    lw x5, 260(x31)
    andi x3, x1, -1934
    addi x5, x25, 2028
    xori x1, x2, -1971
    sltu x19, x3, x4
    beq x1, x3, branch_target_102
    add x1, x2, x4  # Speculative shadow
branch_target_102:
    sltiu x2, x2, -494
    or x3, x3, x5
    srli x2, x2, 25
    srai x30, x5, 4
    srai x19, x3, 12
    jal x1, jal_target_103
    add x3, x12, x5  # Speculative shadow
jal_target_103:
    sltu x5, x5, x3
    blt x10, x5, branch_target_104
    add x3, x5, x1  # Speculative shadow
branch_target_104:
    lw x1, 436(x31)
    bgeu x3, x21, branch_target_105
    add x1, x2, x4  # Speculative shadow
branch_target_105:
    sub x3, x3, x5
    xori x15, x3, 1
    xor x5, x4, x3
    jal x4, jal_target_106
    add x1, x2, x3  # Speculative shadow
jal_target_106:
    ori x16, x5, -1428
    andi x3, x4, 166
    srai x6, x5, 25
    lw x4, 188(x31)
    or x18, x3, x4
    srai x4, x1, 13
    slli x4, x5, 26
    sw x2, 332(x31)
    sltu x17, x13, x1
    sub x23, x29, x1
    lw x5, 700(x31)
    srai x4, x5, 7
    slti x25, x17, -1125
    add x13, x2, x2
    sltu x1, x17, x25
    srli x5, x5, 10
    sw x5, 356(x31)
    sltu x21, x2, x2
    sltiu x3, x5, 1557
    sltiu x12, x3, -1157
    beq x3, x16, branch_target_107
    add x1, x29, x18  # Speculative shadow
branch_target_107:
    andi x2, x1, -1937
    xor x3, x3, x5
    andi x1, x1, -1115
    sw x2, 144(x31)
    slt x2, x4, x2
    or x4, x30, x4
    srai x2, x3, 22
    sw x3, 12(x31)
    la x4, jalr_target_108
    jalr x1, x4, 0
    add x2, x8, x24  # Speculative shadow
jalr_target_108:
    addi x25, x5, -1769
    add x5, x22, x2
    sw x2, 632(x31)
    jal x3, jal_target_109
    add x5, x4, x2  # Speculative shadow
jal_target_109:
    bne x1, x14, branch_target_110
    add x3, x5, x4  # Speculative shadow
branch_target_110:
    addi x3, x5, -1069
    slt x15, x3, x20
    sub x4, x2, x4
    jal x1, jal_target_111
    add x4, x5, x5  # Speculative shadow
jal_target_111:
    sltiu x1, x10, -1913
    beq x5, x4, branch_target_112
    add x2, x3, x28  # Speculative shadow
branch_target_112:
    sw x1, 888(x31)
    addi x2, x2, -803
    srai x11, x3, 1
    slt x18, x5, x2
    slli x2, x7, 0
    srai x4, x25, 26
    sw x4, 256(x31)
    sw x2, 188(x31)
    bge x14, x4, branch_target_113
    add x5, x4, x4  # Speculative shadow
branch_target_113:
    la x2, jalr_target_114
    jalr x5, x2, 0
    add x3, x4, x2  # Speculative shadow
jalr_target_114:
    add x3, x4, x3
    jal x2, jal_target_115
    add x2, x1, x8  # Speculative shadow
jal_target_115:
    srli x26, x5, 10
    jal x30, jal_target_116
    add x14, x2, x3  # Speculative shadow
jal_target_116:
    sw x1, 472(x31)
    slti x4, x3, 1085
    xori x5, x2, 418
    bltu x4, x3, branch_target_117
    add x5, x4, x22  # Speculative shadow
branch_target_117:
    slti x4, x3, 1274
    sltu x3, x14, x4
    sub x14, x1, x1
    andi x20, x3, 333
    bge x5, x4, branch_target_118
    add x24, x11, x4  # Speculative shadow
branch_target_118:
    sw x3, 512(x31)
    sltiu x5, x5, 810
    srli x3, x3, 30
    xor x4, x4, x2
    xor x26, x4, x10
    lw x1, 968(x31)
    sub x4, x5, x3
    lw x4, 464(x31)
    bne x3, x2, branch_target_119
    add x3, x2, x3  # Speculative shadow
branch_target_119:
    ori x5, x1, -1950
    sltu x3, x5, x1
    srli x27, x1, 26
    sltiu x3, x5, -754
    ori x4, x2, 325
    bne x4, x24, branch_target_120
    add x5, x29, x5  # Speculative shadow
branch_target_120:
    xor x30, x1, x2
    lw x4, 684(x31)
    and x4, x4, x4
    lw x3, 524(x31)
    andi x3, x3, 1029
    bge x5, x4, branch_target_121
    add x6, x1, x3  # Speculative shadow
branch_target_121:
    ori x16, x1, -252
    bge x2, x4, branch_target_122
    add x4, x23, x5  # Speculative shadow
branch_target_122:
    sub x5, x5, x8
    and x1, x1, x5
    jal x1, jal_target_123
    add x4, x2, x4  # Speculative shadow
jal_target_123:
    jal x5, jal_target_124
    add x4, x1, x3  # Speculative shadow
jal_target_124:
    sw x1, 284(x31)
    sltiu x3, x4, 499
    srai x4, x1, 6
    slti x4, x12, -660
    lw x3, 852(x31)
    bge x5, x1, branch_target_125
    add x5, x4, x25  # Speculative shadow
branch_target_125:
    srai x29, x5, 31
    beq x11, x1, branch_target_126
    add x2, x2, x1  # Speculative shadow
branch_target_126:
    bge x20, x24, branch_target_127
    add x5, x1, x10  # Speculative shadow
branch_target_127:
    bne x3, x4, branch_target_128
    add x17, x3, x17  # Speculative shadow
branch_target_128:
    or x3, x5, x4
    sltu x2, x2, x5
    ori x2, x4, 1024
    sw x3, 324(x31)
    sltu x22, x5, x1
    xor x5, x25, x2
    or x4, x1, x1
    sw x26, 524(x31)
    sltu x1, x3, x4
    and x1, x1, x4
    lw x8, 208(x31)
    bne x1, x2, branch_target_129
    add x25, x1, x2  # Speculative shadow
branch_target_129:
    jal x3, jal_target_130
    add x2, x3, x4  # Speculative shadow
jal_target_130:
    la x2, jalr_target_131
    jalr x3, x2, 0
    add x7, x2, x3  # Speculative shadow
jalr_target_131:
    bgeu x1, x3, branch_target_132
    add x4, x27, x20  # Speculative shadow
branch_target_132:
    beq x11, x4, branch_target_133
    add x4, x28, x3  # Speculative shadow
branch_target_133:
    la x2, jalr_target_134
    jalr x5, x2, 0
    add x3, x14, x5  # Speculative shadow
jalr_target_134:
    ori x5, x4, -1286
    srai x4, x2, 16
    or x1, x3, x3
    andi x4, x3, 1206
    sltu x1, x4, x4
    ori x19, x1, 219
    add x2, x1, x27
    la x3, jalr_target_135
    jalr x2, x3, 0
    add x1, x4, x3  # Speculative shadow
jalr_target_135:
    xor x1, x3, x1
    srai x3, x2, 8
    slli x2, x5, 25
    add x5, x4, x2
    bltu x3, x5, branch_target_136
    add x5, x4, x2  # Speculative shadow
branch_target_136:
    or x1, x3, x4
    andi x2, x5, 178
    slti x3, x2, -655
    bne x17, x4, branch_target_137
    add x5, x5, x1  # Speculative shadow
branch_target_137:
    add x6, x5, x3
    srai x1, x1, 8
    and x1, x5, x2
    and x5, x18, x3
    bne x29, x2, branch_target_138
    add x1, x11, x5  # Speculative shadow
branch_target_138:
    lw x5, 340(x31)
    srli x1, x5, 25
    sltu x2, x2, x4
    la x3, jalr_target_139
    jalr x3, x3, 0
    add x5, x4, x1  # Speculative shadow
jalr_target_139:
    sw x3, 12(x31)
    sw x1, 888(x31)
    slti x3, x1, -1162
    blt x4, x2, branch_target_140
    add x1, x5, x3  # Speculative shadow
branch_target_140:
    ori x1, x5, 1452
    sltiu x3, x1, -762
    slli x3, x21, 9
    and x4, x28, x3
    sltu x1, x19, x4
    slt x5, x4, x3
    slt x2, x2, x11
    sltiu x1, x19, -477
    sw x5, 584(x31)
    la x3, jalr_target_141
    jalr x2, x3, 0
    add x1, x4, x29  # Speculative shadow
jalr_target_141:
    beq x3, x2, branch_target_142
    add x2, x1, x4  # Speculative shadow
branch_target_142:
    srli x18, x5, 21
    or x4, x2, x11
    bge x1, x3, branch_target_143
    add x5, x4, x19  # Speculative shadow
branch_target_143:
    add x4, x1, x5
    lw x7, 480(x31)
    bne x4, x4, branch_target_144
    add x1, x1, x3  # Speculative shadow
branch_target_144:
    add x3, x30, x2
    lw x3, 532(x31)
    bltu x1, x5, branch_target_145
    add x5, x3, x14  # Speculative shadow
branch_target_145:
    add x4, x5, x29
    addi x3, x5, -1283
    sw x2, 804(x31)
    sw x4, 900(x31)
    ori x4, x4, 1760
    slt x3, x3, x1
    slli x3, x26, 3
    jal x27, jal_target_146
    add x4, x3, x4  # Speculative shadow
jal_target_146:
    slt x4, x15, x8
    add x3, x1, x1
    sltu x10, x5, x5
    sub x1, x2, x2
    jal x4, jal_target_147
    add x3, x2, x3  # Speculative shadow
jal_target_147:
    jal x2, jal_target_148
    add x1, x5, x4  # Speculative shadow
jal_target_148:
    sub x2, x8, x3
    or x8, x2, x18
    jal x23, jal_target_149
    add x3, x1, x2  # Speculative shadow
jal_target_149:
    add x2, x4, x19
    andi x2, x8, -1708
    add x2, x10, x4
    or x4, x9, x3
    add x4, x5, x2
    sltiu x5, x1, -1889
    beq x5, x4, branch_target_150
    add x2, x4, x21  # Speculative shadow
branch_target_150:
    ori x3, x1, -443
    srai x2, x2, 23
    andi x24, x2, -1517
    sw x2, 164(x31)
    blt x9, x4, branch_target_151
    add x2, x3, x1  # Speculative shadow
branch_target_151:
    xor x5, x13, x1
    sw x17, 976(x31)
    addi x4, x2, -1955
    srli x4, x5, 27
    beq x5, x3, branch_target_152
    add x21, x2, x2  # Speculative shadow
branch_target_152:
    sw x14, 352(x31)
    xor x6, x1, x1
    lw x5, 260(x31)
    xori x5, x5, -7
    addi x5, x4, -66
    lw x4, 572(x31)
    sltiu x4, x1, 1934
    sub x1, x5, x4
    sub x3, x5, x27
    bge x14, x9, branch_target_153
    add x3, x1, x1  # Speculative shadow
branch_target_153:
    slt x4, x26, x3
    srai x3, x4, 2
    and x19, x5, x2
    la x20, jalr_target_154
    jalr x1, x20, 0
    add x1, x3, x2  # Speculative shadow
jalr_target_154:
    la x16, jalr_target_155
    jalr x4, x16, 0
    add x1, x1, x16  # Speculative shadow
jalr_target_155:
    lw x1, 596(x31)
    sub x2, x1, x3
    lw x5, 952(x31)
    slli x28, x1, 12
    sw x1, 736(x31)
    sw x19, 704(x31)
    bge x4, x1, branch_target_156
    add x3, x1, x5  # Speculative shadow
branch_target_156:
    beq x3, x30, branch_target_157
    add x2, x1, x4  # Speculative shadow
branch_target_157:
    ori x4, x1, 708
    lw x1, 68(x31)
    beq x5, x9, branch_target_158
    add x3, x1, x1  # Speculative shadow
branch_target_158:
    sw x1, 280(x31)
    sw x5, 340(x31)
    slt x12, x5, x5
    blt x3, x5, branch_target_159
    add x4, x4, x3  # Speculative shadow
branch_target_159:
    slli x13, x5, 14
    lw x5, 820(x31)
    slti x4, x30, 946
    andi x1, x3, 119
    blt x16, x5, branch_target_160
    add x1, x20, x3  # Speculative shadow
branch_target_160:
    sltu x30, x4, x1
    jal x2, jal_target_161
    add x27, x5, x2  # Speculative shadow
jal_target_161:
    or x2, x1, x4
    lw x4, 332(x31)
    or x2, x4, x2
    or x22, x1, x17
    bge x23, x1, branch_target_162
    add x2, x3, x2  # Speculative shadow
branch_target_162:
    sltu x3, x17, x24
    add x17, x24, x4
    or x20, x24, x11
    andi x1, x5, 1323
    sltiu x1, x5, 203
    jal x24, jal_target_163
    add x4, x4, x3  # Speculative shadow
jal_target_163:
    bne x5, x4, branch_target_164
    add x3, x4, x27  # Speculative shadow
branch_target_164:
    add x5, x2, x5
    la x4, jalr_target_165
    jalr x3, x4, 0
    add x5, x8, x2  # Speculative shadow
jalr_target_165:
    blt x1, x4, branch_target_166
    add x2, x26, x27  # Speculative shadow
branch_target_166:
    jal x9, jal_target_167
    add x1, x2, x1  # Speculative shadow
jal_target_167:
    sltiu x28, x4, -1027
    sw x5, 896(x31)
    bge x8, x4, branch_target_168
    add x5, x3, x6  # Speculative shadow
branch_target_168:
    srai x12, x5, 7
    slt x8, x3, x2
    slti x13, x2, -1874
    andi x5, x4, 797
    ori x3, x5, -1820
    blt x1, x2, branch_target_169
    add x2, x3, x5  # Speculative shadow
branch_target_169:
    and x5, x4, x4
    slt x15, x1, x22
    jal x5, jal_target_170
    add x3, x4, x2  # Speculative shadow
jal_target_170:
    bne x1, x1, branch_target_171
    add x2, x5, x4  # Speculative shadow
branch_target_171:
    add x23, x1, x4
    la x3, jalr_target_172
    jalr x3, x3, 0
    add x1, x2, x5  # Speculative shadow
jalr_target_172:
    ori x1, x3, -238
    addi x5, x3, 1824
    sw x4, 300(x31)
    bge x1, x4, branch_target_173
    add x4, x8, x23  # Speculative shadow
branch_target_173:
    bge x1, x3, branch_target_174
    add x5, x1, x2  # Speculative shadow
branch_target_174:
    xori x4, x5, -942
    bne x5, x6, branch_target_175
    add x3, x3, x4  # Speculative shadow
branch_target_175:
    slli x2, x5, 18
    srli x3, x4, 28
    ori x2, x2, -1052
    sub x4, x1, x2
    xori x5, x29, 344
    add x5, x4, x4
    or x4, x3, x3
    sub x20, x3, x20
    bltu x3, x4, branch_target_176
    add x24, x4, x4  # Speculative shadow
branch_target_176:
    bge x2, x29, branch_target_177
    add x3, x13, x30  # Speculative shadow
branch_target_177:
    or x3, x4, x5
    slt x3, x1, x1
    slti x5, x3, -890
    slti x3, x15, -751
    bge x29, x4, branch_target_178
    add x5, x15, x4  # Speculative shadow
branch_target_178:
    bgeu x1, x1, branch_target_179
    add x1, x2, x3  # Speculative shadow
branch_target_179:
    ori x4, x1, -1466
    ori x13, x2, 183
    beq x2, x10, branch_target_180
    add x23, x5, x2  # Speculative shadow
branch_target_180:
    lw x1, 668(x31)
    bge x1, x3, branch_target_181
    add x27, x16, x2  # Speculative shadow
branch_target_181:
    slli x16, x5, 11
    lw x4, 412(x31)
    or x4, x5, x1
    bge x5, x4, branch_target_182
    add x3, x13, x2  # Speculative shadow
branch_target_182:
    and x2, x3, x4
    slli x21, x1, 28
    sub x2, x30, x5
    sw x26, 52(x31)
    ori x3, x1, 371
    srai x1, x26, 17
    addi x1, x9, 966
    bge x3, x2, branch_target_183
    add x2, x1, x20  # Speculative shadow
branch_target_183:
    bltu x3, x1, branch_target_184
    add x18, x5, x9  # Speculative shadow
branch_target_184:
    addi x4, x1, -426
    lw x3, 892(x31)
    bgeu x5, x1, branch_target_185
    add x3, x1, x4  # Speculative shadow
branch_target_185:
    or x6, x2, x3
    add x25, x1, x1
    sltiu x3, x13, -332
    slli x2, x11, 3
    srai x1, x2, 11
    xori x2, x2, 91
    lw x2, 520(x31)
    srai x17, x1, 17
end_loop:
    j end_loop