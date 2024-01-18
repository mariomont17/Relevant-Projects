`timescale 1ns/1ps

module tb_module_Reloj;

// Variables de estimulo
logic clk;

// Salidas del modulo
logic clk_10m;
logic locked;

module_Reloj Reloj (
    .clk (clk),
    .clk_10m (clk_10m),
    .locked (locked)
);

initial begin
    clk = 1;
   
    
    #1000
    $finish;

end

always #5 clk = ~clk;

endmodule