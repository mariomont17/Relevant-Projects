`timescale 1ns / 1ps

module reg_bank_tb;
      parameter W=16;
      parameter N=5;

    // Señales de prueba
    logic              clk=0;
    logic              reset=0;
    logic              we=0;
    logic  [2**N-1:0]  addr_rd=0;
    logic  [2**N-1:0]  addr_rs1=0;
    logic  [2**N-1:0]  addr_rs2=0;
    logic  [W-1:0]     data_in=0;
    logic  [W-1:0]     rs1=5;
    logic  [W-1:0]     rs2=0;

    // Instanciación del módulo a probar
    reg_bank #(.N(N), .W(W)) dut(
        .clk         (clk),
        .reset       (reset),
        .we          (we),
        .addr_rd     (addr_rd),
        .addr_rs1    (addr_rs1),
        .addr_rs2    (addr_rs2),
        .data_in     (data_in),
        .rs1         (rs1),
        .rs2         (rs2)
    );

    initial begin
        
        clk = 1;
        forever #50 clk = ~clk;
         
        $finish;
    end
    
                       
 always @ (posedge clk) begin;
    test1(); 
 end
    
          
          
task test1 ();
        
        begin
            #100;
            we        =   1;
            data_in   =   {$random}%36654;
            addr_rd   =   addr_rd + 1'b1;
            addr_rs1 <=   addr_rd==0 ;
            addr_rs2 <=   addr_rd - 1;
            
            #100;
            we       <=   0;
               
        end
endtask


endmodule

