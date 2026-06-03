module control_unit (
    input [5:0] opcode,
    input [5:0] funct,

    output reg RegDst,
    output reg Jump,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg [3:0] ALUControl
);

    always @(*) begin
        RegDst   = 0;
        Jump     = 0;
        Branch   = 0;
        MemRead  = 0;
        MemtoReg = 0;
        ALUOp    = 2'b00;
        MemWrite = 0;
        ALUSrc   = 0;
        RegWrite = 0;

        case (opcode)
            6'b000000: begin
                RegDst   = 1;
                RegWrite = 1;
                ALUOp    = 2'b10;
            end

            6'b100011: begin
                ALUSrc   = 1;
                MemtoReg = 1;
                RegWrite = 1;
                MemRead  = 1;
                ALUOp    = 2'b00;
            end

            6'b101011: begin
                ALUSrc   = 1;
                MemWrite = 1;
                ALUOp    = 2'b00;
            end

            6'b000100: begin
                Branch = 1;
                ALUOp  = 2'b01;
            end

            6'b000010: begin
                Jump = 1;
            end

            6'b001000: begin
                ALUSrc   = 1;
                RegWrite = 1;
                ALUOp    = 2'b00;
            end
        endcase
    end

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010;
            2'b01: ALUControl = 4'b0110;

            2'b10: begin
                case (funct)
                    6'b100000: ALUControl = 4'b0010;
                    6'b100010: ALUControl = 4'b0110;
                    6'b100100: ALUControl = 4'b0000;
                    6'b100101: ALUControl = 4'b0001;
                    6'b101010: ALUControl = 4'b0111;
                    default:   ALUControl = 4'b0010;
                endcase
            end

            default: ALUControl = 4'b0010;
        endcase
    end

endmodule
