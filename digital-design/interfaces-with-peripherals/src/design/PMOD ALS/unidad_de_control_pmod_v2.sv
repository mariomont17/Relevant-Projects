module unidad_de_control_pmod_v2 #(
    // MUESTREO DE DATOS, SE PUEDE CAMBIAR PARA SIMULACION
    parameter MUESTREO = 10_000_000  // (10x10^6)(100x10^-9) = 1 segundo

)(
    
    input logic             clk,
    input logic             rst,

    // INTERFAZ SPI
    input logic [31 : 0]    salida_spi,     // VALOR ACTUAL
    output logic [31 : 0]   entrada_spi,    // VALOR SIGUIENTE
    output logic            wr_spi,
    output logic            reg_sel_spi,
    output logic [2 : 0]    addr_spi,
    
    // INTERFAZ UART
    input logic [31 : 0]    salida_uart,    // VALOR ACTUAL
    output logic [31 : 0]   entrada_uart,   // VALOR SIGUIENTE del registro de control, va al mux 0
    output logic            wr_uart,
    output logic            reg_sel_uart,
    output logic            addr_uart,
    
    // 7 SEGMENTOS
    output logic            we_7seg,

    // MUX 4 a 1 INTERMEDIO
    
    output logic [1 : 0]    sel_mux,
    output logic [7 : 0]    medicion  
      
);

// estas variables se utilizan para ralizar la obtencion
// de los 8 bits de informacion de la medicion del sensor 

logic [4:0]     spi_0;  // guarda los bits mas significativos, registro 0 del spi
logic [2:0]     spi_1;  // guarda los tres bits menos significativos, registro 1 del spi
logic           we_spi_0;     
logic           we_spi_1;
logic           we_spi_0_next;
logic           we_spi_1_next;
logic [7 : 0]   union_spi;

logic [$clog2(MUESTREO) - 1 : 0] contador_reg;  // contador que controla el muestreo de 1 segundo

// Definicion de variables de salida

logic [31 : 0]   entrada_spi_next;
logic            wr_spi_next;
logic            reg_sel_spi_next;
logic [2 : 0]    addr_spi_next;

logic [31 : 0]   entrada_uart_next;
logic            wr_uart_next;
logic            reg_sel_uart_next;
logic            addr_uart_next;

logic            we_7seg_next;
    
logic [1 : 0]    sel_mux_next;

// estas variables permiten realizar un tiempo necesario entre transacciones del UART

localparam N = 100000;

logic [$clog2(N) - 1 : 0] q_reg;
logic [$clog2(N) - 1 : 0] q_next;

// se concatenan los datos de la medicion del sensor para obtener un solo byte

assign union_spi = {spi_0, spi_1};
assign medicion = union_spi;

//definicion de estados 

typedef enum logic [4 : 0] {
    ZERO,
    INICIO,
    DATO_SPI_0,
    WAIT_ADDR,
    DATO_SPI_1,
    MOSTRAR_DATO,
    CENTENAS,
    WAIT1,
    ENVIAR1,
    ESPERA1,
    DECENAS,
    WAIT2,
    ENVIAR2,
    ESPERA2,
    UNIDADES,
    WAIT3,
    ENVIAR3,
    ESPERA3,
    ENTER,
    WAIT4,
    ENVIAR4
} state_type;

state_type state_reg;
state_type state_next;

// LOGICA SECUENCIAL 

always_ff @(posedge clk) 
begin
    if (rst)
    begin
        state_reg <= ZERO;
        contador_reg <= MUESTREO;
        q_reg   <= '0;
    end else begin
        entrada_spi <= entrada_spi_next;    // VALOR SIGUIENTE
        wr_spi <= wr_spi_next;
        reg_sel_spi <= reg_sel_spi_next;
        addr_spi <= addr_spi_next;

        entrada_uart <= entrada_uart_next;   // VALOR SIGUIENTE del registro de control, va al mux 0
        wr_uart <= wr_uart_next;
        reg_sel_uart <= reg_sel_uart_next;
        addr_uart <= addr_uart_next;
        
        we_7seg <= we_7seg_next;

        sel_mux <= sel_mux_next;
        
        we_spi_0 <= we_spi_0_next;
        we_spi_1 <= we_spi_1_next;
        
        state_reg <= state_next;
        
        q_reg <= q_next;
        
        // esta parte permite resetear el contador cuando se alcance un segundo
        
        if (contador_reg == '0)
        begin
            contador_reg <= MUESTREO;
        end            
        else 
        begin
            contador_reg <= contador_reg - 1'b1;
        end
    end

end

always_ff @(posedge clk) 
begin
    if (rst)begin
        spi_0 <= 5'd0;
        spi_1 <= 3'd0;
    end else begin
        if (we_spi_0) begin
            spi_0 <= salida_spi[4:0];
        end
        if (we_spi_1) begin
            spi_1 <= salida_spi[7:5];
        end
    end

end

// LOGICA DEL ESTADO SIGUIENTE

always_comb 
begin   
//  VALORES POR DEFECTO
entrada_spi_next         = 32'd0;
wr_spi_next              = 1'b0;
reg_sel_spi_next         = 1'b0;
addr_spi_next            = 3'b0;

entrada_uart_next        = 32'd0;  // este es el de control
wr_uart_next             = 1'b0;
reg_sel_uart_next        = 1'b0;
addr_uart_next           = 1'b0;

we_7seg_next             = 1'b0;
sel_mux_next             = 2'b00;

we_spi_0_next            = 1'b0;
we_spi_1_next            = 1'b0;

q_next                   = q_reg; 

state_next  = state_reg;

    unique case (state_reg)
        ZERO: 
        begin
           entrada_spi_next         = 32'd0;
            wr_spi_next              = 1'b0;
            reg_sel_spi_next         = 1'b0;
            addr_spi_next            = 3'b0;
            
            entrada_uart_next        = 32'd0;  // este es el de control
            wr_uart_next             = 1'b0;
            reg_sel_uart_next        = 1'b0;
            addr_uart_next           = 1'b0;
            
            we_7seg_next             = 1'b0;
            sel_mux_next             = 2'b00;
            
            we_spi_0_next            = 1'b0;
            we_spi_1_next            = 1'b0; 
            state_next              = INICIO;
        end
        
        INICIO:
        begin
            if (contador_reg == '0) 
            begin
                entrada_spi_next = 32'h0000_0013;    // escribe 1 en el registro de control, hace una transferencia
                wr_spi_next      = 1'b1;     // WE reg control spi
                state_next  = DATO_SPI_0; 
            end
        end
        
        DATO_SPI_0:
        begin
// si el bit de send esta en cero -> se ha completado la transferencia SPI -> se lee el registro de datos  
            //if (salida_spi[0] == 1'b0)  
            if(salida_spi == 32'h0002_0010)   
            begin
                reg_sel_spi_next         = 1'b1;
                addr_spi_next            = 3'b0;
                we_spi_0_next            = 1'b1;
                state_next          = WAIT_ADDR;
                
            end   
        
        end
        WAIT_ADDR:
        begin
            addr_spi_next = 3'b1;
            state_next = DATO_SPI_1;
        end
        DATO_SPI_1:
        begin
            reg_sel_spi_next         = 1'b1;
            addr_spi_next            = 3'b1;
            we_spi_1_next            = 1'b1;
            state_next          = MOSTRAR_DATO;
        end
        
        MOSTRAR_DATO: 
        begin
            we_7seg_next     = 1'b1;     // se muestra el dato BCD en display
            state_next  = CENTENAS;
        end
        
        CENTENAS: // se escriben las centenas en el registro de datos cero
        begin
            sel_mux_next         = 2'b01;
            reg_sel_uart_next    = 1'b1;
            wr_uart_next         = 1'b1;
            state_next      = WAIT1;
        end
        WAIT1:
        begin
            state_next = ENVIAR1;
        end
        ENVIAR1: 
        begin
            if (salida_uart[0] == 1'b0)
            begin
                sel_mux_next         = 2'b00;
                reg_sel_uart_next    = 1'b0;
                wr_uart_next         = 1'b1;
                entrada_uart_next    = 32'd1;
                q_next               = N;
                state_next      = ESPERA1;
            end else begin
                reg_sel_uart_next = 1'b0;
                state_next = ENVIAR1;
            end
        end
        ESPERA1:
        begin
            q_next = q_reg - 1;
            if(q_next == '0) 
            begin
                sel_mux_next = 2'b10;
                state_next = DECENAS;
            end else begin
                state_next = ESPERA1;
            end
        end
        
        DECENAS: 
        begin
            if (salida_uart[0] == 1'b0)
            begin
                sel_mux_next         = 2'b10;
                reg_sel_uart_next    = 1'b1;
                wr_uart_next         = 1'b1;
                state_next      = WAIT2;
            end else begin
                reg_sel_uart_next    = 1'b0;
                sel_mux_next         = 2'b10;
                state_next = DECENAS;
            end
        end
        
        WAIT2: 
        begin
        
            reg_sel_uart_next = 1'b0;
            state_next  =   ENVIAR2;        
        end
        
        ENVIAR2:
        begin
            if (salida_uart[0] == 1'b0)
            begin
                sel_mux_next         = 2'b00;
                reg_sel_uart_next    = 1'b0;
                wr_uart_next         = 1'b1;
                entrada_uart_next    = 32'd1;
                q_next               = N;
                state_next      = ESPERA2;
            end else begin
                reg_sel_uart_next = 1'b0;
                state_next = ENVIAR2;
            end
        end
        ESPERA2: 
        begin
            q_next = q_reg - 1;
            if(q_next == '0) 
            begin
                sel_mux_next = 2'b11;
                state_next = UNIDADES;
            end else begin
                state_next = ESPERA2;
            end
        end
        
        UNIDADES:
        begin
            if (salida_uart[0] == 1'b0)
            begin
                sel_mux_next         = 2'b11;
                reg_sel_uart_next    = 1'b1;
                wr_uart_next         = 1'b1;
                state_next      = WAIT3;
            end else begin
                reg_sel_uart_next    = 1'b0;
                sel_mux_next         = 2'b11;
                state_next = UNIDADES;
            end
        end
        
        WAIT3:
        begin
            reg_sel_uart_next = 1'b0;
            state_next = ENVIAR3;
        end
        
        ENVIAR3:
        begin
            if (salida_uart[0] == 1'b0)
            begin
                sel_mux_next         = 2'b00;
                reg_sel_uart_next    = 1'b0;
                wr_uart_next         = 1'b1;
                entrada_uart_next    = 32'd1;
                q_next               = N;
                state_next      = ESPERA3;
            end else begin
                reg_sel_uart_next = 1'b0;
                state_next = ENVIAR3;
            end
        end
        ESPERA3:
        begin
            q_next = q_reg - 1;
            if(q_next == '0) 
            begin
                sel_mux_next = 2'b11;
                state_next = ENTER;
            end else begin
                state_next = ESPERA3;
            end
        end
        ENTER:
        begin
            if (salida_uart[0] == 1'b0)
            begin
                sel_mux_next         = 2'b00;
                reg_sel_uart_next    = 1'b1;
                wr_uart_next         = 1'b1;
                entrada_uart_next    = 32'h20;
                state_next      = WAIT4;
            end else begin
                reg_sel_uart_next    = 1'b0;
                sel_mux_next         = 2'b11;
                state_next = ENTER;
            end
        end
        WAIT4:
        begin
            reg_sel_uart_next = 1'b0;
            state_next = ENVIAR4;
        end
        ENVIAR4:
        begin
            if (salida_uart[0] == 1'b0)
            begin
                sel_mux_next         = 2'b00;
                reg_sel_uart_next    = 1'b0;
                wr_uart_next         = 1'b1;
                entrada_uart_next    = 32'd1;
                q_next               = N;
                state_next      = ZERO;
            end else begin
                reg_sel_uart_next = 1'b0;
                state_next = ENVIAR4;
            end
        end
    endcase


end

endmodule