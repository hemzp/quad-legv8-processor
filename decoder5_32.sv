`timescale 1ns/10ps


module decoder5_32(RegWrite, a0, a1, a2, a3, a4, enable_in ,write_enable);
    output logic [31:0]     write_enable;
    input  logic            a0, a1, a2, a3, a4;
    input  logic            enable_in; 
    input  logic            RegWrite;

    logic [3:0]             enable_out;


    decoder2_4 duu  (.a3(a3), .a4(a4), .RegWrite(RegWrite), .enable_out(enable_out));
    decoder3_8 duu2 (.a0(a0), .a1(a1), .a2(a2), .enable_in(enable_out[0]), .write_enable(write_enable[7:0]));
    decoder3_8 duu3 (.a0(a0), .a1(a1), .a2(a2), .enable_in(enable_out[1]), .write_enable(write_enable[15:8]));
    decoder3_8 duu4 (.a0(a0), .a1(a1), .a2(a2), .enable_in(enable_out[2]), .write_enable(write_enable[23:16]));
    decoder3_8 duu5 (.a0(a0), .a1(a1), .a2(a2), .enable_in(enable_out[3]), .write_enable(write_enable[31:24]));

endmodule

module decoder5_32_tb();
    logic [31:0] write_enable;
    logic       a0, a1, a2, a3, a4, enable_in, RegWrite;

    decoder5_32 dut (.*);

    initial begin 
        {enable_in, RegWrite} = 2'b00;
        {enable_in, RegWrite} = 2'b11;

        {a0, a1, a2, a3, a4} = 5'b00000;
        {a0, a1, a2, a3, a4} = 5'b00000;

        {a4, a3, a2, a1, a0} = 5'b00000; #(200); 
        {a4, a3, a2, a1, a0} = 5'b00001; #(200); 
        {a4, a3, a2, a1, a0} = 5'b00011; #(200);
        {a4, a3, a2, a1, a0} = 5'b00010; #(200); 
        {a4, a3, a2, a1, a0} = 5'b00110; #(200); 
        {a4, a3, a2, a1, a0} = 5'b00111; #(200); 
        {a4, a3, a2, a1, a0} = 5'b00101; #(200); 
        {a4, a3, a2, a1, a0} = 5'b00100; #(200); 
        {a4, a3, a2, a1, a0} = 5'b01100; #(200); 
        {a4, a3, a2, a1, a0} = 5'b01101; #(200); 
        {a4, a3, a2, a1, a0} = 5'b01111; #(200); 
        {a4, a3, a2, a1, a0} = 5'b01110; #(200); 
        {a4, a3, a2, a1, a0} = 5'b01010; #(200); 
        {a4, a3, a2, a1, a0} = 5'b01011; #(200); 
        {a4, a3, a2, a1, a0} = 5'b01001; #(200); 
        {a4, a3, a2, a1, a0} = 5'b01000; #(200); 
        {a4, a3, a2, a1, a0} = 5'b11000; #(200); 
        {a4, a3, a2, a1, a0} = 5'b11001; #(200); 
        {a4, a3, a2, a1, a0} = 5'b11011; #(200); 
        {a4, a3, a2, a1, a0} = 5'b11010; #(200); 
        {a4, a3, a2, a1, a0} = 5'b11110; #(200); 
        {a4, a3, a2, a1, a0} = 5'b11111; #(200); 
        {a4, a3, a2, a1, a0} = 5'b11101; #(200); 
        {a4, a3, a2, a1, a0} = 5'b11100; #(200); 
        {a4, a3, a2, a1, a0} = 5'b10100; #(200); 
        {a4, a3, a2, a1, a0} = 5'b10101; #(200); 
        {a4, a3, a2, a1, a0} = 5'b10111; #(200); 
        {a4, a3, a2, a1, a0} = 5'b10110; #(200);
        {a4, a3, a2, a1, a0} = 5'b10010; #(200); 
        {a4, a3, a2, a1, a0} = 5'b10011; #(200); 
        {a4, a3, a2, a1, a0} = 5'b10001; #(200); 
        {a4, a3, a2, a1, a0} = 5'b10000; #(200); 
        $stop;
    end
endmodule


