module module_Reloj (
    input  logic clk,      // Se�al de reloj 100 MHz
    output logic clk_10m,  // Se�al de reloj 10 MHz
    output logic locked    // Se�al de reset
);
     clk_wiz_0 instance_name (
     
    // Clock out ports
    .clk_out1(clk_10m),     // Output clk_out1
    
    // Status and control signals
    .locked(locked),       // Output locked
    
   // Clock in ports
    .clk_in1(clk)          // Clock 100 MHz
    );

endmodule
