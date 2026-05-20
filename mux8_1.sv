`timescale 1ns/10ps

module mux8_1 (out, d, selectLines);
    output logic       out;
    input  logic [7:0] d;
    input  logic [2:0] selectLines;

    logic y0, y1;

    mux4_1 #(.WIDTH(1)) duu1 (.out(y0), .i0(d[0]), .i1(d[1]), .i2(d[2]), .i3(d[3]), .sel0(selectLines[0]), .sel1(selectLines[1]));
    mux4_1 #(.WIDTH(1)) duu2 (.out(y1), .i0(d[4]), .i1(d[5]), .i2(d[6]), .i3(d[7]), .sel0(selectLines[0]), .sel1(selectLines[1]));

    mux2_1 #(.WIDTH(1)) duu3 (.out(out), .i0(y0), .i1(y1), .sel(selectLines[2]));

endmodule