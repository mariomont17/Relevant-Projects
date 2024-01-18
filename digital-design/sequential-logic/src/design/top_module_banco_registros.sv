



module top_module_banco_registros #(

    parameter W = 7,
    parameter N = 4


)(
    input  logic                clk, 
    input  logic                reset, 
    input  logic                we,                            
    input  logic [N-1:0]        addr_rs1, 
    input  logic [N-1:0]        addr_rs2,
    input  logic [N-1:0]        addr_rd,  
    input  logic [W-1:0]        data_in,                            
    output logic [W-1:0]        rs1, 
    output logic [W-1:0]        rs2
);
    logic clk_10MHz;

clk_wiz_0 instance_name
    (
        .clk_out1(clk_10MHz),
        .clk_in1(clk)
        );
        
        
reg_bank #(
        .W(W),
        .N(N)
        )DUT
(
        .clk         (clk_10MHz),
        .reset       (reset),
        .we          (we),
        .addr_rs1    (addr_rs1),
        .addr_rs2    (addr_rs2),
        .addr_rd     (addr_rd),
        .data_in     (data_in),
        .rs1         (rs1),
        .rs2         (rs2)
        );
        
endmodule
