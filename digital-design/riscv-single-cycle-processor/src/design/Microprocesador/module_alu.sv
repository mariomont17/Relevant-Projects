module module_alu(

    input  logic    [31 : 0]        dato1_i,
    input  logic    [31 : 0]        dato2_i,
    input  logic    [2 : 0]         alu_control_i,
    output logic                    zero_o,
    output logic    [31 : 0]        alu_out_o
    
    );
    
    logic [31 : 0]          condinvb; 
    logic [31 : 0]          sum;
    logic                   v;          // overflow
    logic                   isAddSub;   // verdadero cuando es suma o resta
    
    assign condinvb     =   alu_control_i[0] ? ~dato2_i : dato2_i;
    assign sum          =   dato1_i + condinvb + alu_control_i[0];
    assign isAddSub     =   ~alu_control_i[2] & ~alu_control_i[1] | ~alu_control_i[1] & alu_control_i[0];
    
    always_comb begin
        case (alu_control_i)
            3'b000: alu_out_o = sum;                        // add
            3'b001: alu_out_o = sum;                        // subtract
            3'b010: alu_out_o = dato1_i & dato2_i;          // and
            3'b011: alu_out_o = dato1_i | dato2_i;          // or
            3'b100: alu_out_o = dato1_i ^ dato2_i;          // xor
            3'b101: alu_out_o = sum[31] ^ v;                // slt
            3'b110: alu_out_o = dato1_i << dato2_i[4:0];    // sll
            3'b111: alu_out_o = dato1_i >> dato2_i[4:0];    // srl
            default: alu_out_o = 32'bx;
        endcase
    end    
    assign zero_o = (alu_out_o == 32'b0);
    assign v = ~(alu_control_i[0] ^ dato1_i[31] ^ dato2_i[31]) & (dato1_i[31] ^ sum[31]) & isAddSub;
   
endmodule