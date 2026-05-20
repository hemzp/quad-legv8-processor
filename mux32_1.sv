`timescale 1ns/10ps

module mux32_1 (out, d, selectLines);
    output logic        out;
    input  logic [31:0] d;
    input  logic [4:0]  selectLines;

    logic y0, y1, y2, y3;

    mux8_1 mux1 (.out(y0), .d(d[7:0]), .selectLines(selectLines[2:0]));
    mux8_1 mux2 (.out(y1), .d(d[15:8]), .selectLines(selectLines[2:0]));
    mux8_1 mux3 (.out(y2), .d(d[23:16]), .selectLines(selectLines[2:0]));
    mux8_1 mux4 (.out(y3), .d(d[31:24]), .selectLines(selectLines[2:0]));

    mux4_1 #(.WIDTH(1)) mux5 (.out(out), .i0(y0), .i1(y1), .i2(y2), .i3(y3), .sel0(selectLines[3]), .sel1(selectLines[4]));

endmodule


module mux32_1_tb();

    logic        out;
    logic [31:0] d;
    logic [4:0]  selectLines;

    mux32_1 dut (.out(out), .d(d), .selectLines(selectLines));

    initial begin
    d = 32'hA5A5A5A5; //1010_0101_1010_0101_1010_0101_1010_0101
    
    selectLines = 5'b01000; //sel = 8
    #(500);
    selectLines = 5'b11011; //sel = 27
    #(500);
    selectLines = 5'b00000; //sel = 0
    #(500);
    selectLines = 5'b11111; //sel = 31
    #(500);
    selectLines = 5'b01110; //sel = 28

    //should be 1, 0, 1, 1 on waveform
    $stop;
end
endmodule




