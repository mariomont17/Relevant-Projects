class ambiente #(parameter filas = 4, parameter columnas =4, parameter ancho =40, parameter profundidad = 4, parameter broadcast = {8{1'b1}});
    
    //Declaracion de la interfaz
    virtual dut_if #(.ROWS(filas), .COLUMS(columnas), .pckg_sz(ancho), .fifo_depth(profundidad), .bdcst(broadcast)) _if;

    //Declaracion de los componentes del ambiente
    generador #(.filas(filas), .columnas(columnas), .ancho(ancho), .profundidad(profundidad), .broadcast(broadcast)) gen_inst;
    agente #(.filas(filas), .columnas(columnas), .ancho(ancho), .profundidad(profundidad), .broadcast(broadcast)) agent_inst;
    driver #(.filas(filas), .columnas(columnas), .ancho(ancho), .profundidad(profundidad), .broadcast(broadcast)) driver_inst [filas*2+columnas*2];
    monitor #(.filas(filas), .columnas(columnas), .ancho(ancho), .profundidad(profundidad), .broadcast(broadcast)) monitor_inst [filas*2+columnas*2];
    checkr #(.filas(filas), .columnas(columnas), .ancho(ancho), .profundidad(profundidad), .broadcast(broadcast)) checker_inst;
    scoreboard #(.filas(filas), .columnas(columnas), .ancho(ancho), .profundidad(profundidad), .broadcast(broadcast)) scoreboard_inst;

    // DEFINICIÓN DE LOS MAILBOXES DEL AMBIENTE
    trans_router_mbx gen_agnt_mbx;                      // del generador al agente
    trans_router_mbx agnt_drv_mbx [filas*2+columnas*2]; // del agente a los 16 drivers
    trans_router_mbx agnt_chckr_mbx;                    // del agente al checker
    trans_router_mbx mnt_chckr_mbx [filas*2+columnas*2];// del monitor al checker
    checker_scb_mbx chckr_scb_mbx;                      // mailbox del checker al scoreboard   
    test_genr_mbx test_gen_mbx;                         // mailbox del test al generador
    tst_scb_mbx test_scb_mbx;                           // mailbox del test al scoreboard

    function new();

        // instanciación de los mailboxes
        gen_agnt_mbx    = new();
        agnt_chckr_mbx  = new();
        chckr_scb_mbx   = new();
        test_gen_mbx    = new();
        test_scb_mbx    = new();

        // instanciación de los componententes del ambiente
        gen_inst        = new();
        agent_inst      = new();
        scoreboard_inst = new();
        checker_inst    = new();

        for (int i = 0; i < (filas*2+columnas*2); i++) begin
            agnt_drv_mbx[i] = new();
            mnt_chckr_mbx[i] = new();
            monitor_inst[i] = new(i);
            driver_inst[i] = new(i);
        end
        
        // conexión de las interfaces y mailboxes en el ambiente
        checker_inst.agnt_chckr_mbx         = agnt_chckr_mbx;
        checker_inst.chckr_scb_mbx          = chckr_scb_mbx;
        gen_inst.test_gen_mbx               = test_gen_mbx;
        gen_inst.gen_agnt_mbx               = gen_agnt_mbx;
        agent_inst.gen_agnt_mbx             = gen_agnt_mbx;
        agent_inst.agnt_chckr_mbx           = agnt_chckr_mbx;
        scoreboard_inst.test_scb_mbx        = test_scb_mbx;
        scoreboard_inst.chckr_scb_mbx       = chckr_scb_mbx; 

        // conexión de los mailboxes de los drivers/agente y monitores/checker 
        for (int i=0; i< (filas*2+columnas*2); i++) begin
            agent_inst.agnt_drv_mbx[i]      = agnt_drv_mbx[i];
            driver_inst[i].agnt_drv_mbx     = agnt_drv_mbx[i];
            checker_inst.mnt_chckr_mbx[i]   = mnt_chckr_mbx[i];
            monitor_inst[i].mnt_chckr_mbx   = mnt_chckr_mbx[i];
        end

    endfunction //new()

    virtual task run();
        
        $display("[%g]  El ambiente fue inicializado",$time);
        // primero se conectan las interfases de los drivers y monitores
        for (int i=0; i< (filas*2+columnas*2); i++) begin
            monitor_inst[i].vif  = _if;
            driver_inst[i].vif   = _if;
        end
        agent_inst.vif = _if; // se conecta la interfaz del agente
        fork // se corren los componentes en paralelo
            gen_inst.run();
            agent_inst.run();
            checker_inst.run();
            checker_inst.run2();
            scoreboard_inst.run();
            for (int j = 0; j < (filas*2+columnas*2); j++) begin
                fork
                    automatic int n = j;
                    driver_inst[n].run();  
                    monitor_inst[n].run();
                join_none
            end
        join_none

    endtask


endclass //ambiente 