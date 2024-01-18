//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Este modulo tiene como fin aleatorizar la cantidad de terminales y profundidad de las FIFOs de la prueba //
// genera un package con los respectivos valores aleatorios para que puedan ser usados en el testbench      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module param_gen;

    class param_randomizer;

        rand int unsigned TERMINALES;
        rand int unsigned PROFUNDIDAD;

        constraint control_ { 
                        TERMINALES inside { [4:32] };
                        PROFUNDIDAD inside { [10:32] };
        }

        function void printPackage;
            int f = $fopen("parameters_pkg.sv");
            $fdisplay(f, "package params_pkg;");
            $fdisplay(f, "  parameter TERMINALES = %0d;",TERMINALES);
            $fdisplay(f, "  parameter PROFUNDIDAD = %0d;",PROFUNDIDAD);
            $fdisplay(f, "endpackage");
        endfunction
    endclass

    param_randomizer my_class;
    initial begin
        my_class = new();
        my_class.randomize();
        my_class.printPackage();
    end
endmodule