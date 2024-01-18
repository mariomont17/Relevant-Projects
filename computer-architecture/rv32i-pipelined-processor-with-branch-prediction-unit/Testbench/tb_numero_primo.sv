`timescale 1ns / 1ps

`define FORWARDING 1
`define PREDICCION_SALTOS 1
 
module tb_num_primo();
    logic clk;
    logic reset;
    logic [31:0] WriteData, DataAdr;
    logic MemWrite;
    logic NoForwarding, NoBPU;
    
    shortreal InstructionCount;
    shortreal ClockCyles;
    shortreal CPI;

    top_v1 dut(clk, reset, WriteData, DataAdr, MemWrite, NoForwarding, NoBPU );
    

    initial
        begin
            NoForwarding = `FORWARDING;
            NoBPU = `PREDICCION_SALTOS;
            reset <= 1; # 22; reset <= 0;
        end
    
    always
        begin
            clk <= 1; # 50; clk <= 0; # 50;
        end
    
    
    always @(posedge clk)
    begin
        if(tb_num_primo.dut.riscv.dp.rf.we3_i) begin
            if(tb_num_primo.dut.riscv.dp.rf.rf[10][31:0] === 32'h1 ) begin

                $display("[%g] Simulación completada exitosamente", $time);
                $display("[%g] El número es primo", $time);
//                $stop;
            end
        end
    end
    
    
    initial begin
        InstructionCount = 0;
        ClockCyles = 0;
    end
    
    always @(posedge clk) begin
        if (tb_num_primo.dut.ROM.spo != 32'h0) begin
            if ($changed(tb_num_primo.dut.ROM.spo)) begin
                InstructionCount++;
            end
        end 
        if (!reset) ClockCyles++;
    end
    
    
    property RestarFlushes; // esta propiedad funciona si no hay predictor de saltos
        disable iff (reset)
        @(posedge clk) 
         (!NoBPU && (!tb_num_primo.dut.riscv.hu.stalld_o) && (tb_num_primo.dut.riscv.hu.stallf_o) && (tb_num_primo.dut.ROM.spo != 32'h0)) |=> (!tb_num_primo.dut.riscv.hu.flushd_o);
    endproperty
    
    property RestarFlushesConBPU; // esta propiedad funciona si hay predictor de saltos
        disable iff (reset)
        @(posedge clk) 
        NoBPU  |-> !tb_num_primo.dut.riscv.hu.flushd_o;
    endproperty

    property terminar;
        disable iff (reset)
        @(negedge clk) 
         (tb_num_primo.dut.ROM.spo == 32'h0)[*5] |-> $stable(tb_num_primo.dut.ROM.a);
    endproperty
    
    prop_terminar: assert property (terminar) else begin
        $display("[%g] La simulación ha terminado, cálculo del CPI con Forwarding = %0b y Predicción de saltos = %0b", $time,NoForwarding,NoBPU);
        CPI = ClockCyles/InstructionCount;
        $display("[%g] Cantidad de Instrucciones: %0d", $time, InstructionCount);
        $display("[%g] Cantidad de Ciclos del Reloj: %0d", $time, ClockCyles);
        $display("[%g] CPI de la aplicicación de Fibonacci: %0.3f", $time, CPI);
        $finish;
    end
    
    prop_RestarFlushes: assert property (RestarFlushes) else begin
       InstructionCount--; 
    end
    
    prop_RestarFlushesConBPU: assert property (RestarFlushesConBPU) else begin
       InstructionCount = InstructionCount-2; 
    end
    
    
endmodule