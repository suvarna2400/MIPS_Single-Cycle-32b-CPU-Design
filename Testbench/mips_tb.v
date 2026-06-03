`timescale 1ns/1ps

module tb_mips_single_cycle;

    reg clk;
    reg reset;

    mips_single_cycle uut (
        .clk(clk),
        .reset(reset)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 1;

        #10;
        reset = 0;

        #120;

        
        $display("MAXIMUM OF TWO NUMBERS PROGRAM");
       
        $display("a = $t0 = %d", uut.data_path.RF.registers[8]);
        $display("b = $t1 = %d", uut.data_path.RF.registers[9]);
        $display("comparison result $t2 = %d", uut.data_path.RF.registers[10]);
        $display("max = $t3 = %d", uut.data_path.RF.registers[11]);
        $display("Memory[0] = %d", uut.data_path.DM.memory[0]);

        $display("--------------------------------");

        if (uut.data_path.DM.memory[0] == 40)
            $display("TEST PASSED: Maximum value is correct.");
        else
            $display("TEST FAILED: Maximum value is incorrect.");

        $finish;
    end

endmodule
