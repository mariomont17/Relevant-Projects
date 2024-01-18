////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Monitor: Esta clase se encarga de recibir los datos de un terminal del DUT y transmitirlos hasta al checker para su posterior revisión //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class monitor #(parameter ancho=16, parameter terminales = 4, parameter broadcast = {8{1'b1}}, parameter profundidad = 10);

    bit [ancho-1:0] fifo_emul [$:profundidad];  // queue que emula el comportamiento de la FIFO de entrada al DUT
    bit push;    // señal de pop que viene desde el DUT
    int id; // identificador de la FIFO de entrada 

    virtual bus_if #(.bits(1), .drvrs(terminales), .pckg_sz(ancho), .broadcast(broadcast)) vif; // interfaz virtual del DUT

    trans_bus_mbx mnt_chckr_mbx; 
    trans_bus #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) transaction;

    function new (int id);
        this.fifo_emul = {};  
        this.push = 0;
        this.id = id; 
    endfunction
    
    task reset();   // task de reseteo 
        this.vif.reset = 1; // reset asíncrono
        this.fifo_emul = {};
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
            vif.reset = 0;
            push = vif.push[0][id]; // se asigna el push de la FIFO emulada dependiendo del valor del push del DUT justo antes del flanco positivo del reloj
            if (push) begin
                fifo_emul.push_back(vif.D_push[0][id]); //se hace push en la FIFO del dato D_push del DUT
                `ifdef DEBUG
                $display("[%g] Monitor hijo #%g: Push desde el DUT", $time, id);
                `endif 
            end
            
            if (fifo_emul.size() != 0) begin // si la FIFO emulada no esta vacia
                transaction = new();
                transaction.paquete = fifo_emul.pop_front(); // se guarda lo que sale de la fifo en el objeto transaction (ID y PAYLOAD)
                transaction.tiempo_recibido = $time;    // se guarda el tiempo en que se hizo pop desde la FIFO
                transaction.terminal_recibido = this.id;    // se guarda el terminal que hace pop
                mnt_chckr_mbx.put(transaction); // se envia la transacción al checker
                `ifdef DEBUG
                transaction.print("Monitor: Transacción Recibida");
                `endif 
            end
        end
    endtask

endclass

