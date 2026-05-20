`timescale 1ns/10ps


module register_array # (parameter WIDTH = 32) (data, write_data, write_enable, reset, clk);
    output logic [63:0]         data;
    input  logic [63:0]         write_data;
    input  logic [WIDTH - 1:0]  write_enable; //decoder output
    input  logic                reset, clk;


    genvar i;

    generate
        for(i = 0; i < WIDTH; i++) begin: each_reg
            D_FF64 dff64 (.q(data[i]), .d(write_data), .write_enable(write_enable[i]), .reset(reset), .clk(clk));
        end
    endgenerate

endmodule    




