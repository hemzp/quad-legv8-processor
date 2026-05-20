`timescale 1ns/10ps

module signExtender #(parameter IMM_WIDTH = 26, parameter IMM_START = 0) (instruction_input, sign_extended_instruction);
    output logic [63:0] sign_extended_instruction;
    input  logic [31:0] instruction_input;

    genvar i;
    generate
        for(i = 0; i < IMM_WIDTH; i++) begin: passthrough
            assign sign_extended_instruction[i] = instruction_input[IMM_START + i];
        end

        for(i = IMM_WIDTH; i < 64; i++) begin: extension
            assign sign_extended_instruction[i] = instruction_input[IMM_START + IMM_WIDTH - 1];
        end
    endgenerate
endmodule

//detection for zeroExtension vs sign_extended_instruction


module signExtender_tb;

    logic [31:0] instruction;
    logic [63:0] ext_b, ext_cb, ext_d, ext_i;

    // B/BL: 26-bit immediate, bits [25:0]
    signExtender #(.IMM_WIDTH(26), .IMM_START(0)) se_b (
        .instruction_input(instruction),
        .sign_extended_instruction(ext_b)
    );

    // B.LT/CBZ: 19-bit immediate, bits [23:5]
    signExtender #(.IMM_WIDTH(19), .IMM_START(5)) se_cb (
        .instruction_input(instruction),
        .sign_extended_instruction(ext_cb)
    );

    // LDUR/STUR: 9-bit immediate, bits [20:12]
    signExtender #(.IMM_WIDTH(9), .IMM_START(12)) se_d (
        .instruction_input(instruction),
        .sign_extended_instruction(ext_d)
    );

    // ADDI: 12-bit immediate, bits [21:10]
    signExtender #(.IMM_WIDTH(12), .IMM_START(10)) se_i (
        .instruction_input(instruction),
        .sign_extended_instruction(ext_i)
    );

    initial begin
        // ADDI X1, X2, #42, zeroExtension
        instruction = 32'b1001000100_000000101010_00010_00001;
        #(200);
        assert(ext_i == 64'h000000000000002A) else $error("ADDI failed");

        // B #-3  
        instruction = {6'b000101, 26'b11_1111_1111_1111_1111_1111_1101};
        #(200);
        assert(ext_b == 64'hFFFFFFFFFFFFFFFD) else $error("B failed");

        // B.LT #10 imm19 = 10, sign bit = 0, zero-extend
        instruction = {8'b01010100, 19'd10, 5'b01011};
        #(200);
        assert(ext_cb == 64'h000000000000000A) else $error("B.LT failed");

        // BL #100  imm26 = 100, sign bit = 0, zero-extend
        instruction = {6'b100101, 26'd100};
        #(200);
        assert(ext_b == 64'h0000000000000064) else $error("BL failed");

        // CBZ X3, #-5  imm19 = -5, sign bit = 1, sign-extend
        instruction = {8'b10110100, 19'b111_1111_1111_1111_1011, 5'b00011};
        #(200);
        assert(ext_cb == 64'hFFFFFFFFFFFFFFFB) else $error("CBZ failed");

        // LDUR X5, [X10, #7]  imm9 = 7, sign bit = 0, zero-extend
        instruction = {11'b11111000010, 9'd7, 2'b00, 5'b01010, 5'b00101};
        #(200);
        assert(ext_d == 64'h0000000000000007) else $error("LDUR failed");

        // STUR X8, [X12, #-4]  imm9 = -4, sign bit = 1, sign-extend
        instruction = {11'b11111000000, 9'b111111100, 2'b00, 5'b01100, 5'b01000};
        #(200);
        assert(ext_d == 64'hFFFFFFFFFFFFFFFC) else $error("STUR failed");

        $stop;
    end

endmodule






