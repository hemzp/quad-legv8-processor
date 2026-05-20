`timescale 1ns/10ps

module branchingLogic (BrTaken, UncondBranch, doCBZ, zero, neg, overflow, doBLT, doBR);

    output logic BrTaken;
    input  logic UncondBranch, doCBZ, zero, neg, overflow, doBLT, doBR;

    and #(0.05) a1 (cbz, doCBZ, zero);
    xor #(0.05) x1 (no, neg, overflow);
    and #(0.05) a2 (lt, no, doBLT);


    or #(0.05) br (BrTaken, UncondBranch, cbz, lt, doBR);

endmodule

