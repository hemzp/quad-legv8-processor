# ============================================================
# runlab_test05.do - B.LT / SUBS / ADDI / B test
# Expected (final state):
#   X0 = 1
#   X1 = 1
# REMEMBER: set BENCHMARK to "./benchmarks/test05_Blt.arm" in instructmem.sv
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

# ---- Branch Logic ----
add wave -divider "Branch"
add wave -color magenta /quad_testbench/dut/doBLT
add wave -color magenta /quad_testbench/dut/doCBZ
add wave -color magenta /quad_testbench/dut/UncondBranch
add wave -color magenta -radix unsigned /quad_testbench/dut/branchedOutput
add wave -color magenta -radix unsigned /quad_testbench/dut/nextInstruction

add wave /quad_testbench/reset
add wave -radix decimal /quad_testbench/dut/aluOut
add wave /quad_testbench/dut/RegWrite
add wave /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -radix unsigned /quad_testbench/dut/writeReg_final
add wave -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- Flag Registers (critical for B.LT) ----
add wave -divider "Flags (registered, negedge)"
add wave -color yellow /quad_testbench/dut/zero_reg
add wave -color yellow /quad_testbench/dut/neg_reg
add wave -color yellow /quad_testbench/dut/ovf_reg
add wave -color yellow /quad_testbench/dut/carry_reg

# ---- Flags (combinational from ALU) ----
add wave -divider "Flags (ALU comb)"
add wave -color yellow /quad_testbench/dut/zero
add wave -color yellow /quad_testbench/dut/negative
add wave -color yellow /quad_testbench/dut/overflow
add wave -color yellow /quad_testbench/dut/carry_out

# ---- Pipeline Latches ----
add wave -divider "Pipeline Stages"
add wave -color cyan -radix hex /quad_testbench/dut/instruction_latch_IF_ID
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch_exmem
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch_memwb

# ---- ALU ----
add wave -divider "ALU"
add wave -color green -radix decimal /quad_testbench/dut/busA
add wave -color green -radix decimal /quad_testbench/dut/busB
add wave -color green -radix decimal /quad_testbench/dut/aluOut

# ---- WB Stage ----
add wave -divider "WB Stage"
add wave -color magenta /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -color magenta -radix unsigned /quad_testbench/dut/writeReg_final
add wave -color magenta -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- Registers X0-X3 ----
add wave -divider "Registers"
add wave -color green -radix decimal -label "X0 (=1)" /quad_testbench/dut/GPRegisters/input_lines(0)
add wave -color green -radix decimal -label "X1 (=1)" /quad_testbench/dut/GPRegisters/input_lines(1)
add wave -color green -radix decimal -label "X2"      /quad_testbench/dut/GPRegisters/input_lines(2)
add wave -color green -radix decimal -label "X3"      /quad_testbench/dut/GPRegisters/input_lines(3)

view wave
view structure
view signals

run -all
