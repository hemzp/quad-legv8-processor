# ============================================================
# runlab_test01.do - ADDI / B test
# Expected (final state):
#   X0 = 0, X1 = 1, X2 = 2, X3 = 3, X4 = 4
#   Should halt at infinite branch loop
# REMEMBER: set BENCHMARK to "./benchmarks/test01_AddiB.arm" in instructmem.sv
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

# ---- WB Stage Control ----
add wave -divider "WB Stage"
add wave -color magenta /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -color magenta /quad_testbench/dut/wb_after_memwb.MemtoReg
add wave -color magenta /quad_testbench/dut/wb_after_memwb.doBL
add wave -color magenta -radix unsigned /quad_testbench/dut/writeReg_final
add wave -color magenta -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- ALU ----
add wave -divider "ALU"
add wave -color green -radix decimal /quad_testbench/dut/busA
add wave -color green -radix decimal /quad_testbench/dut/busB
add wave -color green -radix decimal /quad_testbench/dut/aluOut

# ---- Registers X0-X4 ----
add wave -divider "Registers"
add wave -color green -radix decimal -label "X0" /quad_testbench/dut/GPRegisters/input_lines(0)
add wave -color green -radix decimal -label "X1" /quad_testbench/dut/GPRegisters/input_lines(1)
add wave -color green -radix decimal -label "X2" /quad_testbench/dut/GPRegisters/input_lines(2)
add wave -color green -radix decimal -label "X3" /quad_testbench/dut/GPRegisters/input_lines(3)
add wave -color green -radix decimal -label "X4" /quad_testbench/dut/GPRegisters/input_lines(4)

view wave
view structure
view signals

run -all
