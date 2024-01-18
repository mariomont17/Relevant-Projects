module module_sincronizador (

        input  logic clk_i,    // Señal de reloj
        input  logic reset_i,  // Señal de reset
        input  logic D0_i,     // Dato de entrada
        output logic D1_o      // Dato de salida
        
    );
    
        logic M; // Variable intermedia M, sirve para conectar los 2 flip-flops en serie
    
        always_ff @(posedge clk_i)   // En el flanco positivo de reloj...
            if (!reset_i) begin      // Si reset está en bajo...
                D1_o = 0;            // Dato de salida en 0...
            end else begin         // Si ese no es el caso...
                M <= D0_i;           // D0 pasa a ser M (procesado por el flip-flop 1)
                D1_o <= M;           // M pasa a ser D1 (procesado por el flip-flop 2)
            end
        
endmodule