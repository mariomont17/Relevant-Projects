module top_sistema_empotrado(  // TOP DEL SISTEMA EMPOTRADO FINAL
    
    input logic                 clk_100m_i, // clock de 100 MHz
    input logic                 rst_i,      // boton de reset
    input logic [19 : 0]        sw_bt_i,    // 16 switches y 4 botones
    input logic                 rx_a_i,     
    input logic                 rx_b_i,
    input logic                 rx_c_i,
    
    output logic [15 : 0]       leds_o,      
    output logic [7 : 0]        an_o,
    output logic [7 : 0]        seg_o,
    output logic                tx_a_o,
    output logic                tx_b_o,
    output logic                tx_c_o
    
    );
    
    // SENAL DEL RELOJ DE 10 MHZ
    
    logic                   clk;
    logic                   locked;
    
    // SENALES DEL MICROPROCESADOR
    
    logic                   mem_write; 
    logic [31 : 0]          write_data; 
    logic [31 : 0]          alu_out;
    logic [31 : 0]          instr;
    logic [31 : 0]          pc;
    logic [31 : 0]          read_data;
    
    // SENALES DEL BUS DRIVER
    
    logic [31 : 0]          do_ram;
    logic [31 : 0]          do_switches;
    logic [31 : 0]          do_uart_a;
    logic [31 : 0]          do_uart_b;
    logic [31 : 0]          do_uart_c;
    logic                   we_ram;
    logic                   we_leds;
    logic                   we_7seg;
    logic                   we_uart_a;
    logic                   we_uart_b;
    logic                   we_uart_c;
    logic [31 : 0]          d_out;
         
    
    
    // INSTANCIA DE LOS MODULOS
    
    // CLOCKING WIZARD
    clk_wiz_0 RELOJ (
        
        .clk_out1           (clk),
        .clk_in1            (clk_100m_i),
        .locked             (locked)
        
    );
    
    // MICROPROCESADOR
    module_riscvsingle_v2 MICROPROCESADOR (

        .clk_i              (clk),              // reloj
        .rst_i              (rst_i),            // reset
        .ProgIn_i           (instr),            // instruccion de la ROM
        .Data_In_i          (d_out),            // datos leidos (del bus driver)
        .we_o               (mem_write),        // WE datos     (va al bus driver)
        .ProgAddress_o      (pc),               // address de programa (va a la ROM)
        .DataAddress_o      (alu_out),          // direccion (address datos, va a todo lado)
        .DataOut_o          (write_data)        // dato de salida 32 bits (va a todo lado)
   
    );
    
    // MEMORIA ROM 
    mem_rom_sist_empotrado ROM (
        
        .a                  (pc[31:2]),
        .spo                (instr)    
    
    );
    
    // BUS DRIVER
    module_conductor_de_bus BUS_DRIVER (
    
        .we_i               (mem_write),              
        .addr_i             (alu_out),
        .do_ram_i           (do_ram),
        .do_switches_i      (do_switches),
        .do_uart_a_i        (do_uart_a),
        .do_uart_b_i        (do_uart_b),
        .do_uart_c_i        (do_uart_c),
        .we_ram_o           (we_ram),
        .we_leds_o          (we_leds),
        .we_7seg_o          (we_7seg),
        .we_uart_a_o        (we_uart_a),
        .we_uart_b_o        (we_uart_b),
        .we_uart_c_o        (we_uart_c),
        .d_out_o            (d_out)     

    );
    
    // MEMORIA RAM (256 lineas)
    mem_ram RAM (
        
        .a                  (alu_out[9:2]),
        .d                  (write_data),
        .clk                (clk),
        .we                 (we_ram),
        .spo                (do_ram)    
    
    );
    
    // SWITCHES
    module_switches SWITCHES(
    
        .clk_i              (clk),
        .rst_i              (rst_i),
        .sw_bt_i            (sw_bt_i),
        .sw_o               (do_switches)
        
    );
    
    // LEDS
    module_leds LEDS(
    
        .clk_i              (clk),
        .rst_i              (rst_i),
        .we_leds_i          (we_leds),
        .leds_i             (write_data),
        .leds_o             (leds_o)

    );
    
    // 7 SEGMENTOS
    module_7seg_disp DISPLAY(
    
        .clk                (clk),
        .rst                (rst_i),
        .data_in            (write_data),	
        .we                 (we_7seg),
        .an                 (an_o),
        .seg                (seg_o)

    );
    
    // INTERFAZ UART A
    module_interfaz_UART UART_A( 
    
        .clk_i              (clk),                                
        .rst_i              (rst_i),                                 
        .entrada_i          (write_data),
        .reg_sel_i          (alu_out[3]),
        .wr_i               (we_uart_a),
        .addr_i             (alu_out[2]),
        .rx                 (rx_a_i),
        .salida_o           (do_uart_a),
        .tx                 (tx_a_o)
             
    );
    
    // INTERFAZ UART B
    module_interfaz_UART UART_B( 
    
        .clk_i              (clk),                                
        .rst_i              (rst_i),                                 
        .entrada_i          (write_data),
        .reg_sel_i          (alu_out[3]),
        .wr_i               (we_uart_b),
        .addr_i             (alu_out[2]),
        .rx                 (rx_b_i),
        .salida_o           (do_uart_b),
        .tx                 (tx_b_o)
             
    );
    
    // INTERFAZ UART C
    module_interfaz_UART UART_C( 
    
        .clk_i              (clk),                                
        .rst_i              (rst_i),                                 
        .entrada_i          (write_data),
        .reg_sel_i          (alu_out[3]),
        .wr_i               (we_uart_c),
        .addr_i             (alu_out[2]),
        .rx                 (rx_c_i),
        .salida_o           (do_uart_c),
        .tx                 (tx_c_o)
             
    );

endmodule