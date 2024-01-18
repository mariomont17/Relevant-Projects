class monitor #(parameter filas = 4, parameter columnas =4, parameter ancho =40, parameter profundidad = 4, parameter broadcast = {8{1'b1}});

    int id; // identificador de la FIFO de entrada 

    //Declaracion de la interface
    virtual dut_if #(.ROWS(filas), .COLUMS(columnas), .pckg_sz(ancho), .fifo_depth(profundidad), .bdcst(broadcast)) vif; // interfaz del DUT

    //Declaracion del mailbox
    trans_router_mbx mnt_chckr_mbx;  //Monitor checker

    //Declaracion de la transaccion
    trans_router #(.ancho(ancho)) transaction; 

    function new (int id);
        this.id = id; 
    endfunction
    
    task reset();   // task de reseteo 
        this.vif.reset = 1; // reset asíncrono
    endtask

    task run();
        $display("[%g] El monitor #%g fue inicializado", $time, this.id);
        vif.reset = 1; // se aplica un reset de 4 ciclos al inicio de la simulación
        @(posedge vif.clk);
        for (int i= 0; i<4; i++) begin
            @(posedge vif.clk);
        end


        forever begin
            @(posedge vif.clk);
            vif.reset = 0;   //Baja el reset
            vif.pop[id] = 0; //Mantiene el pop en 0
            for (int i= 0; i<1; i++) begin
                @(posedge vif.clk);
            end

            if (vif.pndng[id]) begin //Si hay un pending desde el DUT
                transaction = new(); // Genera la transaccion.
                transaction.paquete = vif.data_out[id]; // se guarda lo que sale de la fifo en el objeto transaction (ID y PAYLOAD)
                transaction.tiempo_recibido = $time;    // se guarda el tiempo en que se hizo pop a la FIFO
                transaction.term_recibido = this.id;    // se guarda el terminal que hace pop
                transaction.UnPackage(); //Deshace la transaccion

                @(posedge vif.clk);

                vif.pop[id] = 1; //Le hace pop al dato
                mnt_chckr_mbx.put(transaction); // se envia la transacción al checker
                `ifdef DEBUG2
                transaction.print("Monitor: Transacción Recibida");
                `endif 
            end else begin

            end    
        end
    endtask

endclass