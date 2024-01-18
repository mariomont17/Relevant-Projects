module module_riscv_pipelined(
    
    input logic             clk_i, rst_i,
    output logic [31:0]     PCF_o,
    input logic [31:0]      InstrF_i,
    output logic            MemWriteM_o,
    output logic [31:0]     ALUResultM_o, WriteDataM_o,
    input logic [31:0]      ReadDataM_i

    );
    
    logic [6:0]     opD;
    logic           PredictionE;
    logic [2:0]     funct3D;
    logic           funct7b5D;
    logic [2:0]     ImmSrcD;
    logic           ZeroE;
    logic           PCSrcE, WE_BTB;
    logic [2:0]     ALUControlE;
    logic           ALUSrcAE, ALUSrcBE;
    logic           ResultSrcEb0;
    logic           RegWriteM;
    logic [1:0]     ResultSrcW;
    logic           RegWriteW;
    logic [1:0]     ForwardAE, ForwardBE;
    logic           StallF, StallD, FlushD, FlushE;
    logic [4:0]     Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
    
    module_controller c(
    
        .clk_i              (clk_i), 
        .rst_i              (rst_i),
        .opD_i              (opD),
        .funct3D_i          (funct3D),
        .funct7b5D_i        (funct7b5D),
        .ImmSrcD_o          (ImmSrcD),
        .FlushE_i           (FlushE),
        .ZeroE_i            (ZeroE),
        .PCSrcE_o           (PCSrcE), 
        .WE_BTB_o           (WE_BTB),
        .ALUControlE_o      (ALUControlE),
        .ALUSrcAE_o         (ALUSrcAE),
        .ALUSrcBE_o         (ALUSrcBE), 
        .ResultSrcEb0_o     (ResultSrcEb0), 
        .MemWriteM_o        (MemWriteM_o),
        .RegWriteM_o        (RegWriteM), 
        .RegWriteW_o        (RegWriteW),
        .ResultSrcW_o       (ResultSrcW)

    );

    module_datapath dp(

        .clk_i              (clk_i), 
        .rst_i              (rst_i),
        .StallF_i           (StallF),
        .PCF_o              (PCF_o),
        .InstrF_i           (InstrF_i),
        .PredictionE_o      (PredictionE),
        .opD_o              (opD),
        .funct3D_o          (funct3D),
        .funct7b5D_o        (funct7b5D),
        .StallD_i           (StallD), 
        .FlushD_i           (FlushD),
        .ImmSrcD_i          (ImmSrcD),
        .FlushE_i           (FlushE),
        .ForwardAE_i        (ForwardAE), 
        .ForwardBE_i        (ForwardBE),
        .PCSrcE_i           (PCSrcE),
        .WE_BTB_i           (WE_BTB),
        .ALUControlE_i      (ALUControlE),
        .ALUSrcAE_i         (ALUSrcAE),
        .ALUSrcBE_i         (ALUSrcBE),
        .ZeroE_o            (ZeroE),
        .MemWriteM_i        (MemWriteM_o),
        .WriteDataM_o       (WriteDataM_o), 
        .ALUResultM_o       (ALUResultM_o),
        .ReadDataM_i        (ReadDataM_i),
        .RegWriteW_i        (RegWriteW),
        .ResultSrcW_i       (ResultSrcW),
        .Rs1D_o             (Rs1D), 
        .Rs2D_o             (Rs2D), 
        .Rs1E_o             (Rs1E), 
        .Rs2E_o             (Rs2E),
        .RdE_o              (RdE), 
        .RdM_o              (RdM), 
        .RdW_o              (RdW)
        
        );
        
    module_hazard hu(
    
        .rs1d_i             (Rs1D),
        .rs2d_i             (Rs2D),
        .rs1e_i             (Rs1E),
        .rs2e_i             (Rs2E),
        .rde_i              (RdE),
        .rdm_i              (RdM),
        .rdw_i              (RdW),
        .pcsrce_i           (PCSrcE),
        .prediction_bit_i   (PredictionE),
        .resultsrceb0_i     (ResultSrcEb0), 
        .regwritem_i        (RegWriteM),
        .regwritew_i        (RegWriteW),   
        .forwardae_o        (ForwardAE),
        .forwardbe_o        (ForwardBE),
        .stallf_o           (StallF),
        .stalld_o           (StallD),
        .flushd_o           (FlushD),
        .flushe_o           (FlushE)
    
    );   

endmodule