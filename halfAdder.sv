`timescale 1ns/10ps


module halfAdder (inA, inB, sum, c_out);
    output logic sum, c_out;
    input  logic inA, inB;

    xor #(0.05) x1 (sum, inA, inB);
    and #(0.05) o1 (c_out, inA, inB);
endmodule


