# QuadCore-5 — A 5-Stage Pipelined ARMv8 (LEGv8) CPU

A gate-level, 64-bit pipelined processor implementing a teaching subset of ARMv8 (LEGv8), written in SystemVerilog and simulated in ModelSim. The datapath is built from primitive gates (`and`, `or`, `not`, `xor`, custom D-flip-flops with explicit `#delay`); only the three control modules — `control`, `hazard_detection_unit`, `forwarding_unit`, plus the small `cbz_FU` — use behavioral RTL.

## What's Implemented

**Pipeline.** Classic 5-stage: IF → ID → EX → MEM → WB. Pipeline registers (`if_id_reg`, `id_ex_reg`, `ex_mem_reg`, `mem_wb_reg`) latch every datapath and control signal between stages.

**Instruction set.** `ADDI`, `ADDS`, `SUBS`, `LDUR`, `STUR`, `CBZ`, `B`, `B.LT`, `BL`, `BR` — enough to run the provided benchmarks (`test01`–`test12`) including bubble sort and Fibonacci.

**Hazard handling.**
- *Forwarding* (`forwarding_unit`): EX/MEM and MEM/WB → EX-stage ALU inputs.
- *Load-use stall* (`hazard_detection_unit`): one-cycle bubble when an LDUR's destination is needed by the next instruction.
- *Flag stall*: holds `B.LT` in IF/ID while a flag-setting `SUBS` is still in EX.
- *CBZ value forwarding* (`cbz_FU`): forwards in-flight register writes (EX/MEM/WB) into the CBZ zero-check, since CBZ resolves in ID and can't wait for the regfile.
- *Branch gating*: `BrTaken` is gated by `!stall` so branches never fire on stale flags.

**Branch resolution in ID** to keep the misprediction penalty to a single flushed instruction. `if_id_reg.flush` clears the speculatively-fetched instruction when `BrTaken=1`.

**Register file.** 32 × 64-bit, negedge-written, with `X31` (XZR) hardwired to 0.

**Verification.** Runs the full benchmark suite end-to-end in ModelSim. `test11_Sort` (bubble sort of 10 elements) and `test12_Fibonacci` both produce correct final register and memory state.

## Known Bugs Fixed Along the Way

See `pipeline_bugs.pdf` for the detailed write-up. Short version:
1. `program_counter` was ignoring its own `write_enable` input → PC advanced through stalls and ate instructions.
2. `CBZ` was reading stale X0 from the regfile → outer loops never terminated. Fixed with the dedicated `cbz_FU` + 3-mux priority chain.
3. `BrTaken` fired during stall cycles → `B.LT` branched on stale flags. Fixed by gating `BrTaken` with `!stall` at the gate level.

## Future Work

- **Branch prediction.** Static "predict not taken" is fine for the benchmarks but expensive on tight loops. A small BTB + 2-bit saturating counter would cut wasted fetches dramatically.
- **Memory hierarchy.** Currently `instructmem` and `datamem` are single-cycle, 1-port behavioral models. Adding an I-cache and D-cache (direct-mapped first, then set-associative) is the natural next step.
- **Wider ISA coverage.** No `ANDS`, no `EOR`, no shift-immediates, no MOV variants. Filling these in is mostly control-unit work.
- **Exceptions and interrupts.** No exception state, no `SVC`, no privileged mode.
- **Out-of-order or superscalar extensions.** Probably overkill for this codebase, but the cleanly-separated forwarding and hazard units would make a scoreboard / Tomasulo experiment tractable.
- **Synthesis.** Currently sim-only. Targeting a real FPGA (the project name nods to the Cyclone/DE-series boards) would require resolving combinational delays and replacing the negedge-write regfile with a synchronous BRAM-backed equivalent.

## Repo Layout

- `quad.sv` — top-level CPU
- `*_reg.sv` — pipeline latches (IF/ID, ID/EX, EX/MEM, MEM/WB)
- `control.sv`, `hazard_detection_unit.sv`, `forwarding_unit.sv`, `cbz_FU.sv` — control / hazard logic
- `alu.sv`, `AluControl.sv`, `dedALU4.sv`, `branchingAdd.sv`, `branchingLogic.sv` — datapath ops
- `regfile.sv`, `register_array.sv`, `D_FF*.sv`, `mux*.sv`, `decoder*.sv` — building blocks
- `instructmem.sv`, `datamem.sv` — memories
- `benchmarks/*.arm` — test programs
- `pipeline_bugs.pdf` — debug notes
