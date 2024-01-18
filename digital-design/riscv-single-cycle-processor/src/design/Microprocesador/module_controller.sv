module module_controller(
    
    input logic             funct7b5_i,
    input logic             zero_i,
    input logic [6 : 0]     op_i,
    input logic [2 : 0]     funct3_i,
    
    output logic            mem_write_o,
    output logic            pc_src_o,
    output logic            alu_src_o,
    output logic            reg_write_o,
    output logic            jump_o,
    output logic [1 : 0]    result_src_o,
    output logic [1 : 0]    imm_src_o, 
    output logic [2 : 0]    alu_control_o   

);

    logic [1 : 0]   alu_op;
    logic           branch;

    module_main_decoder main_decoder (
        
        .op_i                   (op_i), 
        .result_src_o           (result_src_o), 
        .mem_write_o            (mem_write_o), 
        .branch_o               (branch),
        .alu_src_o              (alu_src_o), 
        .reg_write_o            (reg_write_o), 
        .jump_o                 (jump_o),
        .imm_src_o              (imm_src_o),
        .alu_op_o               (alu_op)
            
    );
    
    module_alu_decoder alu_decoder (
        
        .opb5_i                 (op_i[5]), 
        .funct3_i               (funct3_i),
        .funct7b5_i             (funct7b5_i),
        .alu_op_i               (alu_op),
        .alu_control_o          (alu_control_o)
        
    );
    
    // COMPUERTA XOR para bne    
    assign pc_src_o = (branch & (zero_i ^ funct3_i[0])) | jump_o;

endmodule
