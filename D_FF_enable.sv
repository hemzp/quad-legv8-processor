`timescale 1ns/10ps

module D_FF_enable (q, d, write_enable, reset, clk);
    output q;
    input d, write_enable, reset, clk;

    logic d_in, q_out, not_we, and1, and2;

    // d_in = (~write_enable & q_out) | (write_enable & d);
    not #(0.05) gate1 (not_we, write_enable);
    and #(0.05) gate2 (and1, not_we, q_out);
    and #(0.05) gate3 (and2, write_enable, d);
    or  #(0.05) gate4 (d_in, and1, and2); 

    D_FF d0(.q(q_out), .d(d_in), .reset(reset), .clk(clk));

    assign q = q_out;

endmodule

module D_FF_enable_tb();
    logic q;
    logic d, write_enable, reset, clk;

    parameter T = 200;
    D_FF_enable dut (.q(q), .d(d), .write_enable(write_enable), .reset(reset), .clk(clk));

    initial begin
        clk <= 0;
        forever #(T/2) clk <= ~clk;
    end

    initial begin   
        {reset, d, write_enable} = 3'b100;
        @(posedge clk); 
        #1; 

        reset <= 0;


        @(posedge clk); 
        #1;
        {d, write_enable} = 2'b00; 

        #(T);     

        @(posedge clk); 
        #1;
        {d, write_enable} = 2'b01;

        #(T);

        @(posedge clk); 
        #1;
        {d, write_enable} = 2'b10;

        #(T);

        @(posedge clk); 
        #1;
        {d, write_enable} = 2'b11;

        #(T);

        @(posedge clk);
        #1;
        {d, write_enable} = 2'b10;

        #(T);

        @(posedge clk); 
        #1;
        {d, write_enable} = 2'b00; 

        #(T);     

        @(posedge clk); 
        #1;
        {d, write_enable} = 2'b01;

        #(T);

        @(posedge clk); 
        #1;
        {d, write_enable} = 2'b10;

        #(T);

        @(posedge clk); 
        #1;
        {d, write_enable} = 2'b11;


        
        
        
        $stop;
    end 
endmodule 

        






 