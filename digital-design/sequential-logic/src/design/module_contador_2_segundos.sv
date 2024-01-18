`timescale 1ns / 1ps

module module_contador_2_segundos(
    input logic     clk,
    input logic     rst,
    output logic    enable
);
// se necesitan 20x10^6 ciclos del reloj de 10 MHz para generar un WE cada 2 segundos (0.5 Hz) (10 MHz/0.5 Hz = 20 Millones de ciclos)
logic [24 : 0]   contador;// 25 bits, lo que permite contar hasta más de 20 Millones

always_ff @(posedge clk, posedge rst)
    if (!rst) begin
        enable <= 0;                    // senal de reset
    end else begin
        if (contador < 20000000) begin   // si no se han alcanzado los 20 millones de ciclos del reloj
			contador <= contador + 1;    // se sigue incrementando el contador
			enable <= 0;                 // senal de enable en bajo
	    end else begin
			contador <= 0;               // si se ha llegado a la cantidad especifica, han pasado 2 segundos aprox.
			 enable <= 1;                // se genera una senal de enable que ira al WE del pipo register
	    end
    end

endmodule
