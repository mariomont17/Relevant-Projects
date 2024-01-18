`timescale 1ns / 1ps
module tb_top_single_cycle_processor;
    
    logic                   clk_100m_i  = '0;
    logic                   rst_i       = 1;
    logic [31 : 0]          write_data;     
    logic [31 : 0]          alu_out;     
    logic                   mem_write;
    
    top_riscv_single_cycle_processor_v2 DUT(
    
        .clk_100m_i     (clk_100m_i),
        .rst_i          (rst_i), 
        .write_data     (write_data),
        .alu_out        (alu_out),
        .mem_write      (mem_write)
    
    );
    
    always #5 clk_100m_i = ~clk_100m_i;//clk 100MHz
    
    initial begin
        
        #7000
        rst_i = 1'b1;
        #200 
        rst_i = 1'b0;
        #3000
        $finish;
        
    end
    
   
    
endmodule