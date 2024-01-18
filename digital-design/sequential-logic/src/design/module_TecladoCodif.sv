module module_TecladoCodif (
    input  logic [3:0] in, // Columna y fila de tecla presionada
    output logic [3:0] out // Salida hacia el decodificador 7 segmentos
);
    always @(*) begin
        case(in)
            4'b0000: out = 4'b0001; // Columna 0 Fila 0 -> 1
            4'b0001: out = 4'b0100; // Columna 0 Fila 1 -> 4
            4'b0010: out = 4'b0111; // Columna 0 Fila 2 -> 7
            4'b0011: out = 4'b1110; // Columna 0 Fila 3 -> E
            4'b0100: out = 4'b0010; // Columna 1 Fila 0 -> 2
            4'b0101: out = 4'b0101; // Columna 1 Fila 1 -> 5
            4'b0110: out = 4'b1000; // Columna 1 Fila 2 -> 8
            4'b0111: out = 4'b0000; // Columna 1 Fila 3 -> 0
            4'b1000: out = 4'b0011; // Columna 2 Fila 0 -> 3
            4'b1001: out = 4'b0110; // Columna 2 Fila 1 -> 6
            4'b1010: out = 4'b1001; // Columna 2 Fila 2 -> 9
            4'b1011: out = 4'b1111; // Columna 2 Fila 3 -> F
            4'b1100: out = 4'b1010; // Columna 3 Fila 0 -> A
            4'b1101: out = 4'b1011; // Columna 3 Fila 1 -> B
            4'b1110: out = 4'b1100; // Columna 3 Fila 2 -> C
            4'b1111: out = 4'b1101; // Columna 3 Fila 3 -> D
            default: out = 4'b0000; // Por defecto poner 0
        endcase
    end
endmodule    