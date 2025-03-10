`timescale 1ns / 1ps
`include "instruction_fetch.v"
module instruction_fetch_tb();

    reg [31:0] pc;
    wire [31:0] instruction;

    instruction_fetch uut (
        .pc(pc),
        .instruction(instruction)
    );

    initial begin
        pc = 0;  

        repeat (8) begin
            #10;
            $display("Time: %0t | PC: %0h | Instruction: %b", 
                     $time, pc, instruction);
            pc = pc + 4;  
        end

        $finish;
    end

endmodule
