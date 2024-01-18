module module_binary_to_bcd(
    input logic [7:0]   ENTRADA,
    output logic [3:0]  UNIDADES,
    output logic [3:0]  DECENAS,
    output logic [3:0]  CENTENAS
);

logic [3:0] c1,c2,c3,c4,c5,c6,c7;
logic [3:0] d1,d2,d3,d4,d5,d6,d7;

assign d1 = {1'b0,ENTRADA[7:5]};
assign d2 = {c1[2:0],ENTRADA[4]};
assign d3 = {c2[2:0],ENTRADA[3]};
assign d4 = {c3[2:0],ENTRADA[2]};
assign d5 = {c4[2:0],ENTRADA[1]};
assign d6 = {1'b0,c1[3],c2[3],c3[3]};
assign d7 = {c6[2:0],c4[3]};

add3 m1(d1,c1);
add3 m2(d2,c2);
add3 m3(d3,c3);
add3 m4(d4,c4);
add3 m5(d5,c5);
add3 m6(d6,c6);
add3 m7(d7,c7);

assign UNIDADES = {c5[2:0], ENTRADA[0]};
assign DECENAS  = {c7[2:0], c5[3]};
assign CENTENAS = {2'b00, c6[3], c7[3]};

endmodule