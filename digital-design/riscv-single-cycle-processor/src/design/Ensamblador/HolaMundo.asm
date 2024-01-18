.global main
.data

.text

main:
	addi s8,zero,2000 
	addi s10, zero, 50

	addi s9,zero,0   
         
	cont1:
	addi s9,s9,1
	bne s9,s8,cont1            
                          
                                       
                                                                 
	addi s1, zero, 0x20                    #s1=0000000000100000
	slli s1, s1, 8                         #s1=0010000000000000

	addi s4, zero, 1                       #s4=1, bit de send en 1 

	addi s3, zero, 72                      #letra H  s3=72
	sw s3, 0x38(s1)                        #Se guarda el valor en el registro de datos 0
	sw s4, 0x30(s1)                        #Se pone el bit de send en 1
	reg_ctrl_cero:                         #Espera a que el bit de send este en cero   
		lw s6, 0x30(s1)                #S6 va a leer el valor del registro de control
		andi s6,s6,01                  #Se hace uso de una máscara solo para el bit de send
		beq s6, s4, reg_ctrl_cero      #Si s6 y s4 son distintos significa que el bit de send está en cero por lo tanto puede continuar.


	addi s3, zero, 79 # letra O
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero1:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero1


	addi s3, zero, 76 # letra L
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero2:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero2

	
	addi s3, zero, 65 # letra A
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero3:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero3
	
	addi s3, zero, 32 # espacio
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero4:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero4
	
	addi s3, zero, 77 # letra M
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero5:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero5
	
	addi s3, zero, 85 # letra U
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero6:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero6
	
	addi s3, zero, 78 # letra N
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero7:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero7
	
	addi s3, zero, 68 # letra D
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero8:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero8
	
	addi s3, zero, 79 # letra O
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero9:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero9
		
	addi s3, zero, 32 # espacio
	sw s3, 0x38(s1)
	sw s4, 0x30(s1)
	reg_ctrl_cero10:	
		lw s6, 0x30(s1)
		andi s6,s6,01
		beq s6, s4, reg_ctrl_cero10





