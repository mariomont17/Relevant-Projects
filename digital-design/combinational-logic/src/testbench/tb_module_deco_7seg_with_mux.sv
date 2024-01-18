`timescale 1ns/1ps

module tb_module_deco_7seg_with_mux;

    //VARIABLES DE ESTIMULO
    logic [3 : 0]       sw_1_4;
    logic [3 : 0]       sw_5_8;
    logic [3 : 0]       sw_9_12;
    logic [3 : 0]       sw_13_16;
    logic [1 : 0]       btn;
    
    //SALIDAS DEL MODULO
    logic [7 : 0]       segments;
    
module_deco_7seg_with_mux DUT(
    .sw_1_4         (sw_1_4),
    .sw_5_8         (sw_5_8),
    .sw_9_12        (sw_9_12),
    .sw_13_16       (sw_13_16),
    .btn            (btn),
    .segments       (segments)
);

initial begin
    sw_1_4 = '0;
    sw_5_8 = '0;
    sw_9_12 = '0;
    sw_13_16 = '0;
    btn = '0;
    #10
    btn = 2'b00;
    sw_1_4 = 10;
    #10
    btn = 2'b01;
    sw_5_8 = 7;
    #10
    btn = 2'b10;
    sw_9_12 = 15;
    #10
    btn = 2'b11;
    sw_13_16 = 2;
    #10
    $finish;
end
endmodule