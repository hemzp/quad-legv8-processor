`timescale 1ns/10ps

module dedALU4 (currentInstruction, newInstruction);
    output logic [63:0] newInstruction;
    input  logic [63:0] currentInstruction;

    logic [61:0] carry_chain;

    assign newInstruction[0] = currentInstruction[0];
    assign newInstruction[1] = currentInstruction[1];

    halfAdder duu1 (.inA(currentInstruction[2]), .inB(1'b1), .c_out(carry_chain[0]), .sum(newInstruction[2]));


    genvar i;

    generate 
        for(i = 3; i < 64; i++) begin: eachHA
            halfAdder duu2 (.inA(currentInstruction[i]), .inB(carry_chain[i - 3]), .c_out(carry_chain[i - 2]), .sum(newInstruction[i]));
        end
    endgenerate

endmodule



module dedALU4_testbench();
    logic [63:0] currentInstruction, newInstruction;

    dedALU4 dut (.currentInstruction, .newInstruction);

    initial begin
        // Basic increment
        currentInstruction = 64'd0;  #(200);
        assert(newInstruction == 64'd4);

        currentInstruction = 64'd4;  #(200);
        assert(newInstruction == 64'd8);

        currentInstruction = 64'd8;  #(200);
        assert(newInstruction == 64'd12);

        // Carry propagation through bit 2->3
        currentInstruction = 64'd4;  #10;  // 100 + 100 = 1000
        assert(newInstruction == 64'd8);

        // Longer carry chain
        currentInstruction = 64'd12; #(200);  // 1100 + 100 = 10000
        assert(newInstruction == 64'd16);

        currentInstruction = 64'd28; #(200);  // 11100 + 100 = 100000
        assert(newInstruction == 64'd32);

        // Large aligned address
        currentInstruction = 64'd1000; #(200);
        assert(newInstruction == 64'd1004);

        // Near max carry propagation
        currentInstruction = 64'hFFFFFFFFFFFFFFFC; #(200);  // all 1s except bits [1:0]
        assert(newInstruction == 64'd0);

        // Bits [1:0] pass through unchanged
        currentInstruction = 64'd1;  #(200);
        assert(newInstruction == 64'd5);

        currentInstruction = 64'd3;  #(200);
        assert(newInstruction == 64'd7);
        $stop;
    end
endmodule



