# ============================================================
# runlab_test11.do - Bubble sort of 10 elements - DEBUG VERSION
# Expected (final state):
#   X11=1, X12=2, X13=3, X14=4, X15=5
#   X16=6, X17=7, X18=8, X19=9, X20=10
#   Mem[0..72] should hold sorted values 1..10
# REMEMBER: set BENCHMARK to "./benchmarks/test11_Sort.arm" in instructmem.sv
# ============================================================

vlib work
vlog *.sv

vsim -voptargs="+acc" -t 1ps -lib work quad_testbench

# ---- System ----
add wave -divider "System"
add wave -color white /quad_testbench/clk
add wave -color white /quad_testbench/reset

# ---- Fetch / Pipeline Stages ----
add wave -divider "Pipeline Stages"
add wave -color green -radix unsigned /quad_testbench/dut/currentInstruction
add wave -color green -radix hex      /quad_testbench/dut/instruction

# ---- Key Registers (loop counters + constant) ----
# X0 = outer loop counter (should count 9->8->7->...->0)
# X1 = inner loop counter
# X4 = 8*X1 (address offset)
# X5 = constant 1 (used for decrementing X0)
add wave -divider "Loop Control Registers"
add wave -color cyan -radix decimal -label "X0 (outer ctr, 9->0)" /quad_testbench/dut/GPRegisters/input_lines(0)
add wave -color cyan -radix decimal -label "X1 (inner ctr)"       /quad_testbench/dut/GPRegisters/input_lines(1)
add wave -color cyan -radix decimal -label "X4 (addr 8*X1)"       /quad_testbench/dut/GPRegisters/input_lines(4)
add wave -color cyan -radix decimal -label "X5 (=1 const)"        /quad_testbench/dut/GPRegisters/input_lines(5)

# ---- Hazard / Stall ----
add wave -divider "Hazard"
add wave -color yellow /quad_testbench/dut/stall
add wave -color yellow /quad_testbench/dut/BrTaken

# ---- Forwarding ----
add wave -divider "Forwarding"
add wave -color magenta -radix binary /quad_testbench/dut/forwardA
add wave -color magenta -radix binary /quad_testbench/dut/forwardB

# ---- Branch Logic ----
add wave -divider "Branch"
add wave -color magenta /quad_testbench/dut/doBLT
add wave -color magenta /quad_testbench/dut/doCBZ

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

# ---- WB Stage (critical for "registers all zero" bug) ----
add wave -divider "WB Stage"
add wave -color magenta /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -color magenta -radix unsigned -label "WriteReg (dest)" /quad_testbench/dut/writeReg_final
add wave -color magenta -radix decimal  -label "WriteData"       /quad_testbench/dut/data_write_to_reg

# ---- Sorted Results X11-X20 ----
add wave -divider "Sorted Output Registers"
add wave -color green -radix decimal -label "X11 (=1)"  /quad_testbench/dut/GPRegisters/input_lines(11)
add wave -color green -radix decimal -label "X12 (=2)"  /quad_testbench/dut/GPRegisters/input_lines(12)
add wave -color green -radix decimal -label "X13 (=3)"  /quad_testbench/dut/GPRegisters/input_lines(13)
add wave -color green -radix decimal -label "X14 (=4)"  /quad_testbench/dut/GPRegisters/input_lines(14)
add wave -color green -radix decimal -label "X15 (=5)"  /quad_testbench/dut/GPRegisters/input_lines(15)
add wave -color green -radix decimal -label "X16 (=6)"  /quad_testbench/dut/GPRegisters/input_lines(16)
add wave -color green -radix decimal -label "X17 (=7)"  /quad_testbench/dut/GPRegisters/input_lines(17)
add wave -color green -radix decimal -label "X18 (=8)"  /quad_testbench/dut/GPRegisters/input_lines(18)
add wave -color green -radix decimal -label "X19 (=9)"  /quad_testbench/dut/GPRegisters/input_lines(19)
add wave -color green -radix decimal -label "X20 (=10)" /quad_testbench/dut/GPRegisters/input_lines(20)

# ---- Data Memory (sorted array) ----
add wave -divider "Data Memory (sorted 1..10)"
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(0)
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(8)
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(16)
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(24)
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(32)
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(40)
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(48)
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(56)
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(64)
add wave -color cyan -radix decimal /quad_testbench/dut/DM/mem(72)

view wave
view structure
view signals

run -all
