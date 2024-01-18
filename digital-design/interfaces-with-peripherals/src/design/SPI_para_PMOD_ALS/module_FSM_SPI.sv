module module_FSM_SPI #(
    parameter N = 32                          // Profundidad del banco de registros
)(
    input  logic                   clk_i,       // Reloj 10 MHz
    input  logic                   reset_i,     // Señal de reset
    input  logic [31:0]            data_ctrl_i, // Datos de control
    input  logic [31:0]            data_tx_i,   // Datos a enviar
    input  logic [7:0]             data_rx_i,   // Datos recibidos
    input  logic                   spi_fin_i,   // Indicador de fin de transacción
    input  logic [($clog2(N)):0]   n_i,         // Cuantas transacciones llevo
    output logic [7:0]             data_tx_o,   // Datos enviados hacia SPI
    output logic                   en_spi_o,    // Habilitador del SPI
    output logic                   en_cont_o,   // Habilitador del contador de transacciones
    output logic                   wr_ctrl_o,   // Sobreescribir en registro de control
    output logic                   wr_data_o,   // Sobreescribir en registro de datos
    output logic                   hold_ctrl_o, // Para registro datos, escoger si hacerle caso al SPI o a afuera
    output logic [31:0]            data_o,      // Salida de datos hacia registro de datos
    output logic [31:0]            data_ctrl_o, // Salida de datos hacia registro de control
    output logic [($clog2(N))-1:0]   addr_data_o // Dirección para escribir en registro de datos
);

// Definición de estados
typedef enum logic [2:0] {
   Inicio,
   Cambio_addr,
   Cambio_dato,
   Evaluar,
   Operar,
   Fin
} state_type;

state_type estado_act; // Estado actual
state_type estado_sig; // Estado siguiente

logic [7:0]           data_tx_next;
logic                 en_spi_next;
logic                 en_cont_next;
logic                 wr_ctrl_next;
logic                 wr_data_next;
logic                 hold_ctrl_next;
logic [31:0]          data_next;
logic [31:0]          data_ctrl_next;
logic [($clog2(N)):0] addr_data_next;

// Registros
always_ff @(posedge clk_i)
    if (reset_i) begin
        data_tx_o <= 0;
        en_spi_o <= 0;
        en_cont_o <= 0;
        wr_ctrl_o <= 0;
        wr_data_o <= 0;
        hold_ctrl_o <= 0;
        data_o <= 0;
        data_ctrl_o <= 0;
        addr_data_o <= 0;
        estado_act <= Inicio;
    end else begin
        data_tx_o <= data_tx_next;
        en_spi_o <= en_spi_next;
        en_cont_o <= en_cont_next;
        wr_ctrl_o <= wr_ctrl_next;
        wr_data_o <= wr_data_next;
        hold_ctrl_o <= hold_ctrl_next;
        data_o <= data_next;
        data_ctrl_o <= data_ctrl_next;
        addr_data_o <= addr_data_next;
        estado_act <= estado_sig;
    end

// Lógica de estado siguiente
always_comb begin

    estado_sig = estado_act;
    
    data_tx_next = data_tx_o;
    en_spi_next = en_spi_o;
    en_cont_next = en_cont_o;
    wr_ctrl_next = wr_ctrl_o;
    wr_data_next = wr_data_o;
    hold_ctrl_next = hold_ctrl_o;
    data_next = data_o;
    data_ctrl_next = data_ctrl_o;
    addr_data_next = addr_data_o;
    
    unique case (estado_act)
    Inicio: begin
        data_tx_next = 0;
        en_spi_next = 0;
        en_cont_next = 0;
        wr_ctrl_next = 0;
        wr_data_next = 0;
        hold_ctrl_next = 0;
        data_next = 0;
        data_ctrl_next = 0;
        addr_data_next = 0;
        if (data_ctrl_i[0]) begin
            hold_ctrl_next = 1;
            addr_data_next = n_i;
            estado_sig = Cambio_addr;
        end else begin
            estado_sig = Inicio;
        end
    end
    
    Cambio_addr: begin
        wr_data_next = 0;
        addr_data_next = n_i;
        estado_sig = Cambio_dato;
    end
    
    Cambio_dato: begin
        if (n_i <= data_ctrl_i[12:4]) begin
            wr_ctrl_next = 1;
            data_ctrl_next[0] = 1;
            data_ctrl_next[1] = 1; 
            data_ctrl_next[12:4] = data_ctrl_i[12:4];
            data_ctrl_next[25:16] = n_i;
            estado_sig = Evaluar;
        end else begin
            en_spi_next = 0;
            wr_data_next = 0;
            wr_ctrl_next = 1;
            data_ctrl_next[0] = 0; 
            data_ctrl_next[1] = 0;
            data_ctrl_next[25:16] = n_i;
            estado_sig = Fin;
        end
    end
    
    Evaluar: begin
        if (data_ctrl_i[0]) begin
            wr_ctrl_next = 0;
            wr_data_next = 0;
            en_cont_next = 1;
            if (n_i <= data_ctrl_i[12:4]) begin
                addr_data_next = n_i;
                if (data_ctrl_i[2]) begin
                    data_tx_next = 8'b00000000;
                    en_spi_next = 1;
                    estado_sig = Operar;
                end else begin
                    if (data_ctrl_i[3]) begin
                        data_tx_next = 8'b11111111;
                        en_spi_next = 1;
                        estado_sig = Operar;
                    end else begin
                        data_tx_next = data_tx_i[7:0];
                        en_spi_next = 1;
                        estado_sig = Operar;
                    end
                end
            end else begin
                en_spi_next = 0;
                wr_data_next = 0;
                wr_ctrl_next = 1;
                data_ctrl_next[0] = 0;
                data_ctrl_next[1] = 0;
                estado_sig = Inicio;
            end
        end else begin
            estado_sig = Inicio;
        end
    end
    
    Operar: begin
        if (spi_fin_i) begin
            if (n_i <= data_ctrl_i[12:4]) begin
                wr_data_next = 1;
                data_next = {'0, data_rx_i};
                addr_data_next = n_i;
                estado_sig = Cambio_addr;
            end else begin
                en_spi_next = 0;
                wr_data_next = 0;
                wr_ctrl_next = 1;
                data_ctrl_next[0] = 0;
                data_ctrl_next[1] = 0; 
                estado_sig = Inicio;
            end
        end else begin
            estado_sig = Operar;
        end
    end
    
    Fin: begin
        estado_sig = Inicio;
    end

    endcase
    
end

endmodule