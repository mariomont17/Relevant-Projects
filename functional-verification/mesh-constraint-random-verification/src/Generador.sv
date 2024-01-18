//////////////////////////////////////////////////////////////////////////////////////////////////////
// Generador: Se encarga de generar las transacciones con base en los escenarios que ordene el Test //
//////////////////////////////////////////////////////////////////////////////////////////////////////

 class generador  #(parameter filas = 4, parameter columnas =4, parameter ancho =40, parameter profundidad = 4, parameter broadcast = {8{1'b1}});
 trans_router_mbx gen_agnt_mbx; // mailbox del generador al agente
 test_genr_mbx test_gen_mbx; // mailbox del test al generador
 int num_transacciones = 15;  // cantidad de transacciones aleatorias
 int retardo_max = 10; // retardo maximo por defecto de 10 ciclos del reloj
 int trans_x_terminal = profundidad; // transacciones por terminal por defecto igual a profundidad de FIFO's

 // para el caso específico
 int retardo_espec; // retardo especifico
 bit [3:0] row_espec; // fila especifica
 bit [3:0] colum_espec; // columna especifica
 bit mode_espec; // modo especifico
 bit [ancho-17:0] pyld_espec; // payload especifico
 int term_envio_espec; // terminal desde la que se envia el paquete especifico
 
 // para las instrucciones del generador
 instruccion_generador instruccion;
 trans_router #(.ancho(ancho)) transaction;

 function new(); //Establece el numero de transacciones y retardo maximo
     num_transacciones = 15;
     retardo_max = 10;  
 endfunction

 task run();
     $display("[%g] El Generador fue inicializado",$time); 
     forever begin
         #5
         if (test_gen_mbx.num() > 0) begin
             $display("[%g]  Generador: ha recibido una instrucción",$time);
             test_gen_mbx.get(instruccion);
             $display("[%g]  Generador Instrucción: %s",$time, instruccion);
             case (instruccion)
                 trans_aleatoria: begin // una sola transaccion aleatoria desde un terminal especifico
                     for (int i=0; i<1; i++) begin
                         transaction = new(); //Creacion de una transaccion.
                         transaction.retardo_max = retardo_max; //Se iguala el retardo maximo
                         transaction.randomize(); //Randomiza los argumentos del paquete
                         transaction.term_envio = term_envio_espec; //Se le indica desde que terminal debe enviar el dato
                         transaction.GetSrcAndId(); //Se genera el id fuente y el id del monitor desde donde se enviara el dato.
                         transaction.BuildPackage(); //Une el paquete 
                         transaction.term_dest(); //Transforma el id de filas y columnas en un numero entero

                         if (transaction.term_envio != transaction.term_recibido) begin //Primero revisa que no se este enviando a si mismo
                             transaction.print("Generador: transacción creada");
                             gen_agnt_mbx.put(transaction); //Pone la transaccion en el mailbox
                         end else begin
                             i--;
                         end
                     end
                 end
                 trans_especifica: begin //para enviar una transaccion especifica y probar los casos de esquina
                     transaction = new();
                     transaction.retardo = retardo_espec;
                     transaction.row = row_espec; //Establece una fila especifica
                     transaction.colum = colum_espec; //Establece una columna especifica
                     transaction.mode = mode_espec; //Establece un modo especifico
                     transaction.payload = pyld_espec; //Establece un payload especifico
                     transaction.term_envio = term_envio_espec; //Establece una terminal de envio especifico
                     transaction.GetSrcAndId(); //Genera el id fuente y de router
                     transaction.BuildPackage(); //Une el paquete 
                     transaction.term_dest(); //Traduce la terminal de destino en un numero entero
                     transaction.print("Generador: transacción creada");
                     gen_agnt_mbx.put(transaction);
                 end
                 
                 sec_trans_aleatorias: begin //Una seccion de transacciones aleatorias

                     for(int i = 0; i < num_transacciones; i++) begin
                         transaction = new(); //Crea la transaccion
                         transaction.retardo_max = retardo_max; //Establece el retardo maximo
                         transaction.randomize(); //Randomiza las variables de la transaccion
                         transaction.GetSrcAndId(); //Genera el id source y del router desde donde se enviara el paquete 
                         transaction.BuildPackage(); //Une el paquete 
                         transaction.term_dest(); //Genera la terminal de destino

                         if (transaction.term_envio != transaction.term_recibido) begin //Verifica que no se envie a si mismo
                             transaction.print("Generador: transacción creada");
                             gen_agnt_mbx.put(transaction);
                         end else begin
                             i--;
                         end
                     end
                 end

                 trans_aleat_x_terminal: begin // seccion de transacciones aleatorias, especificando la cantidad de transacciones por terminal (todas envían datos)
                     for (int i = 0; i < (filas*2+columnas*2) ; i++) begin // i = indice de terminal					
                        
                       for (int j = 0; j < trans_x_terminal; j++) begin// j = indice de cantidad de transacciones por terminal
                             transaction = new(); //Crea la transaccion
                             transaction.retardo_max = retardo_max; //Le pone el retardo maximo
                             transaction.randomize(); //Randomiza los valores de la transaccion
                             transaction.term_envio = i; //Le indida desde cual terminal enviar el paquete 
                             transaction.GetSrcAndId(); //Genera el id source y de router que enviara el dato
                             transaction.BuildPackage(); //Une el paquete
                             transaction.term_dest(); //Obtiene la terminal de destino
                             if (transaction.term_envio != transaction.term_recibido) begin // para evitar enviar datos a sí mismo
                                 transaction.print("Generador: transacción creada");
                                 gen_agnt_mbx.put(transaction);
                             end else begin
                                 j = j - 1;
                             end
                         end
                     end
                 end

                 todas_a_todas: begin // Envio de todas las terminales a todas las terminales con paquete aleatorio
                    for (int i = 0; i < (filas*2+columnas*2); i=i+1) begin // i = índice de terminal que envia
                        for (int j = 0; j < 1; j=j+1) begin // j = índice de cantidad de transacciones por terminal
                            for (int k = 0; k < 16; k++ ) begin // k = índice del terminal al que se le va a enviar
                                transaction = new(); //Genera una nueva transaccion.
                                transaction.mode = $random; //Modo aleatorio
                                transaction.payload = $urandom; //Payload aleatorio que no se puede repetir
                                transaction.retardo = $urandom_range(0,retardo_max); //Retardo aleatorio en un rango especifico
                                transaction.term_a_enviar(k); //Se le indica a que terminal enviara el dato
                                transaction.term_envio = i; //Se le indica desde donde se enviara el dato
                                transaction.GetSrcAndId(); //Se genera el id source y de router que enviara el dato
                                transaction.BuildPackage(); //Une el paquete
                                transaction.term_dest(); //Guarda el valor de la terminal de destino
                            if (transaction.term_envio != transaction.term_recibido) begin // para evitar enviar datos a sí mismo
                                transaction.print("Generador: transacción creada");
                                gen_agnt_mbx.put(transaction);
                            end
                        end
                        end
                    end
                end 

                todas_a_todas_mode_esp: begin // Envio de todas las terminales a todas las terminales con un modo especifico
                    for (int i = 0; i < (filas*2+columnas*2); i=i+1) begin // i = índice de terminal que envia
                        for (int j = 0; j < 1; j=j+1) begin // j = índice de cantidad de transacciones por terminal
                            for (int k = 0; k < 16; k++ ) begin // k = índice del terminal al que se le va a enviar

                                transaction = new(); //Nueva transacciin
                                transaction.mode = mode_espec; //Se establece el modo especifico
                                transaction.payload = $urandom; //Payload aleatorio sin repetir
                                transaction.retardo = $urandom_range(0,retardo_max); //Retardo aleatorio en un rango determinado
                                transaction.term_a_enviar(k); //Terminal a la que se enviara el dato
                                transaction.term_envio = i; //Terminal desde donde se enviara
                                transaction.GetSrcAndId(); //Se obtien el id del source y el router que enviara el dato
                                transaction.BuildPackage(); //Une el paquete 
                                transaction.term_dest(); //Obtiene la terminal de destino
                            if (transaction.term_envio != transaction.term_recibido) begin // para evitar enviar datos a sí mismo
                                transaction.print("Generador: transacción creada");
                                gen_agnt_mbx.put(transaction);
                            end
                        end
                        end
                    end
                end
                una_a_todas: begin // Envio de una terminal especifico a todas las demas terminales
                    for (int i = 0; i < (filas*2+columnas*2); i=i+1) begin // i = índice de terminal
                        for (int j = 0; j < 1; j=j+1) begin // j = índice de cantidad de transacciones por terminal

                                transaction = new(); //Nueva transaccion
                                transaction.mode = $random; //Modo aleatorio
                                transaction.payload = $urandom; //Payload aleatorio sin repetir
                                transaction.retardo = $urandom_range(0,retardo_max); // Retardo aleatorio en un rango determinado
                                transaction.term_a_enviar(i); //se le indica la termial a la que se le enviara el dato
                                transaction.term_envio = term_envio_espec; //se indica especificamente desde donde se enviara
                                transaction.GetSrcAndId(); //Se obtiene el id source y del router desde donde se enviara el dato
                                transaction.BuildPackage(); //Une el paquete 
                                transaction.term_dest(); //Determina el destino del paquete.
                            if (transaction.term_envio != transaction.term_recibido) begin // para evitar enviar datos a sí mismo
                                transaction.print("Generador: transacción creada");
                                gen_agnt_mbx.put(transaction);
                            end
                        end
                        end
                end

                llenar_fifos: begin // seccion de transacciones aleatorias con retardo 0  para llenar las fifos
                 for (int i = 0; i < 16 ; i++) begin // i = indice de terminal
                   for (int j = 0; j < profundidad; j++) begin// j = indice de cantidad de transacciones por terminal
                                transaction = new(); //Nueva transaccion
                                transaction.retardo_max = 0; //Retardo 0
                                transaction.randomize(); //Randomiza el paquete
                                transaction.term_envio = i; //Terminal la cual se va a llenar 
                                transaction.GetSrcAndId(); //Se obtiene el id source y del router que enviara el dato
                             	transaction.BuildPackage(); //Se une el paquete
                             	transaction.term_dest(); //Se obtiene el id de destino
                               if (transaction.term_envio != transaction.term_recibido) begin // para evitar enviar datos a sí mismo
                                   transaction.print("Generador: transacción creada");
                                   gen_agnt_mbx.put(transaction);
                               end else begin
                                   j = j - 1;
                               end
                            end
                        end
                end
                 default: begin
                     $display("[%g] Generador Error: la instrucción recibida no tiene tipo válido", $time);
                     $finish;
                 end
             endcase
 
         end

     end   
         
 endtask

endclass