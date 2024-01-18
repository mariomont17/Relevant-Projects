`timescale 1ns/1ps
module module_deco_7seg(
    input logic  [3:0]   data,
    input logic          dp,
    output logic [7:0]   seg,
    output logic [7:0]   an
);

    always_comb begin
        
        case(data)
            // al ser un display de anodo comun, los segmentos se activan en bajo
            //                          gfe_dcba
            4'b0000:    seg[6 : 0] = 7'b100_0000; // 0
            4'b0001:    seg[6 : 0] = 7'b111_1001; // 1
            4'b0010:    seg[6 : 0] = 7'b010_0100; // 2
            4'b0011:    seg[6 : 0] = 7'b011_0000; // 3
            4'b0100:    seg[6 : 0] = 7'b001_1001; // 4
            4'b0101:    seg[6 : 0] = 7'b001_0010; // 5
            4'b0110:    seg[6 : 0] = 7'b000_0010; // 6
            4'b0111:    seg[6 : 0] = 7'b111_1000; // 7
            4'b1000:    seg[6 : 0] = 7'b000_0000; // 8
            4'b1001:    seg[6 : 0] = 7'b001_0000; // 9
            4'b1010:    seg[6 : 0] = 7'b000_1000; // A
            4'b1011:    seg[6 : 0] = 7'b000_0011; // B
            4'b1100:    seg[6 : 0] = 7'b100_0110; // C
            4'b1101:    seg[6 : 0] = 7'b010_0001; // D
            4'b1110:    seg[6 : 0] = 7'b000_0110; // E
            default:    seg[6 : 0] = 7'b000_1110; // F      
        endcase
        seg[7] = dp;
        an = 8'b11111110; // Encender solo 1 display
    end  
endmodule