class test #(parameter filas = 4, parameter columnas =4, parameter ancho =40, parameter profundidad = 4, parameter broadcast = {8{1'b1}});

    test_genr_mbx test_gen_mbx;     // mailbox del test al generador
    tst_scb_mbx test_scb_mbx;       // mailbox del test al scoreboard
 
    parameter num_transacciones = 100;
    parameter retardo_max = 20;
    parameter trans_x_terminal = 10;
    instruccion_generador instr_gen; //Declara las instrucciones del test
    reporte_scb instr_scb; //Declara las instrucciones del scoreboard

    // definición del ambiente de prueba
    ambiente #(.filas(filas), .columnas(columnas), .ancho(ancho), .profundidad(profundidad), .broadcast(broadcast)) ambiente_inst;
    // definición de la interfase del DUT
    virtual dut_if #(.ROWS(filas), .COLUMS(columnas), .pckg_sz(ancho), .fifo_depth(profundidad), .bdcst(broadcast)) _if;

    function new();
        // generación de instancias
        test_gen_mbx = new();
        test_scb_mbx = new();
        ambiente_inst = new();
        ambiente_inst._if = _if;
        // conexión de mailboxes 
        ambiente_inst.scoreboard_inst.test_scb_mbx = test_scb_mbx;
        ambiente_inst.test_scb_mbx = test_scb_mbx;
        ambiente_inst.test_gen_mbx = test_gen_mbx;
        ambiente_inst.gen_inst.test_gen_mbx = test_gen_mbx;

        ambiente_inst.gen_inst.num_transacciones = num_transacciones;
        ambiente_inst.gen_inst.retardo_max = retardo_max;
        ambiente_inst.gen_inst.trans_x_terminal = trans_x_terminal;

    endfunction //new()

    task run();

        $display("[%g]  El Test fue inicializado",$time);
        fork
            ambiente_inst.run(); //Corre el ambiente
        join_none


        instr_gen = trans_aleatoria;                  //Indica el tipo de instruccion (transaccion aleatoria)
        ambiente_inst.gen_inst.term_envio_espec = 3;  //Indica la terminal de envio especifico
        test_gen_mbx.put(instr_gen);                  //Pone la intruccion en el mailbox
        $display("[%g]  Test: Enviada la primera instruccion al generador -> transacción aleatoria",$time);
        
        #10
        instr_gen = trans_especifica;                 //Indica el tipo de instruccion (Transaccion especifica)
        ambiente_inst.gen_inst.retardo_espec = 4;     //Retardo especifico
        ambiente_inst.gen_inst.row_espec = 5;         //Fila especifica
        ambiente_inst.gen_inst.colum_espec = 4;       //Columna especifica
        ambiente_inst.gen_inst.mode_espec = 1;        //Modo especifico
        ambiente_inst.gen_inst.pyld_espec = 8'haa;    //Payload especifico
        ambiente_inst.gen_inst.term_envio_espec = 0;  //Terminal de envio especifico
        test_gen_mbx.put(instr_gen);                  //Pone la instruccion en el mailbox
        $display("[%g]  Test: Enviada la segunda instruccion al generador -> transacción específica",$time);


        instr_gen = sec_trans_aleatorias;             //Indica el tipo de instruccion (Secuencia de transacciones aleatorias)
        test_gen_mbx.put(instr_gen);                  //Pone la instruccion en el mailbox
        $display("[%g]  Test: Enviada la tercera instruccion al generador -> sección de %g transacciones aleatorias",$time, num_transacciones);

       
        instr_gen = trans_aleat_x_terminal;           //Indica el tipo de instruccion (Transaccion aleatoria por terminal)
        test_gen_mbx.put(instr_gen);                  //Pone la instruccion en el mailbox
        $display("[%g]  Test: Enviada la cuarta instruccion al generador -> sección de %g transacciones aleatorias por terminal con modo aleatorio",$time, trans_x_terminal);
      
        instr_gen = todas_a_todas_mode_esp;           //Indica el tipo de instruccion (Todas a todas modo especifico)
        ambiente_inst.gen_inst.mode_espec = 0;        //Establece un modo especifico
        test_gen_mbx.put(instr_gen);                  //Pone la instruccion en el mailbox
        $display("[%g]  Test: Enviada la quinta instruccion al generador -> Envio de todas las terminales a todas las terminales con modo 0",$time);
      
        instr_gen = una_a_todas;                      //Indica el tipo de instruccion (Una a todas)
      	ambiente_inst.gen_inst.term_envio_espec = 0;  //Establece un modo especifico 0
        test_gen_mbx.put(instr_gen);                  //Pone la instruccion en el mailbox
        $display("[%g]  Test: Enviada la sexta instruccion al generador -> Envio de terminal especifica a todas las demas terminales",$time);
        
        #500_000

        instr_gen = todas_a_todas_mode_esp;           //Indica el tipo de instruccion (Todas a todas modo especifico)
        ambiente_inst.gen_inst.mode_espec = 1;        //Establece un modo especifico 1
        test_gen_mbx.put(instr_gen);                  //Pone la instruccion en el mailbox
        $display("[%g]  Test: Enviada la sétima instruccion al generador -> Envio de todas las terminales a todas las terminales con modo 1",$time);
      
      
      	instr_gen = trans_especifica;                 //Indica el tipo de instruccion (Transaccion especifica)
        ambiente_inst.gen_inst.retardo_espec = 5;     //Retardo especifico
        ambiente_inst.gen_inst.row_espec = 4;         //Fila especifica
        ambiente_inst.gen_inst.colum_espec = 5;       //Columna especifica
        ambiente_inst.gen_inst.mode_espec = 1;        //Modo especifico 1
      	ambiente_inst.gen_inst.pyld_espec = {(ancho-17){1'b1}}; //payload especifico
        ambiente_inst.gen_inst.term_envio_espec = 0; //Terminal de envio especifica
        test_gen_mbx.put(instr_gen); //Pone la instruccion en el mailbox

        $display("[%g]  Test: Enviada la octava instruccion al generador -> transacción específica (paquete con todos en 1)",$time);
      
      	#100
      	
      	instr_gen = trans_especifica;                               //Indica el tipo de instruccion (Transaccion especifica)
        ambiente_inst.gen_inst.retardo_espec = 5;                   //Retardo especifico
        ambiente_inst.gen_inst.row_espec = 4;                       //Fila especifica
        ambiente_inst.gen_inst.colum_espec = 5;                     //Columna especifica
        ambiente_inst.gen_inst.mode_espec = 0;                      //Modo especifico 0
      	ambiente_inst.gen_inst.pyld_espec = {(ancho-17){1'b0}};     //Payload especifico
        ambiente_inst.gen_inst.term_envio_espec = 0;                //Terminal de envio especifico
        test_gen_mbx.put(instr_gen);                                //Pone la instruccion en el mailbox
      	$display("[%g]  Test: Enviada la novena instruccion al generador -> transacción específica (paquete con todos en 0)",$time);
      
      	#1000

        instr_scb = reporte_transacciones;
        test_scb_mbx.put(instr_scb);
        $display("[%g]  Test: Enviada la primera instruccion al scoreboard -> reporte transacciones completadas",$time);
        #100
      	instr_scb = reporte_trans_inc;
        test_scb_mbx.put(instr_scb);
        $display("[%g]  Test: Enviada la segunda instruccion al scoreboard -> reporte transacciones incompletas/con errores",$time);
        #100

        ambiente_inst.scoreboard_inst.trans_completas = {};
        ambiente_inst.scoreboard_inst.transacciones_completadas = 0;
        ambiente_inst.scoreboard_inst.retraso_total = 0;
      	for (int i = 0; i < 16; i++) begin
            ambiente_inst.scoreboard_inst.transacciones_completadas_x_terminal[i] = 0;
            ambiente_inst.scoreboard_inst.retraso_x_terminal[i] = 0;
        end
      
      	#100
        $display("[%g]  Test: Se calcula el ancho de banda de la transmisión",$time);
      	instr_gen = llenar_fifos;
        test_gen_mbx.put(instr_gen);
      	$display("[%g]  Test: Enviada una instruccion al generador -> llenar FIFOs de entrada",$time);
      	#300_000
        
        instr_scb = retardo_general;
        test_scb_mbx.put(instr_scb);
        $display("[%g]  Test: Enviada la tercera instruccion al scoreboard -> reporte retardo general",$time);
        #100
        instr_scb = reporte_ancho_banda;
        test_scb_mbx.put(instr_scb);
        $display("[%g]  Test: Enviada la cuarta instruccion al scoreboard -> reporte ancho de banda",$time);

        #2_000_000

        $finish;

    endtask

endclass //test
