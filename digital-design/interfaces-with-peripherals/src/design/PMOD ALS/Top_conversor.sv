
module top_conversor(
    input  logic [7:0]   ENTRADA,
    output logic [3:0]   UNIDADES,
    output logic [3:0]   DECENAS,
    output logic [3:0]   CENTENAS,
    output logic [7:0]   ascii_unidades,
    output logic [7:0]   ascii_decenas,
    output logic [7:0]   ascii_centenas
);

logic [3 : 0] unid;
logic [3 : 0] dec;
logic [3 : 0] cent;

always_comb begin
    UNIDADES = unid;
    DECENAS = dec;
    CENTENAS = cent;    
end
    
    module_binary_to_bcd BCD(
    .ENTRADA  (ENTRADA),
    .UNIDADES (unid),
    .DECENAS  (dec),
    .CENTENAS (cent)
    );
    
    module_bcd2ascii ASCII(
    .UNIDADES        (unid),
    .DECENAS         (dec),
    .CENTENAS        (cent),
    .ascii_unidades  (ascii_unidades),
    .ascii_decenas   (ascii_decenas),
    .ascii_centenas  (ascii_centenas)
    );
endmodule
