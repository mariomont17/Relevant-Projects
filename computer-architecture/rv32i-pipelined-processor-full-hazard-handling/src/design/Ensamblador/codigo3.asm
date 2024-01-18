addi x2, zero, 0x20 # x2 = 0x20
slli x2, x2, 8      # x2 = 0x2000
addi x10, zero, 10  # x10 = 10
sw x10, 0(x2)       # ram[0x2000] = 10

addi x5, zero, 2    # x5 = 2
addi x7, zero, 7    # x7 = 7
addi x9, zero, 3    # x9 = 3

lw x1, 0(x2)        # x1 = ram[0x2000]
sub x4, x1, x9      # x4 = x1 - x9
and x6, x1, x7      # x6 = x1 & x7

and x12, x6, x4    # stall

sw x12, 4(x2)      # ram[0x2004] = x12=2 Stall
