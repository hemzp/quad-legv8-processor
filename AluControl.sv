`timescale 1ns/10ps

module AluControl (ALUOp, aluControl);
    output logic [2:0]  aluControl;
    input  logic [1:0]  ALUOp;
    always_comb begin 
        casez(ALUOp)
            2'b00: aluControl = 3'b010; //ADD
            2'b01: aluControl = 3'b011; //SUB
            2'b11: aluControl = 3'b000; //bypass B
            default: aluControl = 3'b010;
        endcase
    end    
endmodule