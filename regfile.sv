`timescale 1ns/10ps

module regfile (read_data_1, read_data_2, read_reg_1, read_reg_2, write_reg, write_data, RegWrite, clk, reset);

    output logic [63:0] read_data_1, read_data_2;
    input  logic [63:0] write_data;
    input  logic [4:0]  read_reg_1, read_reg_2, write_reg;
    input  logic        RegWrite, clk, reset;

    logic [31:0] write_enable; // interm. signal for connnecting output of decoder to registers
    logic [63:0] input_lines [31:0]; //interm. signal for connecting out of reg_array to input lines of mux
    logic clk_inv;
    not (clk_inv, clk);

    decoder5_32 the_decoder (.write_enable(write_enable), 
                            .a0(write_reg[0]), 
                            .a1(write_reg[1]), 
                            .a2(write_reg[2]), 
                            .a3(write_reg[3]), 
                            .a4(write_reg[4]), 
                            .enable_in(1'b1), 
                            .RegWrite(RegWrite));

    mux64_32_1 read_1 (.read_data(read_data_1), .input_lines(input_lines), .read_reg(read_reg_1));
    mux64_32_1 read_2 (.read_data(read_data_2), .input_lines(input_lines), .read_reg(read_reg_2));


    genvar i;
    //creating the register array (32 register each containing 64 bits of information)
    generate
        for(i = 0; i < 31; i++) begin: registers
            D_FF64 dff64 (.q(input_lines[i]), .d(write_data), .write_enable(write_enable[i]), .reset(reset), .clk(clk_inv));
        end
    endgenerate

    assign input_lines[31] = 64'b0;
endmodule










