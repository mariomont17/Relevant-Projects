module module_riscvsingle_v2(
    
    input logic             clk_i,
    input logic             rst_i,
    input logic [31 : 0]    ProgIn_i,
    input logic [31 : 0]    Data_In_i,
    
    output logic            we_o,
    output logic [31 : 0]   ProgAddress_o,
    output logic [31 : 0]   DataAddress_o,
    output logic [31 : 0]   DataOut_o
    
);

// variables internas

    logic           alu_src;
    logic           reg_write;
    logic           jump;
    logic           zero;
    logic           pc_src;
    logic [1 : 0]   result_src;
    logic [1 : 0]   imm_src; 
    logic [2 : 0]   alu_control;

    module_controller controlador_principal(
    
        .zero_i                 (zero),
        .funct7b5_i             (ProgIn_i[30]),
        .op_i                   (ProgIn_i[6 : 0]), 
        .funct3_i               (ProgIn_i[14 : 12]),
        .mem_write_o            (we_o),
        .pc_src_o               (pc_src), 
        .alu_src_o              (alu_src),
        .reg_write_o            (reg_write),
        .jump_o                 (jump),
        .result_src_o           (result_src),
        .imm_src_o              (imm_src),
        .alu_control_o          (alu_control)
    
    );
    
    module_datapath datapath (
    
        .clk_i                  (clk_i),
        .rst_i                  (rst_i),
        .result_src_i           (result_src),
        .pc_src_i               (pc_src),
        .alu_src_i              (alu_src),
        .reg_write_i            (reg_write),
        .imm_src_i              (imm_src),
        .alu_control_i          (alu_control),
        .zero_o                 (zero),
        .pc_o                   (ProgAddress_o),
        .instr_i                (ProgIn_i),
        .alu_out_o              (DataAddress_o),
        .write_data_o           (DataOut_o),
        .read_data_i            (Data_In_i)
        
    );

endmodule