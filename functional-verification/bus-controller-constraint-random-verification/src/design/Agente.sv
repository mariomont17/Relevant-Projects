///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Agente: Se encarga de generar los escenarios de prueba basado en las instrucciones que provienen del Test //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

class agent #(parameter ancho=16, parameter terminales = 4, parameter broadcast = {8{1'b1}});
    trans_bus_mbx agnt_drv_mbx; // mailbox del agente al driver padre
    tst_agnt_mbx test_agent_mbx; // mailbox del test al agente
    int num_transacciones = 4;  // cantidad de transacciones aleatorias
    int retardo_max = 10; // retardo maximo por defecto de 10 ciclos del reloj
    int trans_x_terminal = 10; // 10 transacciones por terminal por defecto

    // para el caso específico
    int retardo_espec; // retardo especifico
    tipo_trans tipo_espec; // tipo especifico (envio)
    bit [ancho-1:0] pkg_espec; // paquete específico: incluye el ID y el Payload (Lo escribe el test)
    int term_envio_espec; // terminal desde la que se envia el paquete especifico
    
    // para las instrucciones del agente
    instruccion_agente instruccion;
    trans_bus #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast)) transaction;

    function new();
        num_transacciones = 4;
        retardo_max = 10;  
    endfunction

    task run();
        $display("[%g] El Agente fue inicializado",$time); 
        forever begin
            #5
            if (test_agent_mbx.num() > 0) begin
                $display("[%g]  Agente: ha recibido una instrucción",$time);
                test_agent_mbx.get(instruccion);
                $display("[%g]  Agente Instrucción: %s",$time, instruccion);
                case (instruccion)
                    trans_aleatoria: begin // una sola transaccion aleatoria
                        transaction = new();
                        transaction.retardo_max = retardo_max;
                        transaction.randomize();
                        transaction.print("Agente: transacción creada");
                        agnt_drv_mbx.put(transaction);
                    
                    end
                    trans_especifica: begin // para enviar una transaccion especifica y probar los casos de esquina
                        transaction = new();
                        transaction.retardo = retardo_espec;
                        transaction.tipo = tipo_espec;
                        transaction.paquete = pkg_espec;
                        transaction.terminal_envio = term_envio_espec;
                        transaction.print("Agente: transacción creada");
                        agnt_drv_mbx.put(transaction);
                    end
                    sec_trans_aleatorias: begin // una seccion de transacciones aleatorias
                        for(int i = 0; i < num_transacciones; i++) begin
                            transaction = new();
                            transaction.retardo_max = retardo_max;
                            transaction.randomize();
                            transaction.print("Agente: transacción creada");
                            agnt_drv_mbx.put(transaction);
                        end
                    end
                    brdcst: begin // broadcast desde un cualquier terminal 
                        transaction = new();
                        transaction.retardo_max = retardo_max;
                        transaction.randomize();
                        transaction.paquete[ancho-1:ancho-8] = broadcast;
                        transaction.print("Agente: transacción creada");
                        agnt_drv_mbx.put(transaction);
                    end
                    trans_aleat_x_terminal: begin // seccion de transacciones aleatorias, especificando la cantidad de transacciones por terminal (todas envían datos)
                        for (int i = 0; i < terminales ; i++) begin // i = indice de terminal
                            for (int j = 0; j < trans_x_terminal; j++) begin// j = indice de cantidad de transacciones por terminal
                                transaction = new();
                                transaction.retardo_max = retardo_max;
                                transaction.randomize();
                                transaction.terminal_envio = i;
                                if (transaction.paquete[ancho-1:ancho-8] != transaction.terminal_envio) begin // para evitar enviar datos a sí mismo
                                    transaction.print("Agente: transacción creada");
                                    agnt_drv_mbx.put(transaction);
                                end else begin
                                    j = j - 1;
                                end
                            end
                        end
                    end
                    llenar_fifos: begin // seccion de transacciones aleatorias sin broadcast ni envios al mismo terminal que la generó
                        for (int i = 0; i < terminales ; i++) begin // i = indice de terminal
                            for (int j = 0; j < num_transacciones; j++) begin// j = indice de cantidad de transacciones por terminal
                                transaction = new();
                                transaction.retardo_max = retardo_max;
                                transaction.randomize();
                                transaction.terminal_envio = i;
                                if ((transaction.paquete[ancho-1:ancho-8] != transaction.terminal_envio) && (transaction.paquete[ancho-1:ancho-8] != broadcast)) begin // para evitar enviar datos a sí mismo
                                    transaction.print("Agente: transacción creada");
                                    agnt_drv_mbx.put(transaction);
                                end else begin
                                    j = j - 1;
                                end
                            end
                        end

                        // for(int i = 0; i < num_transacciones; i++) begin
                        //     transaction = new();
                        //     transaction.retardo_max = retardo_max;
                        //     transaction.randomize();
                        //     if ((transaction.paquete[ancho-1:ancho-8] != transaction.terminal_envio) && (transaction.paquete[ancho-1:ancho-8] != broadcast)) begin // para evitar enviar datos a sí mismo
                        //         transaction.print("Agente: transacción creada");
                        //         agnt_drv_mbx.put(transaction);
                        //     end else begin
                        //         i = i - 1;
                        //     end
                        // end
                    end
                    default: begin
                        $display("[%g] Agente Error: la instrucción recibida no tiene tipo válido", $time);
                        $finish;
                    end
                endcase
    
            end

        end   
            
    endtask

endclass