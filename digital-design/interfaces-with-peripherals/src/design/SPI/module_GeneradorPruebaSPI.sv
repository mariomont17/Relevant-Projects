module module_GeneradorPruebaSPI (
    input  logic [7:0]          entrada_i,
    input  logic [31:0]         salida_i,
    output logic [31:0]         entrada_o,
    output logic [15:0]         salida_o 
);

always_comb begin
    entrada_o = {'0,entrada_i};
    salida_o = salida_i[15:0];
end

endmodule