# Journal

## Introduction

This project was my first attempt at implementing a complete processor datapath in hardware.

Before starting this implementation, components such as the Program Counter, Register File, Control Unit, ALU, and Data Memory were concepts that I had only studied individually. Building a working processor helped me understand how these independent blocks cooperate to execute instructions.

The processor follows the classical **32-bit Single-Cycle MIPS architecture**, where every instruction completes within one clock cycle.

---

# Understanding the MIPS ISA

MIPS instructions are classified into three formats.

## R-Type (Register)

Used for register-to-register operations.

```
-------------------------------------------------
| opcode |   rs   |   rt   |   rd   |sh| funct |
-------------------------------------------------
| 6 bits | 5 bits | 5 bits | 5 bits |5 | 6 bits|
-------------------------------------------------
```

Typical categories:

### Arithmetic

* add
* sub

### Logical

* and
* or

### Comparison

* slt

Implemented:

* add
* sub
* and
* or
* slt

---

## I-Type (Immediate)

Used for memory operations and conditional branches.

```
-----------------------------------------
| opcode |   rs   |   rt   | immediate |
-----------------------------------------
| 6 bits | 5 bits | 5 bits |  16 bits  |
-----------------------------------------
```

Typical instructions:

* lw
* sw
* beq
* addi

Implemented:

* lw
* sw
* beq

---

## J-Type (Jump)

Used for unconditional jumps.

```
------------------------------
| opcode |     target        |
------------------------------
| 6 bits |      26 bits      |
------------------------------
```

Implemented:

* j

---

# Complete Datapath Execution Flow

## 1. Program Counter (PC)

The Program Counter is a 32-bit register that stores the byte address of the current instruction.

At every clock edge, the PC is updated with one of:

* PC + 4
* Branch Target Address
* Jump Target Address

Although the PC updates only on the clock edge, the hardware continuously computes these candidate addresses using combinational logic.

---

## 2. Instruction Memory

The PC value is supplied to the Instruction Memory. The Instruction Memory stores the machine code program and returns the corresponding 32-bit instruction.

In this implementation, the Instruction Memory is organized as an array of 32-bit words because every MIPS instruction is exactly 32 bits long. Although the Program Counter stores byte addresses, the memory returns one complete 32-bit instruction for the given address.

```
    reg [31:0] memory [0:255];
```
The size of the Instruction Memory is:
```
256 × 32 bits = 8192 bits = 1024 bytes (1 KB)
```

Conceptually:

```
PC ---> Instruction Memory ---> 32-bit Instruction
```

---

## 3. Control Unit

The first six bits of the instruction (opcode) are sent to the Main Control Unit.

```
Instruction[31:26]
```

The Control Unit generates all control signals required by the datapath.

Examples include:

* RegDst
* ALUSrc
* MemRead
* MemWrite
* MemtoReg
* RegWrite
* Branch
* Jump
* ALUOp

The datapath itself performs no decision making. It simply follows the control signals generated for the current instruction.

---

## 4. Register File

The Register File contains 32 registers, each 32 bits wide.

It supports:

* Two asynchronous read ports(Doesn't wait for the clock edge - implemented through Combinational logic)
* One synchronous write port(data is written into the selected register only on the active clock edge)

A simplified Verilog implementation is shown below:

```
// Asynchronous reads
assign ReadData1 = registers[rs];
assign ReadData2 = registers[rt];

// Synchronous write
always @(posedge clk) begin
    if (RegWrite && (rd != 5'd0))
        registers[rd] <= WriteData;
```

The source registers are extracted from the instruction fields:

```
rs -> Read Register 1
rt -> Read Register 2
```

For R-type instructions:

* both operands come from registers.

For I-type instructions:

* one operand comes from the register file,
* the other comes from the immediate field through a multiplexer.

---

## 5. Destination Register Selection

Before writing back, the processor must determine which register receives the result.

A multiplexer performs this selection.

For R-type:

```
Destination = rd
```

For I-type:

```
Destination = rt
```

The RegDst control signal controls this multiplexer. This allows one Register File to support multiple instruction formats.

---

## 6. Sign Extension

Immediate values occupy only 16 bits.

However, the ALU operates on 32-bit operands.

Therefore, immediate values must be sign-extended before entering the ALU.

This is done by copying (concatenating) the most significant bit (the sign bit) of the 16-bit immediate into the upper 16 bits of the 32-bit value. If the sign bit is 0, zeros are added; if it is 1, ones are added.

This preserves both positive and negative values correctly when the ALU performs 32-bit operations.

---

## 7. Branch Address Calculation

## Learnings

### 1. Why is PC+4 always computed?

Sequential execution is the default behavior of the processor. Every instruction assumes that the next instruction is located immediately after it, so the processor always computes:

```
PC + 4
```

Branches and jumps simply override this default value when their conditions are satisfied.

---

### 2. Why is the branch formula relative to PC+4 instead of PC?

Reason is architectural. The MIPS ISA defines branch offsets relative to the next sequential instruction (`PC + 4`). The PC register itself changes only at the active clock edge.

During execution, the processor reconstructs the target address using:

```
Branch Target = PC + 4 + (Immediate << 2)
```

---

### 3. The overall view

To understand why the immediate value is shifted left by two bits, it is important to remember how MIPS stores branch offsets.

The 16-bit immediate field in a branch instruction does not represent a byte address. Instead, it represents the number of instructions (or words) to move relative to `PC + 4`.

Since every MIPS instruction is 32 bits (4 bytes) long, consecutive instructions are located at addresses like:

```
0
4
8
12
16
20
...
```

Suppose the current instruction is at address `8`, so `PC + 4` is `12`, and we want to branch to the instruction at address `20`.

The assembler calculates:

```
(20 - 12) / 4 = 2
```

So, the immediate field stored in the instruction is:

```
Immediate = 2
```

During execution, the processor must convert this instruction offset back into a byte address. Since each instruction occupies 4 bytes, it effectively computes:

```
2 × 4 = 8 bytes
```

Rather than using a hardware multiplier, the processor performs a left shift by two bits:

```
2        = 00000010₂
2 << 2   = 00001000₂ = 8
```

In binary arithmetic, shifting left by two bits is equivalent to multiplying by 4.

Thus,

```
Immediate << 2
```

is simply a hardware-efficient way of performing:

```
Immediate × 4
```

This byte offset is then added to `PC + 4`:

```
Branch Target = PC + 4 + (Immediate × 4)
```

Using the same example:

```
Branch Target = 12 + (2 × 4)
              = 12 + 8
              = 20
```

which correctly gives the target instruction address.

In short, the branch immediate represents the number of instructions to skip, while memory addresses are measured in bytes. The left shift by two converts the instruction offset into a byte offset by multiplying it by 4.

## 8. ALU Execution

The ALU performs:

* Arithmetic operations
* Logical operations
* Address calculations
* Equality comparisons

The exact operation is determined by the ALU Control block.

---

## 9. Data Memory

Load and Store instructions access Data Memory.

* lw reads from memory.
* sw writes to memory.

Other instruction types simply bypass this stage.

---

## 10. Write Back

Rather than having a separate destination storage unit, the processor writes the result back into the same Register File.

The final write-back value is selected by a multiplexer:

* ALU Result
* Memory Data

Since Register File reads are asynchronous and writes are synchronous, reading and writing can safely occur during the same clock cycle.

---

# Conclusion

Implementing this processor transformed architectural diagrams into actual hardware.

Many concepts that originally appeared independent—Program Counter, Control Unit, Register File, ALU, multiplexers, memory, and branch logic—became part of one complete execution flow.

This implementation provides the conceptual foundation required for understanding and building a pipelined processor.
