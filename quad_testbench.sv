// `timescale 1ns/10ps

// module quad_testbench;
//     logic clk, reset;
    
//     quad dut (.clk(clk), .reset(reset));
    
//     initial begin
//         clk = 0;
//         reset = 1;
//         #100;
//         reset = 0;
//         #100000;     
//         $stop;
//     end
    
//     always #10 clk = ~clk;
// endmodule


`timescale 1ns/10ps

module quad_testbench;
    logic clk, reset;
    
    quad dut (.clk(clk), .reset(reset));
    
// //     // Display key signals every clock posedge after reset deasserts
// //     always @(posedge clk) begin
// //         if (!reset && dut.wb_after_memwb.RegWrite && dut.writeReg_final >= 11 && dut.writeReg_final <= 20) begin
// //             $display("T=%0t COMMIT X%0d <= %0d (MemtoReg=%b mem_read=%0d aluOut=%0d)",
// //                 $time, dut.writeReg_final, dut.data_write_to_reg,
// //                 dut.wb_after_memwb.MemtoReg, dut.mem_read_data_latch, dut.aluOut_latch_memwb);
// //         end
// //     end

// //     always @(posedge clk) begin
// //     if (!reset && dut.doCBZ) begin
// //         $display("T=%0t CBZ-IN-ID: cbz_zero=%b BrTaken=%b read_d2=%0d X0=%0d stall=%b PC=%0d",
// //             $time, dut.cbz_zero, dut.BrTaken, dut.read_data_2,
// //             dut.GPRegisters.input_lines[0], dut.stall, dut.currentInstruction);
// //     end
// // end 


// // always @(posedge clk) begin
// //     if (!reset && dut.BrTaken) begin
// //         $display("T=%0t BRANCH from PC=%0d -> %0d (UncondBr=%b doBLT=%b doCBZ=%b doBR=%b neg=%b stall=%b)",
// //             $time, dut.pc_latch_IF_ID, dut.nextInstruction,
// //             dut.UncondBranch, dut.doBLT, dut.doCBZ, dut.doBR,
// //             dut.neg_reg, dut.stall);
// //     end
// // end


// // always @(posedge clk) begin
// //     if (!reset && dut.currentInstruction >= 92 && dut.currentInstruction <= 160) begin
// //         $display("T=%0t PC=%0d inst=%h IF/ID=%h stall=%b BrTaken=%b doBLT=%b doCBZ=%b neg=%b X0=%0d X1=%0d X4=%0d",
// //             $time, dut.currentInstruction, dut.instruction, dut.instruction_latch_IF_ID,
// //             dut.stall, dut.BrTaken, dut.doBLT, dut.doCBZ, dut.neg_reg,
// //             dut.GPRegisters.input_lines[0], dut.GPRegisters.input_lines[1],
// //             dut.GPRegisters.input_lines[4]);
// //     end
// // end


// // always @(posedge clk) begin
// //     if (!reset && dut.currentInstruction == 128) begin  // ADDI X1, X1, #1
// //         $display("T=%0t PC=128 (X1++) reaches IF, IF/ID=%h", $time, dut.instruction_latch_IF_ID);
// //     end
// //     if (!reset && dut.currentInstruction == 148) begin  // SUBS X0, X0, X5
// //         $display("T=%0t PC=148 (X0--) reaches IF, X0=%0d", $time, dut.GPRegisters.input_lines[0]);
// //     end
// //     if (!reset && dut.wb_after_memwb.RegWrite && dut.writeReg_final == 1) begin
// //         $display("T=%0t COMMIT X1 <= %0d", $time, dut.data_write_to_reg);
// //     end
// //     if (!reset && dut.wb_after_memwb.RegWrite && dut.writeReg_final == 0) begin
// //         $display("T=%0t COMMIT X0 <= %0d", $time, dut.data_write_to_reg);
// //     end
// // end
    

//     always @(posedge clk) begin
//     if (!reset && dut.currentInstruction == 140) begin   // SUBS X31, X1, X0 in IF
//         $display("T=%0t SUBS_X1X0 fetched X1=%0d X0=%0d", $time,
//             dut.GPRegisters.input_lines[1], dut.GPRegisters.input_lines[0]);
//     end
//     if (!reset && dut.instruction_latch_IF_ID == 32'h54fffeab) begin  // B.LT INNER_LOOP in ID
//         $display("T=%0t BLT_INNER neg=%b BrTaken=%b stall=%b", $time,
//             dut.neg_reg, dut.BrTaken, dut.stall);
//     end
// end

// always @(posedge clk) begin
//     // B.LT NO_SWAP in ID — instruction 5400008b
//     if (!reset && dut.instruction_latch_IF_ID == 32'h5400008b) begin
//         $display("T=%0t BLT_NOSWAP neg=%b BrTaken=%b stall=%b", $time,
//             dut.neg_reg, dut.BrTaken, dut.stall);
//     end
//     // SUBS X31, X2, X3 fetched (compares array elements)
//     if (!reset && dut.instruction_latch_IF_ID == 32'heb03005f) begin
//         $display("T=%0t SUBS_X2X3 in ID, X2 in pipeline X3 in pipeline", $time);
//     end
// end

// always @(posedge clk) begin
//     if (!reset && dut.m_after_exmem.MemWrite) begin
//         $display("T=%0t MEM_WRITE addr=%0d data=%0d", $time, 
//             dut.aluOut_latch_exmem, dut.busB_forward_latch);
//     end
//     if (!reset && dut.m_after_exmem.MemRead) begin
//         $display("T=%0t MEM_READ  addr=%0d data=%0d", $time,
//             dut.aluOut_latch_exmem, dut.mem_read_data);
//     end
// end

// always @(posedge clk) begin
//     if (!reset && dut.setFlags_idex_out) begin  // any flag-setting instr in EX
//         $display("T=%0t FLAG_INSTR_EX busA=%0d busB=%0d aluOut=%0d neg=%b ovf=%b fA=%b fB=%b Rn=%0d Rm=%0d", $time,
//             dut.busA, dut.busB, dut.aluOut, dut.negative, dut.overflow,
//             dut.forwardA, dut.forwardB, dut.Rn_latch, dut.Rm_latch);
//     end
// end
    initial begin
        clk = 0;
        reset = 1;
        #100;
        reset = 0;
        #50000;
        $stop;
    end
    
    always #10 clk = ~clk;
endmodule