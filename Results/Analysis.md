# 📊 Analysis on the Results of Single-Cycle MIPS Processor 

---

# 1. Program Overview (Linear Search Execution)

The processor executes a linear search over an array stored in memory.

### Memory Snapshot

arr[0] = 7  
arr[1] = 3  
arr[2] = 9  
arr[3] = 5  

key    = 9  
result = 2  

---

### Final Output

$t6 = 2  

✔ The processor correctly finds the key at index 2.

---

# 2. Execution Summary

Total cycles      = 12  
Instructions      = 12  
CPI               = 1.0  
IPC               = 1.0  

Software stalls   = 0  
Hazards           = 0  
Flushes           = 0  

---

# 3. CPU Performance Equation

Execution Time = Instructions × CPI × Clock Period  

Since:

Clock Period = 1 / Frequency  

Execution Time = (Instructions × CPI) / Frequency  

---

# 4. Key Idea: CPI vs Real Performance

Even though:

CPI = 1 (ideal case)

Performance is NOT necessarily high because:

👉 Clock Period dominates execution time

---

# 5. Single-Cycle Processor Behavior

## Core Principle

Each instruction completes in exactly ONE clock cycle:

CPI = 1  

But:

✔ No instruction overlap  
✔ Entire datapath used in one cycle  

---

## Datapath Flow

PC → Instruction Memory → Register File → ALU → Data Memory → Write Back  

---

# 6. Hardware Delay Model

Example:

| Block | Delay |
|------|------|
| PC clk→Q | 0.3 ns |
| Instruction Memory | 2 ns |
| Register File | 1 ns |
| ALU | 2 ns |
| Data Memory | 3 ns |
| MUX | 0.5 ns |
| Register Setup | 0.2 ns |

---

## R-type path

0.3 + 2 + 1 + 2 + 0.5 + 0.2 = 6 ns  

## lw path

0.3 + 2 + 1 + 2 + 3 + 0.5 + 0.2 = 9 ns  

---

# 7. Critical Path

Critical Path = lw instruction = 9 ns  

Clock Period = 9 ns  

Frequency = 1 / 9 ns = 111 MHz  

---

# 8. Key Inefficiency in Single-Cycle Design

Even simple instructions like:

- add
- sub
- and

take only ~6 ns of work but are forced to occupy:

9 ns clock cycle

👉 This causes internal time wastage.

---

# 9. Instruction Mix Analysis

| Type | Count |
|------|------|
| R-type | 1 |
| lw | 4 |
| sw | 1 |
| beq | 3 |
| addi | 2 |
| other | 1 |

### Observation:
- Memory-heavy workload
- Branch-driven loop control
- Typical linear search behavior

---

# 10. Functional Unit Activity (NOT Pipeline Stages)

⚠ Important: These are NOT pipeline stages  
They are functional block activations.

| Unit | Active Cycles | Meaning |
|------|--------------|--------|
| IF | 12 | Every instruction fetched |
| ID | 12 | Every instruction decoded |
| EX | 12 | ALU/control used |
| MEM | 5 | lw (4) + sw (1) |
| WB | 7 | R-type + lw + addi |

---

### Why MEM = 5?

lw = 4  
sw = 1  

---

### Why WB = 7?

R-type = 1  
lw = 4  
addi = 2  

---

# 11. CPI and IPC

## CPI

CPI = Total Cycles / Instructions  
CPI = 12 / 12 = 1.0  

---

## IPC

IPC = 1 / CPI = 1.0  

---

## Insight

✔ CPI = 1 does NOT mean high performance  
✔ Because clock frequency is low due to critical path  

---

# 12. No Pipeline Effects

Software stalls   = 0  
Hazards           = 0  
Flushes           = 0  

Reason:
- No overlapping execution
- No pipeline registers
- One instruction completes per cycle

---

# 13. Why Single-Cycle is Slow

Execution time depends on:

CPU Time = Instructions × CPI × Clock Period  

Here:
- CPI = 1
- Clock Period = 9 ns (large)

👉 Performance bottleneck = Clock period

---

### Pipelined results, Analysis and Comparison is available in 5 Stage Pipelined processor repository in Results/Analysis.md


# 14. Final Conclusion

Although the single-cycle MIPS processor achieves:

✔ CPI = 1  
✔ IPC = 1  
✔ Correct execution  
✔ No hazards or stalls  

its performance is fundamentally limited by:

❗ Long critical path delay → large clock period  

---

# 🚀 Key Insight

Single-cycle CPU improves simplicity, not speed.  
Pipeline improves speed by increasing clock frequency, not by reducing CPI.
