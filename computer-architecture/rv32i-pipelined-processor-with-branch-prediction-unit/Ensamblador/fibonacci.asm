    li a0, 11          # Número de términos de Fibonacci a generar
    li t0, 0           # Inicializa el primer término (F(0)) en t0
    li t1, 1           # Inicializa el segundo término (F(1)) en t1
    li t2, 1           # Inicializa el índice en t2
    
    addi t4, zero, 0x20	# carga 0x20 en x3
    slli t4, t4, 8	# shift x3 ocho veces, ahora x3 = 0x2000
	
loop:
    beq t2, a0, done  # Si hemos generado los 10 términos, salta a "done"

    # Calcula el siguiente término de Fibonacci
    add t3, t0, t1    # t3 = t0 + t1 (F(n) = F(n-1) + F(n-2))
    mv t0, t1         # t0 = t1
    mv t1, t3         # t1 = t3

    # Almacena el término actual de Fibonacci en la memoria
    sw t3, 0(t4)      # Almacena el término en la dirección apuntada por t4
    addi t4, t4, 4    # Avanza el puntero en 4 bytes (siguiente posición)

    addi t2, t2, 1     # Incrementa el índice
    beq zero,zero, loop  # Salto de regreso a "loop"

done:
    # El programa termina aquí 