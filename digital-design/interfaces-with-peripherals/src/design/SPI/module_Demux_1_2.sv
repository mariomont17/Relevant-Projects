module module_Demux_1_2 (
    input logic  wr_i,       // Señal de habilitar escritura
    input logic  sel_i,      // Selector de registro
    output logic wr_ctrl_o,  // Write enable de registro control
    output logic wr_data_o   // Write enable de registro datos
);

always_comb begin
    case (sel_i)
        1'b0: begin            // Si selector = 0...
            wr_ctrl_o = wr_i;  // Escribir en registro de control
            wr_data_o = 0;
        end
        1'b1: begin            // Si selector = 1...
            wr_ctrl_o = 0;
            wr_data_o = wr_i;  // Escribir en registro de datos
        end
    endcase
end

endmodule