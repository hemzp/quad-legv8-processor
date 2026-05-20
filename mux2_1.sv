`timescale 1ns/10ps

module mux2_1 #(parameter WIDTH = 64) (out, i0, i1, sel);
    output logic [WIDTH - 1: 0] out;
    input  logic [WIDTH - 1: 0] i0, i1;
    input logic                 sel;

    logic not_sel;
    logic [WIDTH - 1:0] firstAnd, secondAnd;



    not #(0.05) n1 (not_sel, sel);



    genvar i;

    generate
        for(i = 0; i < WIDTH; i++) begin: eachBit
            and #(0.05) a1 (firstAnd[i], not_sel, i0[i]);
            and #(0.05) a2 (secondAnd[i], sel, i1[i]);
            or  #(0.05) or1(out[i], firstAnd[i], secondAnd[i]);
        end
    endgenerate

    // assign out = (i0 & ~sel) | (i1 & sel); // commented in RTL for my reference and ease of understanding
endmodule

//critical path 300000ps