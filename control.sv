`timescale 1ns/10ps

module control (opcode, Reg2Loc, UncondBranch, MemRead, MemtoReg, ALUOp, 
                MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, setFlags);
    output logic        Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, 
                        ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, setFlags;
    output logic [1:0]  ALUOp;
    input  logic [10:0] opcode;

    // Order: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, 
    //         RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp[1:0]} = 14 bits

    always_comb begin
        casez(opcode)
            // ADDI Rd, Rn, Imm12: Rd = Rn + ZeroExtend(Imm12)
            11'b1001000100?: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b0_0_0_0_0_1_1_0_1_0_0_0_00_0;

            // ADDS Rd, Rn, Rm: Rd = Rn + Rm, set flags
            11'b10101011000: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b0_0_0_0_0_0_1_0_0_0_0_0_00_1;

            // SUBS Rd, Rn, Rm: Rd = Rn - Rm, set flags
            11'b11101011000: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b0_0_0_0_0_0_1_0_0_0_0_0_01_1;

            // LDUR Rd, [Rn, #Imm9]: Rd = Mem[Rn + SignExt(Imm9)]
            11'b11111000010: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b0_0_1_1_0_1_1_0_0_0_0_0_00_0;

            // STUR Rd, [Rn, #Imm9]: Mem[Rn + SignExt(Imm9)] = Rd
            11'b11111000000: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b1_0_0_0_1_1_0_0_0_0_0_0_00_0;

            // B Imm26: PC = PC + SignExt(Imm26 << 2)
            11'b000101?????: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b0_1_0_0_0_0_0_0_0_0_0_0_00_0;

            // BL Imm26: X30 = PC + 4, PC = PC + SignExt(Imm26 << 2)
            11'b100101?????: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b0_1_0_0_0_0_1_1_0_0_0_0_00_0;

            // BR Rd: PC = Reg[Rd]   (Reg2Loc=1 routes Rd to read_reg2 → doBR mux)
            11'b11010110000: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b1_0_0_0_0_0_0_0_0_0_0_1_00_0;

            // B.LT Imm19: if (N != V) PC = PC + SignExt(Imm19 << 2)
            11'b01010100???: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b0_0_0_0_0_0_0_0_0_0_1_0_00_0;

            // CBZ Rd, Imm19: if (Reg[Rd] == 0) PC = PC + SignExt(Imm19 << 2)
            // Reg2Loc=1 to read Rd via port 2; ALU result/Zero flag determines branch
            11'b10110100???: {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b1_0_0_0_0_0_0_0_0_1_0_0_00_0;

            // Default: NOP-like, all signals deasserted
            default:         {Reg2Loc, UncondBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, doBL, DI_sel, doCBZ, doBLT, doBR, ALUOp, setFlags} 
                           = 15'b0_0_0_0_0_0_0_0_0_0_0_0_00_0;
        endcase
    end
endmodule
