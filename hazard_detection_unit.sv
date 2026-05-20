module hazard_detection_unit (stall, ID_EX_MemRead, ID_EX_Rd, IF_ID_Rn, IF_ID_Rm, IF_ID_doBLT, ID_EX_setFlags, IF_ID_doCBZ, IF_ID_Rd, ID_EX_RegWrite, EX_MEM_RegWrite, MEM_WB_RegWrite, EX_MEM_Rd, MEM_WB_Rd);
    output logic stall;
    input  logic ID_EX_MemRead, IF_ID_doBLT, ID_EX_setFlags;
    input  logic IF_ID_doCBZ;
    input  logic ID_EX_RegWrite, EX_MEM_RegWrite, MEM_WB_RegWrite;
    input  logic [4:0] ID_EX_Rd, EX_MEM_Rd, MEM_WB_Rd;
    input  logic [4:0] IF_ID_Rn, IF_ID_Rm, IF_ID_Rd;

    logic load_use_stall, flag_stall, cbz_stall;

    assign load_use_stall = ID_EX_MemRead && (ID_EX_Rd != 5'd31) && ((ID_EX_Rd == IF_ID_Rn) || (ID_EX_Rd == IF_ID_Rm));
    
    assign flag_stall = IF_ID_doBLT && ID_EX_setFlags;
    
    assign cbz_stall = IF_ID_doCBZ && (IF_ID_Rd != 5'd31) && ((ID_EX_RegWrite  && ID_EX_Rd  == IF_ID_Rd) || (EX_MEM_RegWrite && EX_MEM_Rd == IF_ID_Rd) || (MEM_WB_RegWrite && MEM_WB_Rd == IF_ID_Rd));

    assign stall = load_use_stall || flag_stall;
endmodule
