`timescale 1ns / 1ps
module tb_fsm_tx_uart;
logic               clk_i = 0;
logic               rst_i = 0;
logic [31 : 0]      control_i = 0;
logic               tx_done_i = 0;
logic               tx_start_o = 0;
logic               we_reg_control = 0;
logic [31 : 0]      control_o = 0;

fsm_tx_uart maquina_tx(
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .control_i      (control_i),
    .tx_done_i      (tx_done_i),
    .tx_start_o     (tx_start_o),
    .we_reg_control (we_reg_control),
    .control_o      (control_o)
);

initial begin
    #200
    @(posedge clk_i);
    #1
    rst_i = 1'b1;
    #200 
    rst_i = 1'b0;
    #200
    @(posedge clk_i);
    #1
    control_i[0] = 1'b1;
    #600
    @(posedge clk_i);
    #1
    tx_done_i = 1'b1;
    control_i[0] = 1'b0;
    #600    
    $finish;
end

always #50 clk_i = ~clk_i;//clk 10MHz

endmodule