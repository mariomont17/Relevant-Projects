module top_unidad_calculo (

    input logic             clk,                    // senal de clock de 100 MHz
    input logic             sw_i,                     // switch que selecciona el modo de operacion
    input logic             F0,
    input logic             F1,
    input logic             F2,
    input logic             F3,
    input  logic            A,
    input  logic            B,
    output logic            C0,
    output logic            C1,
    output logic [7 : 0]    seg,
    output logic [7 : 0]    an,
    output logic            led_error_o,              //led de error
    output logic [3 : 0]    led_o                 //leds de operacion     
);

logic               clk_i;                 // clock de 10 Mhz 
logic               rst_i;
logic               tecla_activa_i;          
logic [3 : 0]       valor_tecla_i;
logic [4 : 0]       addr_rs1_o;              //puntero de lectura del registro en modo 1
logic [4 : 0]       addr_rs2_o;               //puntero de lectura del registro en modo 2
logic [4 : 0]       addr_rd_o;

logic               we_7seg_o;                    // write enable del registro del bloque de 7 segmentos
logic               we_banco_registros_o;           //write enable del banco de registros
logic               mux_o;                          //seleccion del mux
logic [3 : 0]       alucontrol_o;                     // control de operacion de la ALU
logic [15 : 0]      resultado_alu_o;

logic [15 : 0]      rs1;        // salida del banco que va a la entrada del 7 segmentos
logic [15 : 0]      rs2;        // salida del banco que va al segundo operando de la ALU
logic [15 : 0]      data_in; //datos en la salida del mux/ entrada del banco de registros


// RELOJ

clk_wiz_0 inst
  (
  // Clock out ports  
  .clk_out1(clk_i),
  // Status and control signals               
  .locked(rst_i),
 // Clock in ports
  .clk_in1(clk)
  );

// MAQUINA DE ESTADOS

module_fsm_with_data_path DUT (
    .clk_i                  (clk_i),                    
    .rst_i                  (rst_i),                    
    .sw_i                   (sw_i),                     
    .tecla_activa_i         (tecla_activa_i),           
    .valor_tecla_i          (valor_tecla_i),           
           
    .addr_rs1_o             (addr_rs1_o),               
    .addr_rs2_o             (addr_rs2_o),               
    .addr_rd_o              (addr_rd_o),
    .led_error_o            (led_error_o),              
    .we_7seg_o              (we_7seg_o),                     
    .we_banco_registros_o   (we_banco_registros_o),           
    .mux_o                  (mux_o),                          
    .alucontrol_o           (alucontrol_o),                                               
    .led_o                  (led_o)
);


// DISPLAY 7 SEGMENTOS

interfaz_7segmentos display ( 
    .clk        (clk_i),
    .rst        (rst_i),
    .data_in    (rs1),	
    .we         (we_7seg_o),
    .an         (an),
    .seg        (seg)
);

// BANCO DE REGISTROS

reg_bank #(.W(16),.N(5)) registro_calcu
    (
        .clk (clk_i), 
        .reset(rst_i), 
        .we(we_banco_registros_o),                            
        .addr_rs1 (addr_rs1_o), 
        .addr_rs2(addr_rs2_o),
        .addr_rd(addr_rd_o),  
        .data_in(data_in),                            
        .rs1(rs1), 
        .rs2(rs2)
);
// MUX 2 a 1
module_mux_2_1 mux2a1 (
    .a      ({12'b0000_0000_0000, valor_tecla_i}), //entrada 1
    .b      (resultado_alu_o), //entrada 2
    .sel    (mux_o), //seleccion
    .out    (data_in)
);

// ALU 

module_alu_calcu alu(
    .operador_a_i       (rs1),
    .operador_b_i       (rs2),
    .operando_i         (alucontrol_o),
    .result_o           (resultado_alu_o)
);

// TECLADO 

top_teclado_calcu teclado(
    .clk_10m (clk_i),             // Señal de reloj 10 MHz
    .reset      (rst_i),           // Señal de reset
    .F0         (F0),              // Pin del teclado de la fila 0
    .F1         (F1),              // Pin del teclado de la fila 1
    .F2         (F2),              // Pin del teclado de la fila 2
    .F3         (F3),              // Pin del teclado de la fila 3
    .A          (A),               // MSB de salida del codificador A
    .B          (B),               // LSB de salida del codificador B
    .C0         (C0),              // LSB de salida del decodificador
    .C1         (C1),              // MSB de salida del decodificador
    .Bits       (valor_tecla_i),         // Salida del teclado
    .LED_Verif  (tecla_activa_i)
);


endmodule