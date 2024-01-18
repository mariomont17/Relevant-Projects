module module_bcd2ascii (

    input logic  [3:0] UNIDADES,
    input logic  [3:0] DECENAS,
    input logic  [3:0] CENTENAS,
    output logic [7:0] ascii_unidades,
    output logic [7:0] ascii_decenas,
    output logic [7:0] ascii_centenas
    );
//    logic ascii_unidades;
//    logic ascii_decenas;
//    logic ascii_centenas;
    
    assign ascii_unidades = {4'b0011, UNIDADES};
    assign ascii_decenas  = {4'b0011,  DECENAS};
    assign ascii_centenas = {4'b0011, CENTENAS};
    
    //assign ascii_num= {ascii_unidades, ascii_decenas};
    
endmodule