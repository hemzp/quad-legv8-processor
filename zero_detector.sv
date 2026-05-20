`timescale 1ns/10ps

module zero_detector (zero, in);
    output logic        zero;
    input  logic [63:0] in;

    // Tree levels: 32 -> 16 -> 8 -> 4 -> 2 -> 1
    logic [31:0] l1;
    logic [15:0] l2;
    logic [7:0]  l3;
    logic [3:0]  l4;
    logic [1:0]  l5;
    logic        any_bit_set;

    // Level 1: pair adjacent input bits
    genvar i;
    generate
        for (i = 0; i < 32; i++) begin : gen_l1
            or #(0.05) g (l1[i], in[2*i], in[2*i+1]);
        end
        for (i = 0; i < 16; i++) begin : gen_l2
            or #(0.05) g (l2[i], l1[2*i], l1[2*i+1]);
        end
        for (i = 0; i < 8; i++) begin : gen_l3
            or #(0.05) g (l3[i], l2[2*i], l2[2*i+1]);
        end
        for (i = 0; i < 4; i++) begin : gen_l4
            or #(0.05) g (l4[i], l3[2*i], l3[2*i+1]);
        end
        for (i = 0; i < 2; i++) begin : gen_l5
            or #(0.05) g (l5[i], l4[2*i], l4[2*i+1]);
        end
    endgenerate

    // Final OR + invert
    or  #(0.05) g_l6 (any_bit_set, l5[0], l5[1]);
    not #(0.05) g_inv (zero, any_bit_set);
endmodule