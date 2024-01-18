module fsm_tx_uart (
    input  logic    clk_i,                               //Se definen las entradas y salidas de la maquina de estados 
    input  logic    rst_i,
    input  logic    send_reg,
    input  logic    tx_done_i,
    output logic    tx_start_o,                          //Indica cuando ha empezado la transmisión de datos.
    output logic    sel_control,
    output logic    we_reg_control_o,
    output logic    send_next
);
 
 logic fin;
 
typedef enum logic [1 : 0] {                             //Se definen 4 estados diferentes
    IDLE,
    START,
    DATA,
    STOP
} state_type;

state_type state_reg;                                    //Estado actual
state_type state_next;                                   //Estado siguiente

always_ff @(posedge clk_i) begin          //Siempre que pase por el flanco positivo del clk y el reset entonces
    if (rst_i) begin                                     //Si el reset está en 1 entonces que vaya al estado 0
        state_reg <= IDLE;
    end
    else begin                                           //Sino entonces que vaya al estao siguiente.
        state_reg <= state_next; 
    end
end

always_comb begin 
    state_next = state_reg;
    tx_start_o = 1'b0;                                  //La transferencia de datos se mantiene en cero.
    we_reg_control_o = 1'b0;                            //Write enable del registro de control en cero
    sel_control = 1'b0;                                 //Selección del mux está en cero
    send_next        = 1'b0;
    fin     = 1'b0;
    case (state_reg) 

        IDLE: begin                        
            if (send_reg) begin                         //Si entra un bit para la transmisión entonces que pase de estado
                state_next = START;            
            end 
            else begin
                state_next = IDLE;                      //Sino entonces que se mantenga en el primer estado esperando hasta que le llegue un bit.
            end
        end

        START: begin
            tx_start_o = 1'b1;                          //Entra al estado de transmisión por lo tanto pone tx_star_o en 1
            state_next = DATA;
        end

        DATA: begin
            if(tx_done_i) begin                         //Si la transmisión de datos se ha detenido entonces que pase al estado STOP.
                state_next = STOP;
            end
            else begin
                state_next = DATA;
            end
        end

        STOP: begin                                     //Pone el bit de send en 0 para indicar que la transferencia terminó 
            fin              = 1'b1;
            //send_next       = 1'b0;
            sel_control      = 1'b1;                    //La selección del mux se pone 1
            we_reg_control_o = 1'b1;                    //El write enable se pone en 1 para habilitar la escritura.
            state_next       = IDLE;            
        end
    endcase
    
end


endmodule