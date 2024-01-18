# script utilizado para generar los datos para graficar

source /mnt/vol_NFS_rh003/estudiantes/archivos_config/synopsys_tools.sh;

for terminales in 4 8 16 24 32
do 
    for profundidad in 10 20 32
    do
        printf "package params_pkg;\n" > parameters_pkg.sv
        printf "  parameter TERMINALES = %d;\n" $terminales >> parameters_pkg.sv
        printf "  parameter PROFUNDIDAD = %d;\n" $profundidad >> parameters_pkg.sv
        printf "endpackage" >> parameters_pkg.sv

        vcs -Mupdate Testbench.sv -o salida -full64 -sverilog  -kdb -lca -debug_acc+all -debug_region+cell+encrypt -l log_test +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert;
        ./salida -cm line+tgl+cond+fsm+branch+assert;

    done
done
