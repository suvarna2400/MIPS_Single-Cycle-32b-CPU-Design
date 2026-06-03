module pc_register (
    input clk,
    input reset,
    input [31:0] pc_next,
    output reg [31:0] pc_current
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_current <= 32'b0;
        else
            pc_current <= pc_next;
    end

endmodule
