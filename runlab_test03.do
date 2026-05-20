# ============================================================
# runlab_test03.do - CBZ / B / ADDI test
# Expected (final state):
#   X0 = 1   (constant 1 register)
#   X1 = 0   (error register, must stay 0)
#   X2 = 4   (delay slot counter, pipelined CPU)
#   X3 = 1   (signifies program end was reached)
#   X4 = 31  (16+8+4+2+1 = bit set per successful branch)
#   X5 = 0   (must stay 0 - accelerated branches working)
# REMEMBER: set BENCHMARK to "./benchmarks/test03_CbzB.arm" in instructmem.sv
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
add wave -color magenta /quad_testbench/dut/doCBZ
add wave -color magenta /quad_testbench/dut/UncondBranch
add wave -color magenta /quad_testbench/dut/doBLT
add wave -color magenta /quad_testbench/dut/doBR
add wave -color magenta -radix unsigned /quad_testbench/dut/branchedOutput
add wave -color magenta -radix unsigned /quad_testbench/dut/nextInstruction

# ---- Pipeline Latches ----
add wave -divider "Pipeline Stages"
add wave -color cyan -radix hex /quad_testbench/dut/instruction_latch_IF_ID
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch_exmem
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch_memwb

# ---- Flag Registers (negedge) ----
add wave -divider "Flags (registered)"
add wave -color yellow /quad_testbench/dut/zero_reg
add wave -color yellow /quad_testbench/dut/neg_reg
add wave -color yellow /quad_testbench/dut/ovf_reg

# ---- ALU ----
add wave -divider "ALU"
add wave -color green -radix decimal /quad_testbench/dut/busA
add wave -color green -radix decimal /quad_testbench/dut/busB
add wave -color green -radix decimal /quad_testbench/dut/aluOut

# ---- WB Stage Control ----
add wave -divider "WB Stage"
add wave -color magenta /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -color magenta /quad_testbench/dut/wb_after_memwb.doBL
add wave -color magenta -radix unsigned /quad_testbench/dut/writeReg_final
add wave -color magenta -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- Registers X0-X5 ----
add wave -divider "Registers"
add wave -color green -radix decimal -label "X0 (=1)"    /quad_testbench/dut/GPRegisters/input_lines(0)
add wave -color green -radix decimal -label "X1 (=0 err)" /quad_testbench/dut/GPRegisters/input_lines(1)
add wave -color green -radix decimal -label "X2 (delay)"  /quad_testbench/dut/GPRegisters/input_lines(2)
add wave -color green -radix decimal -label "X3 (=1 end)" /quad_testbench/dut/GPRegisters/input_lines(3)
add wave -color green -radix decimal -label "X4 (=31)"   /quad_testbench/dut/GPRegisters/input_lines(4)
add wave -color green -radix decimal -label "X5 (=0)"    /quad_testbench/dut/GPRegisters/input_lines(5)

view wave
view structure
view signals

run -all
