class driver #(parameter filas = 4, parameter columnas =4, parameter ancho =40, parameter profundidad = 4, parameter broadcast = {8{1'b1}});

    bit [ancho-1:0] fifo_emul [$:profundidad];  // queue que emula el comportamiento de la FIFO de entrada al DUT
    bit pop;    // señal de pop que viene desde el DUT
    bit pndng;  // señal de pending hacia el DUT
    int id; // identificador de la FIFO de entrada (0 a 15)

    virtual dut_if #(.ROWS(filas), .COLUMS(columnas), .pckg_sz(ancho), .fifo_depth(profundidad), .bdcst(broadcast)) vif; // interfaz virtual del DUT

    trans_router_mbx agnt_drv_mbx; 
    trans_router #(.ancho(ancho)) transaction;

    function new(int id);   // este constructor genera una nueva FIFO con su respectivo ID
        this.fifo_emul = {};    // se inicializa la cola vacía
        this.pop = 0;
        this.pndng = 0;
        this.id = id;        
    endfunction
    
    task reset();   // task de reseteo 
        this.vif.reset = 1; // reset asíncrono
        this.fifo_emul = {}; // Se vacia el queue
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
            pop = vif.popin[id]; // cada flanco positivo del reloj se actualiza la señal de pop del DUT
            vif.data_out_i_in[id] = fifo_emul[0]; // D_pop apunta al primer elemento de la FIFO
            if ((agnt_drv_mbx.num()>0) && (fifo_emul.size() < profundidad)) begin // se hay algo en el mailbox y la FIFO no esta llena
                agnt_drv_mbx.get(transaction); // se obtiene la transaccion desde el padre
                fifo_emul.push_back(transaction.paquete);   // y se guarda en la FIFO
                `ifdef DEBUG2
                transaction.print("Driver: transaccion completada");
                `endif 
            end 
            if (pop) begin  //Si recibe un pop entonces pone a la salida el dato
                vif.data_out_i_in[id] = fifo_emul.pop_front();
            end 
            if (fifo_emul.size() != 0) begin // si la FIFO no esta vacía
                pndng = 1;  // se pone la señal de pending en alto
            end else begin
                pndng = 0; // si esta vacia se pone en bajo
            end
            vif.pndng_i_in[id] = pndng; // se actualiza la señal de pending del DUT
        end
    endtask
endclass
