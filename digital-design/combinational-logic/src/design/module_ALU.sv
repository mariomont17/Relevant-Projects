
module ALU #(
    parameter ANCHO = 4                         //Parametrizado del valor del tama?o de la ALU para cada entrada
)(
    input logic     [ANCHO - 1 : 0] ALUA,       //Se definen las entradas de la ALU seg?n los nombres dados en el informe
    input logic     [ANCHO - 1 : 0] ALUB,       //Se definen las entradas de la ALU seg?n los nombres dados en el informe
    input logic     [4 : 0]         ALUControl, //Se definen las entradas de la ALU seg?n los nombres dados en el informe
    input logic     [1 : 0]         ALUFlagIn,  //Se definen las entradas de la ALU seg?n los nombres dados en el informe
    output logic    [1 : 0]         C,          //Bandera de salida C
    output logic    [1 : 0]         Z,          //Bandera de salida Z
    output logic    [ANCHO - 1: 0]  ALUResult   //Se definen las salidas de la ALU seg?n los nombres dados en el informe
   
);
    logic   [ANCHO - 1 : 0] ALUResultado;       //definición de las variables locales 
    logic   [ANCHO - 1 : 0] temp = 'b0;
    logic   [1 : 0]         aux;
    assign  ALUResult = ALUResultado;           //assign de la variable local para el testbench
    always  @(*) 
    begin  
       
        case (ALUControl)                       //Control de las funciones
            'h0:                                //and logica
                begin
                    ALUResultado = ALUA & ALUB;                    
                end        
            'h1:                                //or logica
                begin
                    ALUResultado = ALUA | ALUB;                   
                end    
            'h2:                                //suma aritmetica
                begin                           
                    ALUResultado = ALUA + ALUB + ALUFlagIn;                              
                end
               
                         
            'h3:                                //incrementar en uno el operando
                if      (ALUFlagIn == 'b0) 
                    begin
                        ALUResultado = ALUA + 'b1;                       
                    end
                else if (ALUFlagIn == 'b1)
                    begin
                        ALUResultado = ALUB + 'b1;                                              
                    end else
                        begin
                            ALUResultado = 0;
                        end
            'h4:                                //decrementar en 1
                if      (ALUFlagIn == 0)        //Selecci?n del operador A
                    begin 
                        ALUResultado = ALUA - 1;
                    end                    
                else if (ALUFlagIn == 1)        //Selecci?n del operador B
                    begin
                        ALUResultado = ALUB - 1;                        
                    end else                    //Si hay un error se pone en 0
                        ALUResultado = 0;
                
            'h5:                                //not con condici?n de la bandera de entrada
                if      (ALUFlagIn == 0)        //Selecci?n del operador A
                    begin 
                        ALUResultado = ~(ALUA) ;
                    end
                else if (ALUFlagIn == 1)        //Selecci?n del operador B
                    begin
                        ALUResultado = ~(ALUB);
                        
                    end else                    //Si hay un error se pone en 0
                        ALUResultado = 0;
                        
            'h6:                                //Resta
                begin
                     ALUResultado = ALUA - ALUB - ALUFlagIn;                      
                end
                
            'h7:      
                begin                          //XOR
                    ALUResultado = ALUA ^ ALUB;
                end
                
            'h8:                                //corrimiento a la izquierda de A
               if       (ALUFlagIn == 0)        //Selecci?n del operador 0 para corrimiento
                    begin 
                        C = ALUA[ANCHO - ALUB]; 
                        ALUResultado = ALUA << ALUB ;
                    end
                                    
                else if (ALUFlagIn == 1)        //Selecci?n del operador 1 para corrimiento
                    begin
                        
                        C = ALUA[ANCHO - ALUB]; 
                        ALUResultado = ALUA << ALUB ;
                        for (int i = 0; i <ALUB; i++)
                            temp= 'b10**(i) + temp; 
                        ALUResultado = temp + ALUResultado;
                                                //La función for anterior me calcula la cantidad de 1's a agregar
                                                //Luego se los sumo y se concatenan
                     end else                   //Si hay un error se pone en 0
                        begin
                            ALUResultado = 0;                     
                        end  
                             
             'h9:                               //corrimiento a la derecha de A
                if      (ALUFlagIn == 0)        //Selecci?n del operador 0 para corrimiento
                    begin 
                        C = ALUA[ALUB - 1];     //bandera de salida C
                        ALUResultado = ALUA >> ALUB ;
                    end
                        
                    
                else if (ALUFlagIn == 1)        //Selecci?n del operador 1 para corrimiento
                    begin
                        C = ALUA[ALUB - 1];     //Bandera de salida C
                        ALUResultado = ALUA >> ALUB ;
                        for (int i = 0; i <ALUB ; i++) 
                                temp= 'b10**((ANCHO - 1 ) - i) + temp; 
                        ALUResultado = temp + ALUResultado;
                                                //La función for anterior me calcula la cantidad de 1's a agregar
                                                //Luego se los sumo y se concatenan
                        
                    end else                    //Si hay un error se pone en 0
                        ALUResultado = 0;
             
                
           
//            default: ALUResultado = ALUA + ALUB;
     
        
        endcase
        if (ALUResultado == '0)                 //Bandera de salida Z
            begin
                Z = 1;
            end
        else
            Z = 0;
               
    end
endmodule
