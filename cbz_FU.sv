`timescale 1ns/10ps

module cbz_FU (cbz_match_ex, cbz_match_mem, cbz_match_wb, IF_ID_Rd, ID_EX_Rd, ID_EX_RegWrite, EX_MEM_Rd, EX_MEM_RegWrite, MEM_WB_Rd, MEM_WB_RegWrite);
    output logic       cbz_match_ex, cbz_match_mem, cbz_match_wb;
    input  logic [4:0] IF_ID_Rd;
    input  logic [4:0] ID_EX_Rd, EX_MEM_Rd, MEM_WB_Rd;
    input  logic       ID_EX_RegWrite, EX_MEM_RegWrite, MEM_WB_RegWrite;

    //Stalling if pending write to CBZ
    assign cbz_match_ex  = ID_EX_RegWrite  && (ID_EX_Rd  == IF_ID_Rd) && (ID_EX_Rd  != 5'd31);
    assign cbz_match_mem = EX_MEM_RegWrite && (EX_MEM_Rd == IF_ID_Rd) && (EX_MEM_Rd != 5'd31);
    assign cbz_match_wb  = MEM_WB_RegWrite && (MEM_WB_Rd == IF_ID_Rd) && (MEM_WB_Rd != 5'd31);

endmodule