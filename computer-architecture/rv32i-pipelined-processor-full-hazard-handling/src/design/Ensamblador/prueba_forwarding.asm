# Prueba 1, forwarding

addi x1, x0, 0x7
addi x3, x0, 0x5
addi x5, x0, 0x7
addi x6, x0, 0x0

sub x2, x1, x3 # 7 - 5 = 2, x2 vale 2
and x12, x2, x5 # 2 AND 7 = 2
or x13, x6, x2  # 0 OR 2 = 2
add x14, x2, x2 # 2 + 2 = 4
slli x2, x2, 12 # x2 = 2000
sw x14, 4(x2) # [0x2004] = 4 (ram[1])
