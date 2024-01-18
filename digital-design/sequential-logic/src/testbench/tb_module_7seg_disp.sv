`timescale 1ns / 1ps
module tb_module_7seg_disp;

logic           clk = 1'b0;
logic           rst = 1'b0;
logic [15 : 0]  data_in = 16'h0000;
logic           we = 1'b0;
logic [7 : 0]   an = 8'h00;
logic [7 : 0]   seg = 8'h00;


module_7seg_disp DUT ( 
    .clk        (clk),
    .rst        (rst),
    .data_in    (data_in),	
    .we         (we),
    .an         (an),
    .seg        (seg)
);

initial begin
    #100
    @(posedge clk); 
    #1
    rst = 1'b1;
    #100
    rst = 1'b0;
    #100
    data_in = 16'h0255;
    we = 1'b1;
    #1000
    $finish;
end


always #50 clk = ~clk;//clk 10MHz

endmodule