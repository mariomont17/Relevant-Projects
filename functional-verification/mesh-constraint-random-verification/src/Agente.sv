/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// La clase agente lee el mailbox del generador y se encarga de enviar los paquetes por el driver correcto //
// Además, envía la transacción completada al checker para su posterior manipulación                       // 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

class agente #(parameter filas = 4, parameter columnas =4, parameter ancho =40, parameter profundidad = 4, parameter broadcast = {8{1'b1}});
    
    virtual dut_if #(.ROWS(filas), .COLUMS(columnas), .pckg_sz(ancho), .fifo_depth(profundidad), .bdcst(broadcast)) vif; // interfaz del DUT   
    trans_router #(.ancho(ancho)) transaction; //Transaccion
    int espera; // espera entre transacciones

    // definicion de los mailboxes
    trans_router_mbx agnt_drv_mbx [filas*2+columnas*2]; // se tiene un handler de los mailboxes de los drivers
    trans_router_mbx gen_agnt_mbx; // mailbox del generador al agente
    trans_router_mbx agnt_chckr_mbx; // mailbox del agente al checker

    task run();
        $display("[%g]  El Agente fue inicializado",$time);
        @(posedge vif.clk);

        forever begin
            @(posedge vif.clk);
            espera = 0;
            if (gen_agnt_mbx.num()>0) begin //Revisa si hay paquetes en el mailbox
                gen_agnt_mbx.get(transaction); //Toma la transaccion
                `ifdef DEBUG2
                transaction.print("Agente: Transacción recibida");
                `endif 
                if (transaction.term_envio < (filas*2+columnas*2)) begin //Revisa que la terminal de envio se encuentre dentro del rango establecido
                    while(espera < transaction.retardo) begin   // se esperan los ciclos del reloj entre transacciones
                        @(posedge vif.clk);
                        espera = espera + 1;
                    end

                    transaction.tiempo_envio = $time; // guarda el tiempo en que se realizó el envío del paquete
                    agnt_drv_mbx[transaction.term_envio].put(transaction); //Pone el paquete en la terminal correspondiente
                    agnt_chckr_mbx.put(transaction); //Pone el mismo paquete en el checker para verificar despues.

                    `ifdef DEBUG2
                    $display("[%g] Agente: Transacción enviada a driver #%g", $time, transaction.term_envio);
                    `endif 

                end else begin
                    $display("[%g] Agente Error: la transaccion recibida tiene un ID inválido", $time);
                    $finish;
                end
            end
        end
    endtask

endclass