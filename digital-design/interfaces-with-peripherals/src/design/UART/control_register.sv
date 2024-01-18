module control_register(
    input logic             clk_i,  // senal del reloj de 10 MHz
    input logic             rst_i,  // reset del sistema, activo en alto
    input logic             wr1_i,  // WE del usuario
    input logic             wr2_i,  // WE de la interfaz
    input logic [31 : 0]    in1_i,  // entrada datos USUARIO
    input logic [31 : 0]    in2_i,  //  entrada datos interfaz
    output logic [31 : 0]   out_o   // salida del registro de control
);

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        out_o <= '0;
    end 
    else begin
    // tiene prioridad el WR2 de la interfaz 
        if (wr2_i) begin // si WR2 esta en alto, la interfaz escribe en el registro de control
            out_o <= in2_i;
        end 
        //else begin // si WR2 esta en bajo, escribe el usuario
            if (wr1_i) begin
                out_o <= in1_i;
            end 
       // end
    end
end

endmodule