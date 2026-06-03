module mips_single_cycle (
    input clk,
    input reset
);

    wire [5:0] opcode;
    wire [5:0] funct;
    wire zero;

    wire RegDst, Jump, Branch, MemRead, MemtoReg;
    wire MemWrite, ALUSrc, RegWrite;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    control_unit control_path (
        .opcode(opcode),
        .funct(funct),
        .RegDst(RegDst),
        .Jump(Jump),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl)
    );

    datapath data_path (
        .clk(clk),
        .reset(reset),
        .RegDst(RegDst),
        .Jump(Jump),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .opcode(opcode),
        .funct(funct),
        .zero(zero)
    );

endmodule
