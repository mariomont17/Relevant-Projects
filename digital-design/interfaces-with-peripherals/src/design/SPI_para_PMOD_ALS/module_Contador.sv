module module_Contador #(
    parameter CUENTA_REGISTRO = 32                          // Profundidad del registro
)(
    input logic                                  clk_i,     // Reloj 10 MHz
    input logic                                  reset_i,   // Señal de reset
    input logic                                  en_i,      // Señal habilitadora
    input logic  [8:0]                           n_i,       // Dirección de la transacción final
    input logic                                  en_spi_i,  // Indicador final de transacción
    output logic [($clog2(CUENTA_REGISTRO)):0]   contador_o // Contador de transacciones
);

    always_ff @(posedge clk_i) begin                        // En el flanco positivo de reloj...
        if (reset_i) begin                                  // Si reset es 1...
            contador_o <= 0;                                // Contador de transacciones reiniciado
        end else begin                                      // Si ese no es el caso...
            if (en_i) begin                                 // Si Enable es 1...
                if (en_spi_i) begin                         // Si el indicador de final de transacción es 1...
                    if (contador_o <= n_i) begin            // Si el contador de transacciones no ha llegado...
                        contador_o <= contador_o + 1'b1;    // El contador de transacciones sigue contando
                    end else begin                          // Si el contador de transacciones ya llegó al valor correspondiente...
                        contador_o <= 0;                    // Contador de transacciones de reloj reiniciado
                    end
                end
            end else begin                                  // Si Enable es 0...
                contador_o <= 0;                            // Contador de transacciones de reloj reiniciado
            end
        end
    end
    
endmodule
