`timescale 1ns/10ps

module D_FF16(q, d, write_enable, reset, clk);
    output logic [15:0] q;
    input  logic [15:0] d;
    input  logic        write_enable, clk, reset;

    D_FF4 d0(.q(q[3:0]), .d(d[3:0]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF4 d1(.q(q[7:4]), .d(d[7:4]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF4 d2(.q(q[11:8]), .d(d[11:8]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF4 d3(.q(q[15:12]), .d(d[15:12]), .write_enable(write_enable), .clk(clk), .reset(reset));
endmodule