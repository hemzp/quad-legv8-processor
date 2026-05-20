# ============================================================
# runlab_test10.do - Comprehensive forwarding test
# Expected (final state):
#   X0 = 0,   X1 = 8,   X2 = 4,   X3 = 5,   X4 = 7
#   X5 = 2,   X6 = -2,  X7 = -2,  X8 = 0,   X9 = 1
#   X10 = -4, X14 = 5,  X15 = 8,  X16 = 9,  X17 = 1
#   X18 = 99
#   Mem[0] = 8, Mem[8] = 5
# REMEMBER: set BENCHMARK to "./benchmarks/test10_forwarding.arm" in instructmem.sv
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

add wave /quad_testbench/dut/HDU/cbz_stall
add wave /quad_testbench/dut/HDU/IF_ID_doCBZ
add wave /quad_testbench/dut/HDU/IF_ID_Rd
add wave /quad_testbench/dut/HDU/ID_EX_RegWrite
add wave /quad_testbench/dut/HDU/ID_EX_Rd
add wave /quad_testbench/dut/HDU/EX_MEM_RegWrite
add wave /quad_testbench/dut/HDU/EX_MEM_Rd
add wave /quad_testbench/dut/HDU/MEM_WB_RegWrite
add wave /quad_testbench/dut/HDU/MEM_WB_Rd

add wave -radix unsigned /quad_testbench/dut/pc_latch_IF_ID
add wave -radix unsigned /quad_testbench/dut/branchedOutput

# ---- Forwarding (key for this test) ----
add wave -divider "Forwarding"
add wave -color magenta -radix binary /quad_testbench/dut/forwardA
add wave -color magenta -radix binary /quad_testbench/dut/forwardB
add wave -color magenta -radix unsigned /quad_testbench/dut/Rn_latch
add wave -color magenta -radix unsigned /quad_testbench/dut/Rm_latch
add wave -color magenta -radix unsigned /quad_testbench/dut/Rd_latch_exmem
add wave -color magenta -radix unsigned /quad_testbench/dut/Rd_latch_memwb

# ---- Pipeline Latches ----
add wave -divider "Pipeline Stages"
add wave -color cyan -radix hex /quad_testbench/dut/instruction_latch_IF_ID
add wave -color cyan -radix unsigned /quad_testbench/dut/Rd_latch

# ---- ALU ----
add wave -divider "ALU"
add wave -color green -radix decimal /quad_testbench/dut/busA
add wave -color green -radix decimal /quad_testbench/dut/busB
add wave -color green -radix decimal /quad_testbench/dut/busB_forward
add wave -color green -radix decimal /quad_testbench/dut/aluOut

# ---- Memory ----
add wave -divider "Memory Access"
add wave -color yellow /quad_testbench/dut/m_after_exmem.MemRead
add wave -color yellow /quad_testbench/dut/m_after_exmem.MemWrite
add wave -color magenta -radix decimal /quad_testbench/dut/busB_forward_latch
add wave -color magenta -radix decimal /quad_testbench/dut/mem_read_data

# ---- WB Stage ----
add wave -divider "WB Stage"
add wave -color magenta /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -color magenta /quad_testbench/dut/wb_after_memwb.MemtoReg
add wave -color magenta -radix unsigned /quad_testbench/dut/writeReg_final
add wave -color magenta -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- Registers ----
add wave -divider "Registers"
add wave -color green -radix decimal -label "X0"  /quad_testbench/dut/GPRegisters/input_lines(0)
add wave -color green -radix decimal -label "X1"  /quad_testbench/dut/GPRegisters/input_lines(1)
add wave -color green -radix decimal -label "X2"  /quad_testbench/dut/GPRegisters/input_lines(2)
add wave -color green -radix decimal -label "X3"  /quad_testbench/dut/GPRegisters/input_lines(3)
add wave -color green -radix decimal -label "X4"  /quad_testbench/dut/GPRegisters/input_lines(4)
add wave -color green -radix decimal -label "X5"  /quad_testbench/dut/GPRegisters/input_lines(5)
add wave -color green -radix decimal -label "X6"  /quad_testbench/dut/GPRegisters/input_lines(6)
add wave -color green -radix decimal -label "X7"  /quad_testbench/dut/GPRegisters/input_lines(7)
add wave -color green -radix decimal -label "X8"  /quad_testbench/dut/GPRegisters/input_lines(8)
add wave -color green -radix decimal -label "X9"  /quad_testbench/dut/GPRegisters/input_lines(9)
add wave -color green -radix decimal -label "X10" /quad_testbench/dut/GPRegisters/input_lines(10)
add wave -color green -radix decimal -label "X14" /quad_testbench/dut/GPRegisters/input_lines(14)
add wave -color green -radix decimal -label "X15" /quad_testbench/dut/GPRegisters/input_lines(15)
add wave -color green -radix decimal -label "X16" /quad_testbench/dut/GPRegisters/input_lines(16)
add wave -color green -radix decimal -label "X17" /quad_testbench/dut/GPRegisters/input_lines(17)
add wave -color green -radix decimal -label "X18" /quad_testbench/dut/GPRegisters/input_lines(18)

add wave -divider "CBZ Debug"
add wave /quad_testbench/dut/HDU/IF_ID_doCBZ
add wave /quad_testbench/dut/HDU/IF_ID_Rd
add wave /quad_testbench/dut/HDU/cbz_stall
add wave /quad_testbench/dut/stall
add wave /quad_testbench/dut/cbz_zero
add wave -radix unsigned /quad_testbench/dut/read_data_2
add wave -radix hex /quad_testbench/dut/instruction_latch_IF_ID

# ---- Data Memory ----
add wave -divider "Data Memory"
add wave -color green -radix hex /quad_testbench/dut/DM/mem(0)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(8)


view wave
view structure
view signals

run -all
