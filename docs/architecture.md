# Hardware Architecture Specification: 5-Stage RV32I RISC-V Processor

## 1. System Overview

The processor implements a classic **5-stage pipelined RV32I RISC-V architecture** consisting of Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB) stages. The design supports the RV32I base integer instruction set and incorporates dedicated hazard detection and forwarding logic to maintain correct execution while improving pipeline throughput.

The architecture emphasizes modularity by separating the processor core, hazard detection unit, forwarding unit, branch prediction logic, and verification components into independent modules, enabling straightforward functional verification and future architectural extensions.

---

## 2. Pipeline Architecture

### 2.1 Instruction Fetch (IF)

The IF stage retrieves instructions from instruction memory using the Program Counter (PC). The PC is updated sequentially or redirected during control-transfer instructions based on the branch prediction outcome.

---

### 2.2 Instruction Decode (ID)

The ID stage decodes the fetched instruction, generates control signals, and reads operands from the register file. Immediate values are generated according to the RV32I instruction format.

The hazard detection unit simultaneously compares the destination register (**rd**) of instructions in later pipeline stages with the source registers (**rs1** and **rs2**) of the current instruction to detect data dependencies.

---

### 2.3 Execute (EX)

The Execute stage performs ALU operations, branch comparisons, and effective address calculations for memory operations.

Forwarding multiplexers receive control signals from the forwarding unit, allowing operands to be selected from either the register file or later pipeline stages whenever possible.

---

### 2.4 Memory Access (MEM)

The MEM stage performs load and store operations through the data memory interface. Memory reads return data for subsequent write-back, while stores update memory using the calculated address from the Execute stage.

---

### 2.5 Write Back (WB)

The WB stage writes ALU or memory results back into the destination register, completing instruction execution.

---

## 3. Hazard Management

### 3.1 Hazard Detection Unit

The hazard detection unit identifies **load-use hazards** by monitoring register dependencies between adjacent pipeline stages.

When forwarding cannot resolve a dependency, the unit inserts a single pipeline stall by freezing the Program Counter and IF/ID pipeline register while injecting a bubble into the pipeline.

---

### 3.2 Forwarding Unit

The forwarding unit minimizes unnecessary pipeline stalls by forwarding recently computed results directly from later pipeline stages.

The design supports:

* EX-EX Forwarding
* MEM-EX Forwarding
* Forwarding for both RS1 and RS2 operands
* Priority handling when multiple forwarding sources are available

---

### 3.3 Branch Handling

The processor incorporates static branch prediction to reduce control hazard penalties.

Branch conditions are evaluated in the Execute stage. Whenever a prediction is incorrect, the affected instructions are flushed and the Program Counter is redirected to the correct target address.

---

## 4. Pipeline Control

Pipeline execution is coordinated through dedicated control logic responsible for:

* Program Counter updates
* Pipeline register enables
* Stall generation
* Bubble insertion
* Forwarding selection
* Pipeline flushing after branch misprediction

The hazard detection and forwarding units operate independently but collectively ensure correct instruction execution under data and control hazards.

---

## 5. Verification Support

The architecture was designed with verification in mind and integrates seamlessly with the hybrid verification framework.

Dedicated verification components include:

* SystemVerilog Assertions (SVA) for hazard correctness
* Functional coverage models
* Architectural scoreboard
* CPI characterization logic
* Hazard-oriented mutation testing support

These components operate externally to the RTL without modifying processor functionality, enabling comprehensive verification while preserving the original hardware implementation.

---

## 6. Design Characteristics

| Feature             | Description                        |
| ------------------- | ---------------------------------- |
| ISA                 | RV32I Base Integer                 |
| Pipeline            | 5 Stages (IF-ID-EX-MEM-WB)         |
| Hazard Detection    | Load-Use Stall Unit                |
| Forwarding          | EX-EX and MEM-EX                   |
| Branch Prediction   | Static Prediction                  |
| Verification        | Hybrid ABV + CDV                   |
| Mutation Campaign   | 12 Hazard-Oriented RTL Mutants     |
| Performance Metric  | CPI Characterization               |
| Verification Metric | Hazard Detection Sensitivity (HDS) |

---

## 7. Module Organization

The project is organized into independent RTL and verification modules:

```text
rtl/
├── core/
│   ├── fetch.sv
│   ├── decode.sv
│   ├── execute.sv
│   ├── memory.sv
│   ├── writeback.sv
│   └── core.sv
│
├── hazard_units/
│   ├── stall_unit.sv
│   └── forwarding_unit.sv
│
tb/
├── assertions/
├── coverage/
├── tests/
├── scoreboard.sv
└── tb_core.sv
```

This modular organization simplifies maintenance, verification, and future enhancements while enabling independent development of processor and verification components.
