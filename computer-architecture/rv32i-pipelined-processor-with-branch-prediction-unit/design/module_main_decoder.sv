module module_main_decoder (

    input   logic   [6:0]   op_i,
    output  logic           mem_write_o,
    output  logic           branch_o, 
    output  logic           alu_src_a_o,
    output  logic           alu_src_b_o,
    output  logic           reg_write_o,
    output  logic           jump_o,
    output  logic   [1:0]   alu_op_o,
    output  logic   [1:0]   result_src_o,
    output  logic   [2:0]   imm_src_o
    
    );
    
    logic           [12 : 0]    controls;
    
    assign {reg_write_o, imm_src_o, alu_src_a_o, alu_src_b_o, mem_write_o, result_src_o, branch_o, alu_op_o, jump_o} = controls;
            
    always_comb begin
    
        case(op_i)
            
            // RegWrite_ImmSrc_ALUSrcA_ALUSrcB_MemWrite_ResultSrc_Branch_ALUOp_Jump
            7'b0000011: controls = 13'b1_000_0_1_0_01_0_00_0; // lw
            7'b0100011: controls = 13'b0_001_0_1_1_00_0_00_0; // sw
            7'b0110011: controls = 13'b1_xxx_0_0_0_00_0_10_0; // R-type
            7'b1100011: controls = 13'b0_010_0_0_0_00_1_01_0; // beq
            7'b0010011: controls = 13'b1_000_0_1_0_00_0_10_0; // I-type ALU
            7'b1101111: controls = 13'b1_011_0_0_0_10_0_00_1; // jal
            7'b0110111: controls = 13'b1_100_1_1_0_00_0_00_0; // lui
            7'b0000000: controls = 13'b0_000_0_0_0_00_0_00_0; // need valid values
                                                              // at reset
            default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // ???
            
        endcase
    end
    
endmodule