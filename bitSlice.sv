`timescale 1ns/10ps

module bitSlice (a_bit, b_bit, select_bits, c_in, sum, c_out , result);
    output logic        result, sum, c_out;
    input  logic        a_bit, b_bit, c_in;
    input  logic [2:0]  select_bits;

    logic bitwiseAnd, bitwiseOr, bitwiseXor, b;

    and #(0.05) gateOp1 (bitwiseAnd, a_bit, b_bit);
    or  #(0.05) gateOp2 (bitwiseOr, a_bit, b_bit);
    xor #(0.05) gateOp3 (bitwiseXor, a_bit, b_bit);

    xor #(0.05) addSub (b, b_bit, select_bits[0]); //control logic for either add/sub

    fullAdder duu1 (.a(a_bit), .b(b), .c_in(c_in), .sum(sum), .c_out(c_out));

    
    logic [7:0] mux_in;
    assign mux_in = {1'b0, bitwiseXor, bitwiseOr, bitwiseAnd, sum, sum, 1'b0, b_bit};
    //               d[7]    d[6]       d[5]       d[4]       d[3] d[2] d[1]  d[0]

    mux8_1 duu2 (.out(result), .d(mux_in), .selectLines(select_bits));



endmodule //for first slice mode is 
