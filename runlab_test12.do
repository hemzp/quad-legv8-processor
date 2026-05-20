# ============================================================
# runlab_test12.do - Recursive Fibonacci(6) test
# Expected (final state):
#   X0  = 6  (N)
#   X1  = 8  (Result of fibonacci(6))
#   X28 = 8
#   X30 = 196
# REMEMBER: set BENCHMARK to "./benchmarks/test12_Fibonacci.arm" in instructmem.sv
# NOTE: heavy recursion - extend simulation time as needed
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

# ---- Branch Logic (BL/BR critical here) ----
add wave -divider "Branch"
add wave -color magenta /quad_testbench/dut/doBL
add wave -color magenta /quad_testbench/dut/doBR
add wave -color magenta /quad_testbench/dut/doBLT
add wave -color magenta /quad_testbench/dut/UncondBranch
add wave -color magenta -radix unsigned /quad_testbench/dut/branchedOutput
add wave -color magenta -radix unsigned /quad_testbench/dut/nextInstruction
add wave -color magenta -radix unsigned /quad_testbench/dut/read_data_2

# ---- Forwarding ----
add wave -divider "Forwarding"
add wave -color magenta -radix binary /quad_testbench/dut/forwardA
add wave -color magenta -radix binary /quad_testbench/dut/forwardB

# ---- Flag Registers ----
add wave -divider "Flags"
add wave -color yellow /quad_testbench/dut/zero_reg
add wave -color yellow /quad_testbench/dut/neg_reg
add wave -color yellow /quad_testbench/dut/ovf_reg

# ---- ALU ----
add wave -divider "ALU"
add wave -color green -radix decimal /quad_testbench/dut/busA
add wave -color green -radix decimal /quad_testbench/dut/busB
add wave -color green -radix decimal /quad_testbench/dut/aluOut

# ---- WB Stage (BL writes X30 here) ----
add wave -divider "WB Stage"
add wave -color magenta /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -color magenta /quad_testbench/dut/wb_after_memwb.doBL
add wave -color magenta -radix unsigned /quad_testbench/dut/writeReg_final
add wave -color magenta -radix unsigned /quad_testbench/dut/pc_plus4_memwb_out
add wave -color magenta -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- Registers (key for Fibonacci) ----
add wave -divider "Registers"
add wave -color green -radix decimal -label "X0 (N=6)"     /quad_testbench/dut/GPRegisters/input_lines(0)
add wave -color green -radix decimal -label "X1 (fib=8)"   /quad_testbench/dut/GPRegisters/input_lines(1)
add wave -color green -radix decimal -label "X28 (=8)"     /quad_testbench/dut/GPRegisters/input_lines(28)
add wave -color green -radix decimal -label "X29 (frame)"  /quad_testbench/dut/GPRegisters/input_lines(29)
add wave -color green -radix decimal -label "X30 (=196)"   /quad_testbench/dut/GPRegisters/input_lines(30)
add wave -color green -radix decimal -label "X31 (=0)"     /quad_testbench/dut/GPRegisters/input_lines(31)

view wave
view structure
view signals

run -all
