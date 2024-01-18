module interfaz_7segmentos(
    input logic             clk,
    input logic             rst,
    input logic [15 : 0]    data_in,	
    input logic             we,
    output logic [7 : 0]    an,
    output logic [7 : 0]    seg    
);
logic [15 : 0]   data_out;

module_control_disp_7_seg control(
    .clk    (clk),
    .rst    (rst),
    .hex0   (data_out[3:0]),
    .hex1   (data_out[7:4]),
    .hex2   (data_out[11:8]),
    .hex3   (data_out[15:12]),
    .an     (an),
    .seg    (seg)
);

module_pipo_register registro(
    .clk        (clk),
    .rst        (rst),
    .we         (we),
    .data_in    (data_in),
    .data_out   (data_out)
);


endmodule