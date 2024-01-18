module module_SPI (
    input  logic        clk_i,      // Reloj 10 MHz
    input  logic        reset_i,    // Señal de reset
    input  logic [7:0]  data_i,     // Entrada datos a enviar
    input  logic        en_i,       // Habilitador de transacciones
    input  logic        miso_i,     // Bit recibido
    output logic [7:0]  data_rx_o,  // Dato recibido
    output logic        mosi_o,     // Bit enviado
    output logic        sclk_o,     // Reloj de enviar y recibir
    output logic        spi_fin_o   // Señal de aviso de final de transacción
);

// Definición de estados
typedef enum logic [2:0] {
   Inicio,
   Espera1,
   Espera2,
   Espera3,
   cpha_delay,
   Transferir,
   Leer
} state_type;

// Declaración de variables actuales y siguientes
logic        cpol = 1;     // cpol y cpha me definen el modo de operación del SCLK
logic        cpha = 1;
logic [6:0]  cuenta = 49;  // Cuántos ciclos de reloj de 10 MHz debo contar para formar la mitad del reloj de 100 KHz.
logic        p_clk;        // Valor de SCLK (alto o bajo)
logic [7:0]  si_reg;       // Bits recibidos de estado actual
logic [7:0]  si_next;      // Bits recibidos de estado siguiente
logic [7:0]  so_reg;       // Bits enviados en el estado actual
logic [7:0]  so_next;      // Bits enviados en el estado siguiente
logic [2:0]  n_reg;        // Conteo de cuántos bits se han recibido en el estado actual
logic [2:0]  n_next;       // Conteo de cuántos bits se han recibido en el estado siguiente
logic [15:0] c_reg;        // Conteo de pulsos de reloj de 10 MHz en el estado actual
logic [15:0] c_next;       // Conteo de pulsos de reloj de 10 MHz en el estado siguiente
logic        spi_clk_reg;  // Estado actual del reloj SPI 
logic        spi_clk_next; // Estado siguiente del reloj SPI

state_type estado_act;     // Estado actual
state_type estado_sig;     // Estado siguiente

// Registro
always_ff @(posedge clk_i)                     // En el flanco positivo de reloj...                
    if (reset_i) begin                         // Si reset es 1...
        estado_act <= Inicio;                  // Estado siguiente es Inicio
        si_reg <= 0;                           // Las salidas actuales se ponen 0
        so_reg <= 0;
        n_reg <= 0;
        c_reg <= 0;
        spi_clk_reg <= 0;
    end else begin                             // Si ese no es el caso
        estado_act <= estado_sig;              // Estado actual pasa al siguiente
        si_reg <= si_next;                     // Los valores actuales pasan a los siguientes
        so_reg <= so_next;
        n_reg <= n_next;
        c_reg <= c_next;
        spi_clk_reg <= spi_clk_next;
    end

// Lógica de estado siguiente
always_comb begin

    estado_sig = estado_act;                   // Estado siguiente cambia al actual
    si_next = si_reg;                          // Variables siguientes cambian a acutales
    so_next = so_reg;
    n_next = n_reg;
    c_next = c_reg;
    spi_fin_o = 0;                             // Indicador de fin de transacción en 0
    
    unique case (estado_act)
    Inicio: begin                              // Estado Inicio
        if (en_i) begin                        // Si Enable es 1...
            estado_sig = Espera1;              // Estado siguiente es Espera1
        end else begin                         // Si Enable es 0...
            estado_sig = Inicio;               // Estado siguiente es Inicio
        end
    end
    
    Espera1: begin
        estado_sig = Espera2;                  // Estado siguiente es Espera2
    end
    
    Espera2: begin
        if (en_i) begin                        // Si Enable es 1...
            estado_sig = Espera3;              // Estado siguiente es Espera3
        end else begin                         // Si Enable es 0...
            estado_sig = Inicio;               // Estado siguiente es Inicio
        end
    end
    
    Espera3: begin
        so_next = data_i;                      // Los datos a enviar se colocan en un registro
        n_next = 0;                            // El contador de bits enviados se coloca en 0
        c_next = 0;                            // El contador de pulsos de reloj se coloca en 0
        if (cpha) begin
            estado_sig = cpha_delay;           // Estado siguiente es cpha_delay
        end else begin
            estado_sig = Transferir;           // Estado siguiente es Transferir
        end
    end
   
    cpha_delay: begin
        if (c_reg == cuenta) begin
            c_next = 0;
            estado_sig = Transferir;
        end else begin
            c_next = c_reg + 1;
        end
    end
   
    Transferir: begin                          // Estado Transferir
        if (c_reg == cuenta) begin             // Si el contador de pulsos actual es igual a cuenta...
            estado_sig = Leer;                 // Estado siguiente es Leer
            si_next = {si_reg[6:0], miso_i};   // El registro siguiente de datos recibidos es el bit nuevo más los últimos 6
            c_next = 0;                        // Contador de pulsos reiniciado
        end else                               // Si el contador de pulsos actual no ha llegado...
            c_next = c_reg + 1;                // El contador de pulsos siguiente es el actual más 1
        end
    
    Leer: begin                                // Estado Leer
        if (c_reg == cuenta)                   // Si el contador actual es igual a la cuenta...
            if (n_reg == 7) begin              // Si el contador de bits ya llegó a 7
                spi_fin_o = 1;                 // Indicador de fin de transacción en 1
                estado_sig = Inicio;           // Estado siguiente es Inicio
            end else begin                     // Si el contador acutal no ha llegado...
                so_next = {so_reg[6:0], 1'b0}; // El registro siguiente de bits enviados es 1 más los últimos 6
                estado_sig = Transferir;       // Estado siguiente es Transferir
                n_next = n_reg + 1;            // El contador de bits siguiente es el actual más 1
                c_next = 0;                    // Contador de pulsos reiniciado
            end
        else                                   // Si el contador de pulsos no ha llegado
            c_next = c_reg + 1;                // El contador de pulsos siguiente es el actual más 1
    end
    
    endcase
    
end

assign p_clk = ((estado_sig==Leer) && ~cpha) || ((estado_sig==Transferir) && cpha); // Determina el valor de reloj SCLK
assign spi_clk_next = (cpol)? ~p_clk : p_clk; // El valor de spi_clk siguiente es el valor de p_clk

assign data_rx_o = si_reg;   // Dato recibido es lo que hay en el registro de bits recibidos
assign mosi_o = so_reg[7];   // Bit de salida es el de la posición 7 del registro de envío
assign sclk_o = spi_clk_reg; // El valor de reloj SCLK es el valor actual de spi_clk

endmodule