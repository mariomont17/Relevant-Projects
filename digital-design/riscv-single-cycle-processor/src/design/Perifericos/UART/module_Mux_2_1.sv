module module_mux_2_1 #(
    parameter ANCHO = 32 // Ancho de los datos en bits
)(
    input  logic [ANCHO - 1 : 0] dato1_i, // Dato de entrada 1
    input  logic [ANCHO - 1 : 0] dato2_i, // Dato de entrada 2
    input  logic                 sel_i,   // Selector
    output logic [ANCHO - 1 : 0] out_o    // Salida
);

    always_comb begin
        case(sel_i)
            1'b0: out_o = dato1_i; // Si selector en 0, pasar el dato 1
            1'b1: out_o = dato2_i; // Si selector en 1, pasar el dato 2
        endcase
    end

endmodule