`timescale 1ns / 1ps
module tb_top_UART;

logic             clk_100m_i    = '0;
logic             rst_i         = '0;
logic [7 : 0]     entrada_i     = '0;
logic             reg_sel_i     = '0;
logic             wr_i          = '0;
logic             addr_i        = '0;
logic             rx            = '1;   // POR DEFECTO DEBE ESTAR EN ALTO
logic [7 : 0]     leds_o        = '0;
logic             tx            = '0;

logic [7 : 0]     dato_rx       = '0;

top_UART DUT(
    .clk_100m_i     (clk_100m_i),
    .rst_i          (rst_i),
    .entrada_i      (entrada_i),
    .reg_sel_i      (reg_sel_i),
    .wr_i           (wr_i),
    .addr_i         (addr_i),
    .rx             (rx),
    .leds_o         (leds_o),
    .tx             (tx)      
);

task UART_WRITE_BYTE(input logic [7:0] i_Data); // FUNCION PARA LA RECEPCION DE DATOS
    integer     ii;
    begin
       
      // Send Start Bit
      rx <= 1'b0;
      #(104166); // (10x10^6/9600)*100ns = 104166 (SIN REDONDEAR)
       
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          rx <= i_Data[ii];
          #(104166);
        end
       
      // Send Stop Bit
      rx <= 1'b1;
      #(104166);
     end
  endtask
  
  
initial begin
    #7000
    rst_i = 1'b1;
    #2000 
    rst_i = 1'b0;
    #200000
    entrada_i = 8'h25;      // DATO A TRANSMITIR
    wr_i = 1'b1;
    reg_sel_i = 1'b1;
    #6000
    entrada_i = 8'b0000_0001;   // BIT DE SEND EN ALTO
    wr_i = 1'b1;
    reg_sel_i = 1'b0;
    #5000
    wr_i = 1'b0;
    reg_sel_i = 1'b1;   
    #10000 
    addr_i = 1'b1;
    #100000
    @(posedge clk_100m_i);
    dato_rx = 8'hAB;            // DATO ENVIADO DESDE EL EXTERIOR
    UART_WRITE_BYTE(dato_rx);
    #100000
    $display("Sent out 0x%X", dato_rx, " - Received 0x%X", leds_o); // EN LOS LEDS SE LEE EL REGISTRO 1, QUE ALMACENA LOS DATOS RECIBIDOS
    if (leds_o == dato_rx)
        $display("Test Passed - Correct Byte Received");
    else 
        $display("Test Failed - Incorrect Byte Received");
    $finish;
end

always #5 clk_100m_i = ~clk_100m_i;//clk 100MHz

endmodule