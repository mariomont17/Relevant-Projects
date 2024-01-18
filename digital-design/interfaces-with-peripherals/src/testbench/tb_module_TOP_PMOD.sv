`timescale 1ns/1ps
module tb_module_TOP_PMOD();
  
 logic            clk_100m_i = '0;
 logic            rst = '0;  
 logic            rx = '1;
 logic            tx = '1;
 
 logic [7 : 0]    an = '0;
 logic [7 : 0]    seg = '0;
  
 logic            bit_rx_i;
 logic            bit_tx_o;
 logic            cs_o;
 logic            sclk_o;
 
 
 
 module_top_PMOD_ALS #(.MUESTREO(2000))
 DUT(
     .clk_100m_i(clk_100m_i),
     .rst       (rst),  
     .rx        (rx),
     .tx        (tx),
     .an        (an),
     .seg       (seg),
     .bit_rx_i (bit_rx_i),
     .bit_tx_o (bit_tx_o),
     .cs_o      (cs_o),
     .sclk_o    (sclk_o)
 );
 
 always #5 clk_100m_i = ~clk_100m_i; 
 
 
 initial begin
   #7000 // inicio del clocking wizard
   rst = 1'b1;
   bit_rx_i = 1'b1;
   #2000
   rst = 1'b0;
   #200_000   
   //bit_tx_o=1;
   //entrada_spi[7:0] = 8'b10001001;
//   #10000
//   bit_rx_i=0;
//   //bit_tx_o=0;
//   #10000
//   bit_rx_i=1;
//   //bit_tx_o=1;
//   #10000
//   bit_rx_i=0;
//   #10000
//   bit_rx_i=1;
//   #10000
//   bit_rx_i=0;
//   //bit_tx_o=0;
   
    
   $finish;
end
endmodule
