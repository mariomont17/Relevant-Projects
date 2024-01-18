module tb_UART;

logic clk_i = '0;
logic rst_i = '0;
logic tx_start = '0;
logic rx_data_rdy = '0;
logic tx_done = '0;

logic [7 : 0] data_in = '0;
logic [7 : 0] data_out = '0;

logic rx = '0;
logic tx = '0;



UART DUT(
    .clk            (clk_i),
    .reset          (rst_i),
    .tx_start       (tx_start),
    .rx_data_rdy    (rx_data_rdy),
    .tx_done        (tx_done),
    .data_in        (data_in),
    .data_out       (data_out),
    .rx             (rx),
    .tx             (tx)
);


initial begin
    #200
    @(posedge clk_i);
    #1
    rst_i = 1'b1;
    #100 
    rst_i = 1'b0;
    #200000
    @(posedge clk_i);
    #1
    tx_start = 1'b1;
    data_in = 8'b0000_1010;
    #100
    tx_start = 1'b0;
    #1500000000
       
    $finish;

end

always #50 clk_i = ~clk_i;//clk 10MHz

endmodule