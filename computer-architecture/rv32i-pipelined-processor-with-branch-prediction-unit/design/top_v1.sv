module top_v1( // PARA LA PRUEBA DE FORWARDING
    
    input   logic               clk_i,
    input   logic               rst_i,
    output logic [31 : 0]       WriteDataM_o,     // data in ram
    output logic [31 : 0]       DataAdrM_o,        // address ram
    output logic                MemWriteM_o,      // we  
    input logic                 NoForwarding, NoBPU
    
    );

    logic [31:0]    PCF, InstrF, ReadDataM;
    

    
    module_riscv_pipelined riscv(
    
        .clk_i              (clk_i), 
        .rst_i              (rst_i),
        .PCF_o              (PCF),
        .InstrF_i           (InstrF),
        .MemWriteM_o        (MemWriteM_o),
        .ALUResultM_o       (DataAdrM_o), 
        .WriteDataM_o       (WriteDataM_o),
        .ReadDataM_i        (ReadDataM),
        .NoForwarding       (NoForwarding),
        .NoBPU              (NoBPU)

    );
    
    
    mem_ram RAM (
        
        .a                  (DataAdrM_o[9:2]),
        .d                  (WriteDataM_o),
        .clk                (clk_i),
        .we                 (MemWriteM_o),
        .spo                (ReadDataM)    
    
    );
    
    
    mem_rom_v1 ROM (// profundidad = 256
        
        .a                  (PCF[9:2]), // PCF es el address de la ROM
        .spo                (InstrF)    // instruccion (salida ROM)
    
    );

    
endmodule