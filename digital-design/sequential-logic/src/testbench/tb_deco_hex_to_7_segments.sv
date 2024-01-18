`timescale 1ns / 1ps

module tb_deco_hex_to_7_segments;
logic            clk;
logic [7 : 0]    an;
logic [7 : 0]    seg;

logic [15 : 0]   data_out;
logic            o_lfsr_done;
logic [16-1:0]   o_lfsr_data;
logic             enable;
logic            clk_10m;
logic            locked;

// CLOCKING WIZARD
clk_wiz_0 my_clock (
    .clk_out1(clk_10m),
    .locked(locked),    
    .clk_in1(clk)
);
// MODULO DE CONTROL
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

// LFSR
LFSR #(.NUM_BITS(16)) LFSR_inst
         (.i_clk       (clk_10m),
          .i_rst       (locked),
          .i_enable    (locked),
          .i_seed_data ({16{1'b0}}), 
          .o_lfsr_data (o_lfsr_data),
          .o_lfsr_done (o_lfsr_done)
);
 
// REGISTRO DE ENTRADA Y SALIDA EN PARALELO
module_pipo_register registro(
    .clk        (clk_10m),
    .rst        (locked),
    .we         (enable),
    .data_in    (o_lfsr_data),
    .data_out   (data_out)
);

initial begin 
clk = 0;
enable = 0;
#5000
enable = 1;
#3000
enable = 0;
#500
enable = 1;
#1000
$finish;
end
always #5 clk = ~clk;
endmodule
