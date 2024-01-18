module module_antirrebote (

    input  logic    clk_i,      // Se�al de reloj
    input  logic    rst_i,      // Se�al de reset
    input  logic    btn_i,      // Se�al de entrada
    output logic    q_o         // Se�al de salida
        
    );
        
        logic S; // Variable interna S
        logic R; // Variable interna R
    
        always_ff @(posedge clk_i)            // En el flanco positivo de reloj...
        
            if (!rst_i) begin               // Si el reset est� en bajo...
                q_o <= 0;                     // La salida es 0
            end else if (S && !R) begin     // Si S = 1 y R = 0 ("set")...
                q_o <= 1;                     // La salida es 1
            end else if (!S && R) begin     // Si S = 0 y R = 1 ("reset")...
                q_o <= 0;                     // La salida es 0
            end
        
        always @(*) begin
            if (!btn_i && rst_i) begin        // Si Se�al de entrada = 0 y reset = 1
                S <= 0;                     // Hacer un "reset"
                R <= 1; 
            end
            if (btn_i && rst_i) begin         // Si Se�al de entrada = 1 y reset = 1
                S <= 1;                     // Hacer un "set"
                R <= 0;
            end
        end
       
endmodule