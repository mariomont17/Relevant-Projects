module module_Contador_2_Bits (
    input logic  clk,            // Se�al de reloj      
    input logic  reset,          // Se�al de reset
    input logic  en,             // Se�al habilitadora
    output logic [1:0] contador  // Contador de columnas
);
    //Periodo 1 ms
    logic [14:0] contador2; // Contador que habilita cuando llega al valor necesario

    always_ff @(posedge clk) begin                // En el flanco positivo de reloj...
        if (!reset) begin                         // Si reset es 0...
            contador <= 0;                        // Ambos contadores se reinician
            contador2 <= 0;
        end else begin                            // Si ese no es el caso...
            if (contador2 < 10000) begin          // Si es contador 2 no ha llegado a 10 mil...
                contador2 <= contador2 + 2'b01;   // Contin�e contando
            end else begin                        // Cuando llega a 10 mil...
                if (en) begin                     // Si enable es 1...
                    contador <= contador;         // Contador de columnas se frena
                end else begin                    // Si ese no es el caso...
                    contador <= contador + 2'b01; // El contador de columnas sigue contando
                end
                contador2 <= 0;                   // Se reinicia el contador 2
            end
        end
    end
    
endmodule
