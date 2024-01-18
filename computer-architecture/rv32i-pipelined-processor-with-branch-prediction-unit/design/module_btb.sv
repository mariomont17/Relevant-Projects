module BTB (
    input logic clk,
    input logic rst,
    input logic [31:0] PCF_o, // entrada del PC (salida del pcmux), para leer la cache
    input logic [31:0] PCE, // puntero para escribir en la caché, viene desde execute stage
    input logic [31:0] instruction_address, // instrucción a guardar en el BTB, target address, calculada en execute stage
    input logic branch_taken, // entrada de branch tomado o no tomado (PCSrcE)
    input logic write_enable, // write enable para escribir en el BTB, se obtiene de la etapa de ejecución con una OR de JumpE con BranchE
    output logic prediction_o, // bit de taken or not taken (MSB del contador de 2 bits)
    output logic hit_or_miss, // bit de hit or miss
    output logic [31:0] target_address_o // direccion de salto guardada en el BTB
);

logic [31:0] [31:0] btb_target ;  // Target address for each entry
logic [31:0] [1:0] btb_counter ;  // 2-bit counter for each entry
logic [31:0] [0:0] btb_valid ;    // Validation bit for each entry
logic [4:0] index;                  // indice de lectura
logic [4:0] index_escritura;        // indice de escritura en la cache

always_ff @(negedge clk or posedge rst) begin
    if (rst) begin // reset asincrono
        // valores default
        btb_target <= 0;
        btb_counter <= 2'b00; // Initialize counters to "Weakly Not Taken"
        btb_valid <= 0;
    end else if (write_enable) begin
        // Actualizar el BTB según la dirección de salto
        btb_target[index_escritura] <= instruction_address; // guarda la direccion de salto en el BTB
        btb_valid[index_escritura] <= 1'b1; // Pone el bit de validez de ese index en 1

        // Actualiza el contador de 2 bits basado en taken or not taken de la etapa de ejecucion
        if (branch_taken) begin 
            if (btb_counter[index_escritura] < 2'b11)
                btb_counter[index_escritura] <= btb_counter[index_escritura] + 1'b1;
        end else begin
            if (btb_counter[index_escritura] > 2'b00)
                btb_counter[index_escritura] <= btb_counter[index_escritura] - 1'b1;
        end
    end
end

always_comb begin // logica de salida del BTB
    // Check if the index corresponds to the instruction address
    if (btb_valid[index]) begin
        // Predict based on the counter value
        if (btb_counter[index] == 2'b11 || btb_counter[index] == 2'b10)
            prediction_o = 1'b1; // Strongly Taken or Weakly Taken
        else
            prediction_o = 1'b0; // Strongly Not Taken or Weakly Not Taken

        hit_or_miss = 1'b1; // Hit
        target_address_o = btb_target[index];

    end else begin
        prediction_o = 1'b0; // Default prediction
        hit_or_miss = 1'b0; // Miss
        target_address_o = 32'b0; // Default target address   
    end
end

assign index = PCF_o    [6:2];
assign index_escritura = PCE[6:2];

endmodule
