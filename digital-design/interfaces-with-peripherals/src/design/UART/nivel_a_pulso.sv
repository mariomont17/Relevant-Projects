module nivel_a_pulso (
    input logic     clk,
    input logic     rst,
    input logic     button_i,
    output logic    pulse_o
);

typedef enum logic [1 : 0] {
    ESPERA,
    FLANCO,
    ALTO
} state_type;

state_type state_reg;
state_type state_next;

always_ff @(posedge clk, posedge rst) begin
    if(rst) 
        state_reg <= ESPERA;
    else 
        state_reg <= state_next;    
end

always_comb begin
    state_next = state_reg; 
    pulse_o = 1'b0; 
    case (state_reg)
        ESPERA: begin
            if(button_i)
                state_next = FLANCO;
            else state_next = ESPERA;
        end
        FLANCO: begin
            pulse_o = 1'b1;
            if (button_i) 
                state_next = ALTO;
                
            else
                state_next = ESPERA;
        end
        
        ALTO: begin
            if(!button_i)
                state_next = ESPERA;
            else state_next = ALTO;
        end
        default: state_next = ESPERA;
    endcase
end

endmodule