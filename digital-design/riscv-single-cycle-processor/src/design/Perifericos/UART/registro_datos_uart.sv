module registro_datos_uart (
    input logic             clk_i,      //  senal del reloj de 10 MHz
    input logic             rst_i,      //  senal de reset (activa en alto) 
    input logic             addr_i,     //  puntero de lectura desde el usuario (la interfaz solo lee el dato del registro cero)
    input logic             hold_ctrl_i,  //  senal que da prioridad a la escritura desde la interfaz
    input logic             wr1_i,      //  WE del usuario
    input logic             wr2_i,      //  WE de la interfaz
    input logic [31 : 0]    in1_i,      //  entrada de datos desde el usuario al registro 0
    input logic [31 : 0]    in2_i,      //  entrada de datos de la interfaz al registro 1
    output logic [31 : 0]   out1_o,     //  lectura de datos de los registros 0 ó 1 al usuario
    output logic [31 : 0]   out2_o      //  lectura de datos del registro 0 a la interfaz UART
);

logic [1 : 0] [31 : 0] registro; // dos registros de 32 bits cada uno

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        registro <= '0;
    end
    else begin
        if (hold_ctrl_i) begin // si se cumplen las dos condiciones se escribe el dato RECIBIDO en el registro 1
            if(wr2_i) begin
                registro[1] <= in2_i;
            end
        end
        else begin
            if (wr1_i) begin 
                registro[0] <= in1_i;
            end
        end
    end
end

assign out1_o = registro[addr_i]; // el usuario puede leer ambos registros
assign out2_o = registro[0]; // la interfaz solo lee el dato del registro 0

endmodule