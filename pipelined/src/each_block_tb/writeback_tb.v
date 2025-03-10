`timescale 1ns / 1ps
`include "writeback.v"
module writeback_tb;
    // Inputs
    reg clk;
    reg mem_wb_MemtoReg;
    reg mem_wb_RegWrite;
    reg [4:0] mem_wb_rd;
    reg [63:0] mem_wb_alu_result;
    reg [63:0] mem_wb_mem_data;

    // Outputs
    wire wb_RegWrite;
    wire [4:0] wb_rd;
    wire [63:0] wb_registerout;

    // Instantiate the module
    writeback uut (
        .clk(clk),
        .mem_wb_MemtoReg(mem_wb_MemtoReg),
        .mem_wb_RegWrite(mem_wb_RegWrite),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_mem_data(mem_wb_mem_data),
        .wb_RegWrite(wb_RegWrite),
        .wb_rd(wb_rd),
        .wb_registerout(wb_registerout)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        mem_wb_MemtoReg = 0;
        mem_wb_RegWrite = 0;
        mem_wb_rd = 5'd0;
        mem_wb_alu_result = 64'd100;
        mem_wb_mem_data = 64'd200;

        // Monitor signals
        $monitor("Time=%0t | MemtoReg=%b | RegWrite=%b | RD=%d | ALU_Result=%d | Mem_Data=%d | WB_Out=%d", 
                 $time, mem_wb_MemtoReg, mem_wb_RegWrite, wb_rd, mem_wb_alu_result, mem_wb_mem_data, wb_registerout);
        
        // Test case 1: Writing ALU result
        #10 mem_wb_RegWrite = 1;
        mem_wb_MemtoReg = 0;
        mem_wb_rd = 5'd10;
        #10;

        // Test case 2: Writing memory data
        mem_wb_MemtoReg = 1;
        mem_wb_rd = 5'd15;
        #10;

        // Test case 3: Disable writing
        mem_wb_RegWrite = 0;
        #10;
        
        // Finish simulation
        #10 $finish;
    end
endmodule
