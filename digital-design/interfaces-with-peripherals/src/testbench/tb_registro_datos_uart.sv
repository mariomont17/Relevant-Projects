module tb_registro_datos_uart;

logic               clk_i           =   '0;
logic               rst_i           =   '0; 
logic               addr_i          =   '0; 
logic               hold_ctrl_i     =   '0;
logic               wr1_i           =   '0;
logic               wr2_i           =   '0;
logic [31 : 0]      in1_i           =   '0;
logic [31 : 0]      in2_i           =   '0;
logic [31 : 0]      out1_o          =   '0;
logic [31 : 0]      out2_o          =   '0;

registro_datos_uart DUT (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .addr_i         (addr_i), 
    .hold_ctrl_i    (hold_ctrl_i),
    .wr1_i          (wr1_i),
    .wr2_i          (wr2_i),
    .in1_i          (in1_i),
    .in2_i          (in2_i),
    .out1_o         (out1_o),
    .out2_o         (out2_o)
);

initial begin
    #200
    @(posedge clk_i);
    #1
    rst_i = 1'b1;
    #100 
    rst_i = 1'b0;
    #100
    @(posedge clk_i);
    #1
    wr1_i = 1'b1;
    in1_i = {30'b0, 1'b0, 1'b1};
    #100
    wr1_i = 1'b0;
    #500 
    
    
    @(posedge clk_i);
    #1
    hold_ctrl_i = 1'b1;
    wr2_i = 1'b1;
    wr1_i = 1'b1;
    in2_i = {30'b0, 1'b1, 1'b0};
    #100
    wr2_i = 1'b0;
    #500
    wr1_i = 1'b0;
    addr_i = 1'b1;
    #300  
    $finish;
end

always #50 clk_i = ~clk_i;//clk 10MHz


endmodule