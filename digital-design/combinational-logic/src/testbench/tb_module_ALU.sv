`timescale 1ns / 1ps

module tb_ALU; // test


localparam ANCHO1 = 4;

    //Entradas
    logic [ANCHO1 - 1 : 0]   ALUA;       //Se definen las entradas de la ALU seg?n los nombres dados en el informe
    logic [ANCHO1 - 1 : 0]   ALUB;       //Se definen las entradas de la ALU seg?n los nombres dados en el informe
    logic [4 :0]             ALUControl; //Se definen las entradas de la ALU seg?n los nombres dados en el informe
    logic [1 :0]             ALUFlagIn;  //Se definen las entradas de la ALU seg?n los nombres dados en el informe
    
    
    //Salidas
    logic [ANCHO1 - 1 : 0]    ALUResult; //Se definen las salidas de la ALU seg?n los nombres dados en el informe
    logic [1 : 0]             C = 'b0;
    logic [1 : 0]             Z;
    
ALU #(.ANCHO(ANCHO1)) dut(
.ALUA       (ALUA),
.ALUB       (ALUB),
.ALUControl (ALUControl),
.ALUFlagIn  (ALUFlagIn),
.ALUResult  (ALUResult),
.C          (C),
.Z          (Z)    

);
initial begin

    ALUA        =   'b0010;   
    ALUB        =   'b0011;   
    ALUControl  =   'h0;
    ALUFlagIn   =   1;
    #30;    
    ALUA        =   'b0010;   
    ALUB        =   'b0000;   
    ALUControl  =   'h1;
    ALUFlagIn   =   1;
    
    #30;
    ALUA        =   'b0000;   
    ALUB        =   'b0000;   
    ALUControl  =   'h2;
    ALUFlagIn   =   0;
    
    #30;
    ALUA        =   'b0010;   
    ALUB        =   'b0011;   
    ALUControl  =   'h3;
    ALUFlagIn   =   1;
    
    #30;
    ALUA        =   'b0010;   
    ALUB        =   'b0011;   
    ALUControl  =   'h4;
    ALUFlagIn   =   1;
    
    #30;
    ALUA        =   'b0010;   
    ALUB        =   'b0011;   
    ALUControl  =   'h5;
    ALUFlagIn   =   1;
    
    #30;
    ALUA        =   'b0010;   
    ALUB        =   'b0011;   
    ALUControl  =   'h6;
    ALUFlagIn   =   0;
    
    #30;
    ALUA        =   'b0010;   
    ALUB        =   'b0011;   
    ALUControl  =   'h7;
    ALUFlagIn   =   1;
    
    #30;
    ALUA        =   'b0010;   
    ALUB        =   'b0010;   
    ALUControl  =   'h8;
    ALUFlagIn   =   0;
    
    #30;
    ALUA        =   'b0001;   
    ALUB        =   'b0001;   
    ALUControl  =   'h9;
    ALUFlagIn   =   1;
    
    #30
    
    $finish;
end
    
    
endmodule
