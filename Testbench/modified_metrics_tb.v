`timescale 1ns/1ps

module modified_metrics_tb;
    reg clk;
    reg reset;

    integer i;
    integer errors;
    integer timeout_cycles;
    integer instr_index;

    integer total_cycles;
    integer instruction_count;
    integer stall_cycles;
    integer data_hazard_stall_cycles;
    integer branch_hazard_stall_cycles;
    integer branch_flush_count;

    integer r_type_count;
    integer lw_count;
    integer sw_count;
    integer beq_count;
    integer addi_count;
    integer nop_count;
    integer other_count;

    integer if_active_cycles;
    integer id_active_cycles;
    integer ex_active_cycles;
    integer mem_active_cycles;
    integer wb_active_cycles;

    real cpi;
    real ipc;
    real if_util;
    real id_util;
    real ex_util;
    real mem_util;
    real wb_util;

    reg metrics_done;
    reg result_seen;

    localparam integer PROGRAM_WORDS = 25;
    localparam [31:0] NOP_INSTR = 32'b000000_00000_00000_00000_00000_000000;
    localparam [31:0] END_INSTR = 32'b000000_00000_00000_00000_00000_100000;

    mips_single_cycle uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task clear_metrics;
        begin
            total_cycles = 0;
            instruction_count = 0;
            stall_cycles = 0;
            data_hazard_stall_cycles = 0;
            branch_hazard_stall_cycles = 0;
            branch_flush_count = 0;

            r_type_count = 0;
            lw_count = 0;
            sw_count = 0;
            beq_count = 0;
            addi_count = 0;
            nop_count = 0;
            other_count = 0;

            if_active_cycles = 0;
            id_active_cycles = 0;
            ex_active_cycles = 0;
            mem_active_cycles = 0;
            wb_active_cycles = 0;

            cpi = 0.0;
            ipc = 0.0;
            if_util = 0.0;
            id_util = 0.0;
            ex_util = 0.0;
            mem_util = 0.0;
            wb_util = 0.0;

            metrics_done = 1'b0;
            result_seen = 1'b0;
        end
    endtask

    task count_instruction_mix;
        input [31:0] instruction;
        begin
            case (instruction[31:26])
                6'b000000: begin
                    if (instruction == NOP_INSTR)
                        nop_count = nop_count + 1;
                    else
                        r_type_count = r_type_count + 1;
                end
                6'b100011: lw_count = lw_count + 1;
                6'b101011: sw_count = sw_count + 1;
                6'b000100: beq_count = beq_count + 1;
                6'b001000: addi_count = addi_count + 1;
                default: other_count = other_count + 1;
            endcase
        end
    endtask

    function integer current_instruction_index;
        input integer unused;
        begin
            current_instruction_index = uut.data_path.pc_current >> 2;
        end
    endfunction

    task calculate_metrics;
        begin
            if (instruction_count > 0) begin
                cpi = total_cycles * 1.0 / instruction_count;
                ipc = instruction_count * 1.0 / total_cycles;
            end

            if (total_cycles > 0) begin
                if_util = if_active_cycles * 100.0 / total_cycles;
                id_util = id_active_cycles * 100.0 / total_cycles;
                ex_util = ex_active_cycles * 100.0 / total_cycles;
                mem_util = mem_active_cycles * 100.0 / total_cycles;
                wb_util = wb_active_cycles * 100.0 / total_cycles;
            end
        end
    endtask

    task print_metrics;
        begin
            $display("=================================================");
            $display("Single-cycle CPU performance metrics");
            $display("Total cycles                       = %0d", total_cycles);
            $display("Useful instruction count           = %0d", instruction_count);
            $display("CPI                                = %0.3f", cpi);
            $display("IPC                                = %0.3f", ipc);
            $display("Software stall cycles, NOPs        = %0d", stall_cycles);
            $display("Data hazard NOP cycles             = %0d", data_hazard_stall_cycles);
            $display("Branch delay NOP cycles            = %0d", branch_hazard_stall_cycles);
            $display("Branch flush count                 = %0d", branch_flush_count);
            $display("");
            $display("Instruction mix observed in single-cycle fetch");
            $display("R-type                             = %0d", r_type_count);
            $display("lw                                 = %0d", lw_count);
            $display("sw                                 = %0d", sw_count);
            $display("beq                                = %0d", beq_count);
            $display("addi                               = %0d", addi_count);
            $display("nop                                = %0d", nop_count);
            $display("other                              = %0d", other_count);
            $display("");
            $display("Single-cycle datapath unit utilization");
            $display("IF active cycles                   = %0d (%0.2f%%)", if_active_cycles, if_util);
            $display("ID active cycles                   = %0d (%0.2f%%)", id_active_cycles, id_util);
            $display("EX active cycles                   = %0d (%0.2f%%)", ex_active_cycles, ex_util);
            $display("MEM active cycles                  = %0d (%0.2f%%)", mem_active_cycles, mem_util);
            $display("WB active cycles                   = %0d (%0.2f%%)", wb_active_cycles, wb_util);
            $display("=================================================");
        end
    endtask

    task load_program;
        begin
            // Single-cycle version of the linear search program.
            // No software NOPs are required because each instruction completes in one cycle.
            $readmemb("linear_search_single_cycle.bin", uut.data_path.IM.memory, 0, PROGRAM_WORDS - 1);
        end
    endtask

    always @(posedge clk) begin
        if (reset) begin
            metrics_done = 1'b0;
            result_seen = 1'b0;
        end else if (!metrics_done) begin
            instr_index = current_instruction_index(0);

            if ((instr_index >= 0) && (instr_index < PROGRAM_WORDS)) begin
                total_cycles = total_cycles + 1;
                if_active_cycles = if_active_cycles + 1;
                count_instruction_mix(uut.data_path.instruction);

                if (uut.data_path.instruction == NOP_INSTR) begin
                    nop_count = nop_count + 0;
                    stall_cycles = stall_cycles + 1;
                end else begin
                    id_active_cycles = id_active_cycles + 1;
                    instruction_count = instruction_count + 1;
                end

                if (uut.RegWrite || uut.MemRead || uut.MemWrite || uut.Branch || uut.Jump)
                    ex_active_cycles = ex_active_cycles + 1;

                if (uut.MemRead || uut.MemWrite)
                    mem_active_cycles = mem_active_cycles + 1;

                if (uut.RegWrite)
                    wb_active_cycles = wb_active_cycles + 1;

                if (uut.data_path.DM.memory[5] !== 32'hFFFFFFFF)
                    result_seen = 1'b1;

                if (result_seen && (uut.data_path.instruction == END_INSTR))
                    metrics_done = 1'b1;
            end
        end
    end

    initial begin
        errors = 0;
        reset = 1'b1;
        clear_metrics();

        for (i = 0; i < 256; i = i + 1) begin
            uut.data_path.IM.memory[i] = NOP_INSTR;
            uut.data_path.DM.memory[i] = 32'd0;
            uut.data_path.RF.registers[i % 32] = 32'd0;
        end

        load_program();

        // Byte-addressed memory layout used by the assembly program:
        // mem[0]  = arr[0] = 7
        // mem[4]  = arr[1] = 3
        // mem[8]  = arr[2] = 9
        // mem[12] = arr[3] = 5
        // mem[16] = key = 9
        // mem[20] = result
        // The Verilog data memory array is word-indexed internally.
        uut.data_path.DM.memory[0] = 32'd7;
        uut.data_path.DM.memory[1] = 32'd3;
        uut.data_path.DM.memory[2] = 32'd9;
        uut.data_path.DM.memory[3] = 32'd5;
        uut.data_path.DM.memory[4] = 32'd9;
        uut.data_path.DM.memory[5] = 32'hFFFFFFFF;

        #12;
        reset = 1'b0;

        for (timeout_cycles = 0;
             (timeout_cycles < 100) && (metrics_done == 1'b0);
             timeout_cycles = timeout_cycles + 1) begin
            @(negedge clk);
        end

        if (metrics_done == 1'b0) begin
            $display("ERROR: program did not complete before timeout.");
            errors = errors + 1;
        end

        calculate_metrics();

        $display("=================================================");
        $display("Linear search result on single-cycle CPU");
        $display("arr[0] memory[0] = %0d", uut.data_path.DM.memory[0]);
        $display("arr[1] memory[1] = %0d", uut.data_path.DM.memory[1]);
        $display("arr[2] memory[2] = %0d", uut.data_path.DM.memory[2]);
        $display("arr[3] memory[3] = %0d", uut.data_path.DM.memory[3]);
        $display("key    memory[4] = %0d", uut.data_path.DM.memory[4]);
        $display("result memory[5] = %0d", uut.data_path.DM.memory[5]);
        $display("$t6 = %0d", uut.data_path.RF.registers[14]);
        $display("=================================================");

        print_metrics();

        if (uut.data_path.DM.memory[5] !== 32'd2) begin
            $display("ERROR: result should be 2 because arr[2] == key.");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED with %0d error(s)", errors);

        $finish;
    end

    initial begin
        $dumpfile("modified_metrics_tb.vcd");
        $dumpvars(0, modified_metrics_tb);
    end
endmodule
