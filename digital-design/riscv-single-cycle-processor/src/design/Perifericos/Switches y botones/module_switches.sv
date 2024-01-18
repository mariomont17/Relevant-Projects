module module_switches(

    input  logic          clk_i,
    input  logic          rst_i,
    input  logic [19 : 0] sw_bt_i,
    output logic [31 : 0] sw_o
    
    );
    logic [19 : 0] reg_switches;
    always_ff @(posedge clk_i)begin
        if ( rst_i )begin
            reg_switches <= 0;
        end
        else begin
            reg_switches <= sw_bt_i;
        end
    end
    //LOGICA DE SALIDA
    always_comb begin
        sw_o = {12'b0, reg_switches};     
    end
endmodule