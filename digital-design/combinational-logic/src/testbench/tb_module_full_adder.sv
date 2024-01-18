`timescale 10ns / 10ps

module tb_module_full_adder;
   
    logic  A;
    logic  B;
    logic  Cin;
    logic  S;
    logic  Cout;
    
module_full_adder  dut(

    .A     (A),
    .B     (B),
    .Cin   (Cin),
    .S     (S),
    .Cout  (Cout)


);
  
 initial begin
   A    = 0;
   B    = 0;
   Cin  = 0;
   #10;
   A    = 0;
   B    = 0;
   Cin  = 1;
   #10;  
   A    = 0;
   B    = 1;
   Cin  = 0;
   #10;
   A    = 0;
   B    = 1;
   Cin  = 1;
   #10;
   A    = 1;
   B    = 0;
   Cin  = 0;
   #10;
   A    = 1;
   B    = 0;
   Cin  = 1;
   #10;
   A    = 1;
   B    = 1;
   Cin  = 0;
   #10;  
   A    = 1;
   B    = 1;
   Cin  = 1;
   #10;
   $finish;
end
   
endmodule
