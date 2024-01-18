module module_Contador(
    input logic         clk,      // Se�al de reloj
    input logic         rst_n_i,  // Se�al de reset
    input logic         en_i,     // Se�al habilitadora 
    output logic [7:0]  conta_o   // Contador
    );

    logic [1:0] registro_en_r;        // Para detectar el flanco de la se�al en_i

    always_ff@(posedge clk) begin     // En el flanco positivo del reloj...
        registro_en_r <= {registro_en_r[0], en_i}; // Tomar el �ltimo valor del registro y el valor actual de "enable"
    end

    always_ff@(posedge clk) begin     // En el flanco positivo del reloj...
        if(!rst_n_i) conta_o <= 0;    // Si reset est� en bajo, se reinicia el contador
        else begin                    // Si ese no es el caso...
        if(registro_en_r == 2'b01) conta_o <= conta_o + 8'd1; // Si existe un flanco positivo en registro, el contador aumenta en 1
        end
    end

endmodule
