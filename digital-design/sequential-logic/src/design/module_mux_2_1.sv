`timescale 1ns / 1ps
module module_mux_2_1 (
    input logic [15 : 0]       a, //entrada 1
    input logic [15 : 0]       b, //entrada 2
    input logic               sel, //seleccion
    output logic [15 : 0]      out //salida
);

always_comb begin
    case(sel)
        1'b0:       out = a;
        1'b1:       out = b;
        default:    out = '0;
    endcase
end
endmodule

