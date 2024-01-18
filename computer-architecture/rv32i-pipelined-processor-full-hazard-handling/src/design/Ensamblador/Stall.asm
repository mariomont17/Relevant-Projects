# Prueba 2, stalls y forwarding

addi x2, zero, 0x20 # x2 = 0x20
slli x2, x2, 8      # x2 = 0x2000
addi x10, zero, 10  # x10 = 10
sw x10, 0(x2)       # en ram[0] se guarda un 10

addi x5, zero, 2    # x5 = 2
addi x7, zero, 7    # x7 = 7
addi x9, zero, 3    # x9 = 3
add x8, zero, zero  # x8 = 0


lw x1, 0(x2)        # se carga el valor de 10 (ram[0]) en x1, x1 = 10
sub x4, x1, x5      # x4 = 10 - 2 = 8
and x6, x1, x7      # x6 = 10 & 7 = 2
or x8, x1, x9       # x8 = 10 | 3 = 11 = 0xB
xor x11, x4, x6     # x11 = 1000 ^ 0010 = 1010 = 0xA
and x12, x11, x8    # x12 = 1010 & 1011 = 1010 = 0xA

# se debe guardar un 10 (0xA) en ram[1]

sw x12, 4(x2) 