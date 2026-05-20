`timescale 1ns/10ps

module mux64_32_1 (read_data, input_lines, read_reg);

    output logic [63:0]        read_data;
    input  logic [63:0]        input_lines [31:0];
    input  logic [4:0]         read_reg;
    // input  logic               clk, reset;
    genvar i, j;

    // generate 
    //     for(i = 0; i < 64; i++) begin : each_mux
    //         mux32_1 duu (.out(read_data[i]), .d(input_lines[i]), .selectLines(read_reg));
    //     end
    // endgenerate

    generate
        for(i = 0; i < 64; i++) begin : each_mux
            logic [31:0] bit_reg; // 64 of these wires

            for(j = 0; j < 32; j++) begin : each_bit   
                assign bit_reg[j] = input_lines[j][i];
            end
            mux32_1 duu (.out(read_data[i]), .d(bit_reg), .selectLines(read_reg));
        end
    endgenerate
    
endmodule



