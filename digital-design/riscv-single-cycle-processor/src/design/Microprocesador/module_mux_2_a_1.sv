module module_mux_2_a_1 #(parameter WIDTH = 8)(
    
    input   logic                               s_i,
    input   logic       [WIDTH - 1 : 0]         d0_i,
    input   logic       [WIDTH - 1 : 0]         d1_i,
    output  logic       [WIDTH - 1 : 0]         y_o
    
    );
    
    assign y_o = s_i ? d1_i : d0_i;
    
endmodule