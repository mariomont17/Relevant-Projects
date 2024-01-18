`timescale 1ns / 1ps
module tb_fibonacci();
    logic clk;
    logic reset;
    logic [31:0] WriteData, DataAdr;
    logic MemWrite;
    
    shortreal InstructionCount;
    shortreal ClockCyles;
    shortreal CPI;

    top_v1 dut(clk, reset, WriteData, DataAdr, MemWrite);
    

    initial
        begin
            reset <= 1; # 90; reset <= 0;
        end
    
    always
        begin
            clk <= 1; # 50; clk <= 0; # 50;
        end
    
    
    always @(posedge clk)
    begin
        if(MemWrite) begin
            if(DataAdr === 32'h2024 & WriteData === 32'h59) begin
                $display("[%g] Simulación completada", $time);
                $display("[%g] Se escribió un %g en la direccion de memoria %h",$time, WriteData, DataAdr);
               // $stop;
            end
        end
    end
    
    always @(posedge clk) begin
        if (tb_fibonacci.dut.riscv.c.BranchE) begin // si es una instruccion de branch 
            if (tb_fibonacci.dut.riscv.hu.flushd_o) begin
                $display("[%g] Predicción Incorrecta: Flush de los registros IF/ID y ID/EX del pipeline", $time);
            end else begin
                $display("[%g] Predicción Correcta: Se toma el address de la Unidad de Predicción de saltos", $time);
            end
        end    
    end
    
    initial begin
        InstructionCount = 0;
        ClockCyles = 0;
        #9400
        CPI = ClockCyles/InstructionCount;
        $display("[%g] Cantidad de Instrucciones: %0d", $time, InstructionCount);
        $display("[%g] Cantidad de Ciclos del Reloj: %0d", $time, ClockCyles);
        $display("[%g] CPI de la aplicicación de Fibonacci: %0.3f", $time, CPI);
        $finish;
    end
    
    always @(posedge clk) begin
        if ($changed(tb_fibonacci.dut.riscv.dp.pcreg.q_o)) begin
            InstructionCount++;
        end 
        if (tb_fibonacci.dut.riscv.hu.flushd_o || tb_fibonacci.dut.riscv.hu.flushe_o) begin
            InstructionCount = InstructionCount - 3;
        end else if (tb_fibonacci.dut.riscv.hu.stallf_o) InstructionCount = InstructionCount - 2;
        if (!reset) ClockCyles++;
    end
    
    
endmodule