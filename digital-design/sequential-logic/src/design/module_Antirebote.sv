module module_Antirebote (
    input  logic clk,    // Señal de reloj
    input  logic reset,  // Señal de reset
    input  logic btn,    // Señal de entrada
    output logic Q       // Señal de salida
);
    
    logic S; // Variable interna S
    logic R; // Variable interna R

    always_ff @(posedge clk)            // En el flanco positivo de reloj...
    
        if (!reset) begin               // Si el reset está en bajo...
            Q <= 0;                     // La salida es 0
        end else if (S && !R) begin     // Si S = 1 y R = 0 ("set")...
            Q <= 1;                     // La salida es 1
        end else if (!S && R) begin     // Si S = 0 y R = 1 ("reset")...
            Q <= 0;                     // La salida es 0
        end
    
    always @(*) begin
        if (!btn && reset) begin        // Si Señal de entrada = 0 y reset = 1
            S <= 0;                     // Hacer un "reset"
            R <= 1; 
        end
        if (btn && reset) begin         // Si Señal de entrada = 1 y reset = 1
            S <= 1;                     // Hacer un "set"
            R <= 0;
        end
    end
       
endmodule