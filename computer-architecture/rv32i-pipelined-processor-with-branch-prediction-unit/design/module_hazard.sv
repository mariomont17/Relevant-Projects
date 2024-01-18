// Hazard Unit: forward, stall, and flush
module module_hazard(
    
    input logic                 NoForwarding, // no forwarding
    input logic                 NoBPU, // no branch prediction unit
    input logic                 BranchDorJumpD,
    input logic     [4 : 0]     rs1d_i,
    input logic     [4 : 0]     rs2d_i,
    input logic     [4 : 0]     rs1e_i,
    input logic     [4 : 0]     rs2e_i,
    input logic     [4 : 0]     rde_i,
    input logic     [4 : 0]     rdm_i,
    input logic     [4 : 0]     rdw_i,
    input logic                 pcsrce_i,
    input logic                 prediction_bit_i,
    input logic                 resultsrceb0_i, 
    input logic                 regwritem_i,
    input logic                 regwritew_i, 
    input logic                 regwriteE_i,
    output logic    [1 : 0]     forwardae_o,
    output logic    [1 : 0]     forwardbe_o,
    output logic                stallf_o,
    output logic                stalld_o,
    output logic                flushd_o,
    output logic                flushe_o
    
    );
    
    logic lwStallD; // load word stall
    logic NFStall; // stall when no forwarding
    
    //forwading logic
    always_comb begin
        
        forwardae_o = 2'b00;                                                    // No forwarding (use RegFile output)
        forwardbe_o = 2'b00;
        NFStall = 1'b0;
        case(NoForwarding)
            1'b0: begin // si no hay forwarding, hace stalls
                if ((rs1e_i != 5'b0) || (rs1d_i != 5'b0)) 
                    if (((rs1d_i == rde_i) & regwriteE_i) ||((rs1d_i == rdm_i) & regwritem_i) ) NFStall = 1'b1;          
                if ((rs2e_i != 5'b0) || (rs2d_i != 5'b0))
                    if (((rs2d_i == rde_i) & regwriteE_i) ||((rs2d_i == rdm_i) & regwritem_i) ) NFStall = 1'b1;
            end
            1'b1: begin
                if (rs1e_i != 5'b0)
                if      ((rs1e_i == rdm_i) & regwritem_i) forwardae_o = 2'b10;      // forward from Memory stage
                else if ((rs1e_i == rdw_i) & regwritew_i) forwardae_o = 2'b01;      // forward from WriteBack stage
                if (rs2e_i != 5'b0)
                if      ((rs2e_i == rdm_i) & regwritem_i) forwardbe_o = 2'b10;
                else if ((rs2e_i == rdw_i) & regwritew_i) forwardbe_o = 2'b01;
            end

       endcase 
        
    end
    
    // stalls 
    assign lwStallD = resultsrceb0_i & ((rs1d_i == rde_i) | (rs2d_i == rde_i));
    assign stalld_o = lwStallD | NFStall;
    assign stallf_o = NoBPU ? (lwStallD | NFStall) : (lwStallD | NFStall | BranchDorJumpD);
    // Flushes
    assign flushd_o = NoBPU ? (pcsrce_i ^ prediction_bit_i) : (BranchDorJumpD | pcsrce_i); // con Predicción de saltos y sin prediccion de saltos
    assign flushe_o = NoBPU ? (lwStallD | (pcsrce_i ^ prediction_bit_i) | NFStall) : (lwStallD | pcsrce_i | NFStall);
    
endmodule