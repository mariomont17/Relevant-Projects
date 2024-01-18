module router_bus_coverage #(
    parameter pck_sz = 40,      //Tamaño del paquete
    parameter [7:0] ntrfs_id = 0,
    parameter id_c = 0, //Columna
    parameter id_r = 0, //Fila
    parameter rows= 4, 
    parameter columns=4
    )
    (
    input logic clk,
    input logic reset, 
    input logic pop,
    input logic popin, 
    input logic [pck_sz-1:0]data_out, // mensaje enviado en cada terminal
    input logic [pck_sz-1:0]data_out_i_in // mensaje recibido en terminal
    );

    bit [7:0] id= {id_r[3:0],id_c[3:0]};
  
  covergroup cg @(posedge popin);
        option.per_instance = 1;
        c1: coverpoint data_out_i_in[pck_sz-9:pck_sz-16] {   
                
                //Verifica que todos los routers reciban la mayor cantidad de IDs posibles (Fisicamente imposible que reciba todos)
                bins b1[] = {8'h01, 8'h02, 8'h03, 8'h04,
                        8'h10, 8'h20, 8'h30, 8'h40,
                        8'h51, 8'h52, 8'h53, 8'h54,
                        8'h15, 8'h25, 8'h35, 8'h45};

                //Ignora los que se envian a si mismos.
                ignore_bins b2 = {tst(ntrfs_id,id)};

                            }
    endgroup: cg
    
    //Funcion para determinar cual terminal de entrada ignorar dado el caso que el paquete se envie y reciba en una misma terminal
    function bit [7:0] tst (bit [7:0] terminal = 0, bit [7:0] id = 0); 
        bit [7:0] resultado = 8'h99;
        case (id)
            8'h11:  begin if (terminal==0) begin resultado = 8'h01; end
                            else if (terminal==3) begin resultado = 8'h10; end
                    end
            8'h12:  begin if (terminal==0) begin resultado = 8'h02; end
                            
                    end
            8'h13:  begin if (terminal==0) begin resultado = 8'h03; end
                        
                    end 
            8'h14:  begin if (terminal==0) begin resultado = 8'h04; end
                            else if (terminal==1) begin resultado = 8'h15; end
                    end 
            8'h21:  begin if (terminal==3) begin resultado = 8'h20; end    
                    end 
            
            8'h24:  begin if (terminal==1) begin resultado = 8'h25; end

                    end 
            8'h31:  begin if (terminal==3) begin resultado = 8'h30; end
                    end 
            
            8'h34:  begin if (terminal==1) begin resultado = 8'h35; end
                    end 
            8'h41:  begin if (terminal==3) begin resultado = 8'h40; end
                            else if (terminal==2) begin resultado = 8'h51; end
                    end 
            8'h42:  begin if (terminal==2) begin resultado = 8'h52; end
                           
                    end 
            8'h43:  begin if (terminal==2) begin resultado = 8'h53; end
                            
                    end 
            8'h44:  begin if (terminal==2) begin resultado = 8'h54; end
                            else if (terminal==1) begin resultado = 8'h45; end
                    end
            default: resultado = 8'h99;                
        endcase
        return resultado;
    endfunction

    cg cover_inst = new();

    initial begin
        #1_000_000
      $display("Coverage = %0.2f %%, router: %h, term: %h",cover_inst.get_inst_coverage(),id, ntrfs_id );
    end

endmodule


//Se conecta el modulo de coverage con el modulo que maneja los routers 
bind router_bus_interface router_bus_coverage#(.pck_sz(pck_sz),.ntrfs_id(ntrfs_id),.id_c(id_c),.id_r(id_r),.rows(rows),.columns(columns)) cov1( .clk(clk), .reset(reset), .pop(pop), .popin(popin), .data_out(data_out), .data_out_i_in(data_out_i_in) );