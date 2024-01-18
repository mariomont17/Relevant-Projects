//////////////////////////////////////////////////////////////////////////////////////////////////
// Test: se encarga de correr la prueba por medio de instrucciones hacia el agente y scoreboard //
//////////////////////////////////////////////////////////////////////////////////////////////////

class test #(parameter ancho=16, parameter terminales = 4, parameter broadcast = {8{1'b1}}, parameter profundidad = 10);

    tst_agnt_mbx test_agent_mbx;    // mailbox del test al agente
    tst_scb_mbx test_scb_mbx;       // mailbox del test al scoreboard
 
    parameter num_transacciones = 100;
    parameter retardo_max = 10;
    parameter trans_x_terminal = 5;
    instruccion_agente instr_agent;
    reporte_scb instr_scb;

    // definición del ambiente de prueba
    ambiente #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast), .profundidad(profundidad)) ambiente_inst;
    // definición de la interfase del DUT
    virtual bus_if #(.bits(1), .drvrs(terminales), .pckg_sz(ancho), .broadcast(broadcast)) _if;

    function new();
        test_agent_mbx = new();
        test_scb_mbx = new();
        ambiente_inst = new();
        ambiente_inst._if = _if;

        ambiente_inst.scoreboard_inst.test_scb_mbx = test_scb_mbx;
        ambiente_inst.test_scb_mbx = test_scb_mbx;
        ambiente_inst.test_agent_mbx = test_agent_mbx;
        ambiente_inst.agent_inst.test_agent_mbx = test_agent_mbx;

        ambiente_inst.agent_inst.num_transacciones = num_transacciones;
        ambiente_inst.agent_inst.retardo_max = retardo_max;
        ambiente_inst.scoreboard_inst.depth = profundidad;
    endfunction

    task run();
        $display("[%g]  El Test fue inicializado",$time);
        fork
            ambiente_inst.run();
        join_none

        instr_agent = trans_aleatoria;
        test_agent_mbx.put(instr_agent);
        $display("[%g]  Test: Enviada la primera instruccion al agente transacción aleatoria",$time);

        instr_agent = trans_especifica;
        ambiente_inst.agent_inst.retardo_espec = 4;
        ambiente_inst.agent_inst.tipo_espec = envio;
        ambiente_inst.agent_inst.pkg_espec[ancho-1:ancho-8] = 8'h03;
        ambiente_inst.agent_inst.pkg_espec[ancho-9:0] = 15;
        ambiente_inst.agent_inst.term_envio_espec = 3;
        test_agent_mbx.put(instr_agent);
        $display("[%g]  Test: Enviada la segunda instruccion al agente: transacción específica (hacia el mismo terminal)",$time);

        instr_agent = sec_trans_aleatorias;
        test_agent_mbx.put(instr_agent);
        $display("[%g]  Test: Enviada la tercera instruccion al agente: secuencia de %g transaccion_aleatoria",$time,num_transacciones);

        instr_agent = brdcst; // primer broadcast generado a "la fuerza"
        test_agent_mbx.put(instr_agent);
        $display("[%g]  Test: Enviada la cuarta instruccion al agente: broadcast desde cualquier terminal",$time);

        instr_agent = trans_aleat_x_terminal;
        ambiente_inst.agent_inst.trans_x_terminal = trans_x_terminal; // 10 transacciones por terminal
        test_agent_mbx.put(instr_agent);
        $display("[%g]  Test: Enviada la quinta instruccion al agente: secuencia de %g trans_aleat_x_terminal",$time, trans_x_terminal);

        #50
        instr_agent = trans_especifica;
        ambiente_inst.agent_inst.retardo_espec = 6;
        ambiente_inst.agent_inst.tipo_espec = envio;
        ambiente_inst.agent_inst.pkg_espec[ancho-1:ancho-8] = 8'hFE;
        ambiente_inst.agent_inst.pkg_espec[ancho-9:0] = 1;
        ambiente_inst.agent_inst.term_envio_espec = 1;
        test_agent_mbx.put(instr_agent);
        $display("[%g]  Test: Enviada la sexta instruccion al agente: transacción específica (hacia dispositivo que no existe)",$time);
		#5
        instr_agent = trans_especifica;
        ambiente_inst.agent_inst.retardo_espec = 3;
        ambiente_inst.agent_inst.tipo_espec = envio;
        ambiente_inst.agent_inst.pkg_espec[ancho-1:ancho-8] = 8'hFF; // probar broadcast
        ambiente_inst.agent_inst.pkg_espec[ancho-9:0] = 'hA;
        ambiente_inst.agent_inst.term_envio_espec = 2;
        test_agent_mbx.put(instr_agent);
        $display("[%g]  Test: Enviada la sétima instruccion al agente: broadcast desde terminal especifico",$time);

        #200_000
        $display("[%g]  Test: Se alcanza el tiempo límite de la prueba",$time);
       
        instr_scb = reporte_transacciones;
        test_scb_mbx.put(instr_scb);
        $display("[%g]  Test: Enviada la primera instruccion al scoreboard, reporte de transacciones completadas",$time);
        #200
        instr_scb = reporte_trans_inc;
        test_scb_mbx.put(instr_scb);
        $display("[%g]  Test: Enviada la segunda instruccion al scoreboard, reporte de transacciones sin completar",$time);
        #200


        // se hace el cálculo del ancho de banda de las transacciones

        ambiente_inst.agent_inst.num_transacciones = profundidad;
        ambiente_inst.agent_inst.retardo_max = 0;
        ambiente_inst.scoreboard_inst.score_board = {};
        ambiente_inst.scoreboard_inst.transacciones_completadas = 0;
        ambiente_inst.scoreboard_inst.retardo_total = 0;
        for (int i = 0; i < terminales; i++) begin
            ambiente_inst.scoreboard_inst.transacciones_completadas_x_terminal[i] = 0;
            ambiente_inst.scoreboard_inst.retardo_x_terminal[i] = 0;
        end
        
        #100
        instr_agent = llenar_fifos;
        test_agent_mbx.put(instr_agent);
        
        #500_000
        instr_scb = retardo_general;
        test_scb_mbx.put(instr_scb);
        #50
        instr_scb = reporte_bw_prom;
        test_scb_mbx.put(instr_scb);


        #1000
        $finish;

    endtask


endclass