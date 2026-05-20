`timescale 1ns/10ps

module alu(busA, busB, aluControl, out, zero, overflow, carry_out, negative);
    output logic [63:0] out;
    output logic        zero, overflow, carry_out, negative; 
    
    input logic [63:0] busA, busB;
    input logic [2:0]  aluControl;

    logic [64:0] c; //carry chain
    logic [63:0] sum_bits; 
    logic        outputOr;

    assign c[0] = aluControl[0]; //mode select: add or sub

    genvar i;

    generate
        for(i = 0; i < 64; i++) begin: eachSlice
            bitSlice bS (
                .a_bit(busA[i]), 
                .b_bit(busB[i]), 
                .select_bits(aluControl), 
                .c_in(c[i]), 
                .sum(sum_bits[i]), 
                .c_out(c[i+1]), 
                .result(out[i]));
        end
    endgenerate

    assign carry_out = c[64];
    assign negative  = out[63];
    xor #(0.05) gateOp4 (overflow, c[64], c[63]);


    logic [15:0] intm;
    logic [15:0] intm3;
    logic [3:0] intm2;
    

    genvar j;
    generate
        for(j = 0; j < 64; j+=4) begin: eachor
            or #(0.05) gateOp5 (intm[j/4], out[j], out[j+1], out[j+2], out[j+3]);
        end
    endgenerate

    genvar h;
    generate
        for(h = 0; h < 16; h++) begin: eachNot
            not #(0.05) gateOp8 (intm3[h], intm[h]);
        end
    endgenerate



    genvar k;
    generate 
        for(k = 0; k < 16; k+=4) begin: eachAnd
            and #(0.05) gateOp6 (intm2[k/4], intm3[k], intm3[k+1], intm3[k+2], intm3[k+3]);
        end
    endgenerate


    and #(0.05) gateOp7 (zero, intm2[0], intm2[1], intm2[2], intm2[3]);

endmodule


// module alu64_tb();
//     logic [63:0] out;
//     logic        zero, overflow, carry_out, negative; 
    
//     logic [63:0] busA, busB;
//     logic [2:0]  aluControl;

//     alu64_tb(.*);

//     initial begin
//     end
// endmodule
