////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Ambiente: Aquí se genera la instancia de todos los demás componentes del ambiente necesarios para correr la prueba //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class ambiente #(parameter ancho=16, parameter terminales = 4, parameter broadcast = {8{1'b1}}, parameter profundidad = 10);

    //declaración de los componentes del ambiente
    agent #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) agent_inst;
    driver_padre #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) driver_inst; // un solo driver padre
    driver_hijo #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast), .profundidad(profundidad)) driver_h_inst [terminales]; // array de driver hijos
    monitor #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast), .profundidad(profundidad)) monitor_inst [terminales]; // array de monitores
    scoreboard #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) scoreboard_inst;
    checker #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) checker_inst;

    virtual bus_if #(.bits(1), .drvrs(terminales), .pckg_sz(ancho), .broadcast(broadcast)) _if;

    // mailboxes
    trans_bus_mbx agnt_drv_mbx;     // mailbox del agente al driver padre
    trans_bus_mbx drv_chckr_mbx;    // mailbox del driver padre al checker
    trans_bus_mbx drv_padre_mbx [terminales]; // mailboxes de driver hijos al driver padre
    trans_bus_mbx mnt_chckr_mbx;    // mailbox del monitor al checker
    checker_scb_mbx chckr_scb_mbx;  // mailbox del checker al scoreboard   
    tst_agnt_mbx test_agent_mbx;    // mailbox del test al agente
    tst_scb_mbx test_scb_mbx;       // mailbox del test al scoreboard

    function new();

        // instanciación de los mailboxes
        agnt_drv_mbx    = new();
        drv_chckr_mbx   = new();
        mnt_chckr_mbx   = new();
        chckr_scb_mbx   = new();
        test_agent_mbx  = new();
        test_scb_mbx    = new();

        // instanciación de los componententes del ambiente
        agent_inst      = new();
        driver_inst     = new();
        scoreboard_inst = new();
        checker_inst    = new();

        for (int i = 0; i < terminales; i++) begin
            drv_padre_mbx[i] = new();
            monitor_inst[i] = new(i);
            driver_h_inst[i] = new(i);
        end

        // conexión de las interfaces y mailboxes en el ambiente
        checker_inst.mnt_chckr_mbx          = mnt_chckr_mbx;
        checker_inst.drv_chckr_mbx          = drv_chckr_mbx;
        checker_inst.chckr_scb_mbx          = chckr_scb_mbx;
        agent_inst.test_agent_mbx           = test_agent_mbx;
        agent_inst.agnt_drv_mbx             = agnt_drv_mbx;
        scoreboard_inst.test_scb_mbx        = test_scb_mbx;
        scoreboard_inst.chckr_scb_mbx       = chckr_scb_mbx; 
        driver_inst.agnt_drv_mbx            = agnt_drv_mbx; 
        driver_inst.drv_chckr_mbx           = drv_chckr_mbx;

        // conexión de los mailboxes de los drivers y monitores
        for (int i=0; i< terminales; i++) begin
            monitor_inst[i].mnt_chckr_mbx   = mnt_chckr_mbx;
            driver_inst.drv_padre_mbx[i]    = drv_padre_mbx[i];
            driver_h_inst[i].drv_padre_mbx  = drv_padre_mbx[i];
        end

    endfunction

    virtual task run();
        $display("[%g]  El ambiente fue inicializado",$time);
        // primero se conectan las interfases de los drivers y monitores
        for (int i=0; i< terminales; i++) begin
            monitor_inst[i].vif  = _if;
            driver_h_inst[i].vif     = _if;
        end
        driver_inst.vif = _if; // se conecta la interfaz del driver padre (controlador)
        fork // se corren los componentes en paralelo
            agent_inst.run();
            driver_inst.run();
            checker_inst.run();
            scoreboard_inst.run();
            for (int j = 0; j < terminales; j++) begin
                fork
                    automatic int n = j;
                    driver_h_inst[n].run();  
                    monitor_inst[n].run();
                join_none
            end
        join_none
    endtask

endclass