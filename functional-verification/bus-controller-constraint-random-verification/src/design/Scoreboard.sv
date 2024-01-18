////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Scoreboard: Se encarga de generar los reportes de retardos, anchos de banda y listado de transacciones completadas //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class scoreboard #(parameter ancho=16, parameter terminales = 4, parameter broadcast = {8{1'b1}});

    tst_scb_mbx test_scb_mbx;
    checker_scb_mbx chckr_scb_mbx;
    
    trans_sb #(.ancho(ancho)) transaccion_entrante; // transaccion proveniente del Checker, se usa para revisar si se completoó o no la transacción
    trans_sb #(.ancho(ancho)) transaccion_auxiliar; // se usa para guardar una transaccion del queue principal para su posterior manipulación
    trans_sb #(.ancho(ancho)) score_board[$]; // queue principal, maneja todas las transacciones completadas 
    trans_sb #(.ancho(ancho)) auxiliar_array[$]; // queue que se usa para guardar el queue principal del scoreboard y no perder las transacciones al hacer pop
    trans_sb #(.ancho(ancho)) trans_incompletas[$];

    int depth = 10; // parametro que indica la profundidad de las FIFOs

    int tamano_sb = 0; 
    shortreal retardo_promedio; // variable que indica el retardo promedio de la prueba
    shortreal retardo_promedio_x_terminal [terminales]; // array con retardos promedio por cada terminal
    reporte_scb orden; // orden recibida desde el Test
    int retardo_total = 0; // retardo total
    int retardo_x_terminal [terminales]; // retardo por cada terminal
    int transacciones_completadas =0; // cantidad de transacciones total
    int transacciones_completadas_x_terminal [terminales]; // cantidad de transacciones por terminal 

    shortreal tasa_array [1024];
    shortreal tasa_prom[$];
    shortreal tasa_max[$];
    shortreal tasa_min[$];

    int report;
    int bw_prom;
    int bw_max;
    int bw_min;
    int reporte_retardo_prom;

    function new();
        score_board = {};
        auxiliar_array = {};
    endfunction

    task run();
        $display("[%g] El Scoreboard fue inicializado",$time);
        forever begin
            #50
            if (chckr_scb_mbx.num()>0) begin
                chckr_scb_mbx.get(transaccion_entrante);
                transaccion_entrante.print("Score Board: transacción recibida desde el checker");
                if (transaccion_entrante.completado) begin
                    retardo_total = retardo_total + transaccion_entrante.latencia;
                    retardo_x_terminal[transaccion_entrante.term_rx] = retardo_x_terminal[transaccion_entrante.term_rx] + transaccion_entrante.latencia;
                    transacciones_completadas++;
                    transacciones_completadas_x_terminal[transaccion_entrante.term_rx]++;
                    score_board.push_back(transaccion_entrante);
                end else begin
                    trans_incompletas.push_back(transaccion_entrante);
                end
                
            end else begin
                if (test_scb_mbx.num()>0) begin
                    test_scb_mbx.get(orden);
                    $display("Scoreboard: Instrucción Recibida desde el Test");
                    case(orden)
                        retardo_general: begin
                            $display("Scoreboard: Retardo promedio");
                            retardo_promedio = retardo_total/transacciones_completadas; // se imprime en terminal el retardo promedio de la transmisión
                            $display("[%g] Scoreboard: el retardo promedio es: %0.2f ns", $time, retardo_promedio);

                            reporte_retardo_prom = $fopen("reporte_retardo_prom.csv", "a"); // se imprime en csv el retardo promedio de la transmisión
                            `ifdef DEBUG
                            $fwrite(reporte_retardo_prom, "Terminales,Profundidad,Retardo\n");
                            `endif 
                            $fwrite(reporte_retardo_prom, "%0d,%0d,%0.2f\n", terminales, depth, retardo_promedio);
                            $fclose(reporte_retardo_prom);

                            for (int i = 0; i < terminales; i++) begin // ciclo for para calcular el retardo promedio por cada terminal
                                retardo_promedio_x_terminal[i] = retardo_x_terminal[i]/transacciones_completadas_x_terminal[i];
                                $display("[%g] Scoreboard: el retardo promedio en la terminal %g es: %0.2f ns", $time, i, retardo_promedio_x_terminal[i]);
                            end

                        end
                        reporte_transacciones: begin
                            $display("Scoreboard: Reporte de transacciones completadas");
                            $display("Scoreboard: Enviada Recibida Tiempo_Env Tiempo_Rcbd Term_Env Term_Rcbd Latencia Estado");
                            report = $fopen("report.csv", "w");

                            $fwrite(report, "Terminales,Profundidad,Dato_Enviado,Dato_Recibido,Tiempo_Envio,Tiempo_Recibido,Term_Envio,Term_Recibido,Latencia\n");

                            tamano_sb = this.score_board.size();
                            for(int i=0;i<tamano_sb;i++) begin
                                transaccion_auxiliar = score_board.pop_front();
                                transaccion_auxiliar.print("SB_Report:");
                                $fwrite(report, "%0d, %0d, %0h, %0h, %0g, %0g, %g, %g, %g\n", terminales, depth, transaccion_auxiliar.paquete_enviado, transaccion_auxiliar.paquete_recibido, 
                                transaccion_auxiliar.tiempo_envio, transaccion_auxiliar.tiempo_recibido, transaccion_auxiliar.term_tx, transaccion_auxiliar.term_rx,
                                 transaccion_auxiliar.latencia);
                                auxiliar_array.push_back(transaccion_auxiliar);
                            end
                            $fclose(report);
                           score_board = auxiliar_array;
                        end
                        reporte_bw_prom: begin
                            $display("Scoreboard: Reporte de ancho de banda");

                            foreach(score_board[i]) begin
                              tasa_array[i] = (ancho*1_000_000)/(score_board[i].latencia);    // se calcula la tasa de bits de cada transacción, tasa = bits/latencia
                            end 
                            tamano_sb = this.score_board.size();
                            tasa_min[0] = ancho*1_000_000/score_board[$].latencia;
                            tasa_max[0] = ancho*1_000_000/score_board[0].latencia;

                            $display("Ancho de banda máximo: %0.2f kbps", tasa_max[0]);
                            $display("Ancho de banda mínimo: %0.2f kbps", tasa_min[0]);
                            $display("Ancho de banda promedio: %0.2f kbps", tasa_array.sum()/tamano_sb);

                            bw_prom = $fopen("reporte_bw_prom.csv", "a");
                            bw_max = $fopen("reporte_bw_max.csv", "a");
                            bw_min = $fopen("reporte_bw_min.csv", "a");

                            `ifdef DEBUG
                            $fwrite(bw_prom, "Terminales,Profundidad,Ancho_de_Banda\n");
                            `endif 
                            $fwrite(bw_max, "%0d,%0d,%0.2f\n", terminales, depth,  tasa_max[0]);
                            $fwrite(bw_min, "%0d,%0d,%0.2f\n", terminales, depth, tasa_min[0]);
                            $fwrite(bw_prom, "%0d,%0d,%0.2f\n", terminales, depth, tasa_array.sum()/tamano_sb);
                            $fclose(bw_prom);
                            $fclose(bw_max);
                            $fclose(bw_min);


                        end
                        reporte_trans_inc: begin // reporte de las transacciones sin completar debido a su ID inválido (envios a terminales inexistentes y al mismo terminal)
                            $display("Scoreboard: Reporte de transacciones sin completar");
                            $display("Scoreboard: Enviada Recibida Tiempo_Env Tiempo_Rcbd Term_Env Term_Rcbd Latencia Estado");
                            tamano_sb = this.trans_incompletas.size();
                            for(int i=0;i<tamano_sb;i++) begin
                                transaccion_auxiliar = trans_incompletas.pop_front();
                                transaccion_auxiliar.print("SB_Report:");
                                auxiliar_array.push_back(transaccion_auxiliar);
                            end
                            trans_incompletas = auxiliar_array;
                        end
                    endcase
                end
            end 
        end

    endtask

endclass