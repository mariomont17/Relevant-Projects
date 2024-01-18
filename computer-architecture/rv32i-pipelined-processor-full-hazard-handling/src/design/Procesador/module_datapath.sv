module module_datapath (

        input logic             clk_i, rst_i,
        // fetch stage signals
        input logic             StallF_i,
        output logic    [31:0]  PCF_o,
        input logic     [31:0]  InstrF_i,
        output logic            PredictionE_o,
        // Decode stage signals
        output logic    [6:0]   opD_o,
        output logic    [2:0]   funct3D_o,
        output logic            funct7b5D_o,
        input logic             StallD_i, FlushD_i,
        input logic     [2:0]   ImmSrcD_i,
        // Execute stage signals
        input logic             FlushE_i,
        input logic     [1:0]   ForwardAE_i, ForwardBE_i,
        input logic             PCSrcE_i,
        input logic             WE_BTB_i,
        input logic     [2:0]   ALUControlE_i,
        input logic             ALUSrcAE_i, // needed for lui
        input logic             ALUSrcBE_i,
        output logic            ZeroE_o,
        // Memory stage signals
        input logic             MemWriteM_i,
        output logic    [31:0]  WriteDataM_o, ALUResultM_o,
        input logic     [31:0]  ReadDataM_i,
        // Writeback stage signals
        input logic             RegWriteW_i,
        input logic     [1:0]   ResultSrcW_i,
        // Hazard Unit signals
        output logic    [4:0]   Rs1D_o, Rs2D_o, Rs1E_o, Rs2E_o,
        output logic    [4:0]   RdE_o, RdM_o, RdW_o
        
        );
        
        // Fetch stage signals
        logic [31:0] PCNextF, PCPlus4F;
        logic prediction, hit_or_miss;
        logic [31:0] target_address_o;
        logic btb_out;
        logic [31:0] prediction_address_o;
        // Decode stage signals
        logic [31:0] InstrD;
        logic [31:0] PCD, PCPlus4D;
        logic [31:0] RD1D, RD2D;
        logic [31:0] ImmExtD;
        logic [4:0] RdD;
        logic btb_outD;
       // Execute stage signals
        logic [31:0] RD1E, RD2E;
        logic [31:0] PCE, ImmExtE;
        logic [31:0] SrcAE, SrcBE;
        logic [31:0] SrcAEforward;
        logic [31:0] ALUResultE;
        logic [31:0] WriteDataE;
        logic [31:0] PCPlus4E;
        logic [31:0] PCTargetE;
        logic btb_outE;
        // Memory stage signals
        logic [31:0] PCPlus4M;
        // Writeback stage signals
        logic [31:0] ALUResultW;
        logic [31:0] ReadDataW;
        logic [31:0] PCPlus4W;
        logic [31:0] ResultW;
        
        // Fetch stage pipeline register and logic  
        
//        module_mux_2_a_1 #(.WIDTH(32)) pcmux(
    
//            .d0_i                   (PCPlus4F), 
//            .d1_i                   (PCTargetE), 
//            .s_i                    (PCSrcE_i),
//            .y_o                    (PCNextF)
    
//        );
        
        module_mux_2_a_1 #(.WIDTH(32)) btbmux(
    
            .d0_i                   (PCPlus4F), 
            .d1_i                   (target_address_o), 
            .s_i                    (btb_out),
            .y_o                    (prediction_address_o)
    
        );

        module_mux_4_a_1 #(.WIDTH(32)) pcmux(
    
            .a                      (prediction_address_o),
            .b                      (PCTargetE),
            .c                      (PCPlus4E),
            .d                      (prediction_address_o),
            .sel                    ({PredictionE_o,PCSrcE_i}),
            .out                    (PCNextF)
    
        );
        
        module_flopenr #(.WIDTH(32)) pcreg(
    
            .clk_i                  (clk_i),
            .rst_i                  (rst_i),
            .en_i                   (~StallF_i),
            .d_i                    (PCNextF),   
            .q_o                    (PCF_o)
                     
        );
        
        module_adder pcadd (
    
            .a_i                    (PCF_o), 
            .b_i                    (32'h4), 
            .y_o                    (PCPlus4F)
    
        );
        
        BTB bp_unit (
            .clk                    (clk_i),
            .rst                    (rst_i),
            .PCF_o                  (PCF_o), 
            .PCE                    (PCE), 
            .instruction_address    (PCTargetE), 
            .branch_taken           (PCSrcE_i), 
            .write_enable           (WE_BTB_i), 
            .prediction_o           (prediction), 
            .hit_or_miss            (hit_or_miss), 
            .target_address_o       (target_address_o) 
        );

        assign btb_out = prediction & hit_or_miss;
        assign PredictionE_o = btb_outE;
        // Decode stage pipeline register and logic
        
        module_flopenrc #(.WIDTH(97)) regD(
    
            .clk_i                  (clk_i),
            .rst_i                  (rst_i),
            .clr_i                  (FlushD_i),
            .en_i                   (~StallD_i),
            .d_i                    ({InstrF_i, PCF_o, PCPlus4F,btb_out}),   
            .q_o                    ({InstrD, PCD, PCPlus4D,btb_outD})
                     
        );
        
        assign opD_o        = InstrD[6:0];
        assign funct3D_o    = InstrD[14:12];
        assign funct7b5D_o  = InstrD[30];
        assign Rs1D_o       = InstrD[19:15];
        assign Rs2D_o       = InstrD[24:20];
        assign RdD          = InstrD[11:7];
        
        module_regfile rf(
    
            .clk_i                  (clk_i),
            .rst_i                  (rst_i),  
            .we3_i                  (RegWriteW_i), 
            .a1_i                   (Rs1D_o),
            .a2_i                   (Rs2D_o),
            .a3_i                   (RdW_o),
            .wd3_i                  (ResultW), 
            .rd1_o                  (RD1D), 
            .rd2_o                  (RD2D)
        
        );
        
        module_extend   ext(
    
            .instr_i                (InstrD[31 : 7]),
            .imm_src_i              (ImmSrcD_i),
            .imm_ext_o              (ImmExtD)
        
        );
        
        // Execute stage pipeline register and logic
        module_floprc #(.WIDTH(176)) regE(
    
            .clk_i                  (clk_i),
            .rst_i                  (rst_i),
            .clr_i                  (FlushE_i),
            .d_i                    ({RD1D, RD2D, PCD, Rs1D_o, Rs2D_o, RdD, ImmExtD, PCPlus4D,btb_outD}),
            .q_o                    ({RD1E, RD2E, PCE, Rs1E_o, Rs2E_o, RdE_o, ImmExtE, PCPlus4E,btb_outE})
                     
        );
        
        module_mux_3_a_1 #(.WIDTH(32)) faemux(
    
            .d0_i                   (RD1E), 
            .d1_i                   (ResultW),
            .d2_i                   (ALUResultM_o),
            .s_i                    (ForwardAE_i),
            .y_o                    (SrcAEforward)
    
        );
        
        module_mux_2_a_1 #(.WIDTH(32)) srcamux(
    
            .d0_i                   (SrcAEforward), 
            .d1_i                   (32'b0), 
            .s_i                    (ALUSrcAE_i),
            .y_o                    (SrcAE)
    
        ); // for lui
        
        module_mux_3_a_1 #(.WIDTH(32)) fbemux(
    
            .d0_i                   (RD2E), 
            .d1_i                   (ResultW),
            .d2_i                   (ALUResultM_o),
            .s_i                    (ForwardBE_i),
            .y_o                    (WriteDataE)
    
        );
        
        module_mux_2_a_1 #(.WIDTH(32)) srcbmux(
    
            .d0_i                   (WriteDataE), 
            .d1_i                   (ImmExtE), 
            .s_i                    (ALUSrcBE_i),
            .y_o                    (SrcBE)
    
        );
        
        module_alu alu(
    
            .dato1_i                (SrcAE), 
            .dato2_i                (SrcBE), 
            .alu_control_i          (ALUControlE_i),
            .alu_out_o              (ALUResultE), 
            .zero_o                 (ZeroE_o)
            
        );
        
        module_adder branchadd (
    
            .a_i                    (ImmExtE), 
            .b_i                    (PCE), 
            .y_o                    (PCTargetE)
    
        );
        
       // Memory stage pipeline register
       module_flopr #(.WIDTH(101)) regM(
    
            .clk_i                  (clk_i), 
            .rst_i                  (rst_i), 
            .d_i                    ({ALUResultE, WriteDataE, RdE_o, PCPlus4E}), 
            .q_o                    ({ALUResultM_o, WriteDataM_o, RdM_o, PCPlus4M})
            
        );
        
        // Writeback stage pipeline register and logic
        module_flopr #(.WIDTH(101)) regW(
    
            .clk_i                  (clk_i), 
            .rst_i                  (rst_i), 
            .d_i                    ({ALUResultM_o, ReadDataM_i, RdM_o, PCPlus4M}), 
            .q_o                    ({ALUResultW, ReadDataW, RdW_o, PCPlus4W})
            
        );
        
        module_mux_3_a_1 #(.WIDTH(32)) resultmux(
    
            .d0_i                   (ALUResultW), 
            .d1_i                   (ReadDataW),
            .d2_i                   (PCPlus4W),
            .s_i                    (ResultSrcW_i),
            .y_o                    (ResultW)
    
        );
        
endmodule