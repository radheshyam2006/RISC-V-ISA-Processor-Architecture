`timescale 1ns / 1ps
`include "ex_stage.v"
`include "add.v"
`include "sub.v"
`include "and.v"
`include "or.v"
`include "xor.v"
`include "sll.v"
`include "srl.v"
`include "sra.v"
`include "sltu.v"
`include "slt.v"
`include "compartor.v"
module ex_stage_tb;
    // Inputs
    reg signed [63:0] operandA;
    reg signed [63:0] operandB;
    reg [3:0] alu_op;
    reg clk;
    reg id_ex_Memwrite;
    reg id_ex_Memread;
    reg id_ex_MemtoReg;
    reg id_ex_Regwrite;
    reg [4:0] id_ex_rd;
    reg signed [63:0] imm;
    reg alu_src;
    reg signed branch;
    
    // Outputs
    wire signed [63:0] ex_mem_alu_result;
    wire [4:0] ex_mem_rd;
    wire ex_mem_Memwrite;
    wire ex_mem_Memread;
    wire ex_mem_MemtoReg;
    wire ex_mem_Regwrite;
    wire ex_mem_overflow;

    // Instantiate the module
    ex_stage uut (
        .operandA(operandA),
        .operandB(operandB),
        .alu_op(alu_op),
        .clk(clk),
        .id_ex_Memwrite(id_ex_Memwrite),
        .id_ex_Memread(id_ex_Memread),
        .id_ex_MemtoReg(id_ex_MemtoReg),
        .id_ex_Regwrite(id_ex_Regwrite),
        .id_ex_rd(id_ex_rd),
        .imm(imm),
        .alu_src(alu_src),
        .branch(branch),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_Memwrite(ex_mem_Memwrite),
        .ex_mem_Memread(ex_mem_Memread),
        .ex_mem_MemtoReg(ex_mem_MemtoReg),
        .ex_mem_Regwrite(ex_mem_Regwrite),
        .ex_mem_overflow(ex_mem_overflow)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize inputs
        clk = 0;
        operandA = 64'd10;
        operandB = 64'd5;
        alu_src = 0;
        branch = 0;
        id_ex_Memwrite = 0;
        id_ex_Memread = 0;
        id_ex_MemtoReg = 0;
        id_ex_Regwrite = 0;
        id_ex_rd = 5'd1;
        imm = 64'd0;
        
        // Monitor signals
        $monitor("Time=%0t | ALU_OP=%b | OperandA=%d | OperandB=%d | Result=%d | Overflow=%b", 
                 $time, alu_op, operandA, operandB, ex_mem_alu_result, ex_mem_overflow);
        
        // Test different ALU operations
        
        alu_op = 4'b0010; // ADD
        #10;
        alu_op = 4'b0110; // SUB
        #10;
        
        alu_op = 4'b0000; // AND
        #10;
        
        alu_op = 4'b0001; // OR
        #10;
        
        alu_op = 4'b1001; // XOR
        #10;
        
        alu_op = 4'b0011; // SLL
        #10;
        
        alu_op = 4'b0100; // SRL
        #10;
        
        alu_op = 4'b0101; // SRA
        #10;
        
        alu_op = 4'b0111; // SLTU
        #10;
        
        alu_op = 4'b1000; // SLT
        #10;
        
        alu_op = 4'b1010; // Comparator (BEQ)
        #10;
        
        alu_op = 4'b1011; // Comparator (BNE)
        #10;
        operandA = 64'sd9223372036854775807; // INT_MAX for 64-bit signed integer
        alu_op = 4'b0010; // ADD
        #10;
        
        // Finish simulation
        #10 $finish;
    end
endmodule
