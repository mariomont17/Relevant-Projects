# DEFINIR OFFSETs PARA LOS PERIFERICOS (DIRECCIONES 0x2000's)
.eqv 	SWITCHES 	0x00
.eqv 	LEDS		0x04
.eqv 	SEGMENTOS	0x08

.eqv	UART_A_CONTROL	0x10
.eqv	UART_A_DATA1	0x18
.eqv	UART_A_DATA2	0x1C

.eqv	UART_B_CONTROL	0x20
.eqv	UART_B_DATA1	0x28
.eqv	UART_B_DATA2	0x2C

.eqv	UART_C_CONTROL	0x30
.eqv	UART_C_DATA1	0x38
.eqv	UART_C_DATA2	0x3C

addi x3, x0, 0x20	# carga 0x20 en x3
slli x3, x3, 8		# shift x3 ocho veces, ahora x3 = 0x2000

# PARA LA RAM

addi s0, x0, 0x10
slli s0, s0, 8		# ahora s0 = 0x1000

.eqv SEND_MASK		1	# mascara del bit de send
.eqv NEW_RX_MASK	2	# mascara del bit de new_rx

addi s1, x0, SEND_MASK		# s1 = 1 
addi s2, x0, NEW_RX_MASK	# s2 = 2 = 2'b10

REPOSO: 
	# LEE PERIFERICOS
	# PRIMERO SWITCHES Y BOTONES
	lw 	a0, SWITCHES(x3) # a0 contiene la info de switches al inicio
	srli	t4, a0, 16  #shift right 16 veces para obtener el bit de envio sw[16]
	andi	t4, t4, 1
	beq	t4, s1, GENERACION # branch al modo generacion, si bit de send en 1
	
	# SEGUNDO UART A
	lw 	t1, UART_A_CONTROL(x3) # t1 identifica al control UART A 
	andi 	t1, t1, NEW_RX_MASK
	beq	t1, s2, PROCESAMIENTO
	
	# SEGUNDO UART B
	lw 	t2, UART_B_CONTROL(x3) # t2 identifica al control UART B 
	andi 	t2, t2, NEW_RX_MASK
	beq	t2, s2, PROCESAMIENTO
	
	# TERCERO UART C
	lw 	t3, UART_C_CONTROL(x3) # t3 identifica al control UART C 
	andi 	t3, t3, NEW_RX_MASK
	beq	t3, s2, PROCESAMIENTO
	
	# SI NO SE HA RECIBIDO NI GENERADO NADA, SE CICLA
	beq 	x0, x0, REPOSO
	
PROCESAMIENTO:
	
	#contador de paquete recibido, se muestra en los LEDS
	# s10 es el registro contador de paquetes
	addi s10, s10, 1
	sw s10, LEDS(x3)
	
	lw  a0, SWITCHES(x3) # a0 contiene la info de switches al inicio
	srli s3, a0, 8 # s3 tiene a SW[31:8], SW[11:8] son los que importan para identificar
	andi s3, s3, 0xf # s3 tiene los 4 bits de identificacion
	
	beq t1, s2, LEER_DATO_DE_A # se recibe de A
	beq t2, s2, LEER_DATO_DE_B # se recibe de B
	beq t3, s2, LEER_DATO_DE_C # se recibe de C
	
	beq x0, x0, RETRANSMITIR
	
LEER_DATO_DE_A:

	lw a2, UART_A_DATA2(x3)
	andi a3, a2, 0xf
	beq s3, a3, CONSUMIR
	j RETRANSMITIR
	
LEER_DATO_DE_B:

	lw a2, UART_B_DATA2(x3)
	andi a3, a2, 0xf
	beq s3, a3, CONSUMIR
	j RETRANSMITIR
	
LEER_DATO_DE_C:

	lw a2, UART_C_DATA2(x3)
	andi a3, a2, 0xf
	beq s3, a3, CONSUMIR
	j RETRANSMITIR
	# si no, se prosigue al modo RETRANSMITIR
	
RETRANSMITIR:		
	
	beq t1, s2, ENVIAR_EN_B_Y_C # enviar en UART B y C si se recibe de A
	beq t2, s2, ENVIAR_EN_A_Y_C # enviar en UART A y C si se recibe de B
	beq t3, s2, ENVIAR_EN_A_Y_B # enviar en UART A y B si se recibe de C
	
ENVIAR_EN_B_Y_C: # se recibio desde UART A
	
	lw s7, UART_A_DATA2(x3) # en s7 se guarda la palabra recibida del registro de datos 2 del UART
	# se carga la palabra en los registros de datos 1 de B y C
	sw s7, UART_B_DATA1(x3)
	sw s7, UART_C_DATA1(x3)
	# pone en 1 el bit de send de ambas Interfaces
	sw s1, UART_B_CONTROL(x3)
	sw s1, UART_C_CONTROL(x3)
	# limpiar registro de control del UART A
	and t1, x0, x0
	sw t1, UART_A_CONTROL(x3)
	
	# cuando los envia, se retorna a modo REPOSO
	beq x0, x0, REPOSO
	
ENVIAR_EN_A_Y_C: # se recibio de UART B

	lw s7, UART_B_DATA2(x3) # en s7 se guarda la palabra recibida del registro de datos 2 del UART
	# se carga la palabra en los registros de datos 1 de A y C
	sw s7, UART_A_DATA1(x3)
	sw s7, UART_C_DATA1(x3)
	# pone en 1 el bit de send de ambas Interfaces
	sw s1, UART_A_CONTROL(x3)
	sw s1, UART_C_CONTROL(x3)
	# limpiar registro de control del UART B
	and t1, x0, x0
	sw t1, UART_B_CONTROL(x3)
	
	# cuando los envia, se retorna a modo REPOSO
	beq x0, x0, REPOSO	

ENVIAR_EN_A_Y_B: # se recibio de UART C

	lw s7, UART_C_DATA2(x3) # en s7 se guarda la palabra recibida del registro de datos 2 del UART
	# se carga la palabra en los registros de datos 1 de A y B
	sw s7, UART_A_DATA1(x3)
	sw s7, UART_B_DATA1(x3)
	# pone en 1 el bit de send de ambas Interfaces
	sw s1, UART_A_CONTROL(x3)
	sw s1, UART_B_CONTROL(x3)
	# limpiar registro de control del UART C
	and t1, x0, x0
	sw t1, UART_C_CONTROL(x3)
	
	# cuando los envia, se retorna a modo REPOSO
	beq x0, x0, REPOSO
	
CONSUMIR:	
	
	# contador de paquete consumido, se muestra en los 7SEGMENTOS
	# s11 es el registro contador de paquetes procesados
	addi s11, s11, 1
	slli s9, s11, 8
	# a0 se modifica para obtener solo los bits del dato a procesar [7:4]
	srli a2, a2, 4
	andi a2, a2, 0xf
	
	add s9, s9, a2
	
	sw s9, SEGMENTOS(x3)
	sw x0, UART_A_CONTROL(x3)
	sw x0, UART_B_CONTROL(x3)
	sw x0, UART_C_CONTROL(x3)

	beq x0, x0, REPOSO
	
	
GENERACION:
	
	lw      a0, SWITCHES(x3)
	andi    s0, a0, 0x00FF     #Se arma el paquete de datos
	
	#Se procede a enviar los datos por los 3 UARTS 
	addi s4 , zero, 1
	#UART C
	sw      s0, UART_C_DATA1   (x3)
	sw      s4, UART_C_CONTROL (x3)
	
	#UART B
	sw	s0, UART_B_DATA1   (x3)
	sw	s4, UART_B_CONTROL (x3)		
	
	#UART A
	sw	s0, UART_A_DATA1   (x3)
	sw	s4, UART_A_CONTROL (x3)

TERMINAR:		
	
	lw      a0, SWITCHES(x3)
	srli	t4, a0, 16  #shift right 16 veces para obtener el bit de envio sw[16]
	andi	t4, t4, 1
	beq	t4, x0, REPOSO # branch al modo reposo, si bit de send en cero
	j TERMINAR
	
	
