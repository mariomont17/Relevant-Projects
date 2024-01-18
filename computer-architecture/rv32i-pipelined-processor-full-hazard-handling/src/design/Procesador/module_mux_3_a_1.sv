module module_mux_3_a_1 #(parameter WIDTH = 8)(
    
    input   logic       [1 : 0]                 s_i,
    input   logic       [WIDTH - 1 : 0]         d0_i,
    input   logic       [WIDTH - 1 : 0]         d1_i,
    input   logic       [WIDTH - 1 : 0]         d2_i,
    output  logic       [WIDTH - 1: 0]          y_o
    
    );
    
    assign y_o = s_i[1] ? d2_i : (s_i[0] ? d1_i : d0_i);
    
endmodule