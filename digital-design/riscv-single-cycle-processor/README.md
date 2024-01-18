# Lab. 4: Microcontrolador

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo


### 3.1 Microprocesador monociclo

La arquitectura del microprocesador desarrollado se basa en los siguientes módulos:

* `module_riscvsingle.sv`
* `module_controller.sv`
* `module_datapath.sv`
* `module_main_decoder.sv`
* `module_alu_decoder.sv`
* `module_adder.sv`
* `module_alu.sv`
* `module_extend.sv`
* `module_flopr.sv`
* `module_mux_2_a_1.sv`
* `module_mux_3_a_1.sv`
* `module_regfile.sv`


### 3.2 module_riscvsingle

Este es el módulo "top" del microprocesador, por lo que en él se instancian todos los demás módulos.

#### 1. Encabezado del módulo
```SystemVerilog
module module_riscvsingle_v2(
    
    input logic             clk_i,
    input logic             rst_i,
    input logic [31 : 0]    ProgIn_i,
    input logic [31 : 0]    Data_In_i,  
    output logic            we_o,
    output logic [31 : 0]   ProgAddress_o,
    output logic [31 : 0]   DataAddress_o,
    output logic [31 : 0]   DataOut_o
    
    );
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `clk_i`: señal del reloj de 10 MHz.
- `rst_i`: reset del sistema.
- `ProgIn_i`: entrada de la memoria de instrucciones.
- `Data_In_i`: entrada de la memoria de datos.
- `we_o`: señal de write enable.
- `ProgAddress_o`: address de la memoria de instrucciones.
- `DataAddress_o`: address de la memoria de datos.
- `DataOut_o`: datos de la salida.

#### 4. Criterios de diseño

Para el diseño del microprocesador se hizo uso de la literatura recomendada para el curso, dada en [0].

#### 4. Testbench

Este módulo no tiene testbench.


### 3.3 module_controller

Este corresponde al controlador principal del microprocesador monociclo.

#### 1. Encabezado del módulo
```SystemVerilog
module module_controller(
    
    input logic             funct7b5_i,
    input logic             zero_i,
    input logic [6 : 0]     op_i,
    input logic [2 : 0]     funct3_i,  
    output logic            mem_write_o,
    output logic            pc_src_o,
    output logic            alu_src_o,
    output logic            reg_write_o,
    output logic            jump_o,
    output logic [1 : 0]    result_src_o,
    output logic [1 : 0]    imm_src_o, 
    output logic [2 : 0]    alu_control_o   

    );
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `funct7b5_i`: señal de entrada de 1 bit.
- `zero_i`: entrada del indicar de resultado 0 en la ALU.
- `op_i`: dato de 7 bits que contiene la operación por realizar.
- `funct3_i`: señal de entrada de 3 bits.
- `mem_write_o`: señal de salida del write enable.
- `pc_src_o`: señal de salida de 1 bit.
- `alu_src_o`: señal de salida de 1 bit.
- `reg_write_o`: señal de escritura en el registro.
- `jump_o`: señal de salida de 1 bit.
- `result_src_o`:señal de salida de 2 bits.
- `imm_src_o`: señal de salida de 2 bits.
- `alu_control_o`: señal de 3 bits que controla la operación de la ALU.



#### 4. Testbench

Este módulo no tiene testbench.

### 3.4 module_main_decoder 

Este corresponde al decodificador principal del microprocesador monociclo.

#### 1. Encabezado del módulo
```SystemVerilog
module module_main_decoder (

    input   logic   [6:0]   op_i,
    output  logic           mem_write_o,
    output  logic           branch_o, 
    output  logic           alu_src_o,
    output  logic           reg_write_o,
    output  logic           jump_o,
    output  logic   [1:0]   alu_op_o,
    output  logic   [1:0]   result_src_o,
    output  logic   [1:0]   imm_src_o
    
    );
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `op_i`: señal de entrada de 7 bits.
- `mem_write_o`: señal de salida de write enable.
- `branch_o`: señal de salida de 1 bit que permite hacer branch.
- `alu_src_o`: señal de salida de 1 bit.
- `reg_write_o`: señal de escritura en el registro.
- `jump_o`: señal de salida de 1 bit.
- `alu_op_o`: señal de 2 bits que indica la operación en la ALU.
- `result_src_o`; señal de salida de 2 bits.
- `imm_src_o`: señal de salida de 2 bits.




#### 4. Testbench

Este módulo no tiene testbench.



### 3.5 module_alu_decoder

Este corresponde al decodificador de la ALU del microprocesador monociclo.

#### 1. Encabezado del módulo
```SystemVerilog
module module_alu_decoder (

    input   logic                   opb5_i,
    input   logic   [2 : 0]         funct3_i,
    input   logic                   funct7b5_i,
    input   logic   [1 : 0]         alu_op_i,
    output  logic   [2 : 0]         alu_control_o
 
     );
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `opb5_i`: señal de entrada de 1 bit.
- `funct3_i`: señal de entrada de 3 bits.
- `funct7b5_i`: señal de entrada de 1 bit.
- `alu_op_i`: señal de entrada de 2 bits para seleccionar la funcionalidad.
- `alu_control_o`: señal de salida de 3 bits que controla la ALU.




#### 4. Testbench

Este módulo no tiene testbench.


### 3.6 module_datapath

Corresponde al datapath del microprocesador monociclo.

#### 1. Encabezado del módulo
```SystemVerilog
module module_datapath (

        input logic                 clk_i, 
        input logic                 rst_i,
        input logic                 pc_src_i, 
        input logic                 alu_src_i,
        input logic                 reg_write_i, 
        input logic     [1:0]       result_src_i,
        input logic     [1:0]       imm_src_i,
        input logic     [2:0]       alu_control_i,
        input logic     [31:0]      instr_i,
        input logic     [31:0]      read_data_i,
        output logic                zero_o,
        output logic    [31:0]      pc_o,
        output logic    [31:0]      alu_out_o, 
        output logic    [31:0]      write_data_o
        
        );
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `clk_i`: señal de entrada del reloj.
- `rst_i`: señal de entrada del reset.
- `pc_src_i`: señal de entrada para habilitar el program counter.
- `alu_src_i`: señal de entrada de 1 bit.
- `reg_write_i`: señal de entrada para escritura de registro.
- `result_src_i`: señal de entrada de 2 bits de los resultados
- `imm_src_i`: señal de 2 bits de entrada.
- `alu_control_i`: señal de entrada de 3 bits del control de la ALU.
- `instr_i`: señal de entrada de 32 bits.
- `read_data_i`: señal de entrada de 32 bits.
- `zero_o`: señal de salida del zero flag.
- `pc_o`: salida de 32 bits del program counter.
- `alu_out_o`: salida de 32 bits de la ALU.
- `write_data_o`: salida de 32 bits de los datos a escribir en memoria RAM.



#### 4. Testbench

Este módulo no tiene testbench.


### 3.7 module_flopr

Corresponde a un módulo parametrizable de un flip-flop tipo D.

#### 1. Encabezado del módulo
```SystemVerilog
module module_flopr #(parameter WIDTH = 8)(
    
    input   logic                       clk_i,
    input   logic                       rst_i,
    input   logic   [WIDTH - 1: 0]      d_i,
    output  logic   [WIDTH - 1: 0]      q_o
                 
    );
```
#### 2. Parámetros
- `WIDTH`: ancho de los bits de entrada

#### 3. Entradas y salidas:
- `clk_i`: señal de entrada del reloj.
- `rst_i`: señal de reset.
- `d_i`: dato de entrada.
- `q_o`: salida del flip-flop.


#### 4. Testbench

Este módulo no tiene testbench.


### 3.8 module_adder

Corresponde a un módulo sumador de datos de 32 bits.

#### 1. Encabezado del módulo
```SystemVerilog
module module_adder(
    
    input logic [31 : 0]    a_i,
    input logic [31 : 0]    b_i,
    output logic [31 : 0]   y_o
    
);
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `a_i`: sumando 1.
- `b_i`: sumando 2.
- `y_o`: resultado de la suma.

#### 4. Testbench

Este módulo no tiene testbench.


### 3.9 module_mux_2_a_1

Corresponde a un multiplexor 2 a 1 parametrizable.

#### 1. Encabezado del módulo
```SystemVerilog
module module_mux_2_a_1 #(parameter WIDTH = 8)(
    
    input   logic                               s_i,
    input   logic       [WIDTH - 1 : 0]         d0_i,
    input   logic       [WIDTH - 1 : 0]         d1_i,
    output  logic       [WIDTH - 1 : 0]         y_o
    
    );
```
#### 2. Parámetros
- `WIDTH`: ancho de los datos de entrada

#### 3. Entradas y salidas:
- `s_i`: bit de selección del mux.
- `d0_i`: dato 1.
- `d1_i`: dato 2.
- `y_o`: dato de salida.

#### 4. Testbench

Este módulo no tiene testbench.


### 3.10 module_regfile

Corresponde al banco de registros del microprocesador.

#### 1. Encabezado del módulo
```SystemVerilog
module module_regfile(
    
    input   logic               clk_i,
    input   logic               rst_i,
    input   logic               we3_i,
    input   logic   [4 : 0]     a1_i,
    input   logic   [4 : 0]     a2_i,
    input   logic   [4 : 0]     a3_i,
    input   logic   [31 : 0]    wd3_i,
    output  logic   [31 : 0]    rd1_o,
    output  logic   [31 : 0]    rd2_o
    
    );
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `clk_i`: señal del reloj del sistema.
- `rst_i`: reset del sistema.
- `we3_i`: señal de write enable.
- `a1_i`: dirección 1.
- `a2_i`: dirección 2.
- `a3_i`: dirección 3, usada para escribir en los registros.
- `wd3_i`: dato de 32 bits que se desea escribir en los registros.
- `rd1_o`: dato leído 1, controlado por `a1_i`.
- `rd2_o`: dato leído 2, controlado por `a2_i`.




#### 4. Testbench

Este módulo no tiene testbench.




### 3.11 module_extend

Corresponde al decodificador de instrucciones, ya que recibe una instrucción y devuelve otra en la salida.

#### 1. Encabezado del módulo
```SystemVerilog
module module_extend(

    input   logic   [31:7]      instr_i,
    input   logic   [1:0]       imm_src_i,
    output  logic   [31:0]      imm_ext_o
    
    );
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `instr_i`: señal de entrada de 24 bits de instrucción.
- `imm_src_i`: señal de entrada de 2 bits.
- `imm_ext_o`: señal de salida de 32 bits.




#### 4. Testbench

Este módulo no tiene testbench.



### 3.12 module_mux_3_a_1

Corresponde a un mux 3 a 1.

#### 1. Encabezado del módulo
```SystemVerilog
module module_mux_3_a_1 #(parameter WIDTH = 8)(
    
    input   logic       [1 : 0]                 s_i,
    input   logic       [WIDTH - 1 : 0]         d0_i,
    input   logic       [WIDTH - 1 : 0]         d1_i,
    input   logic       [WIDTH - 1 : 0]         d2_i,
    output  logic       [WIDTH - 1: 0]          y_o
    
    );
```
#### 2. Parámetros
- `WIDTH`: ancho de los datos de entrada

#### 3. Entradas y salidas:
- `s_i`: selección del mux.
- `d0_i`: dato 1.
- `d1_i`: dato 2.
- `d2_i`: dato 3.
- `y_o`: salida del mux.


#### 4. Testbench

Este módulo no tiene testbench.


### 3.13 module_alu

Corresponde a la ALU del microprocesador.

#### 1. Encabezado del módulo
```SystemVerilog
module module_alu(

    input  logic    [31 : 0]        dato1_i,
    input  logic    [31 : 0]        dato2_i,
    input  logic    [2 : 0]         alu_control_i,
    output logic                    zero_o,
    output logic    [31 : 0]        alu_out_o
    
    );
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `dato1_i`: operando 1.
- `dato2_i`: operando 2.
- `alu_control_i`: selector de operaciones de la ALU.
- `zero_o`: flag de resultado igual a cero en la ALU.
- `alu_out_o`: salida de la ALU.


#### 4. Testbench

Este módulo no tiene testbench.


### 3.14 top_riscv_single_cycle_processor_v2

Corresponde a un módulo TOP creado para probar el correcto funcionamiento del microprocesador.

#### 1. Encabezado del módulo
```SystemVerilog
module top_riscv_single_cycle_processor_v2(
    
    input   logic               clk_100m_i,
    input   logic               rst_i,
    output logic [31 : 0]       write_data,     
    output logic [31 : 0]       alu_out,        
    output logic                mem_write       
    
    );
```
#### 2. Parámetros
Este módulo no tiene parámetros.

#### 3. Entradas y salidas:
- `clk_100m_i`: señal de entrada del reloj de 100 MHz.
- `rst_i`: señal de entrada del reset del sistema.
- `write_data`: datos de entrada provenientes de la memoria RAM.
- `alu_out`: señal de address de la RAM.
- `mem_write`: señal del write enable de la RAM.

#### 4. Criterios de diseño

Este módulo fue creado únicamente para probar el microprocesador antes de proceder a montar el sistema empotrado final. La programación en ensamblador se encuentra en el archivo `prueba_harris_v2.asm`, este código fue provisto por el libro principal del curso, dado en [0]. En él se prueban todas las instrucciones que es capaz de realizar el microprocesador.

En este módulo se instancian tanto el microprocesador, como los IP-cores de la memoria RAM, ROM y el Clocking Wizard.

#### 5. Testbench

El archivo de testbench se encuentra en `tb_top_single_cycle_processor.sv`. Como se mencionó anteriormente, en este módulo se prueban todas las instrucciones soportadas por el microprocesador monociclo. Por lo que en caso de ejecutar todas las instrucciones correctamente, el microprocesador debería escribir el valor de  4140 (0x102C) en el address 216 (0xd8).

La siguiente figura corresponde a la simulación de comportamiento, la cual muestra el correcto funcionamiento del microprocesador, ya que a los 10.1 ns, se escribe en la memoria RAM un 4140 en la dirección 216.

![](https://hackmd.io/_uploads/S1CLiCvr2.png)


## Apendices:
### Apendice 1:
texto, imágen, etc
