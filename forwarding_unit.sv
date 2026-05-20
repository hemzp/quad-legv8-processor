module forwarding_unit (forwardA, forwardB, ID_EX_Rn, ID_EX_Rm, EX_MEM_Rd, MEM_WB_Rd, EX_MEM_RegWrite_out, MEM_WB_RegWrite_out);

    output logic [1:0] forwardA, forwardB;
    input  logic [4:0] ID_EX_Rn, ID_EX_Rm, EX_MEM_Rd, MEM_WB_Rd;
    input  logic       EX_MEM_RegWrite_out, MEM_WB_RegWrite_out;


    always_comb begin
    //default
        forwardA = 2'b00;
        forwardB = 2'b00;
        
        //forwardA logic
        if (EX_MEM_RegWrite_out && (EX_MEM_Rd != 5'd31) && (EX_MEM_Rd == ID_EX_Rn))
            forwardA = 2'b10;
        else if (MEM_WB_RegWrite_out && (MEM_WB_Rd != 5'd31) && !(EX_MEM_RegWrite_out && (EX_MEM_Rd != 5'd31) && (EX_MEM_Rd == ID_EX_Rn)) && (MEM_WB_Rd == ID_EX_Rn))
            forwardA = 2'b01;
        
        //forwardB logic 
        if (EX_MEM_RegWrite_out && (EX_MEM_Rd != 5'd31) && (EX_MEM_Rd == ID_EX_Rm))
            forwardB = 2'b10;
        else if (MEM_WB_RegWrite_out && (MEM_WB_Rd != 5'd31) && !(EX_MEM_RegWrite_out && (EX_MEM_Rd != 5'd31) && (EX_MEM_Rd == ID_EX_Rm)) && (MEM_WB_Rd == ID_EX_Rm))
            forwardB = 2'b01;

end


endmodule