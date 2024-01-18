module module_Sincronizador (
    input  logic clk,    // Señal de reloj
    input  logic reset,  // Señal de reset
    input  logic D0,     // Dato de entrada
    output logic D1      // Dato de salida
);

    logic M; // Variable intermedia M, sirve para conectar los 2 flip-flops en serie

    always_ff @(posedge clk)   // En el flanco positivo de reloj...
        if (!reset) begin      // Si reset está en bajo...
            D1 = 0;            // Dato de salida en 0...
        end else begin         // Si ese no es el caso...
            M <= D0;           // D0 pasa a ser M (procesado por el flip-flop 1)
            D1 <= M;           // M pasa a ser D1 (procesado por el flip-flop 2)
        end
        
endmodule