# Laboratorio 1 Taller de Diseño Digital

## 1. Abreviaturas y definiciones
- **ALU**: Aritmetic-Logic Unit
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.1 Circuitos digitales discretos  

#### 1. Criterios de diseño
Se deben diseñar 2 bloques: un decodificador 2 a 4 encargado de seleccionar cuál columna del teclado debe responder, y un codificador de prioridad 4 a 2 que debe indicar a cuál fila pertenece la tecla que se está presionando. Para diseñar dichos bloques se construye una tabla de verdad para cada uno, y se construyen mapas de Karnaugh que permitan obtener la función lógica en su forma más sencilla. A continuación se muestran las tablas de verdad para el decodificador con las respectivas funciones que las describen.

![](https://i.imgur.com/ObZJIis.png)

Seguidamente se muestran las tablas de verdad para las salidas A y B del codificador de prioridad 4 a 2, donde A corresponde al bit más significativo. Para la salida A:

![](https://i.imgur.com/Awotkpb.png)

![](https://i.imgur.com/TY8GAp1.png)

Para la salida B:

![](https://i.imgur.com/tdjEoNX.png)

![](https://i.imgur.com/67iTAHa.png)

Una vez resueltos los mapas de Karnaugh se procede a construir con compuertas las funciones lógicas. El decodificador diseñado es el siguiente:

![](https://i.imgur.com/5PWGyg8.png)

El codificador diseñado es el siguiente:

![](https://i.imgur.com/YCcv0ey.png)

Con los circuitos ya diseñados, se conectan los pines correspondientes a las columnas en el teclado como salidas del decodificador y los pines correspondientes a las filas como entradas al codificador. Es importante hacer la siguiente aclaración: para efectos de este diseño, se considera la columna 0 como la columna más a la izquierda del teclado, y se enumeran de izquierda a derecha. Para las filas, se considera la fila 0 como la fila más arriba del teclado, y se enumeran hacia abajo.

### 3.2  Switches, botones y LEDs
#### 1. Encabezado del módulo
```SystemVerilog
module module_leds (
    input  logic   push_button_1,     
    input  logic   push_button_2,
    input  logic   push_button_3,
    input  logic   push_button_4,
    input  logic   [0:3] sw_0_3,
    input  logic   [0:3] sw_4_7,
    input  logic   [0:3] sw_8_11,
    input  logic   [0:3] sw_12_15,
    output logic   [0:3] leds_1,
    output logic   [0:3] leds_2,
    output logic   [0:3] leds_3,
    output logic   [0:3] leds_4,
);
```
#### 2. Parámetros
- Este bloque no contiene parámetros.

#### 3. Entradas y salidas:
- `push_button_1`: Botón que permite apagar el primer grupo de LEDs.
- `push_button_2`: Botón que permite apagar el segundo grupo de LEDs.
- `push_button_3`: Botón que permite apagar el tercer grupo de LEDs.
- `push_button_4`: Botón que permite apagar el cuarto grupo de LEDs.
- `sw_0_3`: Array que contiene la información de las posiciones (encendido o apagado) del primer grupo de switches. Permite encender o apagar los LEDs del primer grupo.
- `sw_4_7`: Array que contiene la información de las posiciones (encendido o apagado) del segundo grupo de switches. Permite encender o apagar los LEDs del segundo grupo.
- `sw_8_11`: Array que contiene la información de las posiciones (encendido o apagado) del tercer grupo de switches. Permite encender o apagar los LEDs del tercer grupo.
- `sw_12_15`: Array que contiene la información de las posiciones (encendido o apagado) del cuarto grupo de switches. Permite encender o apagar los LEDs del cuarto grupo.
- `leds_1`: Array que contiene la información sobre los valores lógicos del primer grupo de LEDs.
- `leds_2`: Array que contiene la información sobre los valores lógicos del segundo grupo de LEDs.
- `leds_3`: Array que contiene la información sobre los valores lógicos del tercer grupo de LEDs.
- `leds_4`: Array que contiene la información sobre los valores lógicos del cuarto grupo de LEDs.

#### 4. Criterios de diseño
Para el diseño, primeramente se describe un ciclo "for" que recorre los 4 valores del array de switches, y transmite esa información al array de LEDs. Por ejemplo, si el valor en la posición 0 del array de switches es 1, esa misma posición 0 debe definirse en 1 en el array de LEDs. De lo contrario, esa posición se define en 0. En otras palabras, se obtiene la información de encendido o apagado de un grupo de switches y controla el grupo de LEDs asociado: si el switch 0 está en posición encendido en la FPGA, el LED 0 debe encenderse. El ciclo "for" se repite para los 4 grupos de switches y LEDs, de esta forma se asocian los 16 interruptores con los 16 LEDs de la FPGA y, a su vez, se dividen en 4 grupos de 4. Estos 4 ciclos "for" tienen la misma identación para que corran en paralelo.

Para los botones, se abre una condición "if": si el botón correspondiente se encuentra en valor lógico 1, se apaga el grupo de LEDs al que está asociado. Se repite este código para los 4 botones (4 grupos de LEDs). Estas condiciones "if" también tienen la misma identación que los ciclos "for" descritos anteriormente, para que los eventos corran en paralelo.

#### 5. Testbench
Las pruebas realizadas son bastante sencillas: inicialmente se definen los botones en valor lógico 0 y se definen unos switches de cada grupo en posición encendido. El grupo 1 tiene en su array [1,0,0,0]. El grupo 2 tiene [1,1,0,0]. El grupo 3 tiene [1,1,1,0]. Y el grupo 4 tiene [1,1,1,1]. A los 10 ns, se presiona el botón 0, y se apaga el grupo 1 de LEDs. A los 20 ns, se presiona el botón 2 y apaga el grupo 3 de LEDs. Al mismo tiempo, el botón 0 se ha mantenido presionado para verificar que al presionar 2 o más botones al mismo tiempo, se apaguen el grupo de LEDs correspondientes al mismo tiempo. A los 30 ns, se deja de presionar el botón 0, por lo que el grupo 1 de LEDS vuelve a encenderse y el grupo 3 de LEDs sigue apagado ya que no se ha dejado de presionar el botón 2. A los 40 ns, se deja de presionar el botón 2, por lo que se vuelve a encender el grupo 3 de LEDs. A los 50 ns, se termina la simulación. A continuación se muesta el gráfico obtenido de la simulación.

![](https://i.imgur.com/deNskAL.png)

### 3.3 Multiplexor 4-to-1
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


### 3.4 Decodificador para display de 7 segmentos
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

### 3.5 Sumador y ruta crítica
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


### 3.6 Unidad aritmética lógica (ALU)
#### 1. Encabezado del módulo
```SystemVerilog
module ALU(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- ANCHO

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
