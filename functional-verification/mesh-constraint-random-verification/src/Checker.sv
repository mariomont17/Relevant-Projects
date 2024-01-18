class checkr#(parameter filas = 4, parameter columnas =4, parameter ancho =40, parameter profundidad = 4, parameter broadcast = {8{1'b1}});

    parameter pckg_sz = ancho;
    trans_router_mbx agnt_chckr_mbx; // del agente al checker2
    trans_router_mbx mnt_chckr_mbx [filas*2+columnas*2]; // de los monitores al checker
    checker_scb_mbx chckr_scb_mbx; // del checker al scoreboard

    trans_router #(.ancho(pckg_sz)) from_agnt; //transaccion recibida desde el agente
    trans_router #(.ancho(pckg_sz)) from_mntr; //transacción recibida desde el monitor
    trans_router #(.ancho(pckg_sz)) aux; // auxiliar 
    trans_sb #(.ancho(pckg_sz)) to_sb; // transaccion hacia el scoreboard
                    
    trans_router #(.ancho(pckg_sz)) queue [filas*2+columnas*2][$]; //Queues que representan el dato recibido en el monitor
    int j;
	  
    int contador_auxiliar;
    cola_de_rutas cola_rutas_aux;
    bit [10:0] ruta_aux;

    bit [10:0] assoc_queue [bit [ancho-9:0]][$]; // arreglo asociativo de colas donde cada index es un paquete y cada elemento de la cola es de 11 bits

    bit[pckg_sz-1:0] paquete [64];
    bit [3:0] id_r [64]; // id que incluye fila
    bit [3:0] id_c [64];

    function new();
        for(int i=0; i<(filas*2+columnas*2); i++) begin
            queue[i] = {};            
        end
    endfunction

    task run();
        $display("[%g] El checker fue inicializado",$time);
        forever begin
            #5
            if (agnt_chckr_mbx.num() > 0) begin
                agnt_chckr_mbx.get(from_agnt); //Obtiene la transaccion desde el agente.
                from_agnt.term_dest(); //Obtiene la terminal de destino pero en numero entero

                `ifdef DEBUG2
                from_agnt.print("Checker: Se recibe transacción desde el Agente");
                `endif 

                cola_rutas_aux = ObtenerRuta(from_agnt.paquete, from_agnt.id); // se obtiene la ruta del paquete con el id fuente y el paquete
                from_agnt.cola_rutas = cola_rutas_aux; // se guarda la ruta en forma de cola en la transaccion

                foreach (from_agnt.cola_rutas[i]) begin
                  assoc_queue[from_agnt.paquete[ancho-9:0]].push_back(from_agnt.cola_rutas[i]); // se guarda la cola de rutas en el arreglo asociativo, con el index del paquete
                end

                // foreach(from_agnt.cola_rutas[i]) begin
                //   ruta_aux = from_agnt.cola_rutas[i];
                //   $display("[%g] Ruta: %h, id_r:%h, id_c:%h, id_term:%h",$time, ruta_aux, ruta_aux[9:6], ruta_aux[5:2], ruta_aux[1:0]);
                // end

                queue[from_agnt.term_recibido].push_back(from_agnt); //Guardo el dato en el queue correspondiente
            end 

            else begin
              foreach (mnt_chckr_mbx[i]) begin
                  	if (mnt_chckr_mbx[i].num() > 0 && queue[i].size() > 0 && agnt_chckr_mbx.num() == 0) begin
                        to_sb = new(); //Se inicializa el paquete que va hacia el scoreboard
                        mnt_chckr_mbx[i].get(from_mntr);
                        from_mntr.term_recibido = i; //Obtengo la direccion de destino para revisar en el queue
                        `ifdef DEBUG2
                        from_mntr.print("Checker: Se recibe trasacción desde el Monitor");
                        $display("Numero de terminal de recibido:",i);
                        `endif

                      	contador_auxiliar = queue[i].size(); //Se obtiene el tamaño del queue para poder iterar
                        j = 0;

                      	while (j < contador_auxiliar) begin //Itero con el tamaño actual del queue seleccionado
                            aux = queue[i][j]; //Se iguala el paquete a un queue auxiliar.


                            //Revisa si el paquete fue recibido en la terminal correcta.
                            if (from_mntr.row == aux.row && from_mntr.colum == aux.colum && from_mntr.payload == aux.payload && from_mntr.mode == aux.mode) begin //Compara los paquetes del queue con el del recibido
                                to_sb.paquete_enviado = aux.paquete;
                                to_sb.paquete_recibido = from_mntr.paquete;
                                to_sb.tiempo_envio = aux.tiempo_envio;
                                to_sb.tiempo_recibido = from_mntr.tiempo_recibido;
                                to_sb.term_tx = aux.term_envio;
                                to_sb.term_rx = from_mntr.term_recibido;
                                to_sb.completado = 1;
                                to_sb.calc_latencia();
                                `ifdef DEBUG2
                                $display("El dato calza con el esperado");
                                to_sb.print("Checker: Transacción Completada");
                                `endif 
                                chckr_scb_mbx.put(to_sb);
                              	queue[i].delete(j);
                                break;
                            end
                            j++;
                        end 

                        if (j == contador_auxiliar) begin //Si el contador llego al limite eso significa que el dato nunca se recibio en la terminal
                            from_mntr.print("Checker: Error el dato de la transacción no calza con el esperado");
                            to_sb.paquete_enviado = {(ancho-1){1'b1}};
                            to_sb.paquete_recibido = from_mntr.paquete;
                            to_sb.tiempo_recibido = from_mntr.tiempo_recibido;
                            to_sb.term_rx = from_mntr.term_recibido;
                            to_sb.completado = 0;
                            chckr_scb_mbx.put(to_sb);
                            //$finish;
                        end
                    end
                end

            end
        end
    endtask

    task run2(); //Este run se encarga de buscar un paquete recibido en algun router en un queue generado para verificar si se encuentra en la ruta correcta
      #50
      forever begin
        @(negedge $root.testbench.clk) begin
        // PRIMERA FILA
          // ROUTER 11
            if($root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[0].rtr_ntrfs_.popin) //110
            begin
                this.paquete[0] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[0] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[0] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[0].rtr_ntrfs_.id_c;
                // llamar una funcion que busque la transaccion en queue del checker y compare id con la cola_ruta de transaccion
                // debe ir eliminando las rutas del queue conforme se vayan dando 
                void'(VerificarRuta(paquete[0],{id_r[0],id_c[0]}));
                

            end
            if($root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[1].rtr_ntrfs_.popin) //111
            begin
                this.paquete[1] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[1] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[1] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[1],{id_r[1],id_c[1]}));
                
            end
            if($root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[2].rtr_ntrfs_.popin)//112
            begin
                this.paquete[2] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[2] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[2] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[2],{id_r[2],id_c[2]}));
            end
            if($root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[3].rtr_ntrfs_.popin)//113
            begin
                this.paquete[3] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[3] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[3] = $root.testbench.DUT._rw_[1]._clm_[1].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[3],{id_r[3],id_c[3]}));
            end

            // ROUTER 12

            if( $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[0].rtr_ntrfs_.popin)//120
            begin
                this.paquete[4] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[4] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[4] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[4],{id_r[4],id_c[4]}));

            end
            if($root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[1].rtr_ntrfs_.popin)//121
            begin
                this.paquete[5] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[5] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[5] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[5],{id_r[5],id_c[5]}));
                
            end
            if($root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[2].rtr_ntrfs_.popin)//122
            begin
                this.paquete[6] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[6] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[6] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[6],{id_r[6],id_c[6]}));
            end
            if($root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[3].rtr_ntrfs_.popin)//123
            begin
                this.paquete[7] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[7] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[7] = $root.testbench.DUT._rw_[1]._clm_[2].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[7],{id_r[7],id_c[7]}));
            end

          // ROUTER 13

            if( $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[0].rtr_ntrfs_.popin)//130
            begin
                this.paquete[8] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[8] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[8] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[8],{id_r[8],id_c[8]}));
            end
           if($root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[1].rtr_ntrfs_.popin)//131
            begin
                this.paquete[9] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[9] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[9] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[9],{id_r[9],id_c[9]}));
            end
            if($root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[2].rtr_ntrfs_.popin)//132
            begin
                this.paquete[10] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[10] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[10] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[10],{id_r[10],id_c[10]}));
            end
            if($root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[3].rtr_ntrfs_.popin)//133
            begin
                this.paquete[11] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[11] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[11] = $root.testbench.DUT._rw_[1]._clm_[3].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[11],{id_r[11],id_c[11]}));
            end

            // ROUTER 14

            if( $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[0].rtr_ntrfs_.popin)//140
            begin
                this.paquete[12] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[12] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[12] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[12],{id_r[12],id_c[12]}));
            end
            if($root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[1].rtr_ntrfs_.popin)//141
            begin
                this.paquete[13] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[13] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[13] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[13],{id_r[13],id_c[13]}));
            end
            if($root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[2].rtr_ntrfs_.popin)//142
            begin
                this.paquete[14] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[14] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[14] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[14],{id_r[14],id_c[14]}));
            end
            if($root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[3].rtr_ntrfs_.popin)//143
            begin
                this.paquete[15] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[15] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[15] = $root.testbench.DUT._rw_[1]._clm_[4].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[15],{id_r[15],id_c[15]}));
            end

        // SEGUNDA FILA
            // ROUTER 21
            if($root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[0].rtr_ntrfs_.popin)//210
            begin
                this.paquete[16] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[16] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[16] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[16],{id_r[16],id_c[16]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[1].rtr_ntrfs_.popin)//211
            begin
                this.paquete[17] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[17] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[17] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[17],{id_r[17],id_c[17]}));
                
            end
            if($root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[2].rtr_ntrfs_.popin)//212
            begin
                this.paquete[18] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[18] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[18] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[18],{id_r[18],id_c[18]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[3].rtr_ntrfs_.popin)//213
            begin
                this.paquete[19] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[19] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[19] = $root.testbench.DUT._rw_[2]._clm_[1].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[19],{id_r[19],id_c[19]}));
            end

            // ROUTER 22

            if( $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[0].rtr_ntrfs_.popin)//220
            begin
                this.paquete[20] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[20] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[20] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[20],{id_r[20],id_c[20]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[1].rtr_ntrfs_.popin)//221
            begin
                this.paquete[21] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[21] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[21] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[21],{id_r[21],id_c[21]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[2].rtr_ntrfs_.popin)//222
            begin
                this.paquete[22] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[22] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[22] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[22],{id_r[22],id_c[22]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[3].rtr_ntrfs_.popin)//223
            begin
                this.paquete[23] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[23] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[23] = $root.testbench.DUT._rw_[2]._clm_[2].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[23],{id_r[23],id_c[23]}));
            end

          // ROUTER 23

            if( $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[0].rtr_ntrfs_.popin)//230
            begin
                this.paquete[24] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[24] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[24] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[24],{id_r[24],id_c[24]}));
            end
           if($root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[1].rtr_ntrfs_.popin)//231
            begin
                this.paquete[25] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[25] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[25] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[25],{id_r[25],id_c[25]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[2].rtr_ntrfs_.popin)//232
            begin
                this.paquete[26] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[26] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[26] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[26],{id_r[26],id_c[26]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[3].rtr_ntrfs_.popin)//233
            begin
                this.paquete[27] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[27] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[27] = $root.testbench.DUT._rw_[2]._clm_[3].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[27],{id_r[27],id_c[27]}));
            end

            // ROUTER 24

            if( $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[0].rtr_ntrfs_.popin)//240
            begin
                this.paquete[28] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[28] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[28] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[28],{id_r[28],id_c[28]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[1].rtr_ntrfs_.popin)//241
            begin
                this.paquete[29] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[29] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[29] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[29],{id_r[29],id_c[29]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[2].rtr_ntrfs_.popin)//242
            begin
                this.paquete[30] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[30] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[30] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[30],{id_r[30],id_c[30]}));
            end
            if($root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[3].rtr_ntrfs_.popin)//243
            begin
                this.paquete[31] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[31] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[31] = $root.testbench.DUT._rw_[2]._clm_[4].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[31],{id_r[31],id_c[31]}));
            end
        // TERCERA FILA
            // ROUTER 31
            if($root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[0].rtr_ntrfs_.popin)//310
            begin
                this.paquete[32] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[32] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[32] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[32],{id_r[32],id_c[32]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[1].rtr_ntrfs_.popin)//311
            begin
                this.paquete[33] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[33] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[33] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[33],{id_r[33],id_c[33]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[2].rtr_ntrfs_.popin)//312
            begin
                this.paquete[34] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[34] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[34] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[34],{id_r[34],id_c[34]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[3].rtr_ntrfs_.popin)//313
            begin
                this.paquete[35] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[35] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[35] = $root.testbench.DUT._rw_[3]._clm_[1].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[35],{id_r[35],id_c[35]}));
            end

            // ROUTER 32

            if( $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[0].rtr_ntrfs_.popin)//320
            begin
                this.paquete[36] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[36] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[36] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[36],{id_r[36],id_c[36]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[1].rtr_ntrfs_.popin)//321
            begin
                this.paquete[37] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[37] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[37] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[37],{id_r[37],id_c[37]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[2].rtr_ntrfs_.popin)//322
            begin
                this.paquete[38] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[38] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[38] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[38],{id_r[38],id_c[38]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[3].rtr_ntrfs_.popin)//323
            begin
                this.paquete[39] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[39] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[39] = $root.testbench.DUT._rw_[3]._clm_[2].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[39],{id_r[39],id_c[39]}));
            end

          // ROUTER 33

            if( $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[0].rtr_ntrfs_.popin)//330
            begin
                this.paquete[40] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[40] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[40] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[40],{id_r[40],id_c[40]}));
            end
           if($root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[1].rtr_ntrfs_.popin)//331
            begin
                this.paquete[41] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[41] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[41] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[41],{id_r[41],id_c[41]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[2].rtr_ntrfs_.popin)//332
            begin
                this.paquete[42] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[42] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[42] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[42],{id_r[42],id_c[42]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[3].rtr_ntrfs_.popin)//333
            begin
                this.paquete[43] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[43] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[43] = $root.testbench.DUT._rw_[3]._clm_[3].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[43],{id_r[43],id_c[43]}));
            end

            // ROUTER 34

            if( $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[0].rtr_ntrfs_.popin)//340
            begin
                this.paquete[44] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[44] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[44] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[44],{id_r[44],id_c[44]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[1].rtr_ntrfs_.popin)//341
            begin
                this.paquete[45] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[45] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[45] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[45],{id_r[45],id_c[45]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[2].rtr_ntrfs_.popin)//342
            begin
                this.paquete[46] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[46] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[46] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[46],{id_r[46],id_c[46]}));
            end
            if($root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[3].rtr_ntrfs_.popin)//343
            begin
                this.paquete[47] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[47] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[47] = $root.testbench.DUT._rw_[3]._clm_[4].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[47],{id_r[47],id_c[47]}));
            end
        // CUARTA FILA
            // ROUTER 41
            if($root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[0].rtr_ntrfs_.popin)//410
            begin
                this.paquete[48] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[48] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[48] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[48],{id_r[48],id_c[48]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[1].rtr_ntrfs_.popin)//411
            begin
                this.paquete[49] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[49] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[49] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[49],{id_r[49],id_c[49]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[2].rtr_ntrfs_.popin)//412
            begin
                this.paquete[50] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[50] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[50] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[50],{id_r[50],id_c[50]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[3].rtr_ntrfs_.popin)//413
            begin
                this.paquete[51] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[51] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[51] = $root.testbench.DUT._rw_[4]._clm_[1].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[51],{id_r[51],id_c[51]}));
            end

            // ROUTER 42

            if( $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[0].rtr_ntrfs_.popin)//420
            begin
                this.paquete[52] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[52] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[52] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[52],{id_r[52],id_c[52]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[1].rtr_ntrfs_.popin)//421
            begin
                this.paquete[53] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[53] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[53] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[53],{id_r[53],id_c[53]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[2].rtr_ntrfs_.popin)//422
            begin
                this.paquete[54] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[54] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[54] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[54],{id_r[54],id_c[54]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[3].rtr_ntrfs_.popin)//423
            begin
                this.paquete[55] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[55] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[55] = $root.testbench.DUT._rw_[4]._clm_[2].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[55],{id_r[55],id_c[55]}));
            end

          // ROUTER 43

            if( $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[0].rtr_ntrfs_.popin)//430
            begin
                this.paquete[56] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[56] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[56] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[56],{id_r[56],id_c[56]}));
            end
           if($root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[1].rtr_ntrfs_.popin)//431
            begin
                this.paquete[57] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[57] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[57] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[57],{id_r[57],id_c[57]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[2].rtr_ntrfs_.popin)//432
            begin
                this.paquete[58] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[58] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[58] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[58],{id_r[58],id_c[58]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[3].rtr_ntrfs_.popin)//433
            begin
                this.paquete[59] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[59] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[59] = $root.testbench.DUT._rw_[4]._clm_[3].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[59],{id_r[59],id_c[59]}));
            end

            // ROUTER 44

            if( $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[0].rtr_ntrfs_.popin)//440
            begin
                this.paquete[60] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[0].rtr_ntrfs_.data_out_i_in;
                this.id_r[60] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[0].rtr_ntrfs_.id_r; 
                this.id_c[60] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[0].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[60],{id_r[60],id_c[60]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[1].rtr_ntrfs_.popin)//441
            begin
                this.paquete[61] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[1].rtr_ntrfs_.data_out_i_in;
                this.id_r[61] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[1].rtr_ntrfs_.id_r; 
                this.id_c[61] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[1].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[61],{id_r[61],id_c[61]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[2].rtr_ntrfs_.popin)//442
            begin
                this.paquete[62] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[2].rtr_ntrfs_.data_out_i_in;
                this.id_r[62] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[2].rtr_ntrfs_.id_r; 
                this.id_c[62] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[2].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[62],{id_r[62],id_c[62]}));
            end
            if($root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[3].rtr_ntrfs_.popin)
            begin
                this.paquete[63] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[3].rtr_ntrfs_.data_out_i_in;
                this.id_r[63] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[3].rtr_ntrfs_.id_r; 
                this.id_c[63] = $root.testbench.DUT._rw_[4]._clm_[4].rtr._nu_[3].rtr_ntrfs_.id_c;
                void'(VerificarRuta(paquete[63],{id_r[63],id_c[63]}));
            end
     
     end
      end
    endtask

    //Esta funcion devuelve el siguiente camamino que debe tomar el paquete dependiendo de la columna y fila actual y el modo
    function bit[10:0] Ruta(bit [3:0] id_r=0, bit[3:0] id_c=0, bit[pckg_sz-1:0] Data_in=0);
      bit [10:0] ruta = 0;  
      bit [1:0] id_term = 0;
      bit [3:0] id_row = 0;
      bit [3:0] id_column = 0;
      bit fin = 0;

      if((id_r != filas)&(id_r != 1)&(id_c != columnas)&(id_c != 1)) begin // si se trata de un router que no está en el marco limítrofe
        if(Data_in[pckg_sz-17]) begin //si el modo es 1 entonces rutea primero fila
          if(Data_in[pckg_sz-9:pckg_sz-12] < id_r) begin // si la fila es mayor que objetivo, se resta 1 en fila y mantiene columna 
            id_term = 2'd0;
            id_row = id_r-1;
            id_column = id_c;
          end
          if(Data_in[pckg_sz-9: pckg_sz-12] > id_r) begin // si la fila es mayor, se suma 1 en fila y sale por terminal 2
            id_term = 2'd2;
            id_row = id_r+1;
            id_column = id_c;
          end
          if(Data_in[pckg_sz-9: pckg_sz-12] == id_r) begin // si esta en la misma fila del objetivo, no se cambia fila y se enruta columna 
            if(Data_in[pckg_sz-13: pckg_sz-16] < id_c) begin // si la columna actual es mayor, se resta 1 en columna y sale por term 3
              id_term = 2'd3;
              id_row = id_r;
              id_column = id_c-1;
            end
            if(Data_in[pckg_sz-13: pckg_sz-16] > id_c) begin // si la columna actual es mayor, se suma 1 en columna y sale por term 1
              id_term = 2'd1;
              id_row = id_r;
              id_column = id_c+1;
            end
            if(Data_in[pckg_sz-13: pckg_sz-16]== id_c) begin // si la columna actual es igual, se pone en alto el bit de fin
              fin = 1;
            end
          end
        end else begin // si el modo es 0 rutea primero columna
          if(Data_in[pckg_sz-13: pckg_sz-16] < id_c) begin 
            id_term = 2'd3;
            id_row = id_r;
            id_column = id_c-1;
          end
          if(Data_in[pckg_sz-13: pckg_sz-16] > id_c) begin
            id_term = 2'd1;
            id_row = id_r;
            id_column = id_c+1;
          end
          if(Data_in[pckg_sz-13: pckg_sz-16] == id_c) begin
            if(Data_in[pckg_sz-9: pckg_sz-12] < id_r) begin
              id_term = 2'd0;
              id_row = id_r-1;
              id_column = id_c;
            end
            if(Data_in[pckg_sz-9: pckg_sz-12] > id_r) begin
              id_term = 2'd2;
              id_row = id_r+1;
              id_column = id_c;
            end
            if(Data_in[pckg_sz-9: pckg_sz-12] == id_r) begin
              fin = 1;
            end
          end
        end
      end else begin // si se trata de un router que está en el marco limítrofe
        if(((Data_in[pckg_sz-9:pckg_sz-12] < id_r)&(id_r == 1))| 
          ((Data_in[pckg_sz-9:pckg_sz-12] > id_r)&(id_r == filas))| 
          ((Data_in[pckg_sz-13:pckg_sz-16] < id_c)&(id_c == 1))| 
          ((Data_in[pckg_sz-13:pckg_sz-16] > id_c)&(id_c == columnas))) begin // si es un caso de salida del mesh

          if((Data_in[pckg_sz-9:pckg_sz-12] < id_r)&(id_r == 1)) begin // si está en el borde superior y la fila es 1
            if(Data_in[pckg_sz-13: pckg_sz-16] == id_c) begin // si está en la columna correcta
              id_term = 2'd0;
              id_row = id_r-1;
              id_column = id_c;
            end
            if(Data_in[pckg_sz-13: pckg_sz-16] < id_c)begin // si está en una columna mayor
              id_term = 2'd3;
              id_row = id_r;
              id_column = id_c-1;
            end
            if(Data_in[pckg_sz-13: pckg_sz-16] > id_c)begin // si está en una columna menor
              id_term = 2'd1;
              id_row = id_r;
              id_column = id_c+1;
            end
          end
          if((Data_in[pckg_sz-9:pckg_sz-12] > id_r)&(id_r == filas)) begin // si está en el borde inferior y la fila es 4
            if(Data_in[pckg_sz-13: pckg_sz-16] == id_c) begin // si está en la columna correcta
              id_term = 2'd2;
              id_row = id_r+1;
              id_column = id_c;
            end
            if(Data_in[pckg_sz-13: pckg_sz-16] < id_c)begin // si está en una columna mayor
              id_term = 2'd3;
              id_row = id_r;
              id_column = id_c-1;
            end
            if(Data_in[pckg_sz-13: pckg_sz-16] > id_c)begin // si está en una columna menor
              id_term = 2'd1;
              id_row = id_r;
              id_column = id_c+1;
            end
          end
          if((Data_in[pckg_sz-13:pckg_sz-16] < id_c)&(id_c == 1)) begin // si está en el borde izquierdo y la columna es 1
            if(Data_in[pckg_sz-9: pckg_sz-12] == id_r) begin // si está en la fila correcta
              id_term = 2'd3;
              id_row = id_r;
              id_column = id_c-1;
            end
            if(Data_in[pckg_sz-9: pckg_sz-12] < id_r)begin // si está en una fila mayor
              id_term = 2'd0;
              id_row = id_r-1;
              id_column = id_c;
            end
            if(Data_in[pckg_sz-9: pckg_sz-12] > id_r)begin // si está en una fila menor
              id_term = 2'd2;
              id_row = id_r+1;
              id_column = id_c;
            end
          end
          if((Data_in[pckg_sz-13:pckg_sz-16] > id_c)&(id_c == columnas)) begin // si está en el borde derecho y la columna es 4
            if(Data_in[pckg_sz-9: pckg_sz-12] == id_r) begin // si está en la fila correcta
              id_term = 2'd1;
              id_row = id_r;
              id_column = id_c+1;
            end
            if(Data_in[pckg_sz-9: pckg_sz-12] < id_r)begin // si está en una fila mayor
              id_term = 2'd0;
              id_row = id_r-1;
              id_column = id_c;
            end
            if(Data_in[pckg_sz-9: pckg_sz-12] > id_r)begin // si está en una fila menor
              id_term = 2'd2;
              id_row = id_r+1;
              id_column = id_c;
            end
          end
        end else begin // si no es un caso de salida
          if(Data_in[pckg_sz-17]) begin //si el modo es 1 entonces rutea primero fila
            if(Data_in[pckg_sz-9:pckg_sz-12] < id_r) begin
              id_term = 2'd0;
              id_row = id_r-1;
              id_column = id_c;
            end
            if(Data_in[pckg_sz-9: pckg_sz-12] > id_r) begin
              id_term = 2'd2;
              id_row = id_r+1;
              id_column = id_c;
            end
            if(Data_in[pckg_sz-9: pckg_sz-12] == id_r) begin
              if(Data_in[pckg_sz-13: pckg_sz-16] < id_c) begin
                id_term = 2'd3;
                id_row = id_r;
                id_column = id_c-1;
              end
              if(Data_in[pckg_sz-13: pckg_sz-16] > id_c) begin
                id_term = 2'd1;
                id_row = id_r;
                id_column = id_c+1;
              end
              if(Data_in[pckg_sz-13: pckg_sz-16]== id_c) begin
                fin = 1;
              end
            end
          end else begin // si el modo es 0 rutea primero columna
            if(Data_in[pckg_sz-13: pckg_sz-16] < id_c) begin
              id_term = 2'd3;
              id_row = id_r;
              id_column = id_c-1;
            end
            if(Data_in[pckg_sz-13: pckg_sz-16] > id_c) begin
              id_term = 2'd1;
              id_row = id_r;
              id_column = id_c+1;
            end
            if(Data_in[pckg_sz-13: pckg_sz-16] == id_c) begin
              if(Data_in[pckg_sz-9: pckg_sz-12] < id_r) begin
                id_term = 2'd0;
                id_row = id_r-1;
                id_column = id_c;
              end
              if(Data_in[pckg_sz-9: pckg_sz-12] > id_r) begin
                id_term = 2'd2;
                id_row = id_r+1;
                id_column = id_c;
              end
              if(Data_in[pckg_sz-9: pckg_sz-12] == id_r) begin
                fin = 1;
              end
            end
          end
        end
      end   
      ruta = {id_row,id_column,id_term}; //Devuelve el id del router y de la terminal 
        return ruta;
    endfunction

    //Esta funcion se encarga de devolver un queue con toda la ruta que debe seguir el paquete
    function cola_de_rutas ObtenerRuta(bit[pckg_sz-1:0] dato=0, bit [7:0] src = 0);
      cola_de_rutas cola_rutas; //Declara el queue
      bit [10:0] ruta = 0;
      bit [7:0] id; // router destino

      ruta[9:2] = src;
      cola_rutas.push_back(ruta);

      for(int i=0; i<7; i++)begin
        ruta = Ruta(src[7:4], src[3:0], dato); //Obtiene el siguiente pedazo de la ruta con la funcion ruta
        src = ruta[9:2];

        if (src != dato[pckg_sz-9:pckg_sz-16]) begin //Si la fuente es diferente al id de destino
          cola_rutas.push_back(ruta); //Agrega el camino al queue 

        end else begin //Si no rompe el ciclo
           break;
        end

      end
      return cola_rutas;
    endfunction

    //La siguiente funcion se encarga de verificar la ruta correcta seguida por el paquete
    function bit VerificarRuta(bit[pckg_sz-1:0] paquete=0, bit [7:0] id=0);
      bit [ancho-9:0] auxiliar;
      bit [10:0] id_aux;
      auxiliar = paquete[ancho-9:0];
      if(this.assoc_queue.exists (auxiliar)) begin // se mira si la transaccion/paquete existe en el arreglo asociativo de colas
        
        // foreach (this.assoc_queue[auxiliar][i]) begin // se recorre la ruta 
        //   id_aux = this.assoc_queue[auxiliar][i]; // se saca un id de la ruta
        //   if (id == id_aux[9:2]) begin // si el id que recibe la transaccion esta en la ruta
        //     this.assoc_queue[auxiliar].delete(i);
        //     return 1;
        //   end
        // end

        id_aux = this.assoc_queue[auxiliar].pop_front(); 
        if (id == id_aux[9:2]) begin // si el id que recibe la transaccion esta en la ruta (debe ir en orden), va por buen camino 
            `ifdef DEBUG2
            $display("[%g] Checker: Paquete: %h, ID_Recibido: %h, ID_Esperado:%h -> Ruta Correcta",$time,paquete,id,id_aux[9:2]);
            `endif 
            if (this.assoc_queue[auxiliar].size() == 0) begin // si se vacia la cola
              $display("[%g] Checker: El Paquete: %h ha llegado a su destino por la ruta correcta",$time,paquete);
              this.assoc_queue.delete(auxiliar); // se elimina el index del arreglo
            end
            return 1;
        end else begin // si no recibe en orden correcto, la transaccion no va bien y se imprime 
            `ifdef DEBUG2
            $display("[%g] Checker Warning: Paquete: %h, ID_Recibido: %h, ID_Esperado:%h -> Ruta Incorrecta",$time,paquete,id,id_aux[9:2]);
            `endif 
         // this.assoc_queue[auxiliar].push_front(id_aux); 
            if (this.assoc_queue[auxiliar].size() == 0) begin // si se vacia la cola y no llega por la ruta correcta
              $display("[%g] Checker: El Paquete: %h ha llegado a su destino por la ruta incorrecta",$time,paquete);
              this.assoc_queue.delete(auxiliar); // se elimina el index del arreglo
            end
            return 0;
        end
      end else begin
        $display("[%g] Checker Error: el Paquete: %h recibido en ID: %h nunca fue generado",$time,paquete,id);
        return 0;
      end

    endfunction

endclass //checker
