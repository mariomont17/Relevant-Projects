
typedef bit [10:0] cola_de_rutas[$]; //queue usado para guardar la direccion que debe seguir un paquete especifico

class trans_router #(parameter ancho =40);

    // se definen primero los bits de contenido del paquete
    bit [ancho-1:0] paquete; // paquete completo que entra al DUT
    // METADATOS
    bit [7:0] nxt_jump; // 8 bits más significativos del paquete, NXT JUMP
    rand bit [3:0] row; // 4 bits para identificador de fila de destino
    rand bit [3:0] colum; // 4 bits para identificador de columna de destino
    rand bit mode; // 1 bit de modo
    // MENSAJE
    rand bit [ancho-18:0] payload; // bits restantes del paquete para payload
    bit [7:0] src; // router fuente 
    bit [7:0] id; // router destino

    // Se definen las características de envio del paquete: retardo, tiempos de envio/recibido, terminal de envio/recibido
    int retardo_max; // retardo máximo de envio de paquetes (en ciclos del reloj) 
    randc int retardo; // retardo del envio específico de un paquete
    rand int unsigned term_envio; // terminal que envía el paquete
    int unsigned term_recibido; // terminal que recibe el paquete
    int tiempo_envio; // tiempo en que se hace "push" en la FIFO de entrada
    int tiempo_recibido; // tiempo en que se hace "pop" desde la FIFO de salida incorporada en el DUT

    cola_de_rutas cola_rutas; // cola que contiene la ruta que debe seguir la transaccion

    constraint row_colum { // constraint para limitar el tamaño de las filas y columnas
        row >= 0; row < 6;  
        colum >= 0; colum < 6;
    }

    constraint c_term_envio{ // constraint para determinar por donde enviar el paquete
        term_envio < 16;
        term_envio >= 0; 
    }
    constraint const_retardo_max {  // constraint que limita el retardo aka delay
        retardo <= retardo_max;
        retardo >= 0;
    }

    constraint limites {
        {row,colum} dist {  8'h01:/6,
                            8'h02:/6,
                            8'h03:/6,
                            8'h04:/6,
                            8'h10:/6,
                            8'h20:/6,
                            8'h30:/6,
                            8'h40:/6,
                            8'h51:/6,
                            8'h52:/6,
                            8'h53:/6,
                            8'h54:/6,
                            8'h15:/6,
                            8'h25:/6,
                            8'h35:/6,
                            8'h45:/6
                        };
    }

    function new(   // constructor para generar una nueva transacción
        bit [7:0] nxt_jump = 0,
        bit [3:0] row = 0,
        bit [3:0] colum = 1,
        bit mode = 0,
        bit [ancho-17:0] payload = 0,
        int retardo = 0,
        int retardo_max = 10,
        int term_envio = 0,
        int tiempo_envio = 0
    );
        this.nxt_jump = nxt_jump;
        this.row = row;
        this.colum = colum;
        this.mode = mode;
        this.payload = payload;
        this.retardo = retardo;
        this.retardo_max = retardo_max;
        this.term_envio = term_envio;
        this.tiempo_envio = tiempo_envio;        
    endfunction

    function void term_dest(); //Pasa de un id en fila y columna a un numero entero
        case({row,colum})
            8'h01: this.term_recibido = 0;
            8'h02: this.term_recibido = 1;
            8'h03: this.term_recibido = 2;
            8'h04: this.term_recibido = 3;
            8'h10: this.term_recibido = 4;
            8'h20: this.term_recibido = 5;
            8'h30: this.term_recibido = 6;
            8'h40: this.term_recibido = 7;
            8'h51: this.term_recibido = 8;
            8'h52: this.term_recibido = 9;
            8'h53: this.term_recibido = 10;
            8'h54: this.term_recibido = 11;
            8'h15: this.term_recibido = 12;
            8'h25: this.term_recibido = 13;
            8'h35: this.term_recibido = 14;
            8'h45: this.term_recibido = 15;
        endcase
    endfunction

    function void term_a_enviar(int term_a_enviar); //Pasa de un numero entero de envio a un id en fila y columna
        case (term_a_enviar)
            0: begin this.row = 0; this.colum = 1; end
            1: begin this.row = 0; this.colum = 2; end
            2: begin this.row = 0; this.colum = 3; end
            3: begin this.row = 0; this.colum = 4; end
            4: begin this.row = 1; this.colum = 0; end
            5: begin this.row = 2; this.colum = 0; end
            6: begin this.row = 3; this.colum = 0; end
            7: begin this.row = 4; this.colum = 0; end
            8: begin this.row = 5; this.colum = 1; end
            9: begin this.row = 5; this.colum = 2; end
            10: begin this.row = 5; this.colum = 3; end
            11: begin this.row = 5; this.colum = 4; end
            12: begin this.row = 1; this.colum = 5; end
            13: begin this.row = 2; this.colum = 5; end
            14: begin this.row = 3; this.colum = 5; end
            15: begin this.row = 4; this.colum = 5; end
        endcase
    endfunction


    function void GetSrcAndId();
        case (term_envio)   //Se obienen el id fuente y del router que enviara el dato dependiendo de la terminal de envio
            0: begin this.src = 8'h01;  this.id = 8'h11; end
            1: begin this.src = 8'h02;  this.id = 8'h12; end
            2: begin this.src = 8'h03;  this.id = 8'h13; end
            3: begin this.src = 8'h04;  this.id = 8'h14; end
            4: begin this.src = 8'h10;  this.id = 8'h11; end
            5: begin this.src = 8'h20;  this.id = 8'h21; end
            6: begin this.src = 8'h30;  this.id = 8'h31; end
            7: begin this.src = 8'h40;  this.id = 8'h41; end
            8: begin this.src = 8'h51;  this.id = 8'h41; end
            9: begin this.src  = 8'h52;  this.id = 8'h42; end
            10: begin this.src  = 8'h53;  this.id = 8'h43; end
            11: begin this.src  = 8'h54;  this.id = 8'h44; end
            12: begin this.src  = 8'h15;  this.id = 8'h14; end
            13: begin this.src  = 8'h25;  this.id = 8'h24; end
            14: begin this.src  = 8'h35;  this.id = 8'h34; end
            15: begin this.src  = 8'h45;  this.id = 8'h44; end
        endcase
    endfunction

    function void BuildPackage(); // funcion para concatenar el paquete
        this.paquete = {this.nxt_jump,this.row,this.colum,this.mode,this.payload};
    endfunction

    function void UnPackage();//Deshace el paquete
        this.nxt_jump = this.paquete[ancho-1:ancho-8];
        this.row = this.paquete[ancho-9:ancho-12];
        this.colum = this.paquete[ancho-13:ancho-16];
        this.mode = this.paquete[ancho-17];
        this.payload = this.paquete[ancho-18:0];
    endfunction

    function void print (string tag = "");
        $display("[%g] %s pkt=%h Retardo=%g trgt_row=%h trgt_colum=%h mode=%b pyld=%h Terminal_env=%g Tiempo_env=%g Terminal rcb=%g Tiempo_rcb=%g", 
        $time, tag,this.paquete,this.retardo, this.row, this.colum, this.mode, this.payload, this.term_envio, this.tiempo_envio, this.term_recibido, this.tiempo_recibido);
    endfunction

endclass



class trans_sb #(parameter ancho = 40);             // Paquete del scoreboard
    bit [ancho-1:0] paquete_enviado;                // paquete enviado al bus
    bit [ancho-1:0] paquete_recibido;               // paquete recibido en terminal
    int tiempo_envio;                               // tiempo en el que se envió el paquete
    int tiempo_recibido;                            // tiempo en el que se recibe el paquete
    int latencia;                                   // latencia
    int term_tx;                                    // terminal de envio
    int term_rx;                                    // terminal de recepcion 
    bit completado;                                 // bit de transaccion completada

    task calc_latencia;
        this.latencia = this.tiempo_recibido - this.tiempo_envio;
    endtask

    function void print (string tag = "");
        $display("[%g] %s dato_tx=0x%h, dato_rx=0x%h, t_tx=%g, t_rx=%g, term_tx=%g, term_rx=%g, ltncy=%g, state=%g",
                $time,
                tag,
                this.paquete_enviado,
                this.paquete_recibido,
                this.tiempo_envio,
                this.tiempo_recibido,
                this.term_tx,
                this.term_rx,
                this.latencia,
                this.completado);
        
    endfunction

endclass


//Enumeracion de los tipos de transacciones (Usado en el generador)
typedef enum {trans_aleatoria, trans_especifica, brdcst, sec_trans_aleatorias, trans_aleat_x_terminal, todas_a_todas, una_a_todas, llenar_fifos,todas_a_todas_mode_esp} instruccion_generador;

//Enumeracion de los datos que seran calculados por el scoreboard
typedef enum {reporte_transacciones, retardo_general, reporte_ancho_banda, reporte_trans_inc} reporte_scb;

//Tipo de dato que maneja el mailbox que normalmente transmite datos tipo trans_router
typedef mailbox #(trans_router #(.ancho(ancho))) trans_router_mbx; 

//Tipo de dato que maneja el mailbox checker scoreboard
typedef mailbox #(trans_sb #(.ancho(ancho))) checker_scb_mbx; 


//Tipo de dato que maneja el test generador
typedef mailbox #(instruccion_generador) test_genr_mbx; // test al agente

//Tipo de dato que maneja el test scoreboard
typedef mailbox #(reporte_scb) tst_scb_mbx; // test a scoreboard

//Declaracion de la interface
interface dut_if #(

    parameter ROWS = 4,
    parameter COLUMS =4,
    parameter pckg_sz =40, 
    parameter fifo_depth = 4,
    parameter bdcst= {8{1'b1}}

    )(
    input bit clk
    );

    logic   reset;
    logic   pndng[ROWS*2+COLUMS*2];
    logic   pop[ROWS*2+COLUMS*2];
    logic   pndng_i_in[ROWS*2+COLUMS*2];
    logic   popin[ROWS*2+COLUMS*2];
    logic   [pckg_sz-1:0] data_out[ROWS*2+COLUMS*2];
    logic   [pckg_sz-1:0]data_out_i_in[ROWS*2+COLUMS*2];

endinterface

