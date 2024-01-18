// MODULO TOP PARA PROBAR EL MICROPROCESADOR UNICICLO (VERSION 2)
// CON EL ARCHIVO DEL HARRIS & HARRIS

module top_riscv_single_cycle_processor_v2(
    
    input   logic               clk_100m_i,
    input   logic               rst_i,
    
    output logic [31 : 0]       write_data,     // data in ram
    output logic [31 : 0]       alu_out,        // address ram
    output logic                mem_write       // we  
    
    );
    logic               clk;
    
    logic [31 : 0]      instr;
    logic [31 : 0]      pc;
    logic [31 : 0]      read_data;
    
    
    clk_wiz_0 clock (
        
        .clk_out1           (clk),
        .clk_in1            (clk_100m_i)
        
    );
    
    module_riscvsingle_v2 procesador_monociclo (

        .clk_i              (clk),
        .rst_i              (rst_i),
        .ProgIn_i           (instr),
        .Data_In_i          (read_data),   
        .we_o               (mem_write),        // WE
        .ProgAddress_o      (pc),               // 
        .DataAddress_o      (alu_out),
        .DataOut_o          (write_data)
   
    );
    
    mem_ram RAM (
        
        .a                  (alu_out[9:2]),
        .d                  (write_data),
        .clk                (clk),
        .we                 (mem_write),
        .spo                (read_data)    
    
    );
    
    mem_rom_prueba_harris ROM (// profundidad = 32
        
        .a                  (pc[31:2]),
        .spo                (instr)    
    
    );
    
endmodule