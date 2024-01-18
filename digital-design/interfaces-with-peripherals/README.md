# Laboratorio 3: Interfaces con periféricos

## 1. Abreviaturas y definiciones
- **ALS**: Ambient Light Sensor.
- **DEMUX**: Demultiplexer.
- **FPGA**: Field Programmable Gate Arrays.
- **MUX**: Multiplexer.
- **MISO**: Master Input Slave Output.
- **MOSI**: Master Output Slave Input.
- **SPI**: Serial Peripherial Interface.
- **PMOD**: Peripheral Module Interface
- **UART**: Universal Asynchronous Receiver / Transmitter.



## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo


### 3.1 Interfaz SPI Maestro - Genérica

### 3.1.1  Módulo "Contador"

Contador de transacciones de reloj, que cuenta cada vez que el reloj tiene un flanco positivo.

#### 1. Encabezado del módulo
```SystemVerilog
module Contador(
    input logic                                  clk_i,    
    input logic                                  reset_i,   
    input logic                                  en_i,      
    input logic  [8:0]                           n_i,       
    input logic                                  en_spi_i,  
    output logic [($clog2(CUENTA_REGISTRO)):0]   contador_o
    );
```
#### 2. Parámetros
- `CUENTA_REGISTRO`: Profundidad del registro a utilizar. Para este caso es igual a 32.

#### 3. Entradas y salidas:
- `clk_i`: Entrada de reloj de 10MHz.
- `reset_i`: Entrada de señal de reset.
- `en_i`: Señal de entrada habilitadora de la máquina de estados.
- `n_i`: Entrada de dirección de la transaccion final
- `en_spi_i`: Entrada indicador final de transacción
- `contador_o`: Salida de contador de transacciones.

#### 4. Criterios de diseño
Para este módulo de *Contador* se diseñó para contar la cantidad de transacciones hechas a partir de que la señal de `en_i` y la señal de `en_spi_i` estén activas ya que estas me permiten conocer cuando la máquina de estados y el módulo de `SPI` pueden terminar la transacción como tal a partir de las anteriores dos señales habilitadoras.

#### 5. Testbench
No se realizó testbench para este módulo.


### 3.1.2  Módulo "Demux_1_2"

Demultiplexor 1 a 2 para funcionamiento de estructura básica del SPI.

#### 1. Encabezado del módulo
```SystemVerilog
module Demux_1_2(
    input logic  wr_i,       
    input logic  sel_i,      
    output logic wr_ctrl_o,  
    output logic wr_data_o   
    );   
```
#### 2. Parámetros
No hay parámetros definidos para este módulo.

#### 3. Entradas y salidas:
- `wr_i`: Señal de entrada que habilita escritura.
- `sel_i`: Señal de entrada que selecciona el registro.
- `wr_ctrl_o`: Señal de salida de Write enable de registro de control.
- `wr_data_o`: Señal de salida de registro de datos.

#### 4. Criterios de diseño
Para este módulo de *Demux_2_1* se utilizó la lógica del circuito Demux que a partir de una entrada se obtienen dos salidas, mediante el análisis de cada caso para la señal `sel_i` donde mediante este funcionamiento me permite definir el registro de control y en el registro de datos al mismo tiempo.

#### 5. Testbench
No se realizó testbench para este módulo.



### 3.1.3  Módulo "FSM_SPI"
Máquina de estados para el módulo de SPI.

#### 1. Encabezado del módulo
```SystemVerilog
module FSM_SPI(
    input  logic                   clk_i,      
    input  logic                   reset_i,   
    input  logic [31:0]            data_ctrl_i, 
    input  logic [31:0]            data_tx_i,   
    input  logic [7:0]             data_rx_i,   
    input  logic                   spi_fin_i,   
    input  logic [($clog2(N)):0]   n_i,         
    output logic [7:0]             data_tx_o,   
    output logic                   en_spi_o,    
    output logic                   en_cont_o,  
    output logic                   wr_ctrl_o,   
    output logic                   wr_data_o,  
    output logic                   hold_ctrl_o, 
    output logic [31:0]            data_o,     
    output logic [31:0]            data_ctrl_o, 
    output logic [($clog2(N)):0]   addr_data_o       
    );
```
#### 2. Parámetros
- `N`: Profundidad del banco de registros. Para este caso igual a 32.

#### 3. Entradas y salidas:
- `clk_i`: Señal de entrada de reloj de 10 MHz.
- `reset_i`: Señal de entrada de reset.
- `data_ctrl_i`: Señal de entrada de datos de control.
- `data_tx_i`: Señal de entrada de datos a enviar.
- `data_rx_i`: Señal de entrada de datos recibidos.
- `spi_fin_i`: Indicador de fin de transacción.
- `n_i`: Señal de entrada de cuantas transacciones llevo.
- `data_tx_o`: Señal de salida de cuantos datos enviados hacia SPI.
- `en_spi_o`: Señal de salida que habilita el módulo SPI.
- `en_cont_o`: Señal de salida que habilita el contador de transacciones.
- `wr_ctrl_o`: Señal de salida que sobreescribe en registro de control.
- `wr_data_o`: Señal de salida que sobreescribe en registro de datos.
- `hold_ctrl_o`: Señal de salida que determina si darle prioridad al SPI o a la interfaz con el usuario.
- `data_o`: Señal de salida de datos hacia el registro de datos.
- `data_ctrl_o`: Señal de salida de datos hacia el registro de control.
- `addr_data_o`: Señal de salida de dirección para escribir en registro de datos.

#### 4. Criterios de diseño
Este módulo *FSM_SPI* es la máquina de estados finita que me dirige el funcionamiento completo de la interfaz genérica y el SPI para que de esta forma logre la transacción según el criterio dado en el instructivo. Para el funcionamiento de esta máquina de estados se planteó realizar una máquina según la siguiente figura:
![](https://i.imgur.com/UYHZUMu.png)


Cuando se empezó a implementar nos dimos cuenta que en realidad la máquina de estados era un poco más compleja y por ende ocupaba diversos estados más para cumplir el funcionamiento deseado.


#### 5. Testbench
No se realizó testbench para este módulo.



### 3.1.4  Módulo "GeneradorPruebaSPI"

Módulo que hace el ajuste de cada valor de salida y entrada del SPI y me delimita el ancho de la variable.

#### 1. Encabezado del módulo
```SystemVerilog
module module_GeneradorPruebaSPI (
    input  logic [7:0]          entrada_i,
    input  logic [31:0]         salida_i,
    output logic [31:0]         entrada_o,
    output logic [15:0]         salida_o 
    );
```
#### 2. Parámetros
No hay parámetros definidos para este módulo.

#### 3. Entradas y salidas:
- `entrada_i`: Variable de entrada del módulo SPI.
- `salida_i`: Variable de entrada de la salida del módulo SPI.
- `entrada_o`: Variable de salida ajustado con `0`.
- `salida_o`: Valor de la variable de salida de 15 bits.

#### 4. Criterios de diseño
Este módulo consta de dos asignaciones de las variables de entrada a las variables de salida donde se ajusta a los valores indicados.

#### 5. Testbench
No se realizó testbench para este módulo.



### 3.1.5  Módulo "Interfaz SPI"

Módulo donde se realizó todas instancias de los módulos anteriormente descritos. Se realizó como un premódulo TOP para realizar la interfaz del SPI.

#### 1. Encabezado del módulo
```SystemVerilog
module module_InterfazSPI(
    input  logic                 clk_i,     
    input  logic                 wr_i,      
    input  logic                 reg_sel_i, 
    input  logic [31:0]          entrada_i, 
    input  logic [$clog2(N):0]   addr_i,    
    input  logic                 bit_rx_i,  
    output logic                 bit_tx_o,  
    output logic                 sclk_o,    
    output logic                 cs_o,      
    output logic [31:0]          salida_o   
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `clk_i`: Señal de entrada de reloj.
- `wr_i`: Señal de entrada de Write Enable.
- `reg_sel_i`: Selector de registros.
- `entrada_i`: Entrada de datos.
- `addr_i`: Dirección de guardado del registro.
- `bit_rx_i`: Bits de recibido del PMOD.
- `bit_tx_i`: Bits enviados al PMOD.
- `sclk_o`: Señal de SCLK.
- `cs_o`: Señal de chip Select.
- `salida_o`: Señal de salida de datos.
#### 4. Criterios de diseño
- `N`: Produnfidad del banco de registros.

#### 5. Testbench
No se realizó testbench para este módulo.




### 3.1.6  Módulo "Mux_2_1"

Módulo de Multiplexor de dos entradas a una, donde por medio de la señal de control se selecciona el dato a mostrar en las salidas.

#### 1. Encabezado del módulo
```SystemVerilog
module module_mux_2_1(
    input  logic [ANCHO - 1 : 0] dato1_i, 
    input  logic [ANCHO - 1 : 0] dato2_i, 
    input  logic                 sel_i,   
    output logic [ANCHO - 1 : 0] out_o    
    );
```
#### 2. Parámetros
- `ANCHO`: Ancho de bits para el tamaño de los datos.

#### 3. Entradas y salidas:
- `dato1_i`: Dato de entrada 1
- `dato2_i`: Dato de entrada 2
- `sel_i`: Dato de entrada de control 
- `out_o`: Dato de salida del multiplexor.

#### 4. Criterios de diseño
Para este módulo se planteó el diseño de un selector que me determina el valor de salida por medio de la máquina de control, mediante una entrada binaria.

#### 5. Testbench

No se realizó testbench para este módulo.

### 3.1.7  Módulo "RegistroCtrl_SPI"

#### 1. Encabezado del módulo
```SystemVerilog
module module_RegistroCtrl_SPI(
    input logic         clk_i,   
    input logic         reset_i, 
    input logic         wr1_i,   
    input logic         wr2_i,   
    input  logic [31:0] data1_i, 
    input  logic [31:0] data2_i, 
    output logic [31:0] data_o    
    );
```
#### 2. Parámetros
No hay parámetros definidos para este módulo.

#### 3. Entradas y salidas:
- `clk_i`: Señal de entrada de clock.
- `reset_i`: Señal de entrada de reset.
- `wr1_i`: Señal de entrada de enable de escritura del módulo externo.
- `wr2_i`: Señal de entrada de enable de escritura del módulo SPI.
- `data1_i`: Señal de entrada de datos de los módulos externos.
- `data2_i`: Señal de entrada de datos de los módulos externos.
- `data_o`: Señal de salida de los datos leídos.

#### 4. Criterios de diseño
Este módulo funciona como banco de registros de control para las señales de entrada según los valores del clock para lógica multiciclo, donde en el flanco positivo de la señal me permite hacer el `write` dentro del banco.

#### 5. Testbench
No se realizó testbench para este módulo.


### 3.1.8  Módulo "RegistroDatos_SPI"

#### 1. Encabezado del módulo
```SystemVerilog
module module_RegistroDatos_SPI(
     input  logic                 clk_i,       
     input  logic                 reset_i,     
     input  logic                 wr1_i,       
     input  logic                 wr2_i,       
     input  logic                 hold_ctrl_i, 
     input  logic [$clog2(N):0]   addr1_i,     
     input  logic [$clog2(N):0]   addr2_i,     
     input  logic [31:0]          data1_i,     
     input  logic [31:0]          data2_i,     
     output logic [31:0]          data_o       
    );
```
#### 2. Parámetros
- `N`: Profundidad del banco de registros.

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Este módulo funciona como banco de registros de datos para las señales de entrada según los valores del clock para lógica multiciclo, donde en el flanco positivo de la señal me permite hacer el `write` dentro del banco.

#### 5. Testbench
No se realizó testbench para este módulo.



### 3.1.9  Módulo "SPI"

#### 1. Encabezado del módulo
```SystemVerilog
module module_SPI (
    input  logic        clk_i,      
    input  logic        reset_i,    
    input  logic [7:0]  data_i,     
    input  logic        en_i,       
    input  logic        miso_i,     
    output logic [7:0]  data_rx_o,  
    output logic        mosi_o,     
    output logic        sclk_o,     
    output logic        spi_fin_o   
    );
```
#### 2. Parámetros
No hay parámetros definidos para este módulo.

#### 3. Entradas y salidas:
- `clk_i`: Señal de entrada de reloj de 10 MHz.
- `reset_i`: Señal de entrada de reset.
- `data_i`: Señal de entrada de datos a enviar.
- `en_i`: Señal de entrada que habilita el módulo.
- `miso_i`: Entrada de bit de recibido.
- `data_rx_o`: Salida de dato de recibido.
- `mosi_o`: Salida de bit enviado.
- `sclk_o`: Salida de reloj de enviar y recibir dato.
- `spi_fin_o`: Señal de aviso de final de transacción.

#### 4. Criterios de diseño
Módulo SPI que se encarga de la recepción de los datos y la transmisión de los mismos y además el control de los accesos a los bancos tanto de control como de registros. Ya que se quizo obtener un funcionamiento serial a paralelo sincrónico mediante un mismo pulso de reloj, por ende la necesidad de la definición de los anteriores módulos que me conforman la esctructura. Además se generó los 6 modos distintos solicitados detallados como `send`, `cscontrol`, `all_1s`, `all_0s`, `n_tx_end ` y `n_rx_end` donde cada uno de ellos se define dentro del instructivo dado. 

A partir del siguiente diagrama de alto nivel para el SPI, fue que se empezó a desarrollar cada sección. Donde además se puede observar que en la parte inferior viene detallado el registro de control para cada uno de los modos específico que yo quiero poner a funcionar.

![](https://i.imgur.com/cfG7GyJ.png)


#### 5. Testbench
Para este testbench se realizó la transmisión de una cadena de 8 bits para el MOSI por medio de un circuito externo de una compuerta `not` que me invirtió todos los valores enviados y como se puede ver en la recepción del MISO este es el dato que se recibe. Además de verificar que los valores de control logren activarse para los flancos positivos de reloj. 

Por otro lado las señales de enable son de suma importancia para el SPI en conjunto ya que me definen los accesos de cada módulo por aparte anteriormente definidos y se puede observar que se realiza con éxito para la transferencia.



![](https://i.imgur.com/YM45Fui.jpg)





### 3.1.10  Módulo "top_InterfazSPI_FPGA"


Módulo TOP para pruebas en FPGA, mediante el uso de los constrains el SPI puede funcionar junto con la FPGA gracias a este, donde se definió diferentes switches para generar la entrada de control necesaria para el funcionamiento del SPI.
#### 1. Encabezado del módulo
```SystemVerilog
module module_top_InterfazSPI_FPGA (
    input  logic                 clk_i,     
    input  logic                 wr_i,      
    input  logic                 reg_sel_i, 
    input  logic [7:0]           entrada_i, 
    input  logic [3:0]           addr_i,    
    input  logic                 bit_rx_i,  
    output logic                 bit_tx_o,  
    output logic                 sclk_o,    
    output logic                 cs_o,      
    output logic [15:0]          salida_o    
    );
```
#### 2. Parámetros
No hay parámetros definidos para este módulo.

#### 3. Entradas y salidas:
- `clk_i`: Entrada de reloj de 100MHz.
- `wr_i`: Entrada de Write Enable.
- `reg_sel_i`: Entrada de selector de registros.
- `entrada_i`: Entrada de datos.
- `addr_i`: Entrada de dirección para almacenar datos.
- `bit_rx_i`: Entrada de bits recibidos por el PMOD.
- `bit_tx_o`: Salida de bits enviados al PMOD.
- `sclk_o`: Señal de salida de `SCLK`.
- `cs_o`: Señal de salida de `chipselect`.
- `salida_o`: Señal de salida de datos.

#### 4. Criterios de diseño
Este módulo fue creado para utilizar la implementación en FPGA así como también generar el Bitstream,  por lo que este módulo solo llama a los demás para completar la transmisión.

#### 5. Testbench
No se realizó testbench para este módulo.

#### 6. Constrains
Se definieron los siguientes constraints:

```sdc
## Clock signal
##Bank = 35, Pin name = IO_L12P_T1_MRCC_35,					Sch name = CLK100MHZ
set_property PACKAGE_PIN E3 [get_ports clk_i]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk_i]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_i]
 
## Switches
##Bank = 34, Pin name = IO_L21P_T3_DQS_34,					Sch name = SW0
set_property PACKAGE_PIN U9 [get_ports {entrada_i[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entrada_i[0]}]
##Bank = 34, Pin name = IO_25_34,							Sch name = SW1
set_property PACKAGE_PIN U8 [get_ports {entrada_i[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entrada_i[1]}]
##Bank = 34, Pin name = IO_L23P_T3_34,						Sch name = SW2
set_property PACKAGE_PIN R7 [get_ports {entrada_i[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entrada_i[2]}]
##Bank = 34, Pin name = IO_L19P_T3_34,						Sch name = SW3
set_property PACKAGE_PIN R6 [get_ports {entrada_i[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entrada_i[3]}]
##Bank = 34, Pin name = IO_L19N_T3_VREF_34,					Sch name = SW4
set_property PACKAGE_PIN R5 [get_ports {entrada_i[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entrada_i[4]}]
##Bank = 34, Pin name = IO_L20P_T3_34,						Sch name = SW5
set_property PACKAGE_PIN V7 [get_ports {entrada_i[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entrada_i[5]}]
##Bank = 34, Pin name = IO_L20N_T3_34,						Sch name = SW6
set_property PACKAGE_PIN V6 [get_ports {entrada_i[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entrada_i[6]}]
##Bank = 34, Pin name = IO_L10P_T1_34,						Sch name = SW7
set_property PACKAGE_PIN V5 [get_ports {entrada_i[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entrada_i[7]}]
##Bank = 34, Pin name = IO_L8P_T1-34,						Sch name = SW8
#set_property PACKAGE_PIN U4 [get_ports {sw[8]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
##Bank = 34, Pin name = IO_L9N_T1_DQS_34,					Sch name = SW9
#set_property PACKAGE_PIN V2 [get_ports {sw[9]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
##Bank = 34, Pin name = IO_L9P_T1_DQS_34,					Sch name = SW10
#set_property PACKAGE_PIN U2 [get_ports {sw[10]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
##Bank = 34, Pin name = IO_L11N_T1_MRCC_34,					Sch name = SW11
set_property PACKAGE_PIN T3 [get_ports {addr_i[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {addr_i[0]}]
##Bank = 34, Pin name = IO_L17N_T2_34,						Sch name = SW12
set_property PACKAGE_PIN T1 [get_ports {addr_i[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {addr_i[1]}]
##Bank = 34, Pin name = IO_L11P_T1_SRCC_34,					Sch name = SW13
set_property PACKAGE_PIN R3 [get_ports {addr_i[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {addr_i[2]}]
##Bank = 34, Pin name = IO_L14N_T2_SRCC_34,					Sch name = SW14
set_property PACKAGE_PIN P3 [get_ports {addr_i[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {addr_i[3]}]
##Bank = 34, Pin name = IO_L14P_T2_SRCC_34,					Sch name = SW15
set_property PACKAGE_PIN P4 [get_ports {reg_sel_i}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {reg_sel_i}]
 


## LEDs
##Bank = 34, Pin name = IO_L24N_T3_34,						Sch name = LED0
set_property PACKAGE_PIN T8 [get_ports {salida_o[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[0]}]
##Bank = 34, Pin name = IO_L21N_T3_DQS_34,					Sch name = LED1
set_property PACKAGE_PIN V9 [get_ports {salida_o[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[1]}]
##Bank = 34, Pin name = IO_L24P_T3_34,						Sch name = LED2
set_property PACKAGE_PIN R8 [get_ports {salida_o[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[2]}]
##Bank = 34, Pin name = IO_L23N_T3_34,						Sch name = LED3
set_property PACKAGE_PIN T6 [get_ports {salida_o[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[3]}]
##Bank = 34, Pin name = IO_L12P_T1_MRCC_34,					Sch name = LED4
set_property PACKAGE_PIN T5 [get_ports {salida_o[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[4]}]
##Bank = 34, Pin name = IO_L12N_T1_MRCC_34,					Sch	name = LED5
set_property PACKAGE_PIN T4 [get_ports {salida_o[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[5]}]
##Bank = 34, Pin name = IO_L22P_T3_34,						Sch name = LED6
set_property PACKAGE_PIN U7 [get_ports {salida_o[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[6]}]
##Bank = 34, Pin name = IO_L22N_T3_34,						Sch name = LED7
set_property PACKAGE_PIN U6 [get_ports {salida_o[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[7]}]
##Bank = 34, Pin name = IO_L10N_T1_34,						Sch name = LED8
set_property PACKAGE_PIN V4 [get_ports {salida_o[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[8]}]
##Bank = 34, Pin name = IO_L8N_T1_34,						Sch name = LED9
set_property PACKAGE_PIN U3 [get_ports {salida_o[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[9]}]
##Bank = 34, Pin name = IO_L7N_T1_34,						Sch name = LED10
set_property PACKAGE_PIN V1 [get_ports {salida_o[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[10]}]
##Bank = 34, Pin name = IO_L17P_T2_34,						Sch name = LED11
set_property PACKAGE_PIN R1 [get_ports {salida_o[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[11]}]
##Bank = 34, Pin name = IO_L13N_T2_MRCC_34,					Sch name = LED12
set_property PACKAGE_PIN P5 [get_ports {salida_o[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[12]}]
##Bank = 34, Pin name = IO_L7P_T1_34,						Sch name = LED13
set_property PACKAGE_PIN U1 [get_ports {salida_o[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[13]}]
##Bank = 34, Pin name = IO_L15N_T2_DQS_34,					Sch name = LED14
set_property PACKAGE_PIN R2 [get_ports {salida_o[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[14]}]
##Bank = 34, Pin name = IO_L15P_T2_DQS_34,					Sch name = LED15
set_property PACKAGE_PIN P2 [get_ports {salida_o[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {salida_o[15]}]

##Bank = 34, Pin name = IO_L5P_T0_34,						Sch name = LED16_R
#set_property PACKAGE_PIN K5 [get_ports RGB1_Red]					
	#set_property IOSTANDARD LVCMOS33 [get_ports RGB1_Red]
##Bank = 15, Pin name = IO_L5P_T0_AD9P_15,					Sch name = LED16_G
#set_property PACKAGE_PIN F13 [get_ports RGB1_Green]				
	#set_property IOSTANDARD LVCMOS33 [get_ports RGB1_Green]
##Bank = 35, Pin name = IO_L19N_T3_VREF_35,					Sch name = LED16_B
#set_property PACKAGE_PIN F6 [get_ports RGB1_Blue]					
	#set_property IOSTANDARD LVCMOS33 [get_ports RGB1_Blue]
##Bank = 34, Pin name = IO_0_34,								Sch name = LED17_R
#set_property PACKAGE_PIN K6 [get_ports RGB2_Red]					
	#set_property IOSTANDARD LVCMOS33 [get_ports RGB2_Red]
##Bank = 35, Pin name = IO_24P_T3_35,						Sch name =  LED17_G
#set_property PACKAGE_PIN H6 [get_ports RGB2_Green]					
	#set_property IOSTANDARD LVCMOS33 [get_ports RGB2_Green]
##Bank = CONFIG, Pin name = IO_L3N_T0_DQS_EMCCLK_14,			Sch name = LED17_B
#set_property PACKAGE_PIN L16 [get_ports RGB2_Blue]					
	#set_property IOSTANDARD LVCMOS33 [get_ports RGB2_Blue]





##Buttons

##Bank = 15, Pin name = IO_L11N_T1_SRCC_15,					Sch name = BTNC
set_property PACKAGE_PIN E16 [get_ports wr_i]						
	set_property IOSTANDARD LVCMOS33 [get_ports wr_i]


##Pmod Header JA
##Bank = 15, Pin name = IO_L1N_T0_AD0N_15,					Sch name = JA1
set_property PACKAGE_PIN B13 [get_ports {cs_o}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {cs_o}]
##Bank = 15, Pin name = IO_L5N_T0_AD9N_15,					Sch name = JA2
set_property PACKAGE_PIN F14 [get_ports {bit_tx_o}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {bit_tx_o}]
##Bank = 15, Pin name = IO_L16N_T2_A27_15,					Sch name = JA3
set_property PACKAGE_PIN D17 [get_ports {bit_rx_i}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {bit_rx_i}]
##Bank = 15, Pin name = IO_L16P_T2_A28_15,					Sch name = JA4
set_property PACKAGE_PIN E17 [get_ports {sclk_o}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sclk_o}]
 ````






















### 3.2 Interfaz UART

### 3.2.1 Módulo "control_register"

#### 1. Encabezado del módulo
```SystemVerilog 
module control_register(
    input  logic             clk_i,  
    input  logic             rst_i,  
    input  logic             wr1_i,  
    input  logic             wr2_i,  
    input  logic [31 : 0]    in1_i,  
    input  logic [31 : 0]    in2_i,  
    output logic [31 : 0]    out_o  
);
```
#### 2. Parámetros
- Este módulo no posee parámetros.

#### 3. Entradas y salidas:
- `clk_i`: Reloj de 10MHz .
- `rst_i`: Señal de reset activa en alto.
- `wr1_i`: Write enable del usuario.
- `wr2_i`: Write enable de la interfaz.
- `in1_i`: Entrada de datos por parte del usuario.
- `in2_i`: Entrada de datos por parte de la interfaz.
- `out_o`: Salida del registro de control.

#### 4. Criterios de diseño
Se utiliza para configurar el comportamiento de la UART y controlar las operaciones de recepción y transmisión de datos.
El registro de control para la unidad UART posee un ancho de 32 bits de los cuales solamente se utilizan los 2 primeros, el primero lleva la información del bit`send` cuando este bit es 1 quiere decir que se está transmitiendo información, cuando está en cero quiere decir que terminó la transmisión.

El otro bit a utilizar es el `new_rx`, este bit indica cuando la `UART` ha recibido un byte desde el sistema externoa  a la FPGA. El módulo funciona dandole la prioridad a la interfaz `wr2_i`, entonces la entrada `in1_i` `in2_i`la guarda en la salida del registro de control `out_o`.
#### 5. Testbench
Descripción y resultados de las pruebas hechas

### 3.2.2 Módulo "registro_datos_uart"

#### 1. Encabezado del módulo
```SystemVerilog 
module registro_datos_uart (
    input  logic             clk_i,      
    input  logic             rst_i,      
    input  logic             addr_i,     
    input  logic             hold_ctrl_i,  
    input  logic             wr1_i,      
    input  logic             wr2_i,      
    input  logic [31 : 0]    in1_i,      
    input  logic [31 : 0]    in2_i,      
    output logic [31 : 0]    out1_o,     
    output logic [31 : 0]    out2_o      
);
```
#### 2. Parámetros
- Este módulo no posee parámetros.

#### 3. Entradas y salidas:
- `clk_i`: Reloj de 10MHz .
- `rst_i`: Señal de reset activa en alto.
- `addr_i`: Puntero de lectura para el usuario.
- `hold_ctrl_i`: Da la prioridad para la escritura desde la interfaz.
- `wr1_i`: Write enable del usuario.
- `wr2_i`: Write enable de la interfaz.
- `in1_i`:  Entrada de datos desde el usuario al registro 0.
- `in2_i`: Entrada de datos de la interfaz al registro 1.
- `out1_o`: Lectura de datos de los registros 0 ó 1 al usuario.
- `out2_o`: Lectura de datos del registro 0 a la interfaz UART

#### 4. Criterios de diseño
Se utiliza para almacenar temporalmente los datos que se van a transmitir o que se han recibido.
Para este módulo se tiene el bit de `hlod_ctrl_i` el cual permite a la interfaz escribir en el registro de datos, además de esto el `wr2_i` permite a la interfaz escribir también al registros de datos 1 por medio de la entrada `in2_i`.

En el caso contrario de que el `wr1_i`
 está en 1  y el `hlod_ctrl_i` en cero, el usuario entonces puede escribir al registro de datos 0 por medio de la entrada `in1_i`. Para la lectura de datos del registro 0 o 1, se usa la salida de 32 bits `out1_o` para que el usuario pueda escoger a cual de los 2 registros acudir por medio del puntero `addr_i`. La salida de 32 bits `out2_o` solamente lee los datos del registro 0 a la interfaz.
#### 5. Testbench
El testbench del funcionamiento de este modulo se muestra en el testbench global de la unidad `UART`.



### 3.2.3 Módulo "fsm_new_rx"

#### 1. Encabezado del módulo
```SystemVerilog
module fsm_new_rx (
    input  logic     clk_i,                                 
    input  logic     rst_i,
    input  logic     rx_data_rdy,
    output logic     we_reg_control,
    output logic     wr2,
    output logic     hold_ctrl,                             
    output logic     new_rx
);
    
```
#### 2. Parámetros
- Este módulo no posee parámetros.

#### 3. Entradas y salidas:
- `clk_i`: Reloj de 10MHz .
- `rst_i`: Señal de reset activa en alto.
- `rx_data_rdy`: Señal que indica si la información ya fue recibida.
- `we_reg_control`: Write enable al registro de control
- `wr2`:Write enable del registro de datos 1.
- `hold_ctrl`:Habilita la escritura al registro de datos 1.
- `new_rx`:Recepción de un dato por el puerto serial.

#### 4. Criterios de diseño
Para la creación de este módulo primero realizamos un diagrama de flujo para poder apreciar mejor el proceso que sufre el bit `new_rx` cuando recibe información por el puerto serial.
![](https://i.imgur.com/zyThVUg.png)

También se hizo uso de un diagrama de estados.
![](https://i.imgur.com/LFIN5Ps.png)

Para el diseño de la maquina de estados se obtuvieron en total 3 estados, los cuales son  `INICIO`,`RECIBIDO` y `REGISTRO`. En el primer estado verifica si se recibieron correctamente los 8 bits ya se recibió completamente , si este es el caso entonces habilita el `wr2` para guardar el dato en el registro de datos 1 y pasa al estado de `RECIBIDO`, si no se han recibido los 8 bits entonces la maquina se mantiene en `INICIO` hasta que se complete.

En el estado `RECIBIDO`, se pone la variable `new_rx` en 1 para indicar que se recibio un dato por el puerto serial y se habilita el write enable del registro de control `we_reg_control` y pasa al ultimo estado.

En el ultimo estado `REGISTRO` lo unico de lo que se encarga es de volver al estado `INICIAL`.



#### 5. Testbench
El testbench de ese módulo se presenta en el testbench de top_UART.




### 3.2.4 Módulo "fsm_tx_uart"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas




### 3.2.5 Módulo "nivel_a_pulso"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas











### 3.2.6 Módulo "top_uart"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas




























### 3.3 Lectura de un sensor de luminosidad

Para este ejercicio se solicitó hacer uso del sensor de luminosidad PMOD ALS, mediante el uso de la interfaz SPI para la recolección de datos, donde después se utilizó los conversores de binario a decimal y de decimal a código ASCII para así mediante la Interfaz UART serial del computador se pudiese ver el resultado sensado en pantalla. En este proyecto se utilizaron los módulos completos de UART y SPI anterior mente descritos por ende se documentó los módulos restantes que lo conforman.

### 3.3.1 Módulo "7_seg_disp"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas



### 3.3.2 Módulo "add3"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas





### 3.3.3 Módulo "bcd2ascii"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas






### 3.3.4 Módulo "binary_to_bcd"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas







### 3.3.5 Módulo "mux_4_1"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas





### 3.3.6 Módulo "top_PMOD_ALS"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas



### 3.3.7 Módulo "top_UART_PMOD"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas





### 3.3.8 Módulo "unidad_de_control_pmod_v2"

#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_i`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas




## Apendices:
### Apendice 1:
texto, imágen, etc

