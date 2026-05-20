# ============================================================
# runlab_test02.do - ADDS / SUBS / ADDI test
# Expected (final state):
#   X0 = 1, X1 = -1, X2 = 2, X3 = -3, X4 = -2,
#   X5 = -5, X6 = 0, X7 = -6
#   Final flags: negative=1, carry_out=1, overflow=0, zero=0
# REMEMBER: set BENCHMARK to "./benchmarks/test02_AddsSubs.arm" in instructmem.sv
# ============================================================

vlib work
vlog *.sv

vsim -voptargs="+acc" -t 1ps -lib work quad_testbench

# ---- System ----
add wave -divider "System"
add wave -color white /quad_testbench/clk
add wave -color white /quad_testbench/reset

# ---- Fetch ----
add wave -divider "Fetch"
add wave -color green -radix unsigned /quad_testbench/dut/currentInstruction
add wave -color green -radix hex      /quad_testbench/dut/instruction
add wave -color yellow /quad_testbench/dut/stall
add wave -color yellow /quad_testbench/dut/BrTaken

# ---- Pipeline Latches ----
add wave -divider "Pipeline Stages"
add wave -color cyan -radix hex /quad_testbench/dut/instruction_latch_IF_ID
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch_exmem
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch_memwb

# ---- Control ----
add wave -divider "Control"
add wave -color cyan  /quad_testbench/dut/Reg2Loc
add wave -color cyan  /quad_testbench/dut/ALUSrc
add wave -color cyan  /quad_testbench/dut/RegWrite
add wave -color cyan  -radix binary /quad_testbench/dut/ALUOp
add wave -color cyan  -radix binary /quad_testbench/dut/aluControl

# ---- ALU ----
add wave -divider "ALU"
add wave -color green -radix decimal /quad_testbench/dut/busA
add wave -color green -radix decimal /quad_testbench/dut/busB
add wave -color green -radix decimal /quad_testbench/dut/aluOut

# ---- FU ----
add wave -divider "FU"
add wave -radix decimal /quad_testbench/dut/forwardA
add wave -radix decimal /quad_testbench/dut/forwardB
add wave -radix decimal /quad_testbench/dut/aluOut_latch_exmem
add wave -radix decimal /quad_testbench/dut/aluOut
add wave -radix decimal /quad_testbench/dut/read_data1_latch_ID_EX
add wave -radix decimal /quad_testbench/dut/read_data2_latch_ID_EX
add wave -radix decimal /quad_testbench/dut/busB_forward
add wave -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- Flags (combinational ALU) ----
add wave -divider "Flags (ALU comb)"
add wave -color yellow /quad_testbench/dut/zero
add wave -color yellow /quad_testbench/dut/negative
add wave -color yellow /quad_testbench/dut/overflow
add wave -color yellow /quad_testbench/dut/carry_out

# ---- Flags (registered, negedge) ----
add wave -divider "Flags (registered)"
add wave -color yellow /quad_testbench/dut/zero_reg
add wave -color yellow /quad_testbench/dut/neg_reg
add wave -color yellow /quad_testbench/dut/ovf_reg
add wave -color yellow /quad_testbench/dut/carry_reg

# ---- WB Stage ----
add wave -divider "WB Stage"
add wave -color magenta /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -color magenta -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- Registers X0-X7 ----
add wave -divider "Registers"
add wave -color green -radix decimal -label "X0 (=1)"  /quad_testbench/dut/GPRegisters/input_lines(0)
add wave -color green -radix decimal -label "X1 (=-1)" /quad_testbench/dut/GPRegisters/input_lines(1)
add wave -color green -radix decimal -label "X2 (=2)"  /quad_testbench/dut/GPRegisters/input_lines(2)
add wave -color green -radix decimal -label "X3 (=-3)" /quad_testbench/dut/GPRegisters/input_lines(3)
add wave -color green -radix decimal -label "X4 (=-2)" /quad_testbench/dut/GPRegisters/input_lines(4)
add wave -color green -radix decimal -label "X5 (=-5)" /quad_testbench/dut/GPRegisters/input_lines(5)
add wave -color green -radix decimal -label "X6 (=0)"  /quad_testbench/dut/GPRegisters/input_lines(6)
add wave -color green -radix decimal -label "X7 (=-6)" /quad_testbench/dut/GPRegisters/input_lines(7)

view wave
view structure
view signals

run -all
