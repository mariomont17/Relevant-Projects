`timescale 1ns / 1ps

module tb_module_fsm_with_data_path;

logic                   clk_i;                   // senal de clock de 10 MHz
logic             rst_i;                   // senal de reset
logic             sw_i;                     // switch que selecciona el modo de operacion
logic             tecla_activa_i;           //indica si se ha presionado una tecla
logic [3 : 0]     valor_tecla_i;           //entrada del valor de la tecla
    
    
logic [4 : 0]    addr_rs1_o;               //puntero de lectura del registro en modo 1
logic [4 : 0]    addr_rs2_o;               //puntero de lectura del registro en modo 2
logic [4 : 0]    addr_rd_o;
logic            led_error_o;              //led de error
logic            we_7seg_o;                     // write enable del registro del bloque de 7 segmentos
logic            we_banco_registros_o;           //write enable del banco de registros
logic            mux_o;                          //salida del mux
logic  [3 : 0]   alucontrol_o;                      // control de operacion de la ALU
logic [3 : 0]    led_o;


module_fsm_with_data_path DUT (
.clk_i       (clk_i),                    
.rst_i          (rst_i),                    
.sw_i       (sw_i),                     
.tecla_activa_i     (tecla_activa_i),           
.valor_tecla_i      (valor_tecla_i),           
    
    
.addr_rs1_o         (addr_rs1_o),               
.addr_rs2_o (addr_rs2_o),               
.addr_rd_o (addr_rd_o),
.led_error_o (led_error_o),              
.we_7seg_o      (we_7seg_o),                     
.we_banco_registros_o       (we_banco_registros_o),           
.mux_o              (mux_o),                          
.alucontrol_o       (alucontrol_o),                                            
.led_o              (led_o)

);

initial begin
        rst_i = 0;
        sw_i = 0;
        clk_i = 0;
        #600
        rst_i = 1;
        #1000
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b0001 ; // num = 1
        #600
        tecla_activa_i = 1'b0;
        
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b1010 ; // num = 1
        #600
        tecla_activa_i = 1'b0;

        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; // suma
        valor_tecla_i = 4'b0001 ;
        #600
        tecla_activa_i = 1'b0;  
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; // enter
        valor_tecla_i = 4'b1111 ;
        #300
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1; 
        valor_tecla_i = 4'b0101 ; // 5
        #500
        tecla_activa_i = 1'b0;
        #300
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b1011 ; // num = 1 
        #500
        tecla_activa_i = 1'b0;
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b0011 ; // resta
        #500
        tecla_activa_i = 1'b0;
        @(posedge clk_i); 
        #1
        tecla_activa_i = 1'b1;
        valor_tecla_i = 4'b1111 ;
        #500
        tecla_activa_i = 1'b0;
        sw_i = 1;
        #10000
        //@(posedge clk_i); 
        //#1
        
        $finish;
    end
    
    always #50 clk_i = ~clk_i;//clk 10MHz
    


endmodule