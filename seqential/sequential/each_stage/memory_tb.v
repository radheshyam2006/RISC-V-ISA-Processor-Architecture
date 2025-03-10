`timescale 1ns / 1ps
`include "memory.v"


module memory_tb;
    reg [63:0] alu_result;
    reg clk;
    reg memread, memwrite;
    reg [63:0] rs2;
    wire [63:0] mem_data;

    // Instantiate the memory module
    memory uut (
        .alu_result(alu_result),
        .clk(clk),
        .memread(memread),
        .memwrite(memwrite),
        .rs2(rs2),
        .mem_data(mem_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        memread = 0;
        memwrite = 0;
        alu_result = 0;
        rs2 = 0;

        #10;
        
        // Test 1: Read from initialized memory location
        alu_result = 64'd0; // Address 0
        memread = 1;
        #10;
        $display("Read Data from Address 0: %d", mem_data);

        // Test 2: Write to memory
        alu_result = 64'd16; // Address 16 (aligned)
        rs2 = 64'd42; // Data to write
        memread = 0;
        memwrite = 1;
        #10;
        memwrite = 0;

        // Test 3: Read back written value
        memread = 1;
        #10;
        $display("Read Data from Address 16: %d", mem_data);
        memread = 0;

        // Test 4: Overwriting memory
        rs2 = 64'd99;
        memwrite = 1;
        #10;
        memwrite = 0;

        // Read again to verify overwrite
        memread = 1;
        #10;
        $display("Read Data from Address 16 after Overwrite: %d", mem_data);
        memread = 0;
        
        // Edge case: Read from uninitialized memory
        alu_result = 64'd200;
        memread = 1;
        #10;
        $monitor("Read Data from Uninitialized Address 200: %d", mem_data);
        $finish;
    end
endmodule
