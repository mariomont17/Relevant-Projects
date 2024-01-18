`timescale 1ns/1ps
`include "parameters_pkg.sv"

//`define DEBUG
//`define DEBUG2 // macro utilizada para debuggear el ambiente
`define DEBUG3 // macro utilizada para ver overflow y underfow

//Parametros
parameter filas = 4;
parameter columnas = 4;
parameter ancho = 40;
parameter profundidad = params_pkg::PROFUNDIDAD;
parameter broadcast = 8'hFF;


//Llamado de los archivos
`define FIFOS
`include "fifo.sv"
`include "Library.sv"
`define LIB 
`include "Router_library.sv"
`include "Interface_transactions.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "Checker.sv"
`include "Scoreboard.sv"
`include "Agente.sv"
`include "Generador.sv"
`include "Ambiente.sv"
`include "Test.sv"

`include "assertions_test.sv" // archivo de aserciones
`include "functional_coverage.sv" // archivo de cobertura funcional

module testbench;

    reg clk;

    always #5 clk = ~clk;

    //Instancia del test
    test #(.filas(filas), .columnas(columnas), .ancho(ancho), .profundidad(profundidad), .broadcast(broadcast)) t0;

    //Instancia de la interface
    dut_if #(.ROWS(filas), .COLUMS(columnas), .pckg_sz(ancho), .fifo_depth(profundidad), .bdcst(broadcast)) _if (clk);

    //Instancia del DUT
    mesh_gnrtr #(.ROWS(filas), .COLUMS(columnas), .pckg_sz(ancho), .fifo_depth(profundidad), .bdcst(broadcast)) DUT (
        .clk            (clk),
        .reset          (_if.reset),
        .pndng          (_if.pndng),
        .data_out       (_if.data_out),
        .popin          (_if.popin),
        .pop            (_if.pop),
        .data_out_i_in  (_if.data_out_i_in),
        .pndng_i_in     (_if.pndng_i_in)
    );

    initial begin
        $dumpfile("prueba_router.vcd");
        $dumpvars(0);
        clk = 0;
        t0 = new(); //Inicializacion del test
        t0._if = _if; //Conexion de la interfaz al DUT
        t0.ambiente_inst._if = _if; //Conexion de la interfaz al ambiente

        //Corriendo el test
        fork
            t0.run();
        join_none
    end
    

    //Tiempo limite de simulacion.
    always@(posedge clk) begin
        if ($time > 2_000_000)begin
        $display("Test_bench: Tiempo límite de prueba en el test_bench alcanzado");
        $finish;
        end
    end
endmodule
