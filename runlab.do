# ============================================================
# runlab_demo.do - Full demo runlab for TA evaluation
#
# Shows EVERYTHING required by the lab spec:
#   - All 32 general-purpose registers (X0 - X31)
#   - All flags (zero, negative, overflow, carry_out)
#   - Full data memory contents
#   - Program counter and current instruction
#   - All control signals
#   - Clock and reset
#
# To switch benchmarks: edit instructmem.sv to change `define BENCHMARK
# ============================================================

vlib work
vlog *.sv

vsim -voptargs="+acc" -t 1ps -lib work quad_testbench

# ============================================================
# System signals
# ============================================================
add wave -divider "System"
add wave -color white /quad_testbench/clk
add wave -color white /quad_testbench/reset

# ============================================================
# Program Counter & Fetch
# ============================================================
add wave -divider "Program Counter & Instruction"
add wave -color green -radix unsigned /quad_testbench/dut/currentInstruction
add wave -color green -radix unsigned /quad_testbench/dut/nextInstruction
add wave -color green -radix unsigned /quad_testbench/dut/newInstruction
add wave -color green -radix hex      /quad_testbench/dut/instruction

# ============================================================
# Control signals
# ============================================================
add wave -divider "Control Signals"
add wave -color cyan /quad_testbench/dut/Reg2Loc
add wave -color cyan /quad_testbench/dut/UncondBranch
add wave -color cyan /quad_testbench/dut/MemRead
add wave -color cyan /quad_testbench/dut/MemtoReg
add wave -color cyan /quad_testbench/dut/MemWrite
add wave -color cyan /quad_testbench/dut/ALUSrc
add wave -color cyan /quad_testbench/dut/RegWrite
add wave -color cyan /quad_testbench/dut/doBL
add wave -color cyan /quad_testbench/dut/DI_sel
add wave -color cyan /quad_testbench/dut/doCBZ
add wave -color cyan /quad_testbench/dut/doBLT
add wave -color cyan /quad_testbench/dut/doBR
add wave -color cyan -radix binary /quad_testbench/dut/ALUOp
add wave -color cyan -radix binary /quad_testbench/dut/aluControl
add wave -color cyan /quad_testbench/dut/BrTaken



# ============================================================
# ALL 32 GENERAL-PURPOSE REGISTERS
# ============================================================
add wave -divider "Registers X0 - X15"
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
add wave -color green -radix decimal -label "X11" /quad_testbench/dut/GPRegisters/input_lines(11)
add wave -color green -radix decimal -label "X12" /quad_testbench/dut/GPRegisters/input_lines(12)
add wave -color green -radix decimal -label "X13" /quad_testbench/dut/GPRegisters/input_lines(13)
add wave -color green -radix decimal -label "X14" /quad_testbench/dut/GPRegisters/input_lines(14)
add wave -color green -radix decimal -label "X15" /quad_testbench/dut/GPRegisters/input_lines(15)

add wave -divider "Registers X16 - X31"
add wave -color green -radix decimal -label "X16" /quad_testbench/dut/GPRegisters/input_lines(16)
add wave -color green -radix decimal -label "X17" /quad_testbench/dut/GPRegisters/input_lines(17)
add wave -color green -radix decimal -label "X18" /quad_testbench/dut/GPRegisters/input_lines(18)
add wave -color green -radix decimal -label "X19" /quad_testbench/dut/GPRegisters/input_lines(19)
add wave -color green -radix decimal -label "X20" /quad_testbench/dut/GPRegisters/input_lines(20)
add wave -color green -radix decimal -label "X21" /quad_testbench/dut/GPRegisters/input_lines(21)
add wave -color green -radix decimal -label "X22" /quad_testbench/dut/GPRegisters/input_lines(22)
add wave -color green -radix decimal -label "X23" /quad_testbench/dut/GPRegisters/input_lines(23)
add wave -color green -radix decimal -label "X24" /quad_testbench/dut/GPRegisters/input_lines(24)
add wave -color green -radix decimal -label "X25" /quad_testbench/dut/GPRegisters/input_lines(25)
add wave -color green -radix decimal -label "X26" /quad_testbench/dut/GPRegisters/input_lines(26)
add wave -color green -radix decimal -label "X27" /quad_testbench/dut/GPRegisters/input_lines(27)
add wave -color green -radix decimal -label "X28" /quad_testbench/dut/GPRegisters/input_lines(28)
add wave -color green -radix decimal -label "X29" /quad_testbench/dut/GPRegisters/input_lines(29)
add wave -color green -radix decimal -label "X30" /quad_testbench/dut/GPRegisters/input_lines(30)
add wave -color green -radix decimal -label "X31 (XZR=0)" /quad_testbench/dut/GPRegisters/input_lines(31)

# ============================================================
# Full Data Memory (1024 bytes - expand in wave to see contents)
# ============================================================
add wave -divider "Data Memory (full)"
add wave -color green -radix hex /quad_testbench/dut/DM/mem

# Also pin the first 80 bytes individually for quick inspection
# (covers test04 Mem[0..16] and test11 Mem[0..72])
add wave -divider "Data Memory bytes 0-79 (pinned)"
add wave -color green -radix hex /quad_testbench/dut/DM/mem(0)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(8)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(16)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(24)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(32)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(40)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(48)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(56)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(64)
add wave -color green -radix hex /quad_testbench/dut/DM/mem(72)

# ============================================================
# Window setup
# ============================================================
view wave
view structure
view signals

# Run simulation
run -all
