module top_teclado_calcu (
    input  logic    clk_10m,             // Señal de reloj 10 MHz
    input  logic    reset,           // Señal de reset
    input  logic    F0,              // Pin del teclado de la fila 0
    input  logic    F1,              // Pin del teclado de la fila 1
    input  logic    F2,              // Pin del teclado de la fila 2
    input  logic    F3,              // Pin del teclado de la fila 3
    input  logic    A,               // MSB de salida del codificador A
    input  logic    B,               // LSB de salida del codificador B
    output logic    C0,              // LSB de salida del decodificador
    output logic    C1,              // MSB de salida del decodificador
    output logic    [3:0] Bits,      // Salida del teclado
    output logic    LED_Verif        // Verificación de tecla presionada
);

    logic VerificarTecla;         // Señal que indica si se está presionando una tecla
    logic AR1;                    // Señal con antirebote para fila 0
    logic AR2;                    // Señal con antirebote para fila 1
    logic AR3;                    // Señal con antirebote para fila 2
    logic AR4;                    // Señal con antirebote para fila 3
    logic [3:0] KeyEncoder;       // Datos de entrada del codificador de tecla
    
    // Antirebote para bit F0
    module_Antirebote ARF0(
    .clk   (clk_10m),
    .reset (reset),
    .btn   (F0),
    .Q     (AR1)
    );
    
    // Antirebote para bit F1
    module_Antirebote ARF1(
    .clk   (clk_10m),
    .reset (reset),
    .btn   (F1),
    .Q     (AR2)
    );
    
    // Antirebote para bit F2
    module_Antirebote ARF2(
    .clk   (clk_10m),
    .reset (reset),
    .btn   (F2),
    .Q     (AR3)
    );
    
    // Antirebote para bit F3
    module_Antirebote ARF3(
    .clk   (clk_10m),
    .reset (reset),
    .btn   (F3),
    .Q     (AR4)
    );

    // Contador de 2 Bits
    module_Contador_2_Bits Conta2Bits(
    .clk      (clk_10m),
    .reset    (reset),
    .en       (VerificarTecla),
    .contador ({C1,C0})
    );
    
    // Verificar Tecla
    module_VerificadorTecla CheckKey(
    .F0 (AR1),
    .F1 (AR2),
    .F2 (AR3),
    .F3 (AR4),
    .V  (VerificarTecla)
    );
    
    // Codificador de tecla
    module_TecladoCodif SalidaKeyEncoder(
    .in (KeyEncoder),
    .out (Bits)
    );
    
    always_ff @(posedge clk_10m) begin   // En el flanco positivo de reloj de 10 MHz...
        LED_Verif <= VerificarTecla;     // Actualizar el LED de verificación
        if (!reset) begin                // Si el reset (locked) es 0...
            KeyEncoder[3] <= 0;          // Los datos de entrada para codificador de tecla son 0
            KeyEncoder[2] <= 0;
            KeyEncoder[1] <= 0;
            KeyEncoder[0] <= 0;
        end else begin                   // Si ese no es el caso...
            if (VerificarTecla) begin    // Si se está presionando 
                KeyEncoder[3] <= C1;     // Se toma el valor actual MSB de entrada del decodificador
                KeyEncoder[2] <= C0;     // Se toma el valor actual LSB de entrada del decodificador
                KeyEncoder[1] <= A;      // Se toma el valor actual MSB de entrada del codificador
                KeyEncoder[0] <= B;      // Se toma el valor actual LSB de entrada del codificador
            end
        end
     end
           
endmodule