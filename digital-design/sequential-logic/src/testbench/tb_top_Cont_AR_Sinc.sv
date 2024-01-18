// Escala de tiempo
`timescale 1ns/1ps

module tb_module_Cont_AR_Sinc;

// Variables de estímulo
logic clk;
logic btn;

// Salidas del módulo
logic [7:0] LEDs;

top_Cont_AR_S Ej2 (
    .clk (clk),
    .btn (btn),
    .LEDs (LEDs)
);

initial begin

    clk = 1;
    
    #5000
    btn = 1;
    #1
    btn = 0;
    #1
    btn = 1;
    #1
    btn = 0;
    #1
    btn = 1;
    
   #5000
    if (LEDs == 1) begin
        $display("Dato correcto");
    end else begin
        $display("Error");
    end
    btn = 0;
    #1
    btn = 1;
    #1
    btn = 0;
    #1
    btn = 1;
    #1
    btn = 0;
    
    #5000
    btn = 1;
    #1
    btn = 0;
    #1
    btn = 1;
    #1
    btn = 0;
    #1
    btn = 1;
    
    
    
   #5000
    if (LEDs == 2) begin
        $display("Dato correcto");
    end else begin
        $display("Error");
    end
    btn = 0;
    #1
    btn = 1;
    #1
    btn = 0;
    #1
    btn = 1;
    #1
    btn = 0;
    
    #5000
    btn = 1;
    #1
    btn = 0;
    #1
    btn = 1;
    #1
    btn = 0;
    #1
    btn = 1;
    
    
   #5000
    if (LEDs == 3) begin
        $display("Dato correcto");
    end else begin
        $display("Error");
    end
    btn = 0;
    #1
    btn = 1;
    #1
    btn = 0;
    #1
    btn = 1;
    #1
    btn = 0;
    
    #1000
    $finish;
    
end

always #5 clk = ~clk; // Emular la señal de reloj de 100 MHz

endmodule