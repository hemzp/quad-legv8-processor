`timescale 1ns/10ps

module D_FF5(q, d, write_enable, reset, clk);
    output logic [4:0] q;
    input  logic [4:0] d;
    input  logic       write_enable, clk, reset;

    D_FF_enable d0(.q(q[0]), .d(d[0]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF_enable d1(.q(q[1]), .d(d[1]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF_enable d2(.q(q[2]), .d(d[2]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF_enable d3(.q(q[3]), .d(d[3]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF_enable d4(.q(q[4]), .d(d[4]), .write_enable(write_enable), .clk(clk), .reset(reset));

endmodule