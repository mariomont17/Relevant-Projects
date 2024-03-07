# Proyecto 1: Implementación de un procesador `rv32i` con pipeline de 5 etapas y unidades de adelantamiento y predicción de riesgos de datos
### EL4314 - Arquitectura de Computadoras I
### Escuela de Ingeniería Electrónica
### Tecnológico de Costa Rica

<br/>

### Preámbulo
En este proyecto, usted implementará, a nivel de RTL, un procesador basado en el ISA `rv32i`. Dicho procesador deberá ser capaz de detectar y resolver riesgos de datos mediante la utilización de las técnicas de *forwarding* e inserción de *stalls*.

Como referencia base para su implementación, podrá utilizar las referencias oficiales del curso, particularmente el capítulo 7 del Harris & Harris y el capítulo 4 del Patterson & Hennessy, ambos en su version de RISC-V.


### Requisitos
Considere las siguientes características para el desarrollo de su procesador:

- Deberá realizar la implementación de su procesador usando SystemVerilog como lenguaje de descripción de hardware.
- El procesador a implementar deberá ser capaz de ejecutar las instrucciones del ISA `rv32i`, aún cuando a este punto no se validará la ejecución de instrucciones de salto.
- La implementación de su procesador será con 5 etapas de *pipeline*, como descrito en la literatura del curso y visto en la clase.
- Deberá implementar una unidad de *forwarding* que permita seleccionar el resultado de la ALU, presente en el registro EX/MEM y MEM/WB, como entrada. Para esto los registros destino y fuente deben ser monitorizados, como descrito en la literatura.
- Su implementación deberá contar con una unidad que permita detectar riesgos de datos, particularmente para el caso en el que una instrucción inmediatamente posterior a un `lw`  presenta un riesgo de datos, como se ilustra en las siguientes dos instrucciones. Ante tal escenario, su implementación deberá introducir un *stall* en la ejecución de las etapas IF e ID.
```
lw x1, 0(x2)
add x4, x1, x3
```
- Deberá desarrollar al menos 3 códigos de prueba que permitan validar el funcionamiento de su procesador. Estos códigos de prueba deben demostrar el funcionamiento apropiado de las unidades de detección de riesgos y *forwarding*. Para dichos códigos, y a este punto del curso, no considere el uso de instrucciones de salto condicional o incondicional. Además, su implementación para este proyecto 1 será validada con un código de prueba que será proveído oportunamente.
- La evaluación de su procesador deberá demonstrarse mediante simulaciones *post-implementation*. Utilice Vivado para realizar la síntesis de su diseño. Considere una FPGA Artix-7 como objetivo, tal como se encuentra presente en una Basys 3 o Nexys 4. Utilice memorias ROM y RAM de los *IP-Cores* disponibles en Vivado para almacenar programa y datos.
- El desarrollo del proyecto se evaluará mediante el uso de un repositorio de GitHub. Para ello, asegúrese de registrar continuamente su desarrollo mediante suficientes *commits*.


