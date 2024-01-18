	addi x6, x0,10
CICLO: 
	addi x5,x5,1
	beq x5,x6, END
	beq x0,x0 CICLO

END: 
	add x29,x5,x0
	sw x29, 0(x5)
	
