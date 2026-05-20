`timescale 1ns/10ps

module branchingAdd (currentInstruction, branchedOutput, signExtended);

    output logic [63:0] branchedOutput;
    input  logic [63:0] currentInstruction;
    input  logic [63:0] signExtended;

    logic               zero, overflow, carry_out, negative;
    logic [63:0]        leftShiftOutput; 
    

    shifter duu (.value(signExtended), .direction(1'b0), .distance(6'd2), .result(leftShiftOutput));

    alu duu1 (.out(branchedOutput), .zero(zero), .overflow(overflow), .carry_out(carry_out), .negative(negative), .busA(currentInstruction), .busB(leftShiftOutput), .aluControl(3'b010));

endmodule

