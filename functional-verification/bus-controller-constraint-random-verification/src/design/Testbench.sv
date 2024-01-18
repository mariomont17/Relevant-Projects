`timescale 1ns/1ps

// `define DEBUG // macro utilizada para debuggear el ambiente

`include "parameters_pkg.sv"

parameter terminales = params_pkg::TERMINALES;
parameter profundidad = params_pkg::PROFUNDIDAD;

parameter bits = 1;
parameter ancho = 32;
parameter broadcast = 8'hFF;

`include "Library.sv"
`include "Interface_Transactions.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "Checker.sv"
`include "Scoreboard.sv"
`include "Agente.sv"
`include "Ambiente.sv"
`include "Test.sv"


module testbench;

    reg clk;

    always #5 clk = ~clk;

    test #(.ancho(ancho), .terminales(terminales), .broadcast(broadcast), .profundidad(profundidad)) t0;
    bus_if #(.bits(bits), .drvrs(terminales), .pckg_sz(ancho), .broadcast(broadcast)) _if (clk);

    bs_gnrtr_n_rbtr #(.bits(bits), .drvrs(terminales), .pckg_sz(ancho), .broadcast(broadcast)) DUT (
        .clk    (clk),
        .reset  (_if.reset),
        .pndng  (_if.pndng),
        .push   (_if.push),
        .pop    (_if.pop),
        .D_pop  (_if.D_pop),
        .D_push (_if.D_push)
    );

    initial begin
        $dumpfile("prueba_bus.vcd");
        $dumpvars(0, testbench, bs_gnrtr_n_rbtr);
        clk = 0;
        t0 = new();
        t0._if = _if;
        t0.ambiente_inst._if = _if;
        fork
            t0.run();
        join_none
    end
    
    always@(posedge clk) begin
        if ($time > 1_000_000)begin
        $display("Test_bench: Tiempo límite de prueba en el test_bench alcanzado");
        $finish;
        end
    end
endmodule