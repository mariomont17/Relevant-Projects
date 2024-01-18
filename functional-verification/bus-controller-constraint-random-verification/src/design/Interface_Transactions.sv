//////////////////////////////////////////////////////////////////////////
// Definicion del tipo de transacciones posibles en el manejador de bus //
//////////////////////////////////////////////////////////////////////////

typedef enum {envio, reset} tipo_trans;

////////////////////////////////////////////////////////////////////////////////////////////////////////
// trans_bus: objeto que representa las transacciones que entran y salen desde el controlador de bus. //
////////////////////////////////////////////////////////////////////////////////////////////////////////

class trans_bus #(parameter ancho = 16, parameter terminales = 4, parameter broadcast = {8{1'b1}});

    rand bit [ancho-1:0] paquete;   // paquete a ser enviado, con ID y Payload
    rand int retardo;               // retardo entre transacciones, en ciclos de reloj
    rand tipo_trans tipo;           // tipo de transferencia: envio y reset
    rand int terminal_envio;        // terminal en la que quiero enviar el paquete
    int tiempo_envio;               // tiempo en que se envió el paquete (push en la FIFO)
    int retardo_max;                // retardo máximo para poner el paquete en la FIFO del driver, en ciclos del reloj

    int tiempo_recibido;            // tiempo en el que se recibe el paquete (POP desde la FIFO del monitor)
    int terminal_recibido;          // terminal por el que se recibe el paquete, se usa en el monitor por lo cual no se randomiza

    constraint const_paquete1 {  // para enviar datos a dispositivos que si existen y broadcast
        paquete[ancho-1:ancho-8] dist { [0:(terminales-1)]:/95, broadcast:/5 };
    }

    constraint const_retardo_max {  // constraint que limita el retardo aka delay
        retardo <= retardo_max;
        retardo >= 0;
    }
    constraint const_term_envio {   // se limita este entero para que tenga sentido el terminal por el que se quieren enviar transacciones
        terminal_envio >= 0;
        terminal_envio < terminales;
    }

    constraint tipo_transaccion {
        tipo == envio;
    }

    function new ( // argumentos de la funcion new
        bit [ancho-1:0] paquete = 0,    // por defecto, paquete sin contenido
        tipo_trans tipo = envio,        // por defecto el tipo de transaccion es envio
        int retardo = 0,                // sin delay
        int terminal_envio = 0,         // por defecto el primer terminal es donde se envian paquetes
        int tiempo_envio = 0,           // se envian por el terminal 0, por defecto
        int retardo_max = 10            // 10 ciclos del reloj por defecto
        ); 

        this.paquete = paquete;
        this.retardo = retardo;
        this.tipo = tipo;
        this.tiempo_envio = tiempo_envio;
        this.terminal_envio = terminal_envio;
        this.retardo_max = retardo_max;

    endfunction

    function clean;
        this.paquete = 0;
        this.retardo = 0;
        this.tipo = envio;
        this.tiempo_envio = 0;
        this.terminal_envio = 0;
        this.tiempo_recibido = 0;
        this.terminal_recibido = 0;
    endfunction

    function void print (string tag = "");
        $display("[%g] %s Retardo=%g Tipo=%s paquete=0x%h Terminal_env=%g Tiempo_env=%g Terminal rcb=%g Tiempo_rcb=%g", $time, tag,this.retardo,this.tipo, this.paquete, this.terminal_envio, this.tiempo_envio, this.terminal_recibido, this.tiempo_recibido);
    endfunction


endclass


////////////////////////////////////////////////////////////////
// trans_sb: objeto de transaccion utilizado en el scoreboard //
////////////////////////////////////////////////////////////////


class trans_sb #(parameter ancho = 16);
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

////////////////////////////////////////////////////////////////
// Definición de las instrucciones del agente y el scoreboard //
////////////////////////////////////////////////////////////////

typedef enum {trans_aleatoria, trans_especifica, brdcst, sec_trans_aleatorias, trans_aleat_x_terminal, llenar_fifos} instruccion_agente;

typedef enum {reporte_transacciones, retardo_general, reporte_bw_prom, reporte_trans_inc } reporte_scb;


//////////////////////////////////////////////////////////////////////////////
// Definicion de los mailboxes de tipo definido para comunicar los bloques  //
//////////////////////////////////////////////////////////////////////////////

typedef mailbox #(trans_bus #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast))) trans_bus_mbx; 

typedef mailbox #(trans_sb #(.ancho(ancho))) checker_scb_mbx; 

typedef mailbox #(instruccion_agente) tst_agnt_mbx; // test al agente

typedef mailbox #(reporte_scb) tst_scb_mbx; // test a scoreboard




///////////////////////////////////////////////////////////////
// Interfaz para conectar el driver y el monitor con el DUT  //
///////////////////////////////////////////////////////////////

interface bus_if #(

    parameter bits = 1,
    parameter drvrs = 4, 
    parameter pckg_sz = 16, 
    parameter broadcast = {8{1'b1}}

    )(
    input bit clk
    );

    logic   reset;
    logic   pndng[bits-1:0][drvrs-1:0];
    logic   push[bits-1:0][drvrs-1:0];
    logic   pop[bits-1:0][drvrs-1:0];
    logic   [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0];
    logic   [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0];

endinterface 