module module_regfile(
    
    input   logic               clk_i,
    input   logic               rst_i,
    input   logic               we3_i,
    input   logic   [4 : 0]     a1_i,
    input   logic   [4 : 0]     a2_i,
    input   logic   [4 : 0]     a3_i,
    input   logic   [31 : 0]    wd3_i,
    output  logic   [31 : 0]    rd1_o,
    output  logic   [31 : 0]    rd2_o
    
    );
    
    logic [31 : 0] [31 : 0] rf;
    
    //archivo de registro de tres puertos
    //leer dos puertos de forma combinada
    //escriba el tercer puerto en el flanco ascendente del reloj
    //registro 0 cableado a 0
    
    always_ff @(posedge clk_i) begin
        if (rst_i) rf <= 0;
        else if(we3_i) rf[a3_i] <= wd3_i;
    
    end
    
    always_comb begin
    
        rd1_o = (a1_i != 0) ? rf[a1_i] : 0;
        
        rd2_o = (a2_i != 0) ? rf[a2_i] : 0;

    end
    
    
endmodule