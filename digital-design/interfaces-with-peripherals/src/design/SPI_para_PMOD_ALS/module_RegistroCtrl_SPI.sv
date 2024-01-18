 module module_RegistroCtrl_SPI (
    input logic         clk_i,   // Reloj 10 MHz
    input logic         reset_i, // Señal de reset
    input logic         wr1_i,   // Enable de escritura de afuera
    input logic         wr2_i,   // Enable de escritura del SPI
    input  logic [31:0] data1_i, // Datos a escribir de afuera
    input  logic [31:0] data2_i, // Datos a escribir del SPI
    output logic [31:0] data_o   // Datos leídos
 );
 
    always_ff @(posedge clk_i) begin      // En el flanco positivo del reloj...
        if (reset_i) begin                // Si reset es 1...
            data_o = '0;                  // Poner todo en 0
        end else begin
            if (wr2_i) begin                            // Si WE del SPI es 1...
                data_o[31:26] <= data2_i[31:26];        // Asociar los bits entrantes del SPI
                data_o[25:16] <= data2_i[25:16];
                data_o[15:13] <= data2_i[15:13];
                data_o[12:4]  <= data2_i[12:4];
                data_o[3]     <= data2_i[3];
                data_o[2]     <= data2_i[2];
                data_o[1]     <= data2_i[1];
                data_o[0]     <= data2_i[0];
            end else begin
                if (wr1_i) begin                        // Si WE de afuera es 1...
                    data_o[31:26] <= data1_i[31:26];    // Asociar los bits entrantes del SPI
                    data_o[25:16] <= data1_i[25:16];
                    data_o[15:13] <= data1_i[15:13];
                    data_o[12:4]  <= data1_i[12:4];
                    data_o[3]     <= data1_i[3];
                    data_o[2]     <= data1_i[2];
                    data_o[1]     <= data1_i[1];
                    data_o[0]     <= data1_i[0];
                end
            end
        end 
    end

 endmodule