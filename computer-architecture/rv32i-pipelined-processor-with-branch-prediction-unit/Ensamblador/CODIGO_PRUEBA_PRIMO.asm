# Define input
addi a0, zero, 97

addi t0, zero, 0x1
beq a0, t0, NOPRIMO

LOOP1:
    addi t0, t0, 0x1
    beq t0, a0, PRIMO
    add t1, a0, zero
LOOP2:
    sub t1, t1, t0
    bge t1, t0, LOOP2
    beq t1, zero, NOPRIMO
    beq zero, zero, LOOP1

NOPRIMO:
    addi a0, zero, 0x0
    jal zero, FIN
PRIMO:
    addi a0, zero, 0x1
FIN:
    add zero, zero, zero