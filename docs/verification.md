# Verification Plan: Hybrid ABV-CDV Verification of a 5-Stage RV32I RISC-V Processor

## 1. Verification Objective

The objective of this project is to verify the correctness and robustness of a **5-stage pipelined RV32I RISC-V processor** using a hybrid verification methodology combining **Assertion-Based Verification (ABV)** and **Coverage-Driven Verification (CDV)**. The verification environment focuses on validating hazard detection, forwarding logic, branch handling, and load-use stall mechanisms while evaluating verification quality using mutation testing and the proposed **Hazard Detection Sensitivity (HDS)** metric.

---

## 2. Verification Environment

The verification environment consists of four major components:

* **SystemVerilog Assertions (SVA):** Concurrent assertions monitor hazard detection, forwarding decisions, branch handling, and pipeline control signals.
* **Scoreboard:** Compares the architectural state of the DUT against a golden reference after every committed instruction.
* **Functional Coverage:** Covergroups monitor hazard scenarios, forwarding paths, branch behavior, predictor transitions, and cross-coverage interactions.
* **Performance Monitor:** Records active cycles, retired instructions, CPI, and stall cycles for performance characterization.

---

## 3. Directed Benchmark Suite

A progressive directed benchmark suite was developed to systematically exercise the major hazard scenarios of the processor, including EX-EX forwarding, MEM-EX forwarding, load-use hazards, branch evaluation, branch misprediction, and combined forwarding interactions.

Coverage analysis of the baseline benchmarks was used to identify verification gaps. Additional forwarding-focused benchmarks were then developed to activate previously uncovered scenarios and improve overall verification effectiveness.

---

## 4. Functional Coverage Strategy

Functional coverage models were developed to monitor both individual pipeline behaviors and interactions between multiple hazard mechanisms.

### Primary Coverpoints

* EX-EX Hazards
* MEM-EX Hazards
* Load-Use Hazards
* Forward A
* Forward B
* Branch Evaluation
* Branch Misprediction
* Branch History Table (BHT) Transitions

### Cross Coverage

* Stall × Forward A
* Stall × Forward B
* Forward A × Forward B
* Branch Dual Forwarding
* Jump × Forward A
* Mispredict × Forward A
* Mispredict × Forward B
* Flush × Stall

The final verification campaign achieved **100% coverage for all primary hazard-related coverpoints**, while the remaining uncovered bins were limited to complex cross-coverage scenarios.

---

## 5. Assertion-Based Verification

Concurrent SystemVerilog Assertions continuously monitor hazard detection and pipeline control throughout simulation. Assertions verify correct load-use stall generation, forwarding selection, branch handling, and pipeline flushing. Any violation of these properties immediately reports an error, providing rapid detection of functional bugs before they propagate through the processor.

---

## 6. Hazard-Oriented Mutation Campaign

To evaluate the effectiveness of the verification environment, a structured mutation campaign consisting of **12 RTL mutants** was performed. The injected mutations targeted the processor's two most critical hazard-handling components: the **stall unit** and the **forwarding unit**. Each mutation represents a realistic RTL design bug that may occur during processor development.

### Stall Unit Mutants

Eight mutants were injected into the hazard detection logic responsible for load-use stall generation.

| Mutant  | Injected Fault                                                            |
| ------- | ------------------------------------------------------------------------- |
| **M1**  | Stall permanently disabled (stuck-at-0)                                   |
| **M2**  | Stall permanently asserted (stuck-at-1) causing pipeline deadlock         |
| **M6**  | RS1 hazard comparison removed                                             |
| **M7**  | RS2 hazard comparison removed                                             |
| **M9**  | Incorrect destination register comparison (`rd + 1`)                      |
| **M10** | Stall generated for all RAW dependencies instead of only load-use hazards |
| **M11** | Stall signal polarity inverted                                            |
| **M12** | Hazard detection logic changed from OR to AND                             |

These mutations evaluate the processor's ability to correctly identify data hazards, insert pipeline stalls only when required, and avoid unnecessary performance degradation.

### Forwarding Unit Mutants

Four mutants targeted the forwarding logic responsible for eliminating unnecessary pipeline stalls.

| Mutant | Injected Fault                        |
| ------ | ------------------------------------- |
| **M3** | EX-EX forwarding path for RS1 removed |
| **M4** | Forward_A path permanently disabled   |
| **M5** | Forward_B path permanently disabled   |
| **M8** | MEM/WB forwarding priority inverted   |

These mutations verify whether the forwarding unit correctly resolves data dependencies while selecting the appropriate forwarding source under multiple hazard conditions.

Each mutant was simulated independently using the complete verification environment. Mutants producing architectural mismatches, watchdog timeouts, or other observable verification failures were classified as **Killed**, while undetected faults were classified as **Survived**. Survivor analysis was subsequently used to guide benchmark refinement and improve verification effectiveness.

---

## 7. Hazard Detection Sensitivity (HDS)

Verification effectiveness is quantified using the proposed **Hazard Detection Sensitivity (HDS)** metric.

### Baseline Verification

* Injected Mutants: **12**
* Killed Mutants: **6**
* Surviving Mutants: **6**
* **HDS = 50.00%**

### Enhanced Verification

Following coverage-guided benchmark refinement:

* Injected Mutants: **12**
* Killed Mutants: **11**
* Surviving Mutants: **1**
* **HDS = 91.67%**

The improvement demonstrates the effectiveness of using mutation survivor analysis to identify verification blind spots and systematically refine benchmark generation.

---

## 8. Performance Analysis

In addition to functional correctness, processor performance was evaluated using **Cycles Per Instruction (CPI)** characterization. The verification environment records active cycles, retired instructions, CPI, and stall cycles to evaluate the impact of hazard frequency on processor performance.

This analysis also identifies performance-oriented defects that preserve architectural correctness but introduce unnecessary pipeline stalls, complementing traditional functional verification.

---

## 9. Conclusion

The processor verification is considered complete after satisfying the following criteria:

* **100% coverage** for all primary hazard-related coverpoints.
* Successful execution of all directed benchmarks without architectural mismatches.
* Zero scoreboard mismatches for the golden RTL.
* No assertion failures during normal processor execution.
* **91.67% Hazard Detection Sensitivity (HDS)** after benchmark refinement.
* CPI characterization demonstrating expected processor behavior under varying hazard densities.

The combination of ABV, CDV, mutation testing, and performance analysis provides a comprehensive verification methodology for hazard-sensitive pipelined RISC-V processors while enabling systematic identification and closure of verification gaps.
