module module_conductor_de_bus(
    
    input logic             we_i,               // entrada del demux  
    input logic [31 : 0]    addr_i,
    
    input logic [31 : 0]    do_ram_i,
    input logic [31 : 0]    do_switches_i,
    input logic [31 : 0]    do_uart_a_i,
    input logic [31 : 0]    do_uart_b_i,
    input logic [31 : 0]    do_uart_c_i,
    
    output logic            we_ram_o,
    output logic            we_leds_o,
    output logic            we_7seg_o,
    output logic            we_uart_a_o,
    output logic            we_uart_b_o,
    output logic            we_uart_c_o,
    
    output logic [31 : 0]   d_out_o            // salida del mux

    );
    
    // DEMUX
    
    always_comb begin
        
        if((addr_i >= 32'd0) && (addr_i <= 32'h0FFC)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h1000) && (addr_i <= 32'h13FC)) begin
            we_ram_o        =   we_i;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h1400) && (addr_i < 32'h2004)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2004) && (addr_i < 32'h2008)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   we_i;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2008) && (addr_i < 32'h200C)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   we_i;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h200C) && (addr_i < 32'h2010)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2010) && (addr_i < 32'h2014)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   we_i;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2014) && (addr_i < 32'h2018)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2018) && (addr_i < 32'h201C)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   we_i;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h201C) && (addr_i < 32'h2020)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2020) && (addr_i < 32'h2024)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   we_i;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2024) && (addr_i < 32'h2028)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2028) && (addr_i < 32'h202C)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   we_i;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h202C) && (addr_i < 32'h2030)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2030) && (addr_i < 32'h2034)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   we_i;
        end
        else if ((addr_i >= 32'h2034) && (addr_i < 32'h2038)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else if ((addr_i >= 32'h2038) && (addr_i < 32'h203C)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   we_i;
        end
        else if ((addr_i >= 32'h203C) && (addr_i < 32'h2040)) begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
        else begin
            we_ram_o        =   1'b0;
            we_leds_o       =   1'b0;
            we_7seg_o       =   1'b0;
            we_uart_a_o     =   1'b0;
            we_uart_b_o     =   1'b0;
            we_uart_c_o     =   1'b0;
        end
    end
    
    // MUX
    
    always_comb begin
        
//        if((addr_i >= 32'd0) && (addr_i <= 32'h0FFC)) begin
//            d_out_o     =   do_rom_i;  
//        end
        if ((addr_i >= 32'h1000) && (addr_i <= 32'h13FC)) begin
            d_out_o     =   do_ram_i;
        end
        else if ((addr_i >= 32'h2000) && (addr_i < 32'h2004)) begin
            d_out_o     =   do_switches_i;
        end
        else if ((addr_i >= 32'h2004) && (addr_i < 32'h2010)) begin
            d_out_o     =   32'd0;
        end
        else if ((addr_i >= 32'h2010) && (addr_i < 32'h2014)) begin
            d_out_o     =   do_uart_a_i;
        end
        else if ((addr_i >= 32'h2014) && (addr_i < 32'h2018)) begin
            d_out_o     =   32'd0;
        end
        else if ((addr_i >= 32'h2018) && (addr_i < 32'h2020)) begin
            d_out_o     =   do_uart_a_i;
        end
        else if ((addr_i >= 32'h2020) && (addr_i < 32'h2024)) begin
            d_out_o     =   do_uart_b_i;
        end
        else if ((addr_i >= 32'h2024) && (addr_i < 32'h2028)) begin
            d_out_o     =   32'd0;
        end
        else if ((addr_i >= 32'h2028) && (addr_i < 32'h2030)) begin
            d_out_o     =   do_uart_b_i;
        end
        else if ((addr_i >= 32'h2030) && (addr_i < 32'h2034)) begin
            d_out_o     =   do_uart_c_i;
        end
        else if ((addr_i >= 32'h2034) && (addr_i < 32'h2038)) begin
            d_out_o     =   32'd0;
        end
        else if ((addr_i >= 32'h2038) && (addr_i < 32'h2040)) begin
           d_out_o     =   do_uart_c_i; 
        end
        else begin
            d_out_o     =   32'd0;
        end
        
    end

endmodule