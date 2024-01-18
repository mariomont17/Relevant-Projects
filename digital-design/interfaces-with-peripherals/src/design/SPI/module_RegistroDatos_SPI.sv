module module_RegistroDatos_SPI #(
    parameter  N = 8    // Profundidad del banco de registros
)
(
     input  logic                 clk_i,       // Reloj 10 MHz
     input  logic                 reset_i,     // Señal de reset
     input  logic                 wr1_i,       // Enable de escritura de afuera
     input  logic                 wr2_i,       // Enable de escritura del SPI 
     input  logic                 hold_ctrl_i, // Escoger si escribir y leer con puntero de SPI o de afuera
     input  logic [$clog2(N)-1:0]   addr1_i,     // Puntero de afuera
     input  logic [$clog2(N)-1:0]   addr2_i,     // Puntero de SPI
     input  logic [31:0]          data1_i,     // Datos a escribir de afuera
     input  logic [31:0]          data2_i,     // Datos a escribir del SPI
     output logic [31:0]          data_o       // Datos leídos
);
  
logic [N-1:0][31:0] registro;                  // Banco de registros
      
always_ff @(posedge clk_i) begin               // En el flanco positivo del reloj...
    if (reset_i) begin                         // Si reset es 1...
        registro <= '0;                        // Registro todo en 0
    end else begin                             // Si ese no es el caso...
        if (hold_ctrl_i) begin                 // Si hold_ctrl es 1...
            if(wr2_i) begin                    // Si WE del SPI es 1...
                registro[addr2_i] <= data2_i;  // Escribir los datos en la dirección
            end
            data_o = registro[addr2_i]; // Leer en la misma dirección
        end else begin                         // Si hold_ctrl es 0...
            if (wr1_i) begin                   // Si WE de afuera es 1...
                registro[addr1_i] <= data1_i;  // Escribir los datos en la dirección
            end
            data_o = registro[addr1_i]; // Leer en la misma dirección
        end
    end    
end

endmodule

