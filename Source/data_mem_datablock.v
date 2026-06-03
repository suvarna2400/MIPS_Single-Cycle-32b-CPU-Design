module data_memory (
    input clk,
    input MemRead,
    input MemWrite,

    input [31:0] address,
    input [31:0] write_data,

    output [31:0] read_data
);

    reg [31:0] memory [0:255];

    assign read_data = MemRead ? memory[address[9:2]] : 32'b0;

    always @(posedge clk) begin
        if (MemWrite)
            memory[address[9:2]] <= write_data;
    end

endmodule
