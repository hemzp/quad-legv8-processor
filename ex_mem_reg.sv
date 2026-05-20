`timescale 1ns/10ps

module ex_mem_reg (
    clk, reset, flush, write_enable,
    
    // data inputs/outputs
    pc_plus4_in, pc_plus4_out,
    aluOut_in, aluOut_out,
    Rd_in, Rd_out, read_data2_in, read_data2_out,
    
    
    // M control 
    MemRead_in, MemRead_out,
    MemWrite_in, MemWrite_out,

    
    // WB control 
    RegWrite_in, RegWrite_out,
    MemtoReg_in, MemtoReg_out,
    doBL_in, doBL_out,

    setFlags_in,
    setFlags_out
);

    input logic        clk, reset, flush, write_enable;
    input logic [63:0] pc_plus4_in,  read_data2_in, aluOut_in;
    input logic [4:0]  Rd_in;
    input logic        MemRead_in, MemWrite_in, MemtoReg_in, doBL_in, RegWrite_in;

    output logic [63:0] pc_plus4_out, read_data2_out, aluOut_out;
    output logic [4:0]  Rd_out;
    output logic        MemRead_out, MemWrite_out, MemtoReg_out, doBL_out, RegWrite_out;
    input logic setFlags_in;
    output logic setFlags_out;


    D_FF64 ff_pc_4 (.q(pc_plus4_out), .d(pc_plus4_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    D_FF64 ff_aluOut (.q(aluOut_out), .d(aluOut_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    D_FF5 ff_Rd (.q(Rd_out), .d(Rd_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    D_FF64 ff_read_data2 (.q(read_data2_out), .d(read_data2_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    //M
    D_FF_enable ff_MemRead (.q(MemRead_out), .d(MemRead_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_MemWrite (.q(MemWrite_out), .d(MemWrite_in), .write_enable(1'b1), .clk(clk), .reset(reset));


    //WB
    D_FF_enable ff_MemtoReg (.q(MemtoReg_out), .d(MemtoReg_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_doBL     (.q(doBL_out), .d(doBL_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_RegWrite (.q(RegWrite_out), .d(RegWrite_in), .write_enable(1'b1), .clk(clk), .reset(reset));

endmodule