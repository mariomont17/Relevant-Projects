`timescale 1ns / 1ps
module tb_top_v1;       // probar HOLA MUNDO

    logic                   clk_100m_i = '0;  // clock de 100 MHz
    logic                   rst_i = 1;        // boton de reset
    logic [19 : 0]          sw_bt_i = '0;          // 16 switches y 4 botones
    logic                   rx_a_i = 1;     
    logic                   rx_b_i = 1;
    logic                   rx_c_i = 1;
    
    logic [15 : 0]          leds_o;      
    logic [7 : 0]           an;
    logic [7 : 0]           seg;
    logic                   tx_a_o;
    logic                   tx_b_o;
    logic                   tx_c_o;
    
    top_v1 DUT(  // PRIMERA VERSION DEL MODULO TOP 
    
        .clk_100m_i         (clk_100m_i), 
        .rst_i              (rst_i),     
        .sw_bt_i            (sw_bt_i),    
        .rx_a_i             (rx_a_i),     
        .rx_b_i             (rx_b_i),
        .rx_c_i             (rx_c_i),
        .leds_o             (leds_o),      
        .an_o               (an),
        .seg_o              (seg),
        .tx_a_o             (tx_a_o),
        .tx_b_o             (tx_b_o),
        .tx_c_o             (tx_c_o)
    
    );
    
    
    always #5 clk_100m_i = ~clk_100m_i;//clk 100MHz
    
    initial begin
        
        #7000
        rst_i = 1'b1;
        #200 
        rst_i = 1'b0;
        #3000
        $finish;
        
    end
    
   
    
endmodule