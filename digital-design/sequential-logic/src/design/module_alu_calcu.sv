module module_alu_calcu(
    input logic  [15:0]     operador_a_i,
    input logic  [15:0]     operador_b_i,
    input logic  [3:0]      operando_i,
    output logic [15:0]     result_o
    );
    
    always_comb begin
        case(operando_i)
            4'b1010:
               result_o = operador_a_i + operador_b_i;
            4'b1011:
                result_o = operador_a_i - operador_b_i;
            4'b1100:
                result_o = operador_a_i | operador_b_i;
            4'b1101:
                result_o = operador_a_i & operador_b_i;
            4'b1110:
                result_o = operador_a_i >> operador_b_i;    
             default: result_o = '0;  
        endcase
    end
endmodule