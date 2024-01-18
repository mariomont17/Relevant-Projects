`timescale 1ns / 1ps
module tb_top_sistema_empotrado;       // probar APLICACION FINAL

    logic                   clk_100m_i = '0;  // clock de 100 MHz
    logic                   rst_i = 1;        // boton de reset
    logic [19 : 0]          sw_bt_i = '0;          // 16 switches y 4 botones
    logic                   rx_a_i = '1;     
    logic                   rx_b_i = '1;
    logic                   rx_c_i = '1;
    
    logic [15 : 0]          leds_o;      
    logic [7 : 0]           an_o;
    logic [7 : 0]           seg_o;
    logic                   tx_a_o;
    logic                   tx_b_o;
    logic                   tx_c_o;
    
    top_sistema_empotrado DUT(  // PRIMERA VERSION DEL MODULO TOP 
    
        .clk_100m_i         (clk_100m_i), 
        .rst_i              (rst_i),     
        .sw_bt_i            (sw_bt_i),    
        .rx_a_i             (rx_a_i),     
        .rx_b_i             (rx_b_i),
        .rx_c_i             (rx_c_i),
        .leds_o             (leds_o),      
        .an_o               (an_o),
        .seg_o              (seg_o),
        .tx_a_o             (tx_a_o),
        .tx_b_o             (tx_b_o),
        .tx_c_o             (tx_c_o)
    
    );
    
    
    always #5 clk_100m_i = ~clk_100m_i;//clk 100MHz
    
    logic [7 : 0]     dato_rx = '0;

    task UART_A_WRITE_BYTE( // FUNCION PARA LA RECEPCION DE DATOS
    
        input logic [7:0] i_Data
        
        ); 
    
    integer     ii;
    begin
       
      // Send Start Bit
      rx_a_i = 1'b0;
      #(104166); // (10x10^6/9600)*100ns = 104166 (SIN REDONDEAR)
       
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          rx_a_i = i_Data[ii];
          #(104166);
        end
       
      // Send Stop Bit
      rx_a_i = 1'b1;
      #(104166);
     end
    endtask
    
    task UART_B_WRITE_BYTE( // FUNCION PARA LA RECEPCION DE DATOS
    
        input logic [7:0] i_Data
        
        ); 
    
    integer     ii;
    begin
       
      // Send Start Bit
      rx_b_i = 1'b0;
      #(104166); // (10x10^6/9600)*100ns = 104166 (SIN REDONDEAR)
       
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          rx_b_i = i_Data[ii];
          #(104166);
        end
       
      // Send Stop Bit
      rx_b_i = 1'b1;
      #(104166);
     end
    endtask    
    
    
    
    
    initial begin
        
        #7000
        rst_i = 1'b1;
        #200 
        rst_i = 1'b0;
        #400000
        
        // TESTEO DEL MODO REPOSO -> PROCESAMIENTO -> CONSUMIR
        
        sw_bt_i = 32'b0000_0000_0010_0000_0000;
        

        @(posedge clk_100m_i);
                     //DATO_DESTINO
        dato_rx =   8'b1010_0010;            // DATO ENVIADO DESDE EL EXTERIOR, identificador igual a SW[11:8]
        UART_A_WRITE_BYTE(dato_rx);
        #100000
        
        // TESTEO DEL MODO REPOSO -> PROCESAMIENTO -> RETRANSMITIR
        
         @(posedge clk_100m_i);
                     //DATO_DESTINO
        dato_rx =   8'b0101_1000;            // DATO ENVIADO DESDE EL EXTERIOR, identificador distinto a SW[11:8]
        UART_B_WRITE_BYTE(dato_rx);
        #100000
        
        #12000000 // se espera para que se puedan enviar datos de nuevo
        // TESTEO DE MODOS: REPOSO -> GENERACION 
        @(posedge clk_100m_i);
        sw_bt_i = 32'b0001_0000_0010_0011_0000;
        #100
        sw_bt_i = 32'b0000_0000_0010_0011_0000;
        #100
        sw_bt_i = 32'b0001_0000_0010_0011_0000;
        #100
        sw_bt_i = 32'b0000_0000_0010_0011_0000;
        #50000
        $finish;
        
    end
    
endmodule