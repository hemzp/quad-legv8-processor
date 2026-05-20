`timescale 1ns/10ps

module decoder3_8(enable_in, a0, a1, a2, write_enable);
    output logic [7:0]      write_enable;
    input  logic            a0, a1, a2;
    input  logic            enable_in;

    not #(0.05) g1 (not_a0, a0);
    not #(0.05) g2 (not_a1, a1);
    not #(0.05) g3 (not_a2, a2);

    and #(0.05) and1 (write_enable[0], enable_in, not_a0, not_a1, not_a2);
    and #(0.05) and2 (write_enable[1], enable_in, a0, not_a1, not_a2);
    and #(0.05) and3 (write_enable[2], enable_in, not_a0, a1, not_a2);
    and #(0.05) and4 (write_enable[3], enable_in, a0, a1, not_a2);
    and #(0.05) and5 (write_enable[4], enable_in, not_a0, not_a1, a2);
    and #(0.05) and6 (write_enable[5], enable_in, a0, not_a1, a2);
    and #(0.05) and7 (write_enable[6], enable_in, not_a0, a1, a2);
    and #(0.05) and8 (write_enable[7], enable_in, a0, a1, a2);

endmodule

module decoder3_8_tb();
    logic [7:0] write_enable;
    logic a0, a1, a2, enable_in;

    decoder3_8 dut (.a0(a0), .a1(a1), .a2(a2), .enable_in(enable_in), .write_enable(write_enable));

    initial begin 
        {a0, a1, a2, enable_in} = 4'b0000;
        #(200);
        {a0, a1, a2, enable_in} = 4'b0001;
        #(200); 
        {a0, a1, a2, enable_in} = 4'b1001;
        #(200);
        {a0, a1, a2, enable_in} = 4'b0101;
        #(200);
        {a0, a1, a2, enable_in} = 4'b1101;
        #(200);
        {a0, a1, a2, enable_in} = 4'b0011;
        #(200);
        {a0, a1, a2, enable_in} = 4'b1011;
        #(200);
        {a0, a1, a2, enable_in} = 4'b0111;
        #(200);
        {a0, a1, a2, enable_in} = 4'b1111;
        #(200);
        $stop;
    end

endmodule