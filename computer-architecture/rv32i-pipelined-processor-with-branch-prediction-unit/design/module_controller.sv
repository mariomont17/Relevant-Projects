module module_controller(
    
    input logic         clk_i, rst_i,
    // Decode stage control signals
    input logic [6:0]   opD_i,
    input logic [2:0]   funct3D_i,
    input logic         funct7b5D_i,
    output logic [2:0]  ImmSrcD_o,
    output logic        BranchDorJumpD,
    // Execute stage control signals
    input logic         FlushE_i,
    input logic         ZeroE_i,
    output logic        PCSrcE_o, // for datapath and Hazard Unit
    output logic        WE_BTB_o, // we for btb cache
    output logic [2:0]  ALUControlE_o,
    output logic        ALUSrcAE_o,
    output logic        ALUSrcBE_o, // for lui
    output logic        ResultSrcEb0_o, // for Hazard Unit
    output logic        RegWriteE_o,
    // Memory stage control signals
    output logic        MemWriteM_o,
    output logic        RegWriteM_o, // for Hazard Unit
    // Writeback stage control signals
    output logic        RegWriteW_o, // for datapath and Hazard Unit
    output logic [1:0]  ResultSrcW_o

    );

    // pipelined control signals
    logic           RegWriteD, RegWriteE; 
    logic [1:0]     ResultSrcD, ResultSrcE, ResultSrcM;
    logic           MemWriteD, MemWriteE;
    logic           JumpD, JumpE;
    logic           BranchD, BranchE;
    logic [1:0]     ALUOpD;
    logic [2:0]     ALUControlD;
    logic           ALUSrcAD;
    logic           ALUSrcBD; // for lui
    
    assign RegWriteE_o = RegWriteE;
    
    // Decode stage logic
    
    module_main_decoder md(

        .op_i                   (opD_i),
        .mem_write_o            (MemWriteD),
        .branch_o               (BranchD), 
        .alu_src_a_o            (ALUSrcAD),
        .alu_src_b_o            (ALUSrcBD),
        .reg_write_o            (RegWriteD),
        .jump_o                 (JumpD),
        .alu_op_o               (ALUOpD),
        .result_src_o           (ResultSrcD),
        .imm_src_o              (ImmSrcD_o)
    
    );
    
    module_alu_decoder ad (
        
        .opb5_i                 (opD_i[5]), 
        .funct3_i               (funct3D_i),
        .funct7b5_i             (funct7b5D_i),
        .alu_op_i               (ALUOpD),
        .alu_control_o          (ALUControlD)
        
    );
    
    // Execute stage pipeline control register and logic
    module_floprc #(.WIDTH(11)) controlregE(
    
        .clk_i                  (clk_i),
        .rst_i                  (rst_i),
        .clr_i                  (FlushE_i),
        .d_i                    ({RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchD,ALUControlD, ALUSrcAD, ALUSrcBD}),
        .q_o                    ({RegWriteE, ResultSrcE, MemWriteE, JumpE, BranchE,ALUControlE_o, ALUSrcAE_o, ALUSrcBE_o})
                 
    );
    
    assign PCSrcE_o = (BranchE & ZeroE_i) | JumpE;
    assign ResultSrcEb0_o = ResultSrcE[0];
    assign WE_BTB_o = BranchE;
    assign BranchDorJumpD = JumpD | BranchD;
    // Memory stage pipeline control register
    module_flopr #(.WIDTH(4)) controlregM(
    
        .clk_i                  (clk_i), 
        .rst_i                  (rst_i), 
        .d_i                    ({RegWriteE, ResultSrcE, MemWriteE}), 
        .q_o                    ({RegWriteM_o, ResultSrcM, MemWriteM_o})
            
    );
   
   // Writeback stage pipeline control register
   module_flopr #(.WIDTH(3)) controlregW(
    
        .clk_i                  (clk_i), 
        .rst_i                  (rst_i), 
        .d_i                    ({RegWriteM_o, ResultSrcM}), 
        .q_o                    ({RegWriteW_o, ResultSrcW_o})
            
    );
   
endmodule
