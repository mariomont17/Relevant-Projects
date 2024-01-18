module fsm_new_rx (
    input logic     clk_i,                                 //Se definen las entradas y salidas de la maquina de estados
    input logic     rst_i,
    input logic     rx_data_rdy,
    output logic    we_reg_control,
    output logic    wr2,
    output logic    hold_ctrl,                             //Indica si la interfaz es la que escribe o el usuario
    output logic    new_rx
);
    
typedef enum logic [1 : 0] {                               //Se define una maquina de estados de 3 estados 
   INICIO,
   RECIBIDO,
   REGISTRO
} state_t;

state_t state_reg;                                         //Estado actual
state_t state_next;                                        //Estado siguiente

always_ff @(posedge clk_i) begin            //En cada ciclo positivo del reloj y el reset entonces
    if (rst_i) begin                                       //Si el reset está en uno entonces que el estado siguiente sea el inicio
        state_reg <= INICIO;
    end
    else begin                                             //Sino entonces que el estado actual pase al estado siguiente
        state_reg <= state_next; 
    end
end

always_comb begin
    state_next = state_reg;
    wr2 = 1'b0;                                            //El write enable del registro 1 se mantiene en cero
    we_reg_control = 1'b0;                                 //El write enable del registro de control se mantiene en cero
    hold_ctrl = 1'b0;                                      //El hold_ctrl se mantiene en cero 
    new_rx = 1'b0;
    case (state_reg)
        INICIO: begin
            if (rx_data_rdy)begin                          //Si se recibió al completo los 8 bits entonces rx_data_rdy se pondrá en 1
                wr2 = 1'b1;                                //Habilitará el write enable del registro 1 para guardar el dato
                hold_ctrl = 1'b1;                          //Pondrá el hold_ctrl para escribir el dato en el registro 1
                state_next = RECIBIDO;                     //Pasa al siguiente estado
            end
            else
                state_next = INICIO;                       //Sino se mantiene esperando hasta que el dato se haya recibido completamente
            end
        
        RECIBIDO: begin
            new_rx = 1'b1;                                 //Pone el new_rx en 1 para indicar que se recibió el dato
            we_reg_control = 1'b1;                         //Se habilita en write enable del registro de control
            state_next = REGISTRO;
        end
        
        REGISTRO: begin                                   //Pasa al estado incial
            state_next = INICIO;       
        end
    endcase

end
endmodule
