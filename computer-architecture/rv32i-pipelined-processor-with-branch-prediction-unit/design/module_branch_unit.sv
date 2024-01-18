module module_branch_unit(

    input logic BranchE,
    input logic [2:0] Flags,
    input logic [2:0] funct3E,
    output logic taken
    
    );
    
    logic v, n, z; // Flags: overflow, negative, zero
    logic cond; // cond is 1 when condition for branch met
    
    assign {v, n, z} = Flags;
    assign taken = cond & BranchE;
    
    always_comb begin
        case (funct3E)
            3'b000: cond = z; // beq
            3'b001: cond = ~z; // bne
            3'b100: cond = (n ^ v); // blt
            3'b101: cond = ~(n ^ v); // bge
            default: cond = 1'b0;
        endcase 
    end
endmodule
