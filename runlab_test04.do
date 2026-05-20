# ============================================================
# runlab_test04.do - LDUR / STUR test
# Expected (final state):
#   X0 = 1, X1 = 2, X2 = 3
#   X3 = 8, X4 = 11
#   X5 = 1, X6 = 2, X7 = 3
#   Mem[0] = 1, Mem[8] = 2, Mem[16] = 3
# REMEMBER: set BENCHMARK to "./benchmarks/test04_LdurStur.arm" in instructmem.sv
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

# ---- Forwarding ----
add wave -divider "Forwarding"
add wave -color magenta -radix binary /quad_testbench/dut/forwardA
add wave -color magenta -radix binary /quad_testbench/dut/forwardB

# ---- Memory ----
add wave -divider "Memory Access"
add wave -color yellow /quad_testbench/dut/m_after_exmem.MemRead
add wave -color yellow /quad_testbench/dut/m_after_exmem.MemWrite
add wave -color magenta -radix unsigned /quad_testbench/dut/aluOut_latch_exmem
add wave -color magenta -radix decimal /quad_testbench/dut/busB_forward_latch
add wave -color magenta -radix decimal /quad_testbench/dut/mem_read_data

# ---- ALU ----
add wave -divider "ALU"
add wave -color green -radix decimal /quad_testbench/dut/busA
add wave -color green -radix decimal /quad_testbench/dut/busB
add wave -color green -radix decimal /quad_testbench/dut/aluOut

# ---- WB Stage ----
add wave -divider "WB Stage"
add wave -color magenta /quad_testbench/dut/wb_after_memwb.RegWrite
add wave -color magenta /quad_testbench/dut/wb_after_memwb.MemtoReg
add wave -color magenta -radix unsigned /quad_testbench/dut/writeReg_final
add wave -color magenta -radix decimal /quad_testbench/dut/data_write_to_reg

# ---- Registers X0-X7 ----
add wave -divider "Registers"
add wave -color green -radix decimal -label "X0 (=1)"  /quad_testbench/dut/GPRegisters/input_lines(0)
add wave -color green -radix decimal -label "X1 (=2)"  /quad_testbench/dut/GPRegisters/input_lines(1)
add wave -color green -radix decimal -label "X2 (=3)"  /quad_testbench/dut/GPRegisters/input_lines(2)
add wave -color green -radix decimal -label "X3 (=8)"  /quad_testbench/dut/GPRegisters/input_lines(3)
add wave -color green -radix decimal -label "X4 (=11)" /quad_testbench/dut/GPRegisters/input_lines(4)
add wave -color green -radix decimal -label "X5 (=1)"  /quad_testbench/dut/GPRegisters/input_lines(5)
add wave -color green -radix decimal -label "X6 (=2)"  /quad_testbench/dut/GPRegisters/input_lines(6)
add wave -color green -radix decimal -label "X7 (=3)"  /quad_testbench/dut/GPRegisters/input_lines(7)

# ---- Data Memory ----
add wave -divider "Data Memory bytes"
add wave -color green -radix hex /quad_testbench/dut/DM/mem(0)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(1)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(2)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(3)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(4)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(5)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(6)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(7)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(8)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(16)


view wave
view structure
view signals

run -all
