`timescale 1ns/10ps

module pcAdder4_tb ();
    logic [63:0] currentInstruction;
    logic [63:0] newInstruction;
    logic [63:0] nextInstruction;
    logic        write_enable, clk, reset;

    parameter ClockDelay = 5000;

    initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

    program_counter duu  (.currentInstruction(currentInstruction), .nextInstruction(newInstruction), .write_enable(1'b1), .clk(clk), .reset(reset));
    dedALU4         duu1 (.currentInstruction(currentInstruction), .newInstruction(newInstruction));


  initial begin
        reset = 1; @(posedge clk); #10;
        reset = 0; @(posedge clk); #10;
        repeat(10) begin
            $display("PC = %0d", currentInstruction);
            @(posedge clk); #10;
        end

        $stop;
    end
endmodule

