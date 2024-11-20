# Proyecto 2: Predictor de saltos dinámico en procesador RISC-V con pipeline
### EL4314 - Arquitectura de Computadoras I
### Escuela de Ingeniería Electrónica
### Tecnológico de Costa Rica

<br/><br/>

### Descripción del Proyecto

Implementé un predictor de saltos dinámico para un procesador RISC-V escalar, en *pipeline* y de ejecución en orden, desarrollado previamente. El diseño incluye:

- Un *Branch Target Buffer* (BTB) para almacenar direcciones de salto calculadas y determinar si una instrucción es un salto a partir del *Program Counter* (PC).  
- Un predictor de dirección basado en un contador de 2 bits, que se actualiza de acuerdo con la máquina de estados correspondiente.  
- La capacidad de activar o desactivar la predicción de saltos, así como la detección y corrección de riesgos de datos mediante *forwarding*. En caso de desactivar estas técnicas, el procesador introduce *stalls* o realiza *flush* para garantizar la correcta ejecución.  

El cálculo de direcciones de salto se realiza en la etapa de *Execute*, y las direcciones se almacenan en el BTB si no estaban previamente registradas. Si la predicción resulta incorrecta, el procesador realiza un *flush* del *pipeline* y actualiza el PC con la dirección correcta.  

Desarrollé un programa de prueba en ensamblador para evaluar diferentes configuraciones de ejecución:  
1. Sin *forwarding* ni predicción de saltos.  
2. Con *forwarding* pero sin predicción de saltos.  
3. Con predicción de saltos pero sin *forwarding*.  
4. Con *forwarding* y predicción de saltos activos.  

Automaticé la medición de resultados como instrucciones ejecutadas, ciclos de reloj y CPI en el *testbench* para cada escenario.  
