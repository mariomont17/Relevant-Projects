`timescale 1ns / 1ps
module tb_forwarding();
    logic clk;
    logic reset;
    logic [31:0] WriteData, DataAdr;
    logic MemWrite;
    

    top_v1 dut(clk, reset, WriteData, DataAdr, MemWrite);
    

    initial
        begin
            reset <= 1; # 120; reset <= 0;
        end
    
    always
        begin
            clk <= 1; # 50; clk <= 0; # 50;
        end
    
    
    always @(posedge clk)
    begin
        if(MemWrite) begin
            //if(DataAdr === 32'ha & WriteData === 32'ha) begin
            if(DataAdr === 32'ha & WriteData === 32'ha) begin
                $display("Simulacion completada");
                $display("En %g ns se escribió un %g en la direccion de memoria %h",$time, WriteData, DataAdr);
                $stop;
            end
        end
        $display("En %g ns ForwarsAE: %b ForwardBE: %b",$time,tb_forwarding.dut.riscv.hu.forwardae_o,tb_forwarding.dut.riscv.hu.forwardbe_o);
    end
endmodule