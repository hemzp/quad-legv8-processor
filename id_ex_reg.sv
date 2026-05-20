`timescale 1ns/10ps

module id_ex_reg (
    clk, reset, flush, write_enable,
    
    // data inputs/outputs
    pc_plus4_in, pc_plus4_out,
    read_data1_in, read_data1_out,
    read_data2_in, read_data2_out,
    extBus_in, extBus_out,
    Rn_in, Rn_out,
    Rm_in, Rm_out,
    Rd_in, Rd_out,
    
    // EX control
    ALUSrc_in, ALUSrc_out,
    ALUOp_in, ALUOp_out,
    DI_sel_in, DI_sel_out,
    
    // M control 
    MemRead_in, MemRead_out,
    MemWrite_in, MemWrite_out,
    doCBZ_in, doCBZ_out,
    doBLT_in, doBLT_out,
    doBR_in, doBR_out,
    UncondBr_in, UncondBr_out,
    
    // WB control 
    RegWrite_in, RegWrite_out,
    MemtoReg_in, MemtoReg_out,
    doBL_in, doBL_out,
    setFlags_in,
    setFlags_out
);

    input logic        clk, reset, flush, write_enable;
    input logic [63:0] pc_plus4_in,  read_data1_in, read_data2_in, extBus_in;
    input logic setFlags_in;
    output logic setFlags_out;
    input logic [4:0]  Rn_in, Rm_in, Rd_in;
    input logic [1:0]  ALUOp_in;
    input logic        ALUSrc_in, DI_sel_in, MemRead_in, MemWrite_in, doCBZ_in, doBLT_in, doBR_in, UncondBr_in, MemtoReg_in, doBL_in, RegWrite_in;

    output logic [63:0] pc_plus4_out,  read_data1_out, read_data2_out, extBus_out;
    output logic [4:0]  Rn_out, Rm_out, Rd_out;
    output logic [1:0]  ALUOp_out;
    output logic        ALUSrc_out, DI_sel_out, MemRead_out, MemWrite_out, doCBZ_out, doBLT_out, doBR_out, UncondBr_out, MemtoReg_out, doBL_out, RegWrite_out;


    D_FF64 ff_pc_4 (.q(pc_plus4_out), .d(pc_plus4_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    D_FF64 ff_read_data1 (.q(read_data1_out), .d(read_data1_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    D_FF64 ff_read_data2 (.q(read_data2_out), .d(read_data2_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    D_FF64 ff_extBus (.q(extBus_out), .d(extBus_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    // D_FF64 ff_extBus2 (.q(extBus2_out), .d(extBus2_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    D_FF5 ff_Rn (.q(Rn_out), .d(Rn_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF5 ff_Rm (.q(Rm_out), .d(Rm_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF5 ff_Rd (.q(Rd_out), .d(Rd_in), .write_enable(1'b1), .clk(clk), .reset(reset));


    //EX
    D_FF_enable ff_ALUSrc  (.q(ALUSrc_out), .d(ALUSrc_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_ALUOp_1 (.q(ALUOp_out[0]), .d(ALUOp_in[0]), .write_enable(1'b1), .clk(clk), .reset(reset));    
    D_FF_enable ff_ALUOp_2 (.q(ALUOp_out[1]), .d(ALUOp_in[1]), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_DI_sel  (.q(DI_sel_out), .d(DI_sel_in), .write_enable(1'b1), .clk(clk), .reset(reset));


    //M
    D_FF_enable ff_MemRead (.q(MemRead_out), .d(MemRead_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_MemWrite (.q(MemWrite_out), .d(MemWrite_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_doCBZ (.q(doCBZ_out), .d(doCBZ_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_doBLT (.q(doBLT_out), .d(doBLT_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_doBR (.q(doBR_out), .d(doBR_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_UncondBr (.q(UncondBr_out), .d(UncondBr_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    //WB
    D_FF_enable ff_MemtoReg (.q(MemtoReg_out), .d(MemtoReg_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_doBL     (.q(doBL_out), .d(doBL_in), .write_enable(1'b1), .clk(clk), .reset(reset));
    D_FF_enable ff_RegWrite (.q(RegWrite_out), .d(RegWrite_in), .write_enable(1'b1), .clk(clk), .reset(reset));

    D_FF_enable ff_setFlags (.q(setFlags_out), .d(setFlags_in), .write_enable(1'b1), .clk(clk), .reset(reset));

endmodule