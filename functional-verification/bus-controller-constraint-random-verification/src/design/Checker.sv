///////////////////////////////////////////////////////////////////////////////////////////
// La clase checker se encarga de verificar que el DUT se comporta de la manera esperada //
///////////////////////////////////////////////////////////////////////////////////////////

class checker #(parameter ancho=16, parameter terminales = 4, parameter broadcast = {8{1'b1}});
    trans_bus #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) from_drvr; //transaccion recibida desde el driver
    trans_bus #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) from_mntr; //transacción recibida desde el monitor
    trans_bus #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) auxiliar; // auxiliar para leer la queue emulada
    trans_sb #(.ancho(ancho)) to_sb; // transaccion hacia el scoreboard
   
    trans_bus #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) queue [terminales][$]; //golden reference
    int contador_auxiliar;
    bit [7:0] destino_auxiliar;
    int j = 0;
    trans_bus_mbx drv_chckr_mbx; // mailbox del driver al checker
    trans_bus_mbx mnt_chckr_mbx; // mailbox del monitor al checker
    checker_scb_mbx chckr_scb_mbx; // mailbox del checker al scoreboard

    function new();
        for(int i=0; i<terminales; i++) begin
            queue[i] = {};            
        end
        contador_auxiliar = 0;
    endfunction

    task run();
        $display("[%g] El checker fue inicializado",$time);
        forever begin
            #50
            if (drv_chckr_mbx.num()>0) begin
                drv_chckr_mbx.get(from_drvr);
                `ifdef DEBUG
                from_drvr.print("Checker: Se recibe transacción desde el driver");
                `endif 
                destino_auxiliar = from_drvr.paquete[ancho-1:ancho-8];

                if (destino_auxiliar == broadcast) begin // se verifica si el ID corresponde a un broadcast
                    for(int i = 0; i < terminales; i++) begin // en caso de serlo, se guarda la transacción en cada queue del checker para simular el comportamiento del DUT
                        if (i != from_drvr.terminal_envio) begin // no se guarda en el terminal que generó el broadcast
                            queue[i].push_back(from_drvr);
                        end 
                    end
                end 
                else begin
                    if ((destino_auxiliar < terminales) && (destino_auxiliar >= 0) && (destino_auxiliar != from_drvr.terminal_envio)) begin // ID válido, NO BROADCAST
                        queue[destino_auxiliar].push_back(from_drvr);
                    end else begin // se guarda el paquete que no se deberia haber recibido en el scoreboard, con el bit de completado en bajo
                    	to_sb = new(); // se utiliza para generar un reporte de todas las transacciones que no se han completado por razones de ID inválido
                      	to_sb.paquete_enviado = from_drvr.paquete;
                      	to_sb.tiempo_envio = from_drvr.tiempo_envio;
                      	to_sb.term_tx = from_drvr.terminal_envio;
                      	to_sb.completado = 0;
                      	chckr_scb_mbx.put(to_sb);
                    end
                end
            end
            else begin
                if (mnt_chckr_mbx.num()>0) begin
                    to_sb = new();
                    mnt_chckr_mbx.get(from_mntr);
                    `ifdef DEBUG
                    from_mntr.print("Checker: Se recibe trasacción desde el monitor");
                    `endif  
                
                    contador_auxiliar = queue[from_mntr.terminal_recibido].size();  // se obtiene el tamaño de cola del terminal recibido
                    j = 0;
                    while ( j < contador_auxiliar) begin //aqui se busca el elemento en la cola correspondiente
                        auxiliar = queue[from_mntr.terminal_recibido][j]; // auxiliar obtiene el objeto de la cola correspondiente
                        if (from_mntr.paquete == auxiliar.paquete) begin // si el elemento recibido se encuentra en la cola correspondiente
                            to_sb.paquete_enviado = auxiliar.paquete;
                            to_sb.paquete_recibido = from_mntr.paquete;
                            to_sb.tiempo_envio = auxiliar.tiempo_envio;
                            to_sb.tiempo_recibido = from_mntr.tiempo_recibido;
                            to_sb.term_tx = auxiliar.terminal_envio;
                            to_sb.term_rx = from_mntr.terminal_recibido;
                            to_sb.completado = 1;
                            to_sb.calc_latencia();
                            `ifdef DEBUG
                            to_sb.print("Checker: Transacción Completada");
                            `endif 
                            chckr_scb_mbx.put(to_sb);
                            queue[from_mntr.terminal_recibido].delete(j);
                            break;
                        end
                        j++;
                    end
                    if (j == contador_auxiliar) begin // si se sale del for loop sin haber encontrado la transacción, se generó un error en la simulación 
                        from_mntr.print("Checker: Error el dato de la transacción no calza con el esperado");
                        $finish;
                    end                   
                end
            end 
        end

    endtask


endclass
