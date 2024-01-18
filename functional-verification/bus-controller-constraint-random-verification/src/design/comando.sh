source /mnt/vol_NFS_rh003/estudiantes/archivos_config/synopsys_tools.sh;

# Para variar la cantidad de terminales y profundidad de las FIFOS se debe escoger una semilla. Lo que permite variar la aleatorizacion del modulo "module_params.sv"
 
# Sin embargo, La prueba del DUT se corre siempre con la misma semilla (default)

read -p "Enter seed number (1,2,3,4,5,10,22): " SEED

vcs -Mupdate module_params.sv -o salida_params -full64 -sverilog  -kdb -lca -debug_acc+all -debug_region+cell+encrypt -l log_test +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert;

./salida_params +ntb_random_seed=$SEED;

vcs -Mupdate Testbench.sv -o salida -full64 -sverilog  -kdb -lca -debug_acc+all -debug_region+cell+encrypt -l log_test +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert;

./salida -cm line+tgl+cond+fsm+branch+assert;








