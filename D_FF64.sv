`timescale 1ns/10ps

module D_FF64(q, d, write_enable ,reset, clk);
    output logic [63:0] q;
    input  logic [63:0] d;
    input  logic        write_enable, clk, reset;

    D_FF32 d0(.q(q[31:0]), .d(d[31:0]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF32 d1(.q(q[63:32]), .d(d[63:32]), .write_enable(write_enable), .clk(clk), .reset(reset));
endmodule