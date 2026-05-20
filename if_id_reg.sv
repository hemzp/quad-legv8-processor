`timescale 1ns/10ps

module if_id_reg (pc_plus4_in, pc_plus4_out, instruction_in, instruction_out, flush, write_enable, clk, reset);

    input logic [63:0] pc_plus4_in; //PC+4
    input logic [31:0] instruction_in;  //the inst. itself coming from instructionMem
    input logic  flush, write_enable, clk, reset;

    
    output logic [63:0] pc_plus4_out;
    output logic [31:0] instruction_out;

    logic clear;

    or  #(0.05) or1(clear, reset, flush);

    D_FF32 d_FF32 (.q(instruction_out), .d(instruction_in), .write_enable(write_enable), .clk(clk), .reset(clear));
    D_FF64 d_FF64 (.q(pc_plus4_out), .d(pc_plus4_in), .write_enable(write_enable), .clk(clk), .reset(clear));


endmodule


