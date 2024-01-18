# Proyecto 2: Predictor de saltos dinámico en procesador RISC-V con pipeline
### EL4314 - Arquitectura de Computadoras I
### Escuela de Ingeniería Electrónica
### Tecnológico de Costa Rica

<br/><br/>

### Preámbulo
En este proyecto, usted implementará un predictor de saltos dinámico para su procesador RISC-V, escalar, en _pileline_, y de ejecución en orden, desarrollado en el proyecto 1. Su predictor de saltos deberá implementarse empleando un _Branch Target Buffer_ (BTB) para almacenar direcciones de salto calculadas así como determinar si se trata, a partir del _Program Counter_ (PC), de una instrucción de salto. Además deberá incluir un predictor de dirección basado en un contador de 2 bits.


### Requisitos
Considere las siguientes características para el diseño e incorporación del predictor de saltos dinámico en su procesador:

- Deberá realizar la implementación del predictor de saltos dinámico empleado SystemVerilog.
- El procesador deberá contar con la posibilidad de activar o desactivar la predicción de saltos antes de la ejecución de un programa. De igual manera, deberá permitir activar o desactivar la detección de riesgos de datos y su corrección mediante _forwarding_. En caso de que ninguna técnica de mitigación de riesgos de datos y/o control se active, su procesador deberá introducir _stalls_ o realizar _flush_ de manera apropiada para permitir la correcta ejecución.
- El cálculo de la direccion de salto se realiza en la etapa de _Execute_ del procesador. 
- En la etapa de _Instruction Fetch_, al mismo tiempo que se toma el valor del PC para acceder a la memoria de programa y extraer la instrucción, el valor del PC se emplea para acceder la BTB y extraer la dirección de salto (_target address_) en caso de que ya dicha dirección se haya calculado y almacenado en la BTB. Si el acceso a la BTB resulta en un _miss_ y se trata de una instrucción de salto, lo cual se conoce hasta la etapa de _Instruction Decode_, la dirección de salto que se calcula en la etapa de _Execute_ se almacena de forma correspondiente en la BTB.
- En la etapa de _Execute_, además de calcular la dirección de salto, se confirma si el salto se toma o no. Esta información es importante para actualizar el contador de 2 bits de acuerdo con la máquina de estados vista en clase. Si, por ejemplo, la predicción estableció que el salto se tomaba pero en la etapa de _Execute_ se determinó que el salto no debía tomarse, el procesador deberá realizar un _flush_ del _pipeline_ para las instrucciones anteriores al salto y deberá cargar en PC el valor correcto de la dirección de la instrucción que se deberá ejecutar.
- Desarrolle 1 programa de prueba, a nivel de lenguaje ensamblador, suficientemente complejo, y con sentido algorítmico (no solamente un poco de instrucciones juntas) con el que pueda evaluar los siguientes 4 casos: a) ejecución sin _forwarding_ ni predicción de saltos, b) ejecución con _forwarding_ pero sin predicción de saltos, c) ejecución con predicción de saltos pero sin _forwarding_, y d) ejecución con _forwarding_ y predicción de saltos activos. Reporte los resultados de instrucciones ejecutadas, ciclos de reloj y CPI para cada uno de estos escenarios de ejecución. Esto último lo puede automatizar en el _testbench_.

### Advertencia
Aún cuando podrían existir implementaciones disponibles que realizan, en una u otra medida, lo que aquí se les solicita, está prohibido utilizar código existente de algún repositorio (aún cuando este se encuentre abierto y el licenciamiento de que posea permita su utilización).


## Evaluación
Este proyecto se evaluará con la siguiente rúbrica:


| Rubro | % | C | EP | D | NP |
|-------|---|---|----|---|----|
|Implementación del predictor de saltos | 30|   |    |   |    |
|Integración en procesador | 20|   |    |   |    |
|Evaluación con benchmark propuesto | 20|   |    |   |    |
|Evaluación con benchmark profesor | 20|   |    |   |    |
|Uso de repositorio|10|   |    |   |    |

C: Completo,
EP: En progreso ($\times 0,8$),
D: Deficiente ($\times 0,5$),
NP: No presenta ($\times 0$)

## Importante
- El uso del repositorio implica que existan contribuciones de todos los miembros del equipo. 
- La revisión del procesador con el predictor de saltos se realizará el miércoles 1 de octubre, durante el periodio de la clase.
