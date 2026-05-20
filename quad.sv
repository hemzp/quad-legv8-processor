`timescale 1ns/10ps

module quad (clk, reset);

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

    logic stall;

    logic neg_reg, ovf_reg, zero_reg, carry_reg;
    logic setFlags; 
    logic setFlags_idex_out;



    D_FF_enable negFF (.q(neg_reg), .d(negative), .write_enable(setFlags_idex_out), .reset(reset), .clk(clk));
    D_FF_enable ovfFF (.q(ovf_reg), .d(overflow), .write_enable(setFlags_idex_out), .reset(reset), .clk(clk));
    D_FF_enable carryFF (.q(carry_reg), .d(carry_out), .write_enable(setFlags_idex_out), .reset(reset), .clk(clk));
    D_FF_enable zeroFF (.q(zero_reg), .d(zero), .write_enable(setFlags_idex_out), .reset(reset), .clk(clk));


    //DATAPATH SIGNALS

    logic [63:0] currentInstruction, nextInstruction, newInstruction; // type: address not the instruction itself
    logic [63:0] pcMuxOut, branchedOutput, leftShiftInput;

    logic [63:0] ext_b, ext_cb, ext_d, ext_i; // SE signals
    logic [63:0] extBus;
    logic [4:0]  writeReg_final;



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

    

    // found a way to bundle signals like structs in C
    wb_ctrl_t wb_from_ctrl, wb_after_idex, wb_after_exmem, wb_after_memwb;
    m_ctrl_t  m_from_ctrl,  m_after_idex,  m_after_exmem;
    ex_ctrl_t ex_from_ctrl, ex_after_idex;

    
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
    signExtender #(.IMM_WIDTH(26), .IMM_START(0)) se_b (
        .instruction_input(instruction_latch_IF_ID),
        .sign_extended_instruction(ext_b)
    );

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



    regfile GPRegisters (.read_reg_1(instruction_latch_IF_ID[9:5]), .read_reg_2(instr), .write_reg(writeReg_final), .write_data(data_write_to_reg),
                         .read_data_1(read_data_1), .read_data_2(read_data_2), .RegWrite(wb_after_memwb.RegWrite), 
                         .clk(clk), .reset(reset));

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

    hazard_detection_unit HDU (
        .stall(stall), 
        .ID_EX_MemRead(m_after_idex.MemRead), 
        .ID_EX_Rd(Rd_latch), 
        .IF_ID_Rn(instruction_latch_IF_ID[9:5]), 
        .IF_ID_Rm(instr),                            
        .IF_ID_doBLT(doBLT),                        
        .ID_EX_setFlags(setFlags_idex_out),
        //new signals introduced
        .IF_ID_doCBZ(doCBZ),
        .IF_ID_Rd(instruction_latch_IF_ID[4:0]),
        .ID_EX_RegWrite(wb_after_idex.RegWrite),
        .EX_MEM_RegWrite(wb_after_exmem.RegWrite),
        .MEM_WB_RegWrite(wb_after_memwb.RegWrite),
        .EX_MEM_Rd(Rd_latch_exmem),
        .MEM_WB_Rd(Rd_latch_memwb)
    );




    // BRANCHING DECISIONS - MOVED TO ID 

    logic cbz_zero;
    logic [63:0] cbz_input;
    
    // CBZ forwarding 
    logic cbz_match_ex, cbz_match_mem, cbz_match_wb;

    cbz_FU CBZ_FU (
        .cbz_match_ex(cbz_match_ex),
        .cbz_match_mem(cbz_match_mem),
        .cbz_match_wb(cbz_match_wb),
        .IF_ID_Rd(instruction_latch_IF_ID[4:0]),
        .ID_EX_Rd(Rd_latch),
        .ID_EX_RegWrite(wb_after_idex.RegWrite),
        .EX_MEM_Rd(Rd_latch_exmem),
        .EX_MEM_RegWrite(wb_after_exmem.RegWrite),
        .MEM_WB_Rd(Rd_latch_memwb),
        .MEM_WB_RegWrite(wb_after_memwb.RegWrite)
    );

    logic [63:0] cbz_stage1, cbz_stage2;
    mux2_1 cbz_m1 (.out(cbz_stage1), .i0(read_data_2),    .i1(data_write_to_reg),   .sel(cbz_match_wb));
    mux2_1 cbz_m2 (.out(cbz_stage2), .i0(cbz_stage1),     .i1(aluOut_latch_exmem),  .sel(cbz_match_mem));
    mux2_1 cbz_m3 (.out(cbz_input),  .i0(cbz_stage2),     .i1(aluOut),              .sel(cbz_match_ex));
    
    zero_detector cbz_zero_check (.zero(cbz_zero), .in(cbz_input));

    branchingAdd branchingAddress (.branchedOutput(branchedOutput), .currentInstruction(pc_latch_IF_ID), .signExtended(leftShiftInput));

    // main fix eveyrhting works after this
    logic BrTaken_raw, stall_n_br;
    branchingLogic toBranchOrNotToBranch (.BrTaken(BrTaken_raw), .doCBZ(doCBZ), .zero(cbz_zero), .neg(neg_reg), .overflow(ovf_reg), .doBLT(doBLT), .UncondBranch(UncondBranch), .doBR(doBR));

    not #(0.05) (stall_n_br, stall);
    and #(0.05) (BrTaken, BrTaken_raw, stall_n_br);
    // fix end
    
    mux2_1 PCSelect (.out(pcMuxOut), .i0(newInstruction), .i1(branchedOutput), .sel(BrTaken));
    mux2_1 BranchRegister (.out(nextInstruction), .i0(pcMuxOut), .i1(read_data_2), .sel(doBR));

    mux2_1 DISelect (.out(extBus), .i0(ext_d), .i1(ext_i), .sel(DI_sel));
    mux2_1 unconditionalBranchSel (.out(leftShiftInput), .i0(ext_cb), .i1(ext_b), .sel(UncondBranch));


    //Stalled versions of each bundle signals
    wb_ctrl_t wb_to_idex;
    m_ctrl_t  m_to_idex;
    ex_ctrl_t ex_to_idex;

    //pass through normally, force zeros on stall
    mux2_1 #(.WIDTH($bits(wb_ctrl_t))) mux_wb (
        .sel(stall),
        .i0('0),               
        .i1(wb_from_ctrl),     
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
        .Rm_in(instr),
        .Rd_in(instruction_latch_IF_ID[4:0]),
        .read_data1_out(read_data1_latch_ID_EX),
        .read_data2_out(read_data2_latch_ID_EX),
        .extBus_out(extBusLatch),
        .Rn_out(Rn_latch),
        .Rm_out(Rm_latch),
        .Rd_out(Rd_latch),
        
        
        //EX control
        .ALUSrc_in (ex_from_ctrl.ALUSrc),
        .ALUOp_in  (ex_from_ctrl.ALUOp),
        .DI_sel_in (ex_from_ctrl.DI_sel),
        .ALUSrc_out(ex_after_idex.ALUSrc),
        .ALUOp_out (ex_after_idex.ALUOp),
        .DI_sel_out(ex_after_idex.DI_sel),

        .setFlags_in(setFlags),
        .setFlags_out(setFlags_idex_out),
        
        //M control
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
                        .EX_MEM_Rd(Rd_latch_exmem), 
                        .MEM_WB_Rd(Rd_latch_memwb), 
                        .EX_MEM_RegWrite_out(wb_after_exmem.RegWrite), 
                        .MEM_WB_RegWrite_out(wb_after_memwb.RegWrite), 
                        .forwardA(forwardA), 
                        .forwardB(forwardB));
    

    //data hazard protection muxes:
    logic [63:0] busA, busB_forward;
    mux4_1 #(.WIDTH(64)) forwardA_Mux (.out(busA), .i0(read_data1_latch_ID_EX), .i1(data_write_to_reg), .i2(aluOut_latch_exmem), .i3(64'd0), .sel0(forwardA[0]), .sel1(forwardA[1]));
    mux4_1 #(.WIDTH(64)) forwardB_Mux (.out(busB_forward), .i0(read_data2_latch_ID_EX), .i1(data_write_to_reg), .i2(aluOut_latch_exmem), .i3(64'd0), .sel0(forwardB[0]), .sel1(forwardB[1]));


    mux2_1 DataISelect (.out(busB), .i0(busB_forward), .i1(extBusLatch), .sel(ex_after_idex.ALUSrc));
    AluControl ALU_ControlUnit (.aluControl(aluControl), .ALUOp(ex_after_idex.ALUOp));
    alu ALU (.out(aluOut), .zero(zero), .overflow(overflow), .carry_out(carry_out), .negative(negative), .busA(busA), .busB(busB), .aluControl(aluControl));



    logic [4:0] Rd_for_exmem;
    mux2_1 #(.WIDTH(5)) blRdMux_ex (.out(Rd_for_exmem), .i0(Rd_latch), .i1(5'd30), .sel(wb_after_idex.doBL));

    logic [63:0] busB_forward_latch;

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
    
    .Rd_in(Rd_for_exmem),                          
    .Rd_out(Rd_latch_exmem),
    
    .read_data2_in(busB_forward),   
    .read_data2_out(busB_forward_latch),     
    
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


    datamem DM (.address(aluOut_latch_exmem), .write_enable(m_after_exmem.MemWrite), .read_enable(m_after_exmem.MemRead), .write_data(busB_forward_latch), .read_data(mem_read_data), .clk(clk), .xfer_size(4'b1000));
    
    logic [63:0] pc_plus4_memwb_out, aluOut_latch_memwb, mem_read_data_latch;

    mem_wb_reg memwb (
    .clk(clk),
    .reset(reset),
    .flush(1'b0),                              
    .write_enable(1'b1),                       
    
    // Data signals
    .pc_plus4_in(pc_plus4_exmem_out),
    .pc_plus4_out(pc_plus4_memwb_out),
    
    .aluOut_in(aluOut_latch_exmem),
    .aluOut_out(aluOut_latch_memwb),
    
    .Rd_in(Rd_latch_exmem),
    .Rd_out(Rd_latch_memwb),
    
    .mem_read_data_in(mem_read_data),         
    .mem_read_data_out(mem_read_data_latch),
    .RegWrite_in(wb_after_exmem.RegWrite),
    .MemtoReg_in(wb_after_exmem.MemtoReg),
    .doBL_in(wb_after_exmem.doBL),
    .RegWrite_out(wb_after_memwb.RegWrite),
    .MemtoReg_out(wb_after_memwb.MemtoReg),
    .doBL_out(wb_after_memwb.doBL)
);
    

  
    assign writeReg_final = Rd_latch_memwb;

    logic [63:0] pc_plus_4_for_bl;
    dedALU4 bl_adder (.currentInstruction(pc_plus4_memwb_out), .newInstruction(pc_plus_4_for_bl));

    mux4_1 writeDataMux (.out(data_write_to_reg), .i0(aluOut_latch_memwb), .i1(mem_read_data_latch), .i2(pc_plus_4_for_bl), .i3(64'b0), .sel0(wb_after_memwb.MemtoReg), .sel1(wb_after_memwb.doBL));  // might need to change the select lines
    
endmodule


