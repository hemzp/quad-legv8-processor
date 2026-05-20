`timescale 1ns/10ps

module D_FF_enable_neg (q, d, write_enable, reset, clk);
    output q;
    input d, write_enable, reset, clk;

    logic d_in, q_out, not_we, and1, and2;

    // d_in = (~write_enable & q_out) | (write_enable & d);

    not #(0.05) gate1 (not_we, write_enable);
    and #(0.05) gate2 (and1, not_we, q_out);
    and #(0.05) gate3 (and2, write_enable, d);
    or  #(0.05) gate4 (d_in, and1, and2); 

    D_FF_neg d0(.q(q_out), .d(d_in), .reset(reset), .clk(clk));

    assign q = q_out;

endmodule



        






 