////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Scoreboard: Se encarga de generar los reportes de retardos, anchos de banda y listado de transacciones completadas //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class scoreboard#(parameter filas = 4, parameter columnas =4, parameter ancho =40, parameter profundidad = 4, parameter broadcast = {8{1'b1}});
 
tst_scb_mbx test_scb_mbx; // Mailbox del Test con el Scoreboard
checker_scb_mbx chckr_scb_mbx; // Mailbox Checker con el Scoreboard

trans_sb #(.ancho(ancho)) transaccion_entrante; // Objeto de transaccion proveniente del Checker
trans_sb #(.ancho(ancho)) trans_completas[$]; // Queue de las transacciones completadas
trans_sb #(.ancho(ancho)) trans_incompletas[$]; // Queue de las transacciones NO completadas
trans_sb #(.ancho(ancho)) transaccion_auxiliar; // se usa para guardar una transaccion del queue principal para su posterior manipulación 
trans_sb #(.ancho(ancho)) auxiliar_array[$]; // queue que se usa para guardar el queue principal del scoreboard y no perder las transacciones al hacer pop

int retraso_total = 0; // Retraso total en las transacciones hechas 
int retraso_x_terminal [filas*2+columnas*2]; // Retraso por cada terminal
int transacciones_completadas = 0; // cantidad de transacciones total completadas
int transacciones_completadas_x_terminal [filas*2+columnas*2]; // cantidad de transacciones por terminal 
shortreal retardo_promedio_gen; // Retardo promedio de la prueba

int tamano_sb = 0; 
shortreal retardo_promedio_x_terminal [filas*2+columnas*2]; // array con retardos promedio por cada terminal
reporte_scb orden; // orden recibida desde el Test

// Variables para el calculo del ancho de banda
shortreal tasa_array [$];
shortreal ab_min;
shortreal ab_max;
shortreal ab_prom;

//Para los .csv
int report;
int bw_prom;
int bw_max;
int bw_min;
int reporte_retardo_prom;

function new();
    trans_completas = {};
    auxiliar_array = {};
endfunction

task run();
    $display("[%g] El Scoreboard fue inicializado",$time);
    forever begin
        #50
        if (chckr_scb_mbx.num()>0) begin //Revisa si hay transacciones provenientes del checker
            chckr_scb_mbx.get(transaccion_entrante);
            `ifdef DEBUG2
            transaccion_entrante.print("Score Board: transacción recibida desde el checker");
            `endif
            if (transaccion_entrante.completado) begin // Si la transaccion se completó entonces calcula el retraso total
                retraso_total = retraso_total + transaccion_entrante.latencia;
                retraso_x_terminal[transaccion_entrante.term_rx] = retraso_x_terminal[transaccion_entrante.term_rx] + transaccion_entrante.latencia;
                transacciones_completadas++;
                transacciones_completadas_x_terminal[transaccion_entrante.term_rx]++;
                trans_completas.push_back(transaccion_entrante);
            end else begin
                trans_incompletas.push_back(transaccion_entrante); // Si no se completó se guarda en el queue de transacciones incompletas
            end
            
        end else begin
            if (test_scb_mbx.num()>0) begin //Revisa si hay alguna instruccion desde el Test
                test_scb_mbx.get(orden);
                $display("Scoreboard: Instrucción Recibida desde el Test");
                case(orden)
                    retardo_general: begin // Instruccion para ver retardo promedio general de la prueba
                        $display("Scoreboard: Instruccion --> Retardo promedio general");
                        retardo_promedio_gen = retraso_total/transacciones_completadas;
                        $display("[%g] Scoreboard: el retardo promedio general es de: %0.2f ns", $time, retardo_promedio_gen);

                        reporte_retardo_prom = $fopen("reporte_retardo_prom.csv", "a"); // se imprime en csv el retardo promedio de la transmisión
                        `ifdef DEBUG2
                        $fwrite(reporte_retardo_prom, "Dispositivos,Profundidad,Retardo\n");
                        `endif 
                        $fwrite(reporte_retardo_prom, "%0d,%0d,%0.2f\n", filas*2+columnas*2, profundidad, retardo_promedio_gen);
                        $fclose(reporte_retardo_prom);

                        for (int i = 0; i < (filas*2+columnas*2); i++) begin // ciclo for para calcular el retardo promedio por cada terminal
                            retardo_promedio_x_terminal[i] = retraso_x_terminal[i]/transacciones_completadas_x_terminal[i];
                            $display("[%g] Scoreboard: el retardo promedio en la terminal %g es: %0.2f ns", $time, i, retardo_promedio_x_terminal[i]);
                        end

                    end
                    reporte_transacciones: begin // Reporte de las transacciones realizadas 
                        $display("Scoreboard: Instruccion --> Reporte csv de paquetes enviados y recibidos");
                        report = $fopen("report.csv", "w");
                        $fwrite(report, "Dispositivos,Profundidad,Paquete_Enviado,Paquete_Recibido,Tiempo_Envio,Tiempo_Recibido,Terminal_de_Envio,Terminal_de_recibido,Latencia\n");

                        tamano_sb = this.trans_completas.size();
                        for(int i=0;i<tamano_sb;i++) begin
                            transaccion_auxiliar = trans_completas.pop_front();
                            transaccion_auxiliar.print("Scoreboard Reporte:");
                            $fwrite(report, "%0d, %0d, %0h, %0h, %0g, %0g, %g, %g, %g\n", filas*2+columnas*2, profundidad, transaccion_auxiliar.paquete_enviado, transaccion_auxiliar.paquete_recibido, 
                            transaccion_auxiliar.tiempo_envio, transaccion_auxiliar.tiempo_recibido, transaccion_auxiliar.term_tx, transaccion_auxiliar.term_rx,
                             transaccion_auxiliar.latencia);
                            auxiliar_array.push_back(transaccion_auxiliar);
                        end
                        $fclose(report);
                       trans_completas = auxiliar_array;
                    end
                    reporte_ancho_banda: begin // Reporte del ancho de banda mininimo, maximo y promedio
                        $display("Scoreboard: Instruccion --> Reporte de ancho de banda");

                        foreach(trans_completas[i]) begin  // Para cada transaccion completada, guarda la tasa de bits correspondiente en un arreglo
                        tasa_array[i] = ancho/((trans_completas[i].latencia)*0.000_000_001);    // se calcula la tasa de bits de cada transacción, tasa = bits del paquete/latencia en segundos
                        end 

                        tasa_array.sort(); //Ordena de mayor a menor
                        tamano_sb = this.trans_completas.size();
                        ab_max = (tasa_array[$])/1_000_000;
                        ab_min = (tasa_array[0])/1_000_000;
                        ab_prom = (tasa_array.sum()/tamano_sb)/1_000_000;

                        $display("Ancho de banda máximo: %0.2f kbps", ab_max); // Los que toman menos tiempo de retardo
                        $display("Ancho de banda mínimo: %0.2f kbps", ab_min); // Los que toman mas tiempo de retardo 
                        $display("Ancho de banda promedio: %0.2f kbps", ab_prom); // Promedio

                        bw_prom = $fopen("reporte_bw_prom.csv", "a");
                        bw_max = $fopen("reporte_bw_max.csv", "a");
                        bw_min = $fopen("reporte_bw_min.csv", "a");

                        `ifdef DEBUG2
                            $fwrite(bw_prom, "Terminales,Profundidad,Ancho_de_Banda\n");
                        `endif 
                        $fwrite(bw_max, "%0d,%0d,%0.2f\n", filas*2+columnas*2, profundidad,  ab_max);
                        $fwrite(bw_min, "%0d,%0d,%0.2f\n", filas*2+columnas*2, profundidad, ab_min);
                        $fwrite(bw_prom, "%0d,%0d,%0.2f\n", filas*2+columnas*2, profundidad, ab_prom);
                        $fclose(bw_prom);
                        $fclose(bw_max);
                        $fclose(bw_min);

                    end
                    reporte_trans_inc: begin // Reporte de las transacciones sin completar debido a su ID inválido (envios a terminales inexistentes o al mismo terminal)
                        $display("Scoreboard: Instruccion ---> Reporte de transacciones sin completar/ con errores");
                        tamano_sb = this.trans_incompletas.size();
                        for(int i=0;i<tamano_sb;i++) begin
                            transaccion_auxiliar = trans_incompletas.pop_front();
                            transaccion_auxiliar.print("Scorboard Reporte transacciones incompletas:");
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