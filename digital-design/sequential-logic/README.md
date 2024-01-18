# Laboratorio 2: Lógica secuencial

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays.
- **WE**: Write Enable.
- **LSFR**: Linear-Feedback Shift Register.
- **MUX**: Multiplexor

## 2. Referencias
[1] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

[2] Chu, Pong P, *FPGA Prototyping by SystemVerilog Examples: Xilinx MicroBlaze MCS SoC Edition*. John Wiley & Sons, 2018.

## 3. Desarrollo

## 3.1 Módulo Reloj

#### 1. Encabezado del módulo

```SystemVerilog
module module_Reloj (
    input  logic clk,
    output logic clk_10m,
    output logic locked
);
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `clk`: Entrada de reloj de 100 MHz.
- `clk_10m`: Salida de reloj de 10 MHz.
- `locked`: Salida de señal de reset.

#### 4. Criterios de diseño

El módulo *Reloj* se encarga de transformar la señal de reloj de 100 MHz de la FPGA a una señal de 10 MHz, la cual se utiliza en todos los demás módulos. Este cambio en la frecuencia de reloj se realiza mediante el *IP-CORE* *Clocking Wizard*. La entrada corresponde a la señal de reloj de la FPGA, y sus salidas corresponden a la señal de reloj con frecuencia de 10 MHz y una señal `locked` que se utiliza como el reset automático para los demás módulos. Esta señal `locked` inicia en valor lógico 1, y cuando el reloj de 10 MHz ya se estabilizó, dicha señal se coloca en valor lógico 0. Los demás módulos se diseñaron con reset activo en bajo, de tal forma que, al iniciarse el sistema, automáticamente se aplica un reset a los diversos flip-flops. Una vez que el reloj se estabiliza, el sistema ya tiene aplicado un reset el cual define valores para los flip-flops, la señal de reset se coloca en 1 lógico y ahora sí el sistema está listo para operar.

#### 5. Testbench

Para la prueba del testbench, se emula la señal de reloj de 100 MHz (periodo de 10 ns) y se observa que la señal de salida de reloj corresponda a una señal de 10 MHz (periodo de 100 ns). El resultado se observa en la siguiente figura:

![](https://i.imgur.com/biDF64W.png)

## 3.2 Módulo Antirebote, Sincronizador y Contador

### 3.2.1 Módulo top_Cont_AR_S

#### 1. Encabezado del módulo

```SystemVerilog
module module_Reloj (
    input  logic clk,
    input  logic btn,
    output logic [7:0] LEDs
);
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `clk`: Entrada de reloj de 100 MHz.
- `btn`: Entrada de la señal proveniente de un pulsador.
- `LEDs`: Array de salida conteniendo el valor en binario del contador.

#### 4. Criterios de diseño

El módulo *top_Cont_AR_S* corresponde a la unión de 4 bloques diferentes: *Reloj*, *Antirebote*, *Sincronizador* y *Contador*. El diagrama de bloques se muestra en la siguiente figura:

![](https://i.imgur.com/jEdskIo.png)

Este módulo hace un llamado a los otros 4 módulos: *Reloj*, *Antirebote*, *Sincronizador* y *Contador*.

#### 5. Testbench

Para la prueba del testbench, se emula la señal de reloj de 100 MHz (periodo de 10 ns), así como una señal con rebote. El bótón se pulsa 3 veces para visualizar el cambio en el contador a 1,2 y 3 respectivamente. El resultado se observa en la siguiente figura:

![](https://i.imgur.com/qwiKtGA.png)

### 3.2.2 Módulo Antirebote

#### 1. Encabezado del módulo

```SystemVerilog
module module_Antirebote (
    input  logic clk,
    input  logic reset,
    input  logic btn,
    output logic Q
);
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `clk`: Entrada de la señal de reloj de 10 MHz.
- `reset`: Entrada de la señal de reset.
- `btn`: Señal de entrada con rebote.
- `Q`: Señal de salida sin rebote.

#### 4. Criterios de diseño

Para el diseño del bloque Antirebote, se utiliza un latch SR. El módulo tiene como variables locales S y R. La señal de entrada `btn` define los valores de S y R: cuando la señal de entrada es valor lógico 1, S y R se colocan en 1 y 0 respectivamente. Estos valores determinan un "set" para el latch SR, y la salida `Q` se coloca en 1. Cuando la señal de entrada es valor lógico 0, S y R se colocan en 0 y 1 respectivamente. Estos valores determinan un "reset" para el latch SR, y la salida `Q` se coloca en 0.

#### 5. Testbench

Este módulo no tiene un testbench, en su lugar existe un testbench que incluye el funcionamiento del sistema completo. Referirse a 3.2.1 Módulo top_Cont_AR_S.

### 3.2.3 Módulo Sincronizador

#### 1. Encabezado del módulo

```SystemVerilog
module module_Sincronizador (
    input  logic clk,
    input  logic reset,
    input  logic D0,
    output logic D1
);
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `clk`: Entrada de la señal de reloj de 10 MHz.
- `reset`: Entrada de la señal de reset.
- `D0`: Dato de entrada.
- `D1`: Dato de salida.

#### 4. Criterios de diseño

Para el diseño del bloque Sincronizador, el problema principal a resolver corresponde a la metaestabilidad, la cual ocurre cuando se intenta utilizar una señal en el proceso de cambiar de estado lógico bajo a alto y viceversa. Al conectar 2 flip-flops en serie, debido a la señal de reloj así como el tiempo de retardo de los componentes, la señal tiene el tiempo suficiente para cambiar su estado lógico y estabilizarse en dicho estado (La señal tiene el tiempo necesario para resolver su posible estado metaestable).

#### 5. Testbench

Este módulo no tiene un testbench, en su lugar existe un testbench que incluye el funcionamiento del sistema completo. Referirse a 3.2.1 Módulo top_Cont_AR_S.

### 3.2.4 Módulo Contador

#### 1. Encabezado del módulo

```SystemVerilog
module module_Contador(
    input logic         clk,
    input logic         rst_n_i,
    input logic         en_i,
    output logic [7:0]  conta_o
    );
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `clk`: Entrada de la señal de reloj de 10 MHz.
- `rst_n_i`: Entrada de la señal de reset.
- `en_i`: Entrada de la señal habilitadora.
- `conta_o`: Array conteniendo el valor del contador en binario.

#### 4. Criterios de diseño

El bloque Contador fue proporcionado por el profesor. Además de las entrads y salidas mencionadas, tiene un array local "registro_en_r" que se encarga de guardar el último valor de la señal habilitadora `en_i` y el valor actual de la misma. Este array tiene la finalidad de poder visualizar si en `en_i` existe un flanco positivo. Por ejemplo, si el valor anterior de `en_i` es 0 y el valor actual de `en_i` es 1, se considera como un flanco positivo de la señal. Cuando esto ocurre, el contador debe avanzar al siguiente valor. Por lo que al presionar un botón (flanco positivo), el contador debe avanzar al siguiente valor. Cuando el botón se suelta (flanco negativo), el contador no debe avanzar al siguiente valor.

#### 5. Testbench

Este módulo no tiene un testbench, en su lugar existe un testbench que incluye el funcionamiento del sistema completo. Referirse a 3.2.1 Módulo top_Cont_AR_S.

## 3.3 Módulo Interfaz del teclado

### 3.3.1 Módulo top_InterfazTeclado

#### 1. Encabezado del módulo

```SystemVerilog
module module_InterfazTeclado (
    input  logic clk,
    input  logic F0,
    input  logic F1,
    input  logic F2,
    input  logic F3,
    input  logic A,
    input  logic B,
    output logic C0,
    output logic C1,
    output logic [7:0] segments,
    output logic [7:0] an,
    output logic LED_Verif
);
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `clk`: Entrada de reloj de 100 MHz.
- `F0`: Fila 0 del teclado.
- `F1`: Fila 1 del teclado.
- `F2`: Fila 2 del teclado.
- `F3`: Fila 3 del teclado.
- `A`: Bit más significativo de salida del codificador.
- `B`: Bit menos significativo de salida del codificador.
- `C0`: Bit menos significativo de salida del decodificador.
- `C1`: Bit más significativo de salida del decodificador.
- `segments`: Segmentos del display a encender o apagar.
- `an`: Salida encargada de activar o desactivar los ánodos de los displays de la FPGA.
- `LED_Verif`: Salida en un LED para verificar que se está presionando una tecla.

#### 4. Criterios de diseño

Este módulo hace un llamado a los bloques que conforman la interfaz del teclado: *Reloj*, *Antirebote*, *Contador_2_Bits*, *VerificadorTecla* y *TecladoCodif*. El siguiente diagrama de bloques ilustra como están conectados los diversos bloques:

![](https://i.imgur.com/M6Sv7zO.png)

#### 5. Testbench

Para la prueba de testbench, se inicialmente asigna las filas en 1 y se emula el reloj de 100 MHz. En un determinado momento en el tiempo, la fila 2 se coloca en 0, como si se estuviera presionando alguna tecla de la fila 2. El módulo toma el valor del encodificador así como el valor de la columna en la que se encuentra. En este caso, el contador de columnas va por "00" y el valor del encodificador corresponde a "01". Por lo que el valor de entrada al codificador de teclado corresponde a "0010", y lo convierte a "1110", lo que corresponde a una "e" en el display de 7 segmentos. El resultado descrito se observa en la siguiente figura:

![](https://i.imgur.com/GMKcdmY.png)

### 3.3.2 Módulo Contador_2_Bits

#### 1. Encabezado del módulo

```SystemVerilog
module module_Contador_2_Bits (
    input logic  clk,      
    input logic  reset,
    input logic  en,
    output logic [1:0] contador
);
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `clk`: Entrada de señal de reloj de 10 MHz.
- `reset`: Entrada de señal de reset.
- `en`: Entrada de señal habilitadora.
- `contador`: Array de salida con el valor del contador de columnas

#### 4. Criterios de diseño

Este bloque se encarga de recorrer las columas del teclado. Consiste en un contador de 2 bits (0 hasta 3), con una frecuencia de 1 kHz (periodo 1 ms). Para reducir la frecuencia del reloj de 10 MHz a 1 kHz, se utiliza un segundo contador que envía una señal habilitadora a los flip-flops correspondientes del contador de 2 bits. Al mismo tiempo, el contador de 2 bits tiene una señal inhabilitadora `en`, la cual frena el contador en el valor de la columna en el que se encuentra, para permitir a los demás bloques capturar en cuál columna se encuentra ubicada la tecla que se está presionando. La señal inhabilitadora `en` proviene de la salida del bloque VerificarTecla (referirse a 3.3.3 Módulo VerificarTecla), porque el contador de 2 bits de las columnas debe detenerse cuando se confirma que se está presionando una tecla.

#### 5. Testbench

Este módulo no tiene un testbench, en su lugar existe un testbench que incluye el funcionamiento del sistema completo. Referirse a 3.3.1 Módulo top_InterfazTeclado.

### 3.3.3 Módulo VerificarTecla

#### 1. Encabezado del módulo

```SystemVerilog
module module_VerificadorTecla (
    input logic F0,
    input logic F1,
    input logic F2,
    input logic F3,
    output logic V
);
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `F0`: Fila 0 del teclado.
- `F1`: Fila 1 del teclado.
- `F2`: Fila 2 del teclado.
- `F3`: Fila 3 del teclado.
- `V`: Bit de salida.

#### 4. Criterios de diseño

Este bloque no tiene lógica compleja: si todas las filas se encuentran en 1, no se está presionando ninguna tecla, por lo que el bit de salida `V` se coloca en 0. De otra forma, el bit de salida `V` se coloca en 1. Este bit de salida es muy importante debido a que frena el contador que recorre las columnas del teclado, para que se pueda capturar la columna y la fila de la tecla que se está presionando. Y también se utiliza como señal habilitadora para sincronizar los datos de la columna y fila de la tecla presionada y ser enviados al codificador de tecla para finalmente aparecer en el display de la FPGA.

#### 5. Testbench

Este módulo no tiene un testbench, en su lugar existe un testbench que incluye el funcionamiento del sistema completo. Referirse a 3.3.1 Módulo top_InterfazTeclado.

### 3.3.4 Módulo TecladoCodif

#### 1. Encabezado del módulo

```SystemVerilog
module module_TecladoCodif (
    input  logic [3:0] in,
    output logic [3:0] out
);
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `in`: Array con la información de posición de la tecla presionada.
- `out`: Array con la información de etiqueta de la tecla presionada.

#### 4. Criterios de diseño

Este bloque no tiene lógica compleja: corresponde a un *case* que obedece a la siguiente tabla:


| C1  | C0  | F1  | F0  | A   | B   | C   | D   |
|:---:| --- | --- | --- | --- | --- | --- | --- |
| 0   | 0   | 0   | 0   | 0   | 0   | 0   | 1   |
| 0   | 0   | 0   | 1   | 0   | 1   | 0   | 0   |
| 0   | 0   | 1   | 0   | 0   | 1   | 1   | 1   |
| 0   | 0   | 1   | 1   | 1   | 1   | 1   | 0   |
| 0   | 1   | 0   | 0   | 0   | 0   | 1   | 0   |
| 0   | 1   | 0   | 1   | 0   | 1   | 0   | 1   |
| 0   | 1   | 1   | 0   | 1   | 0   | 0   | 0   |
| 0   | 1   | 1   | 1   | 0   | 0   | 0   | 0   |
| 1   | 0   | 0   | 0   | 0   | 0   | 1   | 1   |
| 1   | 0   | 0   | 1   | 0   | 1   | 1   | 0   |
| 1   | 0   | 1   | 0   | 1   | 0   | 0   | 1   |
| 1   | 0   | 1   | 1   | 1   | 1   | 1   | 1   |
| 1   | 1   | 0   | 0   | 1   | 0   | 1   | 0   |
| 1   | 1   | 0   | 1   | 1   | 0   | 1   | 1   |
| 1   | 1   | 1   | 0   | 1   | 1   | 0   | 0   |
| 1   | 1   | 1   | 1   | 1   | 1   | 0   | 1   |

Donde `in` = {C1,C0,F1,F0} y `out` = {A,B,C,D}.

#### 5. Testbench

Este módulo no tiene un testbench, en su lugar existe un testbench que incluye el funcionamiento del sistema completo. Referirse a 3.3.1 Módulo top_InterfazTeclado.

## 3.4. Módulo Decodificador hex-to-7-segments

### 3.4.1. Módulo "control_disp_7_seg"

El módulo *module_control_disp_7_seg* se encarga de generar las señales de control de los 8 displays de 7 segmentos presentes en la tarjeta Nexys 4, dadas por `an`. Las entradas `hex0`, `hex1`, `hex2` y `hex3` son multiplexadas a una frecuencia tal no sea posible notar el "parpadeo" en los displays. 


#### 1. Encabezado del módulo

```SystemVerilog
module module_control_disp_7_seg(
    input logic             clk,
    input logic             rst,
    input logic [3 : 0]     hex0,
    input logic [3 : 0]     hex1,
    input logic [3 : 0]     hex2,
    input logic [3 : 0]     hex3,
    output logic [7 : 0]    an,
    output logic [7 : 0]    seg
);
```
#### 2. Parámetros

Este módulo no contiene parámetros.

#### 3. Entradas y salidas:
- `clk`: Entrada del reloj del módulo.
- `rst`: Entrada del reset del módulo, activo en bajo.
- `hex0`: Entrada del primer dígito hexadecimal.
- `hex1`: Entrada del segundo dígito hexadecimal.
- `hex2`: Entrada del tercer dígito hexadecimal.
- `hex3`: Entrada del cuarto dígito hexadecimal.
- `an`: Salida encargada de activar o desactivar los ánodos de los displays de la FPGA.
- `seg`: Salida del módulo que corresponde al arreglo que contiene la información sobre cuál de los 8 segmentos del display debe ser encendido (incluyendo el punto decimal). 

#### 4. Criterios de diseño

Para la creación de este módulo se basó en el diagrama de bloques provisto en [2], este se muestra en la siguiente figura:

![](https://i.imgur.com/Fem5u2i.jpg)

Tanto los ánodos como los segmentos de los displays son muestreados a una frecuencia de 610 Hz aproximadamente (10 MHz/2^14), ya que se usan los bits más significativos del contador de 16 bits. Esto permite visualizar el contenido de una palabra de 16 bits en 4 displays de la FPGA. A los 4 bits más significativos de `an` se les asigna un 1 lógico por defecto, puesto que solo son necesarios los 4 primeros displays de la tarjeta.

La implementación se realizó con tres bloques always: uno para el contador, otro para el decodificador 2 a 4 junto con el mux y el último para el decodificador para el display de 7 segmentos.

#### 5. Testbench

No se ha diseñado un testbench para este módulo.

### 3.4.2. Módulo "pipo_register"
El módulo *module_pipo_register* corresponde a un registro de entrada y salida en paralelo con WE de 16 bits.

#### 1. Encabezado del módulo

```SystemVerilog
module module_pipo_register( 
    input logic             clk,
    input logic             rst,
    input logic             we,
    input logic [15 : 0]    data_in,
    output logic [15 : 0]   data_out
);
```

#### 2. Parámetros

Este módulo no tiene parámetros.

#### 3. Entradas y salidas:

- `clk`: Entrada del reloj del módulo.
- `rst`: Entrada del reset del módulo, activo en bajo.
- `we`: Entrada que permite la escritura en el registro.
- `data_in`: Entrada de datos de 16 bits.
- `data_out`: Salida del registro.


#### 4. Criterios de diseño

El circuito lógico de un registro con entrada y salida paralela se muestra a continuación:

![](https://i.imgur.com/WVe6EGK.png)

La implementación se realizó en un solo bloque always para registrar los datos de entrada solo si `we` está activado.

#### 5. Testbench

No se creó un testbench para este módulo.

### 3.4.3. Módulo "contador_2_segundos"

Este bloque *module_contador_2_segundos* permite habilitar la escritura del registro `module_pipo_register` para que muestre el valor aleatorio provisto por el LSFR cada 2 segundos aproximadamente.

#### 1. Encabezado del módulo
```SystemVerilog
module module_contador_2_segundos(
    input logic     clk,
    input logic     rst,
    output logic    enable
);
```
#### 2. Parámetros

Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `clk`: Entrada del reloj del módulo.
- `rst`: Entrada del reset del módulo, activo en bajo.
- `enable`: Salida que habilita la escritura en el registro.

#### 4. Criterios de diseño

La implementación de este bloque se realizó en un solo bloque always, en el cual se pregunta si `contador` ha alcanzado el valor de 20x10^6 (10 MHz/0,5 Hz), lo cual corresponde a una frecuencia de 0,5 Hz; es decir, un período de 2 segundos. Cuando se alcanza ese valor, se hace un reset de `contador` y se genera una señal de enable, dada por `enable`.

#### 5. Testbench

Este módulo no tiene testbench.

### 3.4.4. Módulo "lfsr"

El módulo `LFSR` se encarga de generar datos aleatorios en cada ciclo del reloj.

#### 1. Encabezado del módulo
```SystemVerilog
module LFSR #(parameter NUM_BITS = 4) 
(
   input logic                     i_clk,
   input logic                     i_rst,
   input logic                     i_enable,
   input logic [NUM_BITS-1:0]      i_seed_data,
   output logic [NUM_BITS-1:0]     o_lfsr_data,
   output logic                    o_lfsr_done
);
```

#### 2. Parámetros

- `NUM_BITS`: Define el número de bits de la palabra que se desea generar.

#### 3. Entradas y salidas:

- `i_clk`: Entrada del reloj del módulo.
- `i_rst`: Entrada del reset del módulo, activo en bajo.
- `i_enable`: Salida que habilita la escritura en el registro.
- `i_seed_data`: Entrada opcional del valor inicial al cual se empiezan a generar datos aleatorios.
- `o_lfsr_data`: Salida de datos aleatorios.
- `o_lfsr_done`: Salida que indica si se han generado los datos.


#### 4. Criterios de diseño

Este módulo fue provisto como insumo por el profesor.

#### 5. Testbench

El módulo no tiene testbench.

### 3.4.5. Módulo "top_hex_to_7_segments"

Es el módulo *TOP* del sistema. En este se hace instancia del control para los displays, el *Clocking Wizard*, el registro de entrada y salida paralela, el LFSR, así como el módulo `module_contador_2_segundos`.

#### 1. Encabezado del módulo

```SystemVerilog
module top_hex_to_7_segments(
    input logic             clk,
    output logic [7 : 0]    an,
    output logic [7 : 0]    seg    
);
```

#### 2. Parámetros

El módulo no tiene parámetros.

#### 3. Entradas y salidas:

- `clk`: Entrada del reloj del módulo.
- `an`: Salida que se conecta con los ánodos de la FPGA.
- `seg`: Salida que se conecta con los segmentos de los displays de la tarjeta.

#### 4. Criterios de diseño

El diseño de este módulo se basa en el siguiente diagrama de bloques:

![](https://i.imgur.com/5RtgerP.jpg)

Como se puede observar, el reloj de 100 MHz de la FPGA se pasa por el bloque del *Clocking Wizard*, el cual genera un reloj de 10 MHz que es con el que se trabaja en todos los demás módulos. El `LFSR` genera datos aleatorios cada flanco positivo del `clk`, sin embargo, el contador genera el WE únicamente cada 2 segundos. Por lo tanto, el registro de entrada y salida paralela mantiene el dato en los displays de 7 segmentos por 2 segundos también.

### 5. Contraints

Los pines asignados son:

| Señal | Pin    | En tarjeta |
| ----- | ------ | ---------- |
| clk   | E3     | CLK100MHZ  |
| seg[0] | L3 | CA    |
| seg[1] | N1 | CB    |
| seg[2] | L5 | CC    |
| seg[3] | L4 | CD    |
| seg[4] | K3 | CE    |
| seg[5] | M2 | CF    |
| seg[6] | L6 | CG    |
| seg[7] | M4 | DP    |
| an[0] | N6 | AN0    |
| an[1] | M6 | AN1    |
| an[2] | M3 | AN2   |
| an[3] | N5 | AN3   |
| an[4] | N2 | AN4   |
| an[5] | N4 | AN5   |
| an[6] | L1 | AN6   |
| an[7] | M1 | AN7   |





Se definieron los siguientes constraints:

```sdc
set_property PACKAGE_PIN E3 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

set_property PACKAGE_PIN L3 [get_ports {seg[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
	
set_property PACKAGE_PIN N1 [get_ports {seg[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]

set_property PACKAGE_PIN L5 [get_ports {seg[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]

set_property PACKAGE_PIN L4 [get_ports {seg[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]

set_property PACKAGE_PIN K3 [get_ports {seg[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]

set_property PACKAGE_PIN M2 [get_ports {seg[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]

set_property PACKAGE_PIN L6 [get_ports {seg[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

set_property PACKAGE_PIN M4 [get_ports seg[7]]							
	set_property IOSTANDARD LVCMOS33 [get_ports seg[7]]
    
set_property PACKAGE_PIN N6 [get_ports {an[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]

set_property PACKAGE_PIN M6 [get_ports {an[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]

set_property PACKAGE_PIN M3 [get_ports {an[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]

set_property PACKAGE_PIN N5 [get_ports {an[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

set_property PACKAGE_PIN N2 [get_ports {an[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[4]}]

set_property PACKAGE_PIN N4 [get_ports {an[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[5]}]

set_property PACKAGE_PIN L1 [get_ports {an[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[6]}]

set_property PACKAGE_PIN M1 [get_ports {an[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[7]}]
````


#### 6. Testbench

El testbench se encuentra en `tb_deco_hex_to_7_segments.sv`. En este se instancia el *Clocking Wizard*, el módulo de control, el LFSR y el registro de entrada y salida en paralelo. Se decidió no hacer instancia del archivo *TOP* únicamente, debido a que dentro de este archivo se encuentra el contador 2 segundos que hace que el tiempo de simulación sea excesivamente alto. Por lo tanto, en el testbench se generan señales de WE cada cierto tiempo para ver el funcionamiento de los demás bloques en conjunto. 

La siguiente figura muestra el resultado de la simulación post-síntesis.

![](https://i.imgur.com/92XlRUM.png)

En esta se puede observar que el registro escribe los datos del LFSR, `o_lfsr_data`, en el siguiente flanco positivo de `clk_10m` únicamente cuando la señal de *enable* se encuentra habilitada. Cuando *enable* toma el valor de cero lógico, el registro mantiene el dato hasta que se vuelva a habilitar la escritura, lo mismo ocasiona que `seg` mantenga ese valor durante el mismo tiempo.
En la simulación se observa que `an` no cambia su valor, puesto que no han pasado los suficientes ciclos del reloj `clk_10m` como para cambiar su valor y habilitar el siguiente ánodo. 




## 3.5 Módulo Program Counter (PC)

#### 1. Encabezado del módulo
```SystemVerilog
parameter ANCHO = 4
)(                                                                  
    input logic     [ANCHO - 1 : 0] pc_i,                           
    input logic     [1 : 0]         pc_op_i,                       
    input logic                     clk,                           
    input logic                     reset,                        
                                                        
    output logic    [ANCHO - 1 : 0] pc_o,                           
    output logic    [ANCHO - 1 : 0] pcinc_o                        
);
```
#### 2. Parámetros
- Para el Program Counter (PC) solo se utilizó un parametro de `ANCHO` de palabra ya que las direcciones son parametrizables y así lograr diferentes dimensiones del contador. En este caso se utilizó 4 bits por conveniencia.

#### 3. Entradas y salidas:
- `clk`: Entrada que define el ciclo de reloj al cual va a responder el módulo.
- `reset`: Da una señal que envia al registro entero a un valor de cero.
- `pc_i`: Entrada que define la dirección de salto cuando esta operación se ejecuta en el `pc_op_i`.
- `pc_op_i`: Entrada que me define la función a realizar en el PC, si el valor es `00` ejecuta la función de `reset`, si es `01` ejecuta la función de `hold`, si es `10` ejecuta la función de `PC+4` y si es `11` ejecuta la función `jump` a la dirección definida en `pc_i`.
- `pc_o`: Salida del contador que me va contando de 4 en 4 por cada pulso de reloj.
- `pcinc_o`: Salida que me indica la posición de `PC+4` para cuando se ejecuta una operación de `jump`.


#### 4. Criterios de diseño
Este PC se diseñó mediante las especificaciones dadas en el instructivo, donde se tuvo en cuenta que el valor fuera aumentando de 4 en 4, mediante una lógica secuencial con respecto al `clk`. Se planteó el siguiente diagrama de bloques relacionado al PC.

![](https://i.imgur.com/tWABtCW.png)

Aquí se define el funcionamiento de cada uno de los operandos de instrucción, donde como vemos para el valor `00` el genera un reset de todas las variables de salida utilizadas. `01` mantiene el valor del PC que esté en ese periodo de reloj. `10` ejecuta la función de `PC+4` indefinidamente y cuando llega al máximo de bits reinicia con el valor de `0`. Y la función `11` ejecuta el`jump` que me permite hacer un salto a mi dirección definida.
Cabe destacar que para la implementación en la FPGA se necesitó definir un contador para reducir el reloj mediante técnicas apropiadas para FPGAs. Que se puede encontrar dentro del módulo `module_PC_FPGA`, y se logró reducir la frecuencia a un valor de 0.1 Hertz para su funcionamiento correcto.


#### 5. Contraints

Los pines asignados son:

| Señal | Pin    | En tarjeta |
| ----- | ------ | ---------- |
| clk   | E3     | CLK100MHZ  |
| pc_op_i[0]| U9 | SW0    |
| pc_op_i[1] | U8 | SW1    |
| pc_i[0] | T1 | SW12    |
| pc_i[1] | R3 | SW13    |
| pc_i[2]| P3 | SW14    |
| pc_i[3]| P4 | SW15    |
| led1_o[0] | T8 | LED0  |
| led1_o[1] | V9 |LED1   |
| pcinc_o[0] | T5 | LED4   |
| pcinc_o[1] | T4 | LED5  |
| pcinc_o[2] | U7 | LED6   |
| pcinc_o[3] | U6 | LED7  |
| pc_o[0] | V4 | LED8   |
| pc_o[1] | U3 | LED9   |
| pc_o[2] | V1 | LED10  |
| pc_o[3] | R1 | LED11 |
| led4_o[0] | P5 | LED12   |
| led4_o[1] | U1 | LED13   |
| led4_o[2] | R2 | LED14   |
| led4_o[3] | P2 | LED15   |






Se definieron los siguientes constraints:

```sdc
set_property PACKAGE_PIN E3 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
    
set_property PACKAGE_PIN U9 [get_ports {pc_op_i[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_op_i[0]}]
    
set_property PACKAGE_PIN U8 [get_ports {pc_op_i[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_op_i[1]}]
    
set_property PACKAGE_PIN T1 [get_ports {pc_i[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_i[0]}]
    
set_property PACKAGE_PIN R3 [get_ports {pc_i[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_i[1]}]
    
set_property PACKAGE_PIN P3 [get_ports {pc_i[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_i[2]}]
    
set_property PACKAGE_PIN P4 [get_ports {pc_i[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_i[3]}]
    

set_property PACKAGE_PIN T8 [get_ports {led1_o[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led1_o[0]}]

set_property PACKAGE_PIN V9 [get_ports {led1_o[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led1_o[1]}]


set_property PACKAGE_PIN T5 [get_ports {pcinc_o[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pcinc_o[0]}]

set_property PACKAGE_PIN T4 [get_ports {pcinc_o[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pcinc_o[1]}]

set_property PACKAGE_PIN U7 [get_ports {pcinc_o[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pcinc_o[2]}]

set_property PACKAGE_PIN U6 [get_ports {pcinc_o[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pcinc_o[3]}]

set_property PACKAGE_PIN V4 [get_ports {pc_o[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_o[0]}]

set_property PACKAGE_PIN U3 [get_ports {pc_o[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_o[1]}]

set_property PACKAGE_PIN V1 [get_ports {pc_o[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_o[2]}]

set_property PACKAGE_PIN R1 [get_ports {pc_o[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pc_o[3]}]

set_property PACKAGE_PIN P5 [get_ports {led4_o[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led4_o[0]}]

set_property PACKAGE_PIN U1 [get_ports {led4_o[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led4_o[1]}]

set_property PACKAGE_PIN R2 [get_ports {led4_o[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led4_o[2]}]

set_property PACKAGE_PIN P2 [get_ports {led4_o[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led4_o[3]}]
    
````


#### 6. Testbench
Para el Program Counter se hizo un testbench exhaustivo con un reloj de 10MHz. La siguiente imagen detalla lo anterior.
![](https://i.imgur.com/bUR8Nkf.png)


Para este testbench se realizó todas las funciones del PC, donde se puso a prueba el funcionamiento de cada una de las entradas y salidas, se logra observar que cuando el valor es `01` en `pc_o` mantiene el valor de entrada y luego cuando se cambia a `01` luego de un pulso de reloj el `pc_o` comienza a contar de 4 en 4 a partir del valor de inicio, y como se logra observar realizó la secuencia `0, 4, 8, c` hasta llegar a la nueva instrucción de `hold`.

Luego se ejecuta la función `10` de nuevo que indica que empiece a contar desde el número anterior y lo realiza con éxito. Seguidamente se ejecuta la función `11` con el valor de `pc_i` igual a `0011` lo que indica es que me realice un salto a la dirección `0011` o `3` decimal y además en pcinc_o muestreme justo el valor de `PC` más 4 unidades que realiza perfectamente. Luego este valor se pone en `0` de nuevo.










## 3.6 Módulo Banco de Registros
#### 1. Encabezado del módulo
```SystemVerilog
module reg_bank#(
    parameter  W = 8,   
    parameter  N = 3   
)
(
     input logic                  clk,
     input logic                  reset,       
     input logic                  we,          
     input logic     [2**N-1:0]   addr_rd,     
     input logic     [2**N-1:0]   addr_rs1,    
     input logic     [2**N-1:0]   addr_rs2,    
     input logic     [W-1:0]      data_in,     
     output logic    [W-1:0]      rs1,         
     output logic    [W-1:0]      rs2     
);
```
#### 2. Parámetros
- Para el banco de registros se utilizaron 2 parámetros, el ancho de palabra el cual se representa con `W`, yla profundidad del banco de registros el cual está dado por `N`, será el valor 2 a la n para obtener así la profuncidad real del banco de registros.

#### 3. Entradas y salidas:
- `clk`: Entrada que define el ciclo de reloj al cual va a responder el módulo.
- `reset`: Da una señal que envia al registro entero a un valor de cero.
- `we`: Caundo está activado permite al registro escribirse.
- `addr_rd`: Puntero de escritura, donde está apuntando es el espacio del banco de registros donde  se va a sobreescribir.
- `addr_rs1`: Puntero de lectura, donde esté apuntando va a leer el dato que este escrito.
- `addr_rs2`: Puntero de lectura, donde esté apuntando va a leer el dato que este escrito.
- `data_in`: Valor que se sobreescribirá a través de `addr_rd`.
- `rs1`: Salida que muestra en pantalla a cual valor está apuntando el valor `addr_rs1`.
- `rs2`: Salida que muestra en pantalla a cual valor está apuntando el valor `addr_rs2`.


#### 4. Criterios de diseño
Para el diseño del banco de registros se tuvieron en cuenta las especificaciones dadas en el instructivo, basicamente un banco de registros se compone de los espacios  de profundidad de este, el data de entrada, el puntero de escritura y de lectura además de la señal de reloj, como se muestra en el siguiente figura.

![](https://i.imgur.com/imU7J5a.png)

Como se puede ver anteriormente el registro va a tener una cantidad de 2^`N` registros o "filas", cada uno de estos registros tendra una dato  con una cantidad de `W` bits, además de esto tendrá un puntero de lectura, para este caso las intrucciones indicaban que serían 2 punteros de lectura `addr_rs1` y `addr_rs2` que se van moviendo a tráves de lo largo del registro, con sus respectivas salidas `rs1` y `rs2` donde se puede observar el dato de `W bits`. Para la escritura de los datos se utiliza el puntero `addr_rd` que se moverá entre las filas del registro y con `data_in` se sobreescribira la fila a la que este apuntando el puntero de escritura. Esto se hace siguiendo los pulsos del `clk` el cual funciona auna frecuencia de 10 MHz, además de un `reset` para poder poner todas las filas del registro con un valor de cero.

Se puso la condición de que el registro número cero, esto quiere decir que la primera fila del banco siempre tendrá un valor de 0 y que nunca va a poder ser sobreescrito. Para esto se utilizó una  condición que basicamente hace que si `addr_rd` no está en cero entonces que pueda escribir, si está en cero  que le sobreescriba un 0 para así mantener ese valor.


#### 5. Testbench
Para el testbench se generó un señal de `we` la cual posee un una frecuencia menor a la del `clk`, esto para poder simular el pulso real de la FPGA la cual es mucho mayor al del `clk`, además se le introdujo valores aleatorios a la entrada `data_in` para que introdujera valores segun donde esté apuntando `addr_rd`, para el testbench se ultilizó un banco de registros de 16 bits x 32 registros, en la siguiente figura se puede observar la simulación post-sintesis del módulo.

![](https://i.imgur.com/ab8c5rk.jpg)

Para este caso el puntero `addr_rs1` se mantiene apuntando al registro cero para verificar que nunca se sobreescriba y el `addr_rs2` apunta al registro anterior con respecto `addr_rd`. El modulo presenta un pequeño de desfase el cual está alrededor 6.324 ns como se muestra en la siguiente figura.

![](https://i.imgur.com/OneMIkN.jpg)





## 3.7. Módulo "Unidad de Cálculo"
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

![](https://i.imgur.com/2IasRW3.png)

![](https://i.imgur.com/pb21khR.png)




#### 5. Testbench
Descripción y resultados de las pruebas hechas

## Apendices:
### Apendice 1:
texto, imágen, etc

