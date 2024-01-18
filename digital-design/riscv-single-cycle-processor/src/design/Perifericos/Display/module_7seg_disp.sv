module module_7seg_disp(
    
    input logic             clk,
    input logic             rst,
    input logic [31 : 0]    data_in,	
    input logic             we,
    output logic [7 : 0]    an,
    output logic [7 : 0]    seg

);

// SALIDA DEL REGISTRO PARALELO 
logic [15 : 0]   data_out;

logic [3 : 0]     hex0;   // primer digito hexadecimal
logic [3 : 0]     hex1;   // segundo digito hexadecimal
logic [3 : 0]     hex2;   // tercer digito hexadecimal
logic [3 : 0]     hex3;   // cuarto digito hexadecimal

assign hex0 = data_out[3:0];
assign hex1 = data_out[7:4];
assign hex2 = data_out[11:8];
assign hex3 = data_out[15:12];

// TASA DE REFRESCO DE 610 Hz (10MHz/2^14)
localparam N = 16; // parametro del numero de bits del contador interno

logic [N - 1 : 0]   q_reg;  // valor actual del contador
logic [N - 1 : 0]   q_next; // valor del contador despues del siguiente posedge del clk
logic [3 : 0]       hex_in; // variable interna que pasa los datos de entrada por el decodificador

assign an[7 : 4] =  4'b1111;    // asignacion de unos en los 4 primeros display de la FPGA

// CONTADOR DE N BITS, LOGICA DEL ESTADO SIGUIENTE
always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        q_reg <= 0; 
    end else begin
        q_reg <= q_next;
    end
end

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin         // si hay un reset
        data_out <= 16'b0; // se envia a cero el registro
    end else begin
        if (we) begin // si hay un WE 
            data_out <= data_in[15:0]; // se escribe en el registro
        end
    end
 end

// la entrada del registro del contador siempre es igual al valor de la salida mas uno.
assign q_next   =   q_reg + 1;

// logica que permite variar los display con su respectivo digito de entrada
always_comb begin
        case (q_reg[N - 1 : N - 2])
            2'b00:
                begin
                    an[3 : 0]   =   4'b1110; // primer display en alto
                    hex_in      =   hex0;         
                end
            2'b01:
                begin
                   an[3 : 0]   =   4'b1101; // segundo display en alto
                    hex_in      =   hex1;              
                end
            2'b10:
                begin
                    an[3 : 0]   =   4'b1011; // tercer display encendido
                    hex_in      =   hex2; 
                end
            default:
               begin
                    an[3 : 0]   =   4'b0111; // cuarto display encendido
                    hex_in      =   hex3; 
               end 
        endcase 
 end
 
 //DECODIFICADOR PARA EL DISPLAY 
 
 always_comb begin
    case(hex_in)
        4'h0:    seg[6 : 0] = 7'b100_0000; // 0
        4'h1:    seg[6 : 0] = 7'b111_1001; // 1
        4'h2:    seg[6 : 0] = 7'b010_0100; // 2
        4'h3:    seg[6 : 0] = 7'b011_0000; // 3
        4'h4:    seg[6 : 0] = 7'b001_1001; // 4
        4'h5:    seg[6 : 0] = 7'b001_0010; // 5
        4'h6:    seg[6 : 0] = 7'b000_0010; // 6
        4'h7:    seg[6 : 0] = 7'b111_1000; // 7
        4'h8:    seg[6 : 0] = 7'b000_0000; // 8
        4'h9:    seg[6 : 0] = 7'b001_0000; // 9
        4'ha:    seg[6 : 0] = 7'b000_1000; // A
        4'hb:    seg[6 : 0] = 7'b000_0011; // B
        4'hc:    seg[6 : 0] = 7'b100_0110; // C
        4'hd:    seg[6 : 0] = 7'b010_0001; // D
        4'he:    seg[6 : 0] = 7'b000_0110; // E
        default:    seg[6 : 0] = 7'b000_1110; // display en f
    endcase
    seg[7] = 1'b1;    // punto decimal apagado siempre
 end
 
endmodule