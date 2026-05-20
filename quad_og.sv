`timescale 1ns/10ps

module quad_og (clk, reset);

    input logic clk, reset;

    // CONTROL SIGNALS 
    logic UncondBranch;
    logic BrTaken, doCBZ, doBLT, doBR; 
    logic Reg2Loc; 
    logic doBL;    
    logic RegWrite;
    logic [1:0] ALUOp; 
    logic       DI_sel; 
    logic MemWrite; 
    logic MemRead;  
    logic MemtoReg; 
    logic ALUSrc;

    // The ALU
    logic [2:0] aluControl; 
    logic [63:0] busB;
    logic [63:0] aluOut;
    logic        zero, overflow, carry_out, negative; // flags
    
    logic [63:0] mem_read_data;

    logic neg_reg, ovf_reg, zero_reg, carry_reg;
    logic setFlags; 

    D_FF_enable_neg negFF (.q(neg_reg), .d(negative), .write_enable(1'b1), .reset(reset), .clk(clk));
    D_FF_enable_neg ovfFF (.q(ovf_reg), .d(overflow), .write_enable(1'b1), .reset(reset), .clk(clk));
    D_FF_enable_neg carryFF (.q(carry_reg), .d(carry_out), .write_enable(1'b1), .reset(reset), .clk(clk));
    D_FF_enable_neg zeroFF (.q(zero_reg), .d(zero), .write_enable(1'b1), .reset(reset), .clk(clk));


    //DATAPATH SIGNALS

    logic [63:0] currentInstruction, nextInstruction, newInstruction; // type: address not the instruction itself
    logic [63:0] pcMuxOut, branchedOutput, leftShiftInput;

    logic [63:0] ext_b, ext_cb, ext_d, ext_i; // SE signals
    logic [63:0] extBus;
    logic stall;


    typedef struct packed {
        logic RegWrite;
        logic MemtoReg;
        logic doBL;
    } wb_ctrl_t;

    typedef struct packed {
        logic MemRead;
        logic MemWrite;
        logic doCBZ;
        logic doBLT;
        logic doBR;
        logic UncondBranch;
    } m_ctrl_t;

    typedef struct packed {
        logic       ALUSrc;
        logic [1:0] ALUOp;
        logic       DI_sel;
    } ex_ctrl_t;

    // Declare bundle signals at each pipeline stage boundary
    wb_ctrl_t wb_from_ctrl, wb_after_idex, wb_after_exmem, wb_after_memwb;
    m_ctrl_t  m_from_ctrl,  m_after_idex,  m_after_exmem;
    ex_ctrl_t ex_from_ctrl, ex_after_idex;

    // Pack the control unit's outputs into bundles
    assign wb_from_ctrl = '{RegWrite: RegWrite, 
                            MemtoReg: MemtoReg, 
                            doBL:     doBL};

    assign m_from_ctrl  = '{MemRead:  MemRead,
                            MemWrite: MemWrite,
                            doCBZ:    doCBZ,
                            doBLT:    doBLT,
                            doBR:     doBR,
                            UncondBranch: UncondBranch};

    assign ex_from_ctrl = '{ALUSrc:  ALUSrc,
                            ALUOp:   ALUOp,
                            DI_sel:  DI_sel};


    // Register File 
    logic [4:0] instr;
    logic [4:0] instrReg;
    logic [63:0] read_data_1, read_data_2;
    logic [63:0] data_write_to_reg;


    // IF/ID STAGE (FETCHING)

    /* Program Counter Signals:
        - currentInstruction (ouput)
        - nextInstruction    (input)
        - write_enable, clk, reset (input)
    */ 

    program_counter PC (.currentInstruction(currentInstruction), 
                        .nextInstruction(nextInstruction),
                        .write_enable(!stall),
                        .clk(clk), .reset(reset));

    /* Instruction Memory Signals:
        - instruction (ouput)
        - address     (input)
    */ 
    logic [31:0] instruction; //type: the instruction itself 32-bits 
    logic [31:0] instruction_latch_IF_ID;
    logic [63:0] pc_latch_IF_ID;
    logic [63:0] pc_plus4_exmem_out, aluOut_latch_exmem;

    instructmem instructionMemory (.address(currentInstruction), .instruction(instruction), .clk(clk));
    dedALU4 dedicated4Adder (.currentInstruction(currentInstruction), .newInstruction(newInstruction));

    if_id_reg if_id_reg (.pc_plus4_in(currentInstruction), 
                         .pc_plus4_out(pc_latch_IF_ID), 
                         .instruction_in(instruction), 
                         .instruction_out(instruction_latch_IF_ID), 
                         .flush(BrTaken), 
                         .write_enable(!stall), 
                         .clk(clk),
                         .reset(reset));



    

    // DECODE STAGE BEGIN
    /* PC + 4 or Branching Logic */
    signExtender #(.IMM_WIDTH(26), .IMM_START(0)) se_b (
        .instruction_input(instruction_latch_IF_ID),
        .sign_extended_instruction(ext_b)
    );

    // B.LT/CBZ: 19-bit immediate, bits [23:5]
    signExtender #(.IMM_WIDTH(19), .IMM_START(5)) se_cb (
        .instruction_input(instruction_latch_IF_ID),
        .sign_extended_instruction(ext_cb)
    );

    signExtender #(.IMM_WIDTH(12), .IMM_START(10)) se_i (
        .instruction_input(instruction_latch_IF_ID),
        .sign_extended_instruction(ext_i)
    ); // I-Type 

    signExtender #(.IMM_WIDTH(9), .IMM_START(12)) se_d (
        .instruction_input(instruction_latch_IF_ID),
        .sign_extended_instruction(ext_d)
    ); // D-Type

    /* General-Purpose Registers:
        - read_data_1, read_data_2 (data output from the reg, 64-bits) 
        - write_data (input)
        - read_reg_1, read_reg_2 (register 1 and register 2, input)
        - write_reg (input: destination reg)
        - write_data (input: what do you want to write)
        - RegWrite (input: control signal as a write enable)
    */

    logic [4:0] Rn_latch, Rm_latch, Rd_latch;
    logic [4:0] Rd_latch_exmem, Rd_latch_memwb;

    mux2_1 #(.WIDTH(5)) secondRegSelect (.out(instr), .i0(instruction_latch_IF_ID[20:16]), .i1(instruction_latch_IF_ID[4:0]), .sel(Reg2Loc));
    mux2_1 #(.WIDTH(5)) wR (.out(instrReg), .i0(instruction_latch_IF_ID[4:0]), .i1(5'd30), .sel(doBL));

    logic [4:0]  read_reg_1_final;
    mux2_1 #(.WIDTH(5)) cbzReadReg1Mux (
    .out(read_reg_1_final),
    .i0(instruction_latch_IF_ID [9:5]),   
    .i1(5'd31),              
    .sel(doCBZ)
    ); // to do CBZ properly

    regfile GPRegisters (.read_reg_1(read_reg_1_final), .read_reg_2(instr), .write_reg(instrReg), .write_data(data_write_to_reg),
                         .read_data_1(read_data_1), .read_data_2(read_data_2), .RegWrite(RegWrite), 
                         .clk(clk));

    control CU (.Reg2Loc(Reg2Loc), 
                .UncondBranch(UncondBranch), 
                .MemRead(MemRead), 
                .MemtoReg(MemtoReg), 
                .MemWrite(MemWrite), 
                .ALUSrc(ALUSrc), 
                .RegWrite(RegWrite), 
                .doBL(doBL), 
                .DI_sel(DI_sel), 
                .doCBZ(doCBZ), 
                .doBLT(doBLT), 
                .doBR(doBR), 
                .ALUOp(ALUOp), 
                .opcode(instruction_latch_IF_ID[31:21]), 
                .setFlags(setFlags));

    hazard_detection_unit HDU (.stall(stall), .ID_EX_MemRead(m_after_idex.MemRead), .ID_EX_Rd(Rd_latch), .IF_ID_Rn(instruction_latch_IF_ID[9:5]), .IF_ID_Rm(instruction_latch_IF_ID[20:16]));
    // instruction_latch_IF_ID[9:5] = Rn
    // instruction_latch_IF_ID[20:16] = Rm

    // BRANCHING DECISIONS - MOVED TO ID 

    branchingAdd branchingAddress (.branchedOutput(branchedOutput), .currentInstruction(pc_latch_IF_ID), .signExtended(leftShiftInput));
    branchingLogic toBranchOrNotToBranch (.BrTaken(BrTaken), .doCBZ(doCBZ), .zero(zero), .neg(neg_reg), .overflow(ovf_reg), .doBLT(doBLT), .UncondBranch(UncondBranch));

    mux2_1 PCSelect (.out(pcMuxOut), .i0(newInstruction), .i1(branchedOutput), .sel(BrTaken));
    mux2_1 BranchRegister (.out(nextInstruction), .i0(pcMuxOut), .i1(read_data_2), .sel(doBR));

    mux2_1 DISelect (.out(extBus), .i0(ext_d), .i1(ext_i), .sel(DI_sel));
    mux2_1 unconditionalBranchSel (.out(leftShiftInput), .i0(ext_cb), .i1(ext_b), .sel(UncondBranch));


    // Stalled versions of each bundle
    wb_ctrl_t wb_to_idex;
    m_ctrl_t  m_to_idex;
    ex_ctrl_t ex_to_idex;

    // Mux each bundle: pass through normally, force zeros on stall
    mux2_1 #(.WIDTH($bits(wb_ctrl_t))) mux_wb (
        .sel(stall),
        .i0('0),               // bubble: all zeros
        .i1(wb_from_ctrl),     // normal: control unit output
        .out(wb_to_idex)
    );

    mux2_1 #(.WIDTH($bits(m_ctrl_t))) mux_m (
        .sel(stall),
        .i0('0),
        .i1(m_from_ctrl),
        .out(m_to_idex)
    );

    mux2_1 #(.WIDTH($bits(ex_ctrl_t))) mux_ex (
        .sel(stall),
        .i0('0),
        .i1(ex_from_ctrl),
        .out(ex_to_idex)
    );



    // DECODE STAGE END

    logic [63:0] read_data1_latch_ID_EX, read_data2_latch_ID_EX, extBusLatch;
    
    logic [63:0] pc_plus4_idex_out;


    id_ex_reg idex (
        .clk(clk), .reset(reset), .flush(1'b0), .write_enable(1'b1),
        
        // data
        .pc_plus4_in(pc_latch_IF_ID),
        .pc_plus4_out(pc_plus4_idex_out),
        .read_data1_in(read_data_1),
        .read_data2_in(read_data_2),
        .extBus_in(extBus),
        .Rn_in(instruction_latch_IF_ID[9:5]),
        .Rm_in(instruction_latch_IF_ID[20:16]),
        .Rd_in(instruction_latch_IF_ID[4:0]),
        .read_data1_out(read_data1_latch_ID_EX),
        .read_data2_out(read_data2_latch_ID_EX),
        .extBus_out(extBusLatch),
        .Rn_out(Rn_latch),
        .Rm_out(Rm_latch),
        .Rd_out(Rd_latch),
        
        
        // EX control
        .ALUSrc_in (ex_from_ctrl.ALUSrc),
        .ALUOp_in  (ex_from_ctrl.ALUOp),
        .DI_sel_in (ex_from_ctrl.DI_sel),
        .ALUSrc_out(ex_after_idex.ALUSrc),
        .ALUOp_out (ex_after_idex.ALUOp),
        .DI_sel_out(ex_after_idex.DI_sel),
        
        // M control
        .MemRead_in  (m_from_ctrl.MemRead),
        .MemWrite_in (m_from_ctrl.MemWrite),
        .doCBZ_in    (m_from_ctrl.doCBZ),
        .doBLT_in    (m_from_ctrl.doBLT),
        .doBR_in     (m_from_ctrl.doBR),
        .UncondBr_in (m_from_ctrl.UncondBranch),
        .MemRead_out (m_after_idex.MemRead),
        .MemWrite_out(m_after_idex.MemWrite),
        .doCBZ_out   (m_after_idex.doCBZ),
        .doBLT_out   (m_after_idex.doBLT),
        .doBR_out    (m_after_idex.doBR),
        .UncondBr_out(m_after_idex.UncondBranch),
        
        // WB control
        .RegWrite_in (wb_from_ctrl.RegWrite),
        .MemtoReg_in (wb_from_ctrl.MemtoReg),
        .doBL_in     (wb_from_ctrl.doBL),
        .RegWrite_out(wb_after_idex.RegWrite),
        .MemtoReg_out(wb_after_idex.MemtoReg),
        .doBL_out    (wb_after_idex.doBL)
    );


    // EXECUTE STAGE BEGIN
    logic [1:0] forwardA, forwardB;
    forwarding_unit FU (.ID_EX_Rn(Rn_latch), 
                        .ID_EX_Rm(Rm_latch), 
                        .EX_MEM_Rd(Rd_latch_exmem), // EX_MEM register Rd signals fill out later
                        .MEM_WB_Rd(Rd_latch_memwb), // MEM_WB register Rd signals fill out later
                        .EX_MEM_RegWrite_out(wb_after_exmem.RegWrite), // same here
                        .MEM_WB_RegWrite_out(wb_after_memwb.RegWrite), // same here
                        .forwardA(forwardA), 
                        .forwardB(forwardB));
    

    //data hazard protection muxes:
    logic [63:0] busA, busB_forward;
    mux4_1 #(.WIDTH(64)) forwardA_Mux (.out(busA), .i0(read_data1_latch_ID_EX), .i1(data_write_to_reg), .i2(aluOut_latch_exmem), .i3(64'd0), .sel0(forwardA[0]), .sel1(forwardA[1]));
    mux4_1 #(.WIDTH(64)) forwardB_Mux (.out(busB_forward), .i0(read_data1_latch_ID_EX), .i1(data_write_to_reg), .i2(aluOut_latch_exmem), .i3(64'd0), .sel0(forwardB[0]), .sel1(forwardB[1]));


    mux2_1 DataISelect (.out(busB), .i0(busB_forward), .i1(extBusLatch), .sel(ALUSrc));
    AluControl ALU_ControlUnit (.aluControl(aluControl), .ALUOp(ALUOp));
    alu ALU (.out(aluOut), .zero(zero), .overflow(overflow), .carry_out(carry_out), .negative(negative), .busA(read_data_1), .busB(busB), .aluControl(aluControl));



    
    logic [63:0] data_write, data_write_latch;

    ex_mem_reg exmem (
    .clk(clk),
    .reset(reset),
    .flush(1'b0),                              
    .write_enable(1'b1),                       
    
    // Data signals
    .pc_plus4_in(pc_plus4_idex_out),
    .pc_plus4_out(pc_plus4_exmem_out),
    
    .aluOut_in(aluOut),
    .aluOut_out(aluOut_latch_exmem),
    
    .Rd_in(Rd_latch),                          // from ID/EX output
    .Rd_out(Rd_latch_exmem),
    
    .read_data2_in(data_write),   // forwarded value for STUR
    .read_data2_out(data_write_latch),     // goes to DataMem.WriteData
    
    .MemRead_in(m_after_idex.MemRead),
    .MemWrite_in(m_after_idex.MemWrite),
    .MemRead_out(m_after_exmem.MemRead),
    .MemWrite_out(m_after_exmem.MemWrite),
    
    .RegWrite_in(wb_after_idex.RegWrite),
    .MemtoReg_in(wb_after_idex.MemtoReg),
    .doBL_in(wb_after_idex.doBL),
    .RegWrite_out(wb_after_exmem.RegWrite),
    .MemtoReg_out(wb_after_exmem.MemtoReg),
    .doBL_out(wb_after_exmem.doBL)
);

    // MEM-WRITE BACK STAGE
    /* Data Memory:
        - address
        - write_data
        - read_data
        - MemWrite
        - MemRead
    */


    datamem DM (.address(aluOut_latch_exmem), .write_enable(m_after_exmem.MemWrite), .read_enable(m_after_exmem.MemRead), .write_data(data_write_latch), .read_data(mem_read_data), .clk(clk), .xfer_size(4'b1000));
    
    logic [63:0] pc_plus4_memwb_out, aluOut_latch_memwb, mem_read_data_latch;

    mem_wb_reg memwb (
    .clk(clk),
    .reset(reset),
    .flush(1'b0),                              // MEM/WB doesn't flush
    .write_enable(1'b1),                       // MEM/WB doesn't stall
    
    // Data signals
    .pc_plus4_in(pc_plus4_exmem_out),
    .pc_plus4_out(pc_plus4_memwb_out),
    
    .aluOut_in(aluOut_latch_exmem),
    .aluOut_out(aluOut_latch_memwb),
    
    .Rd_in(Rd_latch_exmem),
    .Rd_out(Rd_latch_memwb),
    
    .mem_read_data_in(mem_read_data),          // from data memory output
    .mem_read_data_out(mem_read_data_latch),
    
    // WB control — unpack from wb_after_exmem bundle
    .RegWrite_in(wb_after_exmem.RegWrite),
    .MemtoReg_in(wb_after_exmem.MemtoReg),
    .doBL_in(wb_after_exmem.doBL),
    .RegWrite_out(wb_after_memwb.RegWrite),
    .MemtoReg_out(wb_after_memwb.MemtoReg),
    .doBL_out(wb_after_memwb.doBL)
);

    mux4_1 writeDataMux (.out(data_write_to_reg), .i0(aluOut_latch_memwb), .i1(mem_read_data_latch), .i2(newInstruction), .i3(64'b0), .sel0(MemtoReg), .sel1(doBL));  // might need to change the select lines
    
endmodule