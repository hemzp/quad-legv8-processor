# ============================================================
# runlab_test06.do - BL / BR / ADDI / B test
# Expected (final state):
#   X0 = 1, X1 = 0, X2 = 0
#   X3 = 1 (signifies program end)
#   X4 = 52, X5 = 64
#   X29 = 20, X30 = 68
# REMEMBER: set BENCHMARK to "./benchmarks/test06_BlBr.arm" in instructmem.sv
# ============================================================

vlib work
vlog *.sv

vsim -voptargs="+acc" -t 1ps -lib work quad_testbench

# ---- System ----
add wave -divider "System"
add wave -color white /quad_testbench/clk
add wave -color white /quad_testbench/reset

add wave -divider "Debug X30/BL Forwarding"
add wave -radix unsigned /quad_testbench/dut/Rn_latch
#add wave -radix unsigned /quad_testbench/dut/EX_MEM_Rd_actual
#add wave -radix unsigned /quad_testbench/dut/MEM_WB_Rd_actual
add wave /quad_testbench/dut/wb_after_memwb
add wave /quad_testbench/dut/forwardA
add wave -radix unsigned /quad_testbench/dut/data_write_to_reg
add wave -radix unsigned /quad_testbench/dut/busA
add wave -radix hex /quad_testbench/dut/instruction_latch_IF_ID

add wave -divider "Forwarding"
add wave /quad_testbench/dut/FU/ID_EX_Rn
add wave /quad_testbench/dut/FU/MEM_WB_Rd
add wave /quad_testbench/dut/FU/MEM_WB_RegWrite_out
add wave /quad_testbench/dut/FU/EX_MEM_Rd
add wave /quad_testbench/dut/FU/EX_MEM_RegWrite_out
add wave /quad_testbench/dut/FU/forwardA

# ---- Fetch ----
add wave -divider "Fetch"
add wave -color green -radix unsigned /quad_testbench/dut/currentInstruction
add wave -color green -radix hex      /quad_testbench/dut/instruction
add wave -color yellow /quad_testbench/dut/stall
add wave -color yellow /quad_testbench/dut/BrTaken

# ---- Branch Logic ----
add wave -divider "Branch"
add wave -color magenta /quad_testbench/dut/doBL
add wave -color magenta /quad_testbench/dut/doBR
add wave -color magenta /quad_testbench/dut/UncondBranch
add wave -color magenta -radix unsigned /quad_testbench/dut/branchedOutput
add wave -color magenta -radix unsigned /quad_testbench/dut/nextInstruction
add wave -color magenta -radix unsigned /quad_testbench/dut/read_data_2

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

# ---- WB Stage (BL writes X30 with PC+4) ----
add wave -divider "WB Stage"
add wave -color magenta /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -color magenta /quad_testbench/dut/wb_after_memwb.doBL
add wave -color magenta -radix unsigned /quad_testbench/dut/writeReg_final
add wave -color magenta -radix unsigned /quad_testbench/dut/pc_plus4_memwb_out
add wave -color magenta -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- Registers ----
add wave -divider "Registers"
add wave -color green -radix decimal -label "X0 (=1)"   /quad_testbench/dut/GPRegisters/input_lines(0)
add wave -color green -radix decimal -label "X1 (=0)"   /quad_testbench/dut/GPRegisters/input_lines(1)
add wave -color green -radix decimal -label "X2 (=0)"   /quad_testbench/dut/GPRegisters/input_lines(2)
add wave -color green -radix decimal -label "X3 (=1)"   /quad_testbench/dut/GPRegisters/input_lines(3)
add wave -color green -radix decimal -label "X4 (=52)"  /quad_testbench/dut/GPRegisters/input_lines(4)
add wave -color green -radix decimal -label "X5 (=64)"  /quad_testbench/dut/GPRegisters/input_lines(5)
add wave -color green -radix decimal -label "X29 (=20)" /quad_testbench/dut/GPRegisters/input_lines(29)
add wave -color green -radix decimal -label "X30 (=68)" /quad_testbench/dut/GPRegisters/input_lines(30)

view wave
view structure
view signals

run -all
