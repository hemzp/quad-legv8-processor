`timescale 1ns/10ps

module mux4_1 #(parameter WIDTH = 64) (out, i0, i1, i2, i3, sel0, sel1);
    output logic [WIDTH-1: 0] out;
    input  logic [WIDTH-1: 0] i0, i1, i2, i3;
    input  logic              sel0, sel1;

    logic                     not_sel0, not_sel1;
    logic [WIDTH-1:0]         firstAnd, secondAnd, thirdAnd, fourthAnd;


    not #(0.05) n1 (not_sel0, sel0);
    not #(0.05) n2 (not_sel1, sel1);


    genvar i;
    generate
        for(i = 0; i < WIDTH; i++) begin: eachBit 
            and #(0.05) a1 (firstAnd[i], not_sel0, not_sel1, i0[i]);
            and #(0.05) a2 (secondAnd[i], sel0, not_sel1,i1[i]);
            and #(0.05) a3 (thirdAnd[i], not_sel0, sel1, i2[i]);
            and #(0.05) a4 (fourthAnd[i], sel0, sel1, i3[i]);
            or  #(0.05) or1(out[i], firstAnd[i], secondAnd[i], thirdAnd[i], fourthAnd[i]);
        end 
    endgenerate
    
endmodule
