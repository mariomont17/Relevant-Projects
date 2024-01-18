module tb_control_register;

logic               clk_i   =   '0;  
logic               rst_i   =   '0;  
logic               wr1_i   =   '0;  
logic               wr2_i   =   '0; 
logic [31 : 0]      in1_i   =   '0;
logic [31 : 0]      in2_i   =   '0;
logic [31 : 0]      out_o   =   '0;

control_register DUT(
    .clk_i  (clk_i),  
    .rst_i  (rst_i),
    .wr1_i  (wr1_i),
    .wr2_i  (wr2_i),
    .in1_i  (in1_i),
    .in2_i  (in2_i),
    .out_o  (out_o)
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
    wr2_i = 1'b1;
    wr1_i = 1'b1;
    in2_i = {30'b0, 1'b1, 1'b0};
    #100
    wr2_i = 1'b0;
    #500
       
    $finish;
end

always #50 clk_i = ~clk_i;//clk 10MHz

endmodule