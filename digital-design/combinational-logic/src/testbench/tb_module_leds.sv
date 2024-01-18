`timescale 1ns/1ps // Definir la escala de tiempo

module tb_module_leds;

// Variables de estimulo
logic push_button_0;
logic push_button_1;
logic push_button_2;
logic push_button_3;

logic [0:3] sw_0_3;
logic [0:3] sw_4_7;
logic [0:3] sw_8_11;
logic [0:3] sw_12_15;

// Salidas del modulo
logic [0:3] leds_1;
logic [0:3] leds_2;
logic [0:3] leds_3;
logic [0:3] leds_4;

module_leds #() LEDS (
    .push_button_0        (push_button_0),
    .push_button_1        (push_button_1),
    .push_button_2        (push_button_2),
    .push_button_3        (push_button_3),
    
    .sw_0_3               (sw_0_3),
    .sw_4_7               (sw_4_7),
    .sw_8_11              (sw_8_11),
    .sw_12_15             (sw_12_15),
    
    .leds_1               (leds_1),
    .leds_2               (leds_2),
    .leds_3               (leds_3),
    .leds_4               (leds_4)
);

initial begin

    push_button_0 = '0; //  Definir inicialmente los botones en 0
    push_button_1 = '0;
    push_button_2 = '0;
    push_button_3 = '0;
    
    sw_0_3[0]     = 1; // Defino unos switches del grupo 1 en valor logico 1
    sw_0_3[1]     = 0;
    sw_0_3[2]     = 0;
    sw_0_3[3]     = 0;
    
    sw_4_7[0]     = 1; // Defino unos switches del grupo 2 en valor logico 1
    sw_4_7[1]     = 1;
    sw_4_7[2]     = 0;
    sw_4_7[3]     = 0;
    
    sw_8_11[0]     = 1; // Defino unos switches del grupo 3 en valor logico 1
    sw_8_11[1]     = 1;
    sw_8_11[2]     = 1;
    sw_8_11[3]     = 0;
    
    sw_12_15[0]     = 1; // Defino unos switches del grupo 4 en valor logico 1
    sw_12_15[1]     = 1;
    sw_12_15[2]     = 1;
    sw_12_15[3]     = 1;
    
    #10
    push_button_0 = 1; // Se presiona el boton 0
    
    #10
    push_button_2 = 1; // Se presiona el boton 2, para comprobar el funcionamiento cuando más de un boton se presiona
    
    #10
    push_button_0 = 0; // Se deja de presionar el boton 0
    
    #10
     push_button_2 = 0; // Se deja de presionar el boton 2
    
    #10
    $finish;
    
end
endmodule