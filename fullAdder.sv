`timescale 1ns/10ps


module fullAdder (a, b, c_in, sum, c_out);
    output logic sum, c_out;
    input  logic a, b, c_in;

    xor #(0.05) x1 (xor1, a, b);
    and  #(0.05) a1 (or1, a, b);

    xor #(0.05) x2  (sum, xor1, c_in);
    and  #(0.05) a2 (c1, xor1, c_in);

    or #(0.05) o1 (c_out, c1, or1);
endmodule


