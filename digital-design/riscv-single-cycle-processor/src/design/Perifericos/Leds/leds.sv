module module_leds(
    input  logic          clk_i,
    input  logic          rst_i,
    input  logic          we_leds_i,
    input  logic [31 : 0] leds_i,
    output logic [15 : 0] leds_o

    );
    logic [15 : 0] leds;
    always_ff @ ( posedge clk_i ) begin
        if( rst_i )begin
            leds <= 0;
        end
        else begin
            if( we_leds_i )begin
                leds <= leds_i[15 : 0];
            end
        end
    end
    //Logica de salida
    always_comb begin 
        leds_o = leds;
    end
endmodule