`timescale 1ns/10ps

module decoder2_4(RegWrite, a3, a4, enable_out);
    output logic [3:0]  enable_out;
    input  logic        a3;
    input  logic        a4;
    input  logic        RegWrite;


    not #(0.05) g1 (not_a3, a3);
    not #(0.05) g2 (not_a4, a4);

    and #(0.05) and1 (enable_out[0], RegWrite, not_a3, not_a4);
    and #(0.05) and2 (enable_out[1], RegWrite, a3, not_a4);
    and #(0.05) and3 (enable_out[2], RegWrite, not_a3, a4);
    and #(0.05) and4 (enable_out[3], RegWrite, a3, a4);

endmodule


module decoder2_4_tb();
    logic [3:0] enable_out;
    logic a3, a4, RegWrite;

    decoder2_4 dut (.a3(a3), .a4(a4), .RegWrite(RegWrite), .enable_out(enable_out));

    initial begin
                                     // 0123

        {a3, a4, RegWrite} = 3'b000; // 0000

        #(200);

        {a3, a4, RegWrite} = 3'b001; // 1000

        #(200);

        {a3, a4, RegWrite} = 3'b101; // 0100

        #(200);

        {a3, a4, RegWrite} = 3'b011; // 0010

        #(200);

        {a3, a4, RegWrite} = 3'b111; // 0001

        #(200);

        $stop;
    end
endmodule
