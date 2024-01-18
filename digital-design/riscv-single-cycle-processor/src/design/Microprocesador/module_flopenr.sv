module module_flopenr #(parameter WIDTH = 8)(
    
    input   logic                       clk_i,
    input   logic                       rst_i,
    input   logic                       en,
    input   logic   [WIDTH - 1 : 0]     d_i,
    output  logic   [WIDTH - 1 : 0]     q_o
                 
    );
    
    always_ff @(posedge clk_i) begin 
        
        if(rst_i)   q_o <= 0;
        else if(en) q_o <= d_i;
        
    end
    
endmodule          