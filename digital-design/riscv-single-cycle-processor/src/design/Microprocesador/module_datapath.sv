module module_datapath (

        input logic                 clk_i, 
        input logic                 rst_i,
        input logic                 pc_src_i, 
        input logic                 alu_src_i,
        input logic                 reg_write_i, 
        input logic     [1:0]       result_src_i,
        input logic     [1:0]       imm_src_i,
        input logic     [2:0]       alu_control_i,
        input logic     [31:0]      instr_i,
        input logic     [31:0]      read_data_i,
        output logic                zero_o,
        output logic    [31:0]      pc_o,
        output logic    [31:0]      alu_out_o, 
        output logic    [31:0]      write_data_o
        );
        
        logic           [31:0]      pc_next; 
        logic           [31:0]      pc_plus4; 
        logic           [31:0]      pc_target;
        logic           [31:0]      imm_ext;
        logic           [31:0]      src_a; 
        logic           [31:0]      src_b;
        logic           [31:0]      result;

    // next PC logic
    
    module_flopr #(.WIDTH(32)) pcreg(
    
        .clk_i                  (clk_i), 
        .rst_i                  (rst_i), 
        .d_i                    (pc_next), 
        .q_o                    (pc_o)
        
    );
    
    module_adder pcadd4 (
    
        .a_i                    (pc_o), 
        .b_i                    (32'd4), 
        .y_o                    (pc_plus4)
    
    );
    
    module_adder pcaddbranch (
    
        .a_i                    (pc_o), 
        .b_i                    (imm_ext), 
        .y_o                    (pc_target)
    
    );
    
    module_mux_2_a_1 #(.WIDTH(32)) pcmux(
    
        .d0_i                   (pc_plus4), 
        .d1_i                   (pc_target), 
        .s_i                    (pc_src_i),
        .y_o                    (pc_next)
    
    );
    
    // register file logic
    
    module_regfile register_file(
    
        .clk_i                  (clk_i),
        .rst_i                  (rst_i),  
        .we3_i                  (reg_write_i), 
        .a1_i                   (instr_i[19 : 15]),
        .a2_i                   (instr_i[24 : 20]),
        .a3_i                   (instr_i[11 : 7]),
        .wd3_i                  (result), 
        .rd1_o                  (src_a), 
        .rd2_o                  (write_data_o)
    
    );
    
    module_extend   ext(
    
        .instr_i                (instr_i[31 : 7]),
        .imm_src_i              (imm_src_i),
        .imm_ext_o              (imm_ext)
    
    );
    
    module_mux_2_a_1 #(.WIDTH(32)) srcbmux(
    
        .d0_i                   (write_data_o), 
        .d1_i                   (imm_ext), 
        .s_i                    (alu_src_i),
        .y_o                    (src_b)
    
    );
    
    module_mux_3_a_1 #(.WIDTH(32)) resultmux(
    
        .d0_i                   (alu_out_o), 
        .d1_i                   (read_data_i),
        .d2_i                   (pc_plus4),
        .s_i                    (result_src_i),
        .y_o                    (result)
    
    );
    
    module_alu alu(
    
        .dato1_i                (src_a), 
        .dato2_i                (src_b), 
        .alu_control_i          (alu_control_i),
        .alu_out_o              (alu_out_o), 
        .zero_o                 (zero_o)
        
    );
    
endmodule