`timescale 1ns / 1ps

module module_prueba_reloj(
    input logic     clk,       // Se�al de reloj
    input logic     rst,       // Se�al de reset
    output logic    led        // LED indicador
);

logic [19 : 0] contador;  // Contador 19 Bits
logic enable;             // Se�al habilitadora


always_ff @(posedge clk, posedge rst) begin  // En el flanco positivo de reloj...
    if (!rst) begin                          // Si reset es 0...
        enable <= 0;                         // Enable en 0
        led     <= 0;                        // LED indicador apagado
    end else begin
        if (contador < 1000000) begin        // Si el contador no ha llegado a 1 mill�n
			contador = contador + 1;         // Sigue contando
			enable <= 0;                     // Y el enable no se activa
	    end else begin                       // Si ya lleg� a 1 mill�n
			contador   = 0;                  // Contador en 0                 
			enable     <= 1;                 // Enable activado
		end if (enable) begin                // Cuando enable est� activo...
                led = led + 1;               // LED se enciende si est� apagado y viceversa
		end
    end
end

endmodule
