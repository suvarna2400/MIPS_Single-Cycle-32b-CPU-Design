# Single-Cycle MIPS Processor

A 32-bit Single-Cycle MIPS Processor implemented in Verilog HDL.

This project was developed to understand the internal operation of a processor datapath before moving toward a pipelined architecture. The implementation follows the classical MIPS single-cycle design, where every instruction completes within one clock cycle.

The processor was functionally verified using a Linear Search program.

---

# Repository Structure

```text
Single_Cycle_MIPS/
│
├── README.md
│
├── docs/
│   ├── Journal.md
│   └── MIPS_SingleCycle_Blockdia.png
│
├── Source/
│   ├── *.v
│   └── (All Verilog RTL modules)
│
├── Testbench/
│   ├── Linear_search_single_cycle.bin
│   ├── Linear_search_single_cycle.txt
│   └── modified_metrics_tb.v
│
└── Results/
    ├── Analysis.md
    ├── Console results.txt
    └── Simulated.png
```

---

# Repository Guide

## 📓 docs/

Contains the documentation associated with the project.

### Journal.md

A detailed implementation journal documenting the **key concepts and practical learnings** gained while designing and implementing the processor.

Topics covered include:

* MIPS instruction formats
* Program Counter operation
* Instruction Memory organization
* Register File architecture
* Control signal generation
* Sign extension
* Branch address calculation
* ALU execution
* Data Memory access
* Write-back mechanism
* Lessons learned during implementation

---

## 💻 Source/

Contains all Verilog HDL source files used to construct the processor.

The design is organized into independent hardware modules such as:

* Program Counter
* Instruction Memory
* Main Control Unit
* ALU Control
* Register File
* ALU
* Data Memory
* Top-level datapath integration

This modular organization makes each hardware block easy to understand and verify independently.

---

## 🧪 Testbench/

Contains the files required to simulate and validate the processor.

### Linear_search_single_cycle.bin

Machine code program loaded into Instruction Memory during simulation.

---

### Linear_search_single_cycle.txt

Assembly listing corresponding to the machine code program.

This file provides an easy mapping between assembly instructions and their binary encodings.

---

### modified_metrics_tb.v

Top-level simulation testbench.

The testbench is also used to gather metrics for later comparison with the pipelined implementation.

---

## 📊 Results/

Contains outputs generated after simulation.

### Analysis.md

Documents important architectural observations obtained during implementation.

Topics include:

* Critical path concept
* Clock period and maximum frequency
* CPI versus throughput
* Why single-cycle processors are limited
* Motivation for pipelining

---

### Console results.txt

Raw simulator output showing:

* Instruction execution
* Register contents
* Memory contents
* Final Linear Search result

---

### Simulated.png

Screenshot of the successful simulation, confirming correct execution of the verification program.

---

# Future Work

This implementation serves as the architectural foundation for a classical 5-stage pipelined processor.

Future enhancements include:

* Pipeline registers
* Forwarding Unit
* Hazard Detection Unit
* Stall and Flush logic
* Performance comparison between Single-Cycle and Pipelined architectures
