module top_Cont_AR_S (
    input  logic clk,         // Señal de reloj
    input  logic btn,         // Señal de entrada
    output logic [7:0] LEDs   // Valor del contador
);

    logic clk_10m;  // Reloj 10 MHz
    logic reset;    // Señal de reset
    logic Sinc;     // Dato de entrada del sincronizador
    logic Sinc_out; // Dato de salida del sincronizador
    
    // Bloque Reloj
    module_Reloj Reloj (
    .clk (clk),
    .locked (reset),
    .clk_10m (clk_10m)
    );
    
    // Bloque Antirebotes
    module_Antirebote Antirebote (
    .clk (clk_10m),
    .reset (reset),
    .btn (btn),
    .Q (Sinc)
    );
    
    // Bloque Sincronizador
    module_Sincronizador Sincronizador (
    .clk (clk_10m),
    .reset (reset),
    .D0 (Sinc),
    .D1 (Sinc_out)
    );
    
    // Bloque Contador
    module_Contador Contador (
    .clk (clk_10m),
    .rst_n_i (reset),
    .en_i (Sinc_out),
    .conta_o (LEDs)
    );

endmodule