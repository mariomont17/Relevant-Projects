`timescale 1ns/1ps
module tb_module_mux_4_1_ancho_16;

//PARAMETRO
localparam ANCHO_PRUEBA = 16;

//VARIABLES DE ESTIMULO
     logic [ANCHO_PRUEBA - 1 : 0]     a;
     logic [ANCHO_PRUEBA - 1 : 0]     b;
     logic [ANCHO_PRUEBA - 1 : 0]     c;
     logic [ANCHO_PRUEBA - 1 : 0]     d;
     logic [1 : 0]             sel;
     
//SALIDAS DEL MODULO
     logic [ANCHO_PRUEBA - 1 : 0]    out;

module_mux_4_1 #(.ANCHO(ANCHO_PRUEBA))DUT(
    .a      (a),
    .b      (b),
    .c      (c),
    .d      (d),
    .sel    (sel),
    .out    (out)
);

initial begin
    a   = '0;
    b   = '0;
    c   = '0;
    d   = '0;
    sel = '0;
    #10
    sel = 2'b00;
    for (int i = 0; i <50 ; i++) begin
        #1
        a = i;
        end
    #10
    sel = 2'b01;
    for (int j = 0; j <50 ; j++) begin
        #1
        b = j;
        end
    #10
    sel = 2'b10;
    for (int k = 0; k <50 ; k++) begin
        #1
        c = k;
        end
    #10
    sel = 2'b11;
    for (int l = 0; l <50 ; l++) begin
        #1
        d = l;
        end
    #10
    $finish;
end

endmodule