module module_VerificadorTecla (
    input logic F0, // Fila 0
    input logic F1, // Fila 1
    input logic F2, // Fila 2
    input logic F3, // Fila 3
    output logic V  // Bit de salida
);

    always @(*) begin
        if (F0 && F1 && F2 && F3) begin  // Si todas son iguales a 1...
            V = 0;                       // No se está presionando una tecla
        end else begin                   // Si ese no es el caso... 
            V = 1;                       // Se está presionando una tecla
        end
    end 
endmodule