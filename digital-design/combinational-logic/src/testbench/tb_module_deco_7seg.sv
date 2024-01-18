`timescale 1ns/1ps

module tb_module_deco_7seg;

//VARIABLE DE ESTIMULO
    logic [3 : 0]   data;
    
//SALIDA DEL MODULO
    logic [7 : 0]   seg;

module_deco_7seg DUT(
    .data   (data),
    .dp     (1'b1),
    .seg    (seg)
);

initial begin
    data = 4'b0000;
    #10;
    data = 4'b0001;
    #10;
    data = 4'b0010;
    #10;
    data = 4'b0011;
    #10;
    data = 4'b0100;
    #10;
    data = 4'b0101;
    #10;
    data = 4'b0110;
    #10;
    data = 4'b0111;
    #10;
    data = 4'b1000;
    #10;
    data = 4'b1001;
    #10;
    data = 4'b1010;
    #10;
    data = 4'b1011;
    #10;
    data = 4'b1100;
    #10;
    data = 4'b1101;
    #10;
    data = 4'b1110;
    #10;
    data = 4'b1111;
    #10;
    $finish;
end

endmodule