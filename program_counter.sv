`timescale 1ns/10ps

module program_counter(currentInstruction, nextInstruction, write_enable ,reset, clk);
    output logic [63:0] currentInstruction;
    input  logic [63:0] nextInstruction;
    input  logic        write_enable, clk, reset;

    D_FF32 d0(.q(currentInstruction[31:0]), .d(nextInstruction[31:0]), .write_enable(write_enable), .clk(clk), .reset(reset));
    D_FF32 d1(.q(currentInstruction[63:32]), .d(nextInstruction[63:32]), .write_enable(write_enable), .clk(clk), .reset(reset));

    
endmodule

//currentInstruction is current instuction address 