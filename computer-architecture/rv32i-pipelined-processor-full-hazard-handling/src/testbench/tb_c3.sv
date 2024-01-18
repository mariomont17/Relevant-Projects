`timescale 1ns / 1ps
module tb_c3();
    logic clk;
    logic reset;
    logic [31:0] WriteData, DataAdr;
    logic MemWrite;
    

    top dut(clk, reset, WriteData, DataAdr, MemWrite);
    

    initial
        begin
            reset <= 1; # 22; reset <= 0;
        end
    
    always
        begin
            clk <= 1; # 50; clk <= 0; # 50;
        end
    
    
    always @(posedge clk)
    begin
        if(MemWrite) begin
            if(DataAdr === 32'h2004 & WriteData === 32'h2) begin
                $display("Simulacion completada");
                $display("En %g ns se escribió un %g en la direccion de memoria %h",$time, WriteData, DataAdr);
                $stop;
            end
        end
    end
endmodule