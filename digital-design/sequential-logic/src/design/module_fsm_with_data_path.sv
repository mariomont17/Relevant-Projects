module module_fsm_with_data_path(
    input logic             clk_i,                    // senal de clock de 10 MHz
    input logic             rst_i,                    // senal de reset
    input logic             sw_i,                     // switch que selecciona el modo de operacion
    input logic             tecla_activa_i,           //indica si se ha presionado una tecla
    input logic [3 : 0]     valor_tecla_i,           //entrada del valor de la tecla
    output logic [4 : 0]    addr_rs1_o,               //puntero de lectura del registro en modo 1
    output logic [4 : 0]    addr_rs2_o,               //puntero de lectura del registro en modo 2
    output logic [4 : 0]    addr_rd_o,                  // puntero de escritura del banco de registros
    output logic            led_error_o,              //led de error
    output logic            we_7seg_o,                 // write enable del registro del bloque de 7 segmentos
    output logic            we_banco_registros_o,       //write enable del banco de registros
    output logic            mux_o,                      //salida del mux
    output logic [3 : 0]    alucontrol_o,               // control de operacion de la ALU
    output logic [3 : 0]    led_o                       // leds que muestran la operacion que se realizara en la ALU
);  

//definicion de estados

typedef enum logic [4 : 0]{
    inicio,                 //estado cero, inicial
    sel_modo,            //espera por la seleccion del modo de operacion
    
    apunta_registro,
    mostrar_registro,   //muestra el registro, sw == 1
    
   // sw == 0, se entra en una espera por el primer dato a operar
    wait_dato1,         // espera por el dato 1
    verif_dato1,        //verifica dato 1
    error_dato1,        // error en dato 1
    leer_dato1,         // lee el dato 1 desde el registro
    espera1,
    // espera del operador: suma, resta, and, or y logical shift left
    wait_operador,      //se espera la tecla
    verif_operador,     //verifica operador
    error_operador,     //error en operador
    espera2,
    //estados relacionados con el dato 2
    wait_dato2, 
    verif_dato2, 
    error_dato2,
    leer_dato2,
    espera3,
    //espera del enter para seguir con la operacion en la ALU
    wait_enter, 
    verif_enter,
    error_enter,
    // prosigue a leer y mostrar los resultados de la operacion
    leer_datos, 
    grd_resultado,
    leer_resultado,
    espera4  
} state_type; //definicion de estados 


state_type state_reg; //estado actual
state_type state_next; // estado siguiente(entrada del ff)
//estados del contador de 1 segundo
localparam N = 23; // cantidad de bits del contador (2^N*100ns = 0.8 s) para mostrar el dato 1 segundo aprox. (valor estandar => N = 23; para simular N = 2)
logic [N-1 : 0] q_reg; //estado actual del contador
logic [N-1 : 0] q_next; //estado siguiente

logic [4 : 0] contador_reg; //valor actual del contador del puntero de escritura del registro
logic [4 : 0] contador_next; //valor siguiente

logic [4 : 0] dir_1_reg; //variable utilizada para recorrer el registro en modo 1
logic [4 : 0] dir_1_next;

logic [4 : 0] dir_2_reg; //variable utilizada para recorrer el registro y colocar el dato 2 en la ALU
logic [4 : 0] dir_2_next;

logic [3 : 0] control_reg; //registro que guarda la operacion que se desea realizar
logic [3 : 0] control_next;


logic [4 : 0] contador_modo2_reg; //contador del modo 2
logic [4 : 0] contador_modo2_next;

always_ff @(posedge clk_i, posedge rst_i) begin
    if (!rst_i) begin
        state_reg <= inicio;
        q_reg <= 0;
        contador_reg <= 0;
        dir_1_reg <= 0;
        dir_2_reg <= 0;
        control_reg <= 0;
        contador_modo2_reg <= 0;
    end else begin
        state_reg <= state_next;
        q_reg   <= q_next;
        contador_reg <= contador_next;
        dir_1_reg <= dir_1_next;
        dir_2_reg <= dir_2_next;
        control_reg <= control_next;
        contador_modo2_reg <= contador_modo2_next;
    end
end

always_comb begin
    state_next = state_reg; //salida default
    q_next                  = q_reg;
    contador_next           = contador_reg;
    contador_modo2_next     = contador_modo2_reg;
    dir_1_next              = dir_1_reg;
    dir_2_next              = dir_2_reg;
    control_next            = control_reg;
    led_error_o             = 1'b0;
    led_o                   = control_reg;
    mux_o                   = 1'b0;
    we_7seg_o               = 1'b0;
    we_banco_registros_o    = 1'b0;
    
    addr_rd_o = contador_reg;
    addr_rs1_o = dir_1_reg;
    addr_rs2_o = dir_2_reg;
    alucontrol_o = control_reg;
    
    unique case (state_reg)
    inicio: begin //estado inicial
        mux_o                   = 1'b0;
        addr_rs1_o              = 5'b00000;
        addr_rs2_o              = 5'b00000;
        addr_rd_o               = 5'b00000;
        we_7seg_o               = 1'b0;
        we_banco_registros_o    = 1'b0;
        led_error_o             = 1'b0;
        led_o                   = 4'b0000;
        
        state_next              = sel_modo; 
    end
    
    sel_modo: begin
        
        if (sw_i) begin
            state_next = apunta_registro;
            q_next = {N{1'b1}}; // carga al contador con unos en el siguiente pulso del reloj
        end else begin
            state_next = wait_dato1;
        end   
    end
    
    wait_dato1: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (tecla_activa_i) begin // si se presiono una tecla
                    state_next = verif_dato1; // se pasa a un estado de verificacion de dato 1
                    contador_next = contador_reg + 1;
                end else begin
                    state_next = wait_dato1;// si no se presiona tecla, sigue esperando el operando 
                end
        end
    end
    
    verif_dato1: begin
       if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (valor_tecla_i < 4'b1010) begin // si la tecla corresponde a un numero entre 0 y 9
                    state_next = leer_dato1; // se pasa a mostrar el dato 1
                    we_banco_registros_o = 1'b1; // se habilita la escritura en el banco
                    dir_1_next = contador_reg;     // se apunta a la direccion que se acaba de escribir  para que el dato sea pasado al registro del display
                end else begin
                    led_error_o = 1'b1; //enciende el led de error
                    state_next = error_dato1;// si no se presiona tecla, sigue esperando el operando 
                end
        end     
    end
    
    error_dato1: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (!tecla_activa_i) begin // si la tecla corresponde a un numero entre 0 y 9
                    state_next = error_dato1; // se guarda el dato 1
                    led_error_o = 1'b1;
                end else begin
                    //led_error_o = 1'b0; //apaga el led de error
                    state_next = verif_dato1;// si se presiona tecla, pasa a verificar el dato 
                end
        end
    end
    
    leer_dato1: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                q_next = {N{1'b1}};
                we_7seg_o = 1'b1; //se habilita la escritura en el registro del 7 segmentos        
                state_next = espera1; //se pasa a esperar el operador, el display mantiene el dato en el registro y por tanto se sigue mostrando
                
        end
    end
    
    espera1: begin // estado que espera a que se deje de presionar la tecla!!!!!
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
            q_next = q_reg - 1;
            if (q_next == 0) begin // si el contador ha llegado a cero 
                state_next = wait_operador;
            end else begin // si no ha llegado a cero
                state_next = espera1; // se espera 
            end             
        end
    end
    
    wait_operador: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (tecla_activa_i) begin // si se presiono una tecla
                    state_next = verif_operador; // se pasa a un estado de verificacion del operador
                end else begin
                    state_next = wait_operador;// si no se presiona tecla, sigue esperando el operando 
                end
        end
    end
    
    verif_operador: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (valor_tecla_i < 4'b1111 && valor_tecla_i > 4'b1001) begin // si se presiono la tecla de operaciones (A, B, C, D, #) (suma, resta, and, or, lsl)
                    state_next = espera2;
                    q_next = {N{1'b1}}; // se llena de unos el contador que permite esperar a que se deje de presionar la tecla
                    if (valor_tecla_i == 4'b1010) // SUMA
                        control_next =  4'b1010;
                    else if (valor_tecla_i == 4'b1011) // RESTA
                        control_next =  4'b1011;
                    else if (valor_tecla_i == 4'b1100)  // OR
                        control_next =  4'b1100;
                    else if (valor_tecla_i == 4'b1101)  // AND
                        control_next =  4'b1101;
                    else if (valor_tecla_i == 4'b1110)  // LOGICAL SHIFT LEFT
                        control_next =  4'b1110;                
                end else begin
                    state_next = error_operador;// si no se trata de un error de operador
                end
        end
    
    end
    
    error_operador: begin // ingreso un operador erroneo!!!!
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (!tecla_activa_i) begin // si no se ha vuelto a activar una tecla despues del error
                    state_next = error_operador; // se continua en el estado de error de operador
                    led_error_o = 1'b1;
                end else begin
                    //led_error_o = 1'b0; //apaga el led de error
                    state_next = verif_operador;// si se presiona tecla, pasa a verificar el operador de nuevo 
                end
        end
    
    end
    
    espera2: begin // estado que espera a que se deje de presionar la tecla!!!!!
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
            q_next = q_reg - 1;
            if (q_next == 0) begin // si el contador ha llegado a cero 
                state_next = wait_dato2;
            end else begin // si no ha llegado a cero
                state_next = espera2; // se espera 
            end             
        end
    end
    
    wait_dato2: begin
       if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (tecla_activa_i) begin // si se presiono una tecla
                    state_next = verif_dato2; // se pasa a un estado de verificacion de dato 2
                    contador_next = contador_reg + 1; //cambia el puntero de escritura en una posicion
                end else begin
                    state_next = wait_dato2;// si no se presiona tecla, sigue esperando el operando 
                end
        end 
    
    end
    
    verif_dato2: begin
       if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (valor_tecla_i < 4'b1010) begin // si la tecla corresponde a un numero entre 0 y 9
                    state_next = leer_dato2; // se pasa a mostrar el dato 1
                    we_banco_registros_o = 1'b1; // se habilita la escritura en el banco
                    dir_1_next = contador_reg;     // se apunta a la direccion que se acaba de escribir  para que el dato sea pasado al registro del display
                end else begin
                    led_error_o = 1'b1; //enciende el led de error
                    state_next = error_dato2;// si no se presiona tecla, sigue esperando el operando 
                end
        end     
    end    
    
    error_dato2: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (!tecla_activa_i) begin // si la tecla corresponde a un numero entre 0 y 9
                    state_next = error_dato2; // se guarda el dato 1
                    led_error_o = 1'b1;
                end else begin
                    //led_error_o = 1'b0; //apaga el led de error
                    state_next = verif_dato2;// si se presiona tecla, pasa a verificar el dato 
                end
        end
    end
    
    leer_dato2: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                q_next = {N{1'b1}};
                we_7seg_o = 1'b1; //se habilita la escritura en el registro del 7 segmentos           
                state_next = espera3; //se pasa a esperar el operador, el display mantiene el dato en el registro y por tanto se sigue mostrando
        end
    end
    
    espera3: begin // estado que espera a que se deje de presionar la tecla!!!!!
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
            q_next = q_reg - 1;
            if (q_next == 0) begin // si el contador ha llegado a cero 
                state_next = wait_enter;
            end else begin // si no ha llegado a cero
                state_next = espera3; // se espera 
            end             
        end
    end
    
    
    
    wait_enter: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (tecla_activa_i) begin // si se presiono una tecla
                    state_next = verif_enter; // se pasa a un estado de verificacion de dato 2
                end else begin
                    state_next = wait_enter;// si no se presiona tecla, sigue esperando el operando 
                end
        end 
    
    end
    
    verif_enter: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (valor_tecla_i == 4'b1111) begin // si la tecla corresponde a un numero entre 0 y 9
                    state_next = leer_datos; // se pasan los datos del banco de registros a la ALU
                    contador_next = contador_reg + 1;
                end else begin
                    led_error_o = 1'b1; //enciende el led de error
                    state_next = error_enter;// si no se presiona tecla, sigue esperando el operando 
                end
        end
    end
    
    error_enter: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                if (!tecla_activa_i) begin // si la tecla corresponde a un numero entre 0 y 9
                    state_next = error_enter; // se guarda el dato 1
                    led_error_o = 1'b1;
                end else begin
                    //led_error_o = 1'b0; //apaga el led de error
                    state_next = verif_enter;// si se presiona tecla, pasa a verificar el dato 
                end
        end
    end
    
    leer_datos: begin // se realiza la operacion en la ALU
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
            dir_1_next = contador_reg - 2; //PRIMER OPERANDO
            dir_2_next = contador_reg - 1; // SEGUNDO OPERANDO
            mux_o = 1'b1; //habilita la entrada 2 del mux
            we_banco_registros_o = 1'b0;
            state_next = grd_resultado;
        end
    end
    
    grd_resultado: begin 
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
            mux_o = 1'b1; //habilita la entrada 2 del mux
            we_banco_registros_o = 1'b1;
            dir_1_next = contador_reg;
            state_next = leer_resultado;      
        end
    end
    
    leer_resultado: begin
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
                control_next = 4'b0000;
                q_next = {N{1'b1}};
                we_7seg_o = 1'b1; //se habilita la escritura en el registro del 7 segmentos        
                state_next = espera4; //se pasa a esperar el operador, el display mantiene el dato en el registro y por tanto se sigue mostrando
        end
    end
    
    espera4: begin // estado que espera a que se deje de presionar la tecla!!!!!
        if(sw_i) begin
            state_next = apunta_registro;
        end else begin
            q_next = q_reg - 1;
            if (q_next == 0) begin // si el contador ha llegado a cero 
                state_next = wait_dato1;
            end else begin // si no ha llegado a cero
                state_next = espera4; // se espera 
            end             
        end
    end

    apunta_registro: begin
        if (sw_i) begin
            we_7seg_o = 1'b1;
            q_next = {N{1'b1}};
            state_next = mostrar_registro;
            contador_modo2_next = 0;
        end else begin
            state_next = wait_dato1;
        end
    end
    
    mostrar_registro: begin
        if (sw_i) begin
            we_7seg_o = 1'b1;
            dir_1_next = contador_modo2_reg;
            q_next = q_reg - 1; //decrementa el contador
            state_next = mostrar_registro;
            if (contador_modo2_next <= contador_reg)begin
                
                if (q_next == 0) begin
                    q_next = {N{1'b1}}; //reinicia el contador
                    contador_modo2_next = contador_modo2_reg + 1; //pasa a la siguiente posicion
                end
            end else begin
               state_next = wait_dato1; 
            end
        end else begin
            state_next = wait_dato1;
        end
        
    end
        
    endcase
    
end

endmodule