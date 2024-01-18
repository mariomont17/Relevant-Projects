////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Driver_hijo: Objeto que incluye la FIFO de entrada al DUT. Se encarga de enviar las transacciones que recibe desde el driver padre //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class driver_hijo #(parameter ancho=16, parameter terminales = 4, parameter broadcast = {8{1'b1}}, parameter profundidad = 10);

    bit [ancho-1:0] fifo_emul [$:profundidad];  // queue que emula el comportamiento de la FIFO de entrada al DUT
    bit pop;    // señal de pop que viene desde el DUT
    bit pndng;  // señal de pending hacia el DUT
    int id; // identificador de la FIFO de entrada (n-1 FIFOs)

    virtual bus_if #(.bits(1), .drvrs(terminales), .pckg_sz(ancho), .broadcast(broadcast)) vif; // interfaz virtual del DUT

    trans_bus_mbx drv_padre_mbx; 
    trans_bus #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) transaction;

    function new(int id);   // este constructor genera una nueva FIFO con su respectivo ID
        this.fifo_emul = {};    // se inicializa la cola vacía
        this.pop = 0;
        this.pndng = 0;
        this.id = id;        
    endfunction
    
    task reset();   // task de reseteo 
        this.vif.reset = 1; // reset asíncrono
        this.fifo_emul = {};
        this.pop = 0;
        this.pndng = 0;
    endtask

    task run();
        $display("[%g]  El Driver #%g fue inicializado",$time,this.id);

        // se mantiene el reset en alto por cuatro ciclos del reloj
        vif.reset = 1;
        @(posedge vif.clk);
        for (int i= 0; i<4; i++) begin
            @(posedge vif.clk);
        end

        forever begin
            @(posedge vif.clk);
            vif.reset = 0;
            pop = vif.pop[0][id]; // cada flanco positivo del reloj se actualiza la señal de pop del DUT
            vif.D_pop[0][id] = fifo_emul[0]; // D_pop apunta al primer elemento de la FIFO
            if ((drv_padre_mbx.num()>0) && (fifo_emul.size() < profundidad)) begin // se hay algo en el mailbox y la FIFO no esta llena
                drv_padre_mbx.get(transaction); // se obtiene la transaccion desde el padre
                fifo_emul.push_back(transaction.paquete);   // y se guarda en la FIFO
                `ifdef DEBUG
                transaction.print("Driver hijo: transaccion completada");
                `endif 
            end 
            if (pop) begin 
                vif.D_pop[0][id] = fifo_emul.pop_front();
            end 
            if (fifo_emul.size() != 0) begin // si la FIFO no esta vacía
                pndng = 1;  // se pone la señal de pending en alto
            end else begin
                pndng = 0; // si esta vacia se pone en bajo
            end
            vif.pndng[0][id] = pndng; // se actualiza la señal de pending del DUT
        end
    endtask

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Driver_padre: Se encarga de recibir las transacciones creadas por el Agente y las envía a los hijos //
// dependiendo desde cual terminal se quiere enviar                                                    // 
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class driver_padre #(parameter ancho=16, parameter terminales = 4, parameter broadcast = {8{1'b1}});

    virtual bus_if #(.bits(1), .drvrs(terminales), .pckg_sz(ancho), .broadcast(broadcast)) vif; // interfaz virtual del DUT
    trans_bus #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) transaction;
    int espera; // espera entre transacciones
    
    //mailboxes
    trans_bus_mbx drv_padre_mbx [terminales]; // se tiene un handler de los mailboxes de los driver hijos
    trans_bus_mbx agnt_drv_mbx; // mailbox del agente al driver padre
    trans_bus_mbx drv_chckr_mbx; // mailbox del driver al checker

    task run();
        $display("[%g]  El Driver padre fue inicializado",$time);
        @(posedge vif.clk);
        forever begin
            @(posedge vif.clk);
            espera = 0;
            if (agnt_drv_mbx.num()>0) begin
                agnt_drv_mbx.get(transaction);
                `ifdef DEBUG
                transaction.print("Driver padre: Transacción recibida");
                `endif 
                if (transaction.terminal_envio < terminales) begin
                    while(espera < transaction.retardo) begin   // se esperan los ciclos del reloj entre transacciones
                        @(posedge vif.clk);
                        espera = espera + 1;
                    end
                    transaction.tiempo_envio = $time; // guarda el tiempo en que se realizó el envio del paquete
                    drv_padre_mbx[transaction.terminal_envio].put(transaction);
                    drv_chckr_mbx.put(transaction);
                    `ifdef DEBUG
                    $display("[%g] Driver Padre: Transacción enviada a driver hijo #%g", $time, transaction.terminal_envio);
                    `endif 
                end else begin
                    $display("[%g] Driver Error: la transaccion recibida tiene un ID inválido", $time);
                    $finish;
                end
            end
        end

    endtask 
    
endclass
