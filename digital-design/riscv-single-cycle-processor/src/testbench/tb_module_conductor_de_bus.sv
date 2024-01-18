`timescale 1ns / 1ps
module tb_module_conductor_de_bus;
    
    // ENTRADAS 
    logic               we_i;               // entrada del demux  
    logic [31 : 0]      addr_i;
    logic [31 : 0]      do_ram_i;
    logic [31 : 0]      do_switches_i;
    logic [31 : 0]      do_uart_a_i;
    logic [31 : 0]      do_uart_b_i;
    logic [31 : 0]      do_uart_c_i;
    
    // SALIDAS
    logic               we_ram_o;
    logic               we_leds_o;
    logic               we_7seg_o;
    logic               we_uart_a_o;
    logic               we_uart_b_o;
    logic               we_uart_c_o;
    logic [31 : 0]      d_out_o;

    module_conductor_de_bus DUT(
    
        .we_i               (we_i),                
        .addr_i             (addr_i),
        .do_ram_i           (do_ram_i),
        .do_switches_i      (do_switches_i),
        .do_uart_a_i        (do_uart_a_i),
        .do_uart_b_i        (do_uart_b_i),
        .do_uart_c_i        (do_uart_c_i),
        .we_ram_o           (we_ram_o),
        .we_leds_o          (we_leds_o),
        .we_7seg_o          (we_7seg_o),
        .we_uart_a_o        (we_uart_a_o),
        .we_uart_b_o        (we_uart_b_o),
        .we_uart_c_o        (we_uart_c_o),
        .d_out_o            (d_out_o)           

    );
    
    initial begin
    
        we_i            =   1'b1;
        addr_i          =   1;
        do_ram_i        =   10;
        do_switches_i   =   20;
        do_uart_a_i     =   30;
        do_uart_b_i     =   40;
        do_uart_c_i     =   50;    
        #100
        addr_i          =   1;
        #100
        addr_i          =   32'h1000;
        #100
        addr_i          =   32'h1400;
        #100
        addr_i          =   32'h2000;
        #100
        addr_i          =   32'h2004;
        #100
        addr_i          =   32'h2008;
        #100
        addr_i          =   32'h200C;
        #100
        addr_i          =   32'h2010;
        #100
        addr_i          =   32'h2014;
        #100
        addr_i          =   32'h2018;
        #100
        addr_i          =   32'h201C;
        #100
        addr_i          =   32'h2020;
        #100
        addr_i          =   32'h2028;
        #100
        addr_i          =   32'h202C;
        #100
        addr_i          =   32'h2030;
        #100
        addr_i          =   32'h2034;
        #100
        addr_i          =   32'h2038;
        #100
        addr_i          =   32'h203C;
        #100
        $finish;
    end


endmodule