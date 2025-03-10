`timescale 1ns / 1ps
`include "memory.v"
module memory_tb;
    // Inputs
    reg clk;
    reg [4:0] ex_mem_rd;
    reg ex_mem_Memwrite;
    reg ex_mem_Memread;
    reg ex_mem_MemtoReg;
    reg ex_mem_Regwrite;
    reg [63:0] ex_mem_alu_result;
    reg [63:0] ex_mem_rs2;
    
    // Outputs
    wire [4:0] mem_wb_rd;
    wire mem_wb_MemtoReg;
    wire [63:0] mem_wb_alu_result;
    wire [63:0] mem_wb_mem_data;
    wire mem_wb_RegWrite;

    // Instantiate the module
    memory uut (
        .clk(clk),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_Memwrite(ex_mem_Memwrite),
        .ex_mem_Memread(ex_mem_Memread),
        .ex_mem_MemtoReg(ex_mem_MemtoReg),
        .ex_mem_Regwrite(ex_mem_Regwrite),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_rs2(ex_mem_rs2),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_MemtoReg(mem_wb_MemtoReg),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_mem_data(mem_wb_mem_data),
        .mem_wb_RegWrite(mem_wb_RegWrite)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize inputs
        clk = 0;
        ex_mem_rd = 5'd0;
        ex_mem_Memwrite = 0;
        ex_mem_Memread = 0;
        ex_mem_MemtoReg = 0;
        ex_mem_Regwrite = 0;
        ex_mem_alu_result = 64'd2;
        ex_mem_rs2 = 64'd42;
        
        // Monitor signals
        $monitor("Time=%0t | clk=%b | MemWrite=%b | MemRead=%b | MemtoReg=%b | RegWrite=%b | rd=%d | ALU_Result=%d | MemData=%d", 
                 $time, clk, ex_mem_Memwrite, ex_mem_Memread, ex_mem_MemtoReg, ex_mem_Regwrite, 
                 mem_wb_rd, mem_wb_alu_result, mem_wb_mem_data);
        
        // Test Memory Read
        ex_mem_Memread = 1;
        #10;
        ex_mem_Memread = 0;
        
        // Test Memory Write
        ex_mem_Memwrite = 1;
        #10;
        ex_mem_Memwrite = 0;
        
        // Finish simulation
        #10 $finish;
    end
endmodule
