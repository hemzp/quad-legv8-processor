`timescale 1ns/10ps

module D_FF32(q, d, write_enable ,reset, clk);
    output logic [31:0] q;
    input  logic [31:0] d;
    input  logic        write_enable, clk, reset;

    D_FF16 d0(.q(q[15:0]), .d(d[15:0]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF16 d1(.q(q[31:16]), .d(d[31:16]), .write_enable(write_enable), .clk(clk), .reset(reset));
endmodule