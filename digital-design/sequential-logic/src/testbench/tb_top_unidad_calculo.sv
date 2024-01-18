`timescale 1ns / 1ps

module tb_top_unidad_calculo;

logic             clk_100m = 0;                 //clock de 100 MHz
logic             clk_i = 0;                   // senal de clock de 10 MHz
logic             rst_i = 0;                   // senal de reset
logic             sw_i = 0;                     // switch que selecciona el modo de operacion
logic             tecla_activa_i = 0;           //indica si se ha presionado una tecla
logic [3 : 0]     valor_tecla_i = 0;           //entrada del valor de la tecla
    
logic [4 : 0]    addr_rs1_o = 0;               //puntero de lectura del registro en modo 1
logic [4 : 0]    addr_rs2_o = 0;               //puntero de lectura del registro en modo 2
logic [4 : 0]    addr_rd_o = 0;                 // puntero de escritura
logic            led_error_o = 0;              //led de error
logic            we_7seg_o = 0;                // write enable del registro del bloque de 7 segmentos
logic            we_banco_registros_o = 0;     //write enable del banco de registros
logic            mux_o = 0;                    //salida del mux
logic [3 : 0]    alucontrol_o = 0;             // control de operacion de la ALU
logic [3 : 0]    led_o = 0;
logic [15 : 0]   resultado_alu_o = 0;


logic [15 : 0]   rs1 = 0;        // salida del banco que va a la entrada del 7 segmentos
logic [15 : 0]   rs2 = 0;        // salida del banco que va al segundo operando de la ALU
logic [15 : 0]   data_in = 0; //datos en la salida del mux/ entrada del banco de registros

logic [7 : 0]    seg = 0;
logic [7 : 0]    an = 0;

clk_wiz_0 inst
(
  .clk_out1 (clk_i),              
  .locked   (rst_i),
  .clk_in1  (clk_100m)
);

module_alu_calcu alu(
    .operador_a_i       (rs1),
    .operador_b_i       (rs2),
    .operando_i         (alucontrol_o),
    .result_o           (resultado_alu_o)
);

interfaz_7segmentos display ( 
    .clk        (clk_i),
    .rst        (rst_i),
    .data_in    (rs1),	
    .we         (we_7seg_o),
    .an         (an),
    .seg        (seg)
);

reg_bank #(.W(16),.N(5)) registro_calcu
(
        .clk        (clk_i), 
        .reset      (rst_i), 
        .we         (we_banco_registros_o),                            
        .addr_rs1   (addr_rs1_o), 
        .addr_rs2   (addr_rs2_o),
        .addr_rd    (addr_rd_o),  
        .data_in    (data_in),                            
        .rs1        (rs1), 
        .rs2        (rs2)
);

module_mux_2_1 mux2a1 (
    .a      ({12'b0000_0000_0000, valor_tecla_i}), //entrada 1
    .b      (resultado_alu_o), //entrada 2
    .sel    (mux_o), //seleccion
    .out    (data_in)
);

module_fsm_with_data_path FSM (
    .clk_i                      (clk_i),                    
    .rst_i                      (rst_i),                    
    .sw_i                       (sw_i),                     
    .tecla_activa_i             (tecla_activa_i),           
    .valor_tecla_i              (valor_tecla_i),              
    .addr_rs1_o                 (addr_rs1_o),               
    .addr_rs2_o                 (addr_rs2_o),               
    .addr_rd_o                  (addr_rd_o),
    .led_error_o                (led_error_o),              
    .we_7seg_o                  (we_7seg_o),                     
    .we_banco_registros_o       (we_banco_registros_o),           
    .mux_o                      (mux_o),                          
    .alucontrol_o               (alucontrol_o),                                            
    .led_o                      (led_o)
);

initial begin
        #7000
        // PRIMERA OPERACION
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b0001; // A = 1
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1010 ; // suma
        #400
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b0101 ; // B = 5
        #600
        tecla_activa_i = 1'b0; 
        #600
/*____________________________________________*/
       
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1111 ; // enter
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/
        // SEGUNDA OPERACION 
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b0101; // A = 5
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1011 ; // resta
        #400
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b0010 ; // B = 2
        #600
        tecla_activa_i = 1'b0; 
        #600
/*____________________________________________*/
       
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1111 ; // enter
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/
        
        // TERCERA OPERACION
       @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b1111; // A = F, lo que es incorrecto
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

       @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b1001; // A = 9
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1100 ; // OR
        #400
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b0000 ; // B = 0
        #600
        tecla_activa_i = 1'b0; 
        #600
/*____________________________________________*/
       
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1111 ; // enter
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/
         
       // CUARTA OPERACION
       @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b0011; // A = 3
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1101 ; // AND
        #400
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b0100 ; // B = 4
        #600
        tecla_activa_i = 1'b0; 
        #600
/*____________________________________________*/
       
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1111 ; // enter
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/                    

       // QUINTA OPERACION
       @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b0001; // A = 1
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1110 ; // SHIFT
        #400
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b0100 ; // B = 0
        #600
        tecla_activa_i = 1'b0; 
        #600
/*____________________________________________*/
       
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1111 ; // enter
        #600
        tecla_activa_i = 1'b0;
        #600
/*____________________________________________*/                    
             
         
              
        sw_i = 1;
        #10000
        
        $finish;
end
    
always #5 clk_100m = ~clk_100m;//clk 10MHz
    


endmodule