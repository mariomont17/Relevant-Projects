`timescale 1ns / 1ps

module top_hex_to_7_segments(
    input logic             clk, // senal de clock de la FPGA, por defecto a 100 MHz
    output logic [7 : 0]    an, // salida de anodos 
    output logic [7 : 0]    seg  // salida de los segmentos
);
logic [15 : 0]   data_out; // datos de salida del pipo register
logic            o_lfsr_done; // indica si se ha terminado la generacion de datos aleatorios
logic [15 : 0]   o_lfsr_data; // salida de datos del LFSR
logic             enable; // senal de enable
logic            clk_10m; // clock de 10 MHz
logic            locked; // senal de locked 
clk_wiz_0 my_clock (
    // Clock out ports
    .clk_out1(clk_10m),     // output clk_out1
    // Status and control signals
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk)
    );
module_control_disp_7_seg control(
    .clk    (clk_10m),
    .rst    (locked),
    .hex0   (data_out[3:0]),
    .hex1   (data_out[7:4]),
    .hex2   (data_out[11:8]),
    .hex3   (data_out[15:12]),
    .an     (an),
    .seg    (seg)
);
LFSR #(.NUM_BITS(16)) LFSR_inst
         (.i_clk       (clk_10m),
          .i_rst       (locked),
          .i_enable    (locked),
          .i_seed_data ({16{1'b0}}), 
          .o_lfsr_data (o_lfsr_data),
          .o_lfsr_done (o_lfsr_done)
          );
module_pipo_register registro(
    .clk        (clk_10m),
    .rst        (locked),
    .we         (enable),
    .data_in    (o_lfsr_data),
    .data_out   (data_out)
);
module_contador_2_segundos contador(
    .clk            (clk_10m),
    .rst            (locked),
    .enable         (enable)
);

endmodule