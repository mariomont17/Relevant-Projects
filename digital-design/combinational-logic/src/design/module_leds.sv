module module_leds (
    input  logic push_button_0,    // Definir los 4 botones asociados a cada grupo de LEDs
    input  logic push_button_1,
    input  logic push_button_2,
    input  logic push_button_3,
    input  logic [0:3] sw_0_3,     // Definir los 4 grupos de switches
    input  logic [0:3] sw_4_7,
    input  logic [0:3] sw_8_11,
    input  logic [0:3] sw_12_15,
    output logic [0:3] leds_1,     // Definir los 4 grupos de leds
    output logic [0:3] leds_2,
    output logic [0:3] leds_3,
    output logic [0:3] leds_4
);
    
    always @(*) begin
    
        for (int i = 0; i<$size(sw_0_3); i++) // Ciclo que inicia en 0 hasta 3 (los 4 switches)
            if (sw_0_3[i] == 1) begin         // Si el switch en posicion "i" es 1
                leds_1[i] = 1;                // Encienda el LED correspondiente en dicha posicion "i"
            end else begin                    // Si no,
                leds_1[i] = 0;                // El LED queda apagado
            end
         
        for (int j = 0; j<$size(sw_4_7); j++) // Repetir el ciclo anterior para cada grupo
            if (sw_4_7[j] == 1) begin
                leds_2[j] = 1;
            end else begin
                leds_2[j] = 0;
            end
         
        for (int k = 0; k<$size(sw_8_11); k++) // Repetir el ciclo anterior para cada grupo
            if (sw_8_11[k] == 1) begin
                leds_3[k] = 1;
            end else begin
                leds_3[k] = 0;
            end
         
        for (int l = 0; l<$size(sw_12_15); l++) // Repetir el ciclo anterior para cada grupo
            if (sw_12_15[l] == 1) begin
                leds_4[l] = 1;
            end else begin
                leds_4[l] = 0;
            end
    
        if (push_button_0 == 1) begin // Si el botón 0 se presiona,
            leds_1[0] = 0;            // Apagar los LEDs 0,1,2,3
            leds_1[1] = 0;
            leds_1[2] = 0;
            leds_1[3] = 0;
        end
        
        if (push_button_1 == 1) begin // Si el botón 1 se presiona,
            leds_2[0] = 0;            // Apagar los LEDs 4,5,6,7
            leds_2[1] = 0;
            leds_2[2] = 0;
            leds_2[3] = 0;
        end
        
        if (push_button_2 == 1) begin // Si el botón 2 se presiona,
            leds_3[0] = 0;            // Apagar los LEDs 8,9,10,11
            leds_3[1] = 0;
            leds_3[2] = 0;
            leds_3[3] = 0;
        end
        
        if (push_button_3 == 1) begin // Si el botón 3 se presiona,
            leds_4[0] = 0;            // Apagar los LEDs 12,13,14,15
            leds_4[1] = 0;
            leds_4[2] = 0;
            leds_4[3] = 0;
        end

     end    
endmodule

