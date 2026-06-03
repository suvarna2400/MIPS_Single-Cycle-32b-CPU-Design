module datapath (
    input clk,
    input reset,

    input RegDst,
    input Jump,
    input Branch,
    input MemRead,
    input MemtoReg,
    input MemWrite,
    input ALUSrc,
    input RegWrite,
    input [3:0] ALUControl,

    output [5:0] opcode,
    output [5:0] funct,
    output zero
);

    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;

    wire [31:0] instruction;
    wire [31:0] sign_extended;
    wire [31:0] branch_address;
    wire [31:0] jump_address;

    wire [4:0] write_register;
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] alu_input2;
    wire [31:0] alu_result;
    wire [31:0] memory_read_data;
    wire [31:0] write_data;

    wire branch_taken;
    wire [31:0] pc_branch;

    assign opcode = instruction[31:26];
    assign funct  = instruction[5:0];

    assign pc_plus4 = pc_current + 32'd4;

    assign branch_address = pc_plus4 + (sign_extended << 2);
    assign jump_address   = {pc_plus4[31:28], instruction[25:0], 2'b00};

    assign branch_taken = Branch & zero;
    assign pc_branch = branch_taken ? branch_address : pc_plus4;
    assign pc_next = Jump ? jump_address : pc_branch;

    pc_register PC (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    instruction_memory IM (
        .address(pc_current),
        .instruction(instruction)
    );

    sign_extend SE (
        .in(instruction[15:0]),
        .out(sign_extended)
    );

    assign write_register = RegDst ? instruction[15:11] : instruction[20:16];

    register_file RF (
        .clk(clk),
        .RegWrite(RegWrite),
        .read_reg1(instruction[25:21]),
        .read_reg2(instruction[20:16]),
        .write_reg(write_register),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    assign alu_input2 = ALUSrc ? sign_extended : read_data2;

    alu ALU (
        .a(read_data1),
        .b(alu_input2),
        .alu_control(ALUControl),
        .result(alu_result),
        .zero(zero)
    );

    data_memory DM (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(memory_read_data)
    );

    assign write_data = MemtoReg ? memory_read_data : alu_result;

endmodule
