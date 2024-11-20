# Proyecto: Implementación de un procesador `rv32i` con pipeline de 5 etapas y unidades de adelantamiento y predicción de riesgos de datos
### EL4314 - Arquitectura de Computadoras I
### Escuela de Ingeniería Electrónica
### Tecnológico de Costa Rica

<br/>

### Descripción del Proyecto

Implementé a nivel de RTL un procesador basado en el ISA `rv32i` utilizando SystemVerilog. El diseño incluye:

- Una arquitectura *pipeline* de cinco etapas.  
- Una unidad de *forwarding* para gestionar riesgos de datos mediante la selección de resultados de la ALU presentes en los registros EX/MEM y MEM/WB.  
- Una unidad de detección de riesgos que introduce *stalls* en casos específicos, como cuando una instrucción `lw` seguida de una operación dependiente presenta un riesgo de datos.  

Desarrollé varios programas de prueba para validar la funcionalidad del procesador, demostrando el correcto comportamiento de las unidades de detección de riesgos y *forwarding*. Además, realicé simulaciones *post-implementation* y sintetizé el diseño en Vivado, enfocándome en una FPGA Artix-7 como objetivo. Las memorias ROM y RAM necesarias se implementaron utilizando *IP-Cores* disponibles en Vivado.



