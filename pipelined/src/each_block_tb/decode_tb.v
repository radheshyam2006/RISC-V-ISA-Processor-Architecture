`timescale 1ns / 1ps
`include "decode.v"
module decode_tb;
    reg [31:0] instruction;
    reg clk;
    reg id_ex_MemRead;
    reg [4:0] id_ex_Rd;
    reg [4:0] if_id_Rs1;
    reg [4:0] if_id_Rs2;
    reg hazard_detected;
    
    wire PCWrite;
    wire IF_ID_Write;
    wire id_ex_Memread;
    wire id_ex_MemtoReg;
    wire id_ex_Regwrite;
    wire id_ex_Memwrite;
    wire id_ex_write;
    wire [4:0] id_ex_rs1;
    wire [4:0] id_ex_rs2;
    wire [4:0] id_ex_rd;
    wire [6:0] opcode;
    wire alu_src;
    wire [3:0] alu_op;
    wire branch;
    wire [63:0] imm;
    
    // Instantiate the module
    decode uut (
        .instruction(instruction),
        .clk(clk),
        .id_ex_MemRead(id_ex_MemRead),
        .id_ex_Rd(id_ex_Rd),
        .if_id_Rs1(if_id_Rs1),
        .if_id_Rs2(if_id_Rs2),
        .hazard_detected(hazard_detected),
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .id_ex_Memread(id_ex_Memread),
        .id_ex_MemtoReg(id_ex_MemtoReg),
        .id_ex_Regwrite(id_ex_Regwrite),
        .id_ex_Memwrite(id_ex_Memwrite),
        .id_ex_write(id_ex_write),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .id_ex_rd(id_ex_rd),
        .opcode(opcode),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch),
        .imm(imm)
    );

    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize inputs
        $monitor("PCWrite=%b, IF_ID_Write=%b, id_ex_Memread=%b, id_ex_MemtoReg=%b, id_ex_Regwrite=%b, id_ex_Memwrite=%b, id_ex_write=%b, id_ex_rs1=%d, id_ex_rs2=%d, id_ex_rd=%d, opcode=%b, alu_src=%b, alu_op=%b, branch=%b, imm=%d",
        PCWrite, IF_ID_Write, id_ex_Memread, id_ex_MemtoReg, id_ex_Regwrite, id_ex_Memwrite, id_ex_write, id_ex_rs1, id_ex_rs2, id_ex_rd, opcode, alu_src, alu_op, branch, imm);
        clk = 0;
        id_ex_MemRead = 0;
        id_ex_Rd = 0;
        if_id_Rs1 = 0;
        if_id_Rs2 = 0;
        hazard_detected = 0;
        
        // Test R-type instruction (ADD)
        instruction = 32'b0000000_00001_00010_000_00011_0110011; // ADD x3, x1, x2
        #10;
        
        // Test I-type instruction (ADDI)
        instruction = 32'b000000000101_00001_000_00011_0010011; // ADDI x3, x1, 5
        #10;
        
        // Test Load instruction (LW)
        instruction = 32'b000000000100_00001_010_00011_0000011; // LW x3, 4(x1)
        #10;
        
        // Test Store instruction (SW)
        instruction = 32'b0000000_00011_00001_010_00100_0100011; // SW x3, 4(x1)
        #10;
        
        // Test Branch instruction (BEQ)
        instruction = 32'b0000000_00001_00010_000_00011_1100011; // BEQ x1, x2, offset
        #10;
        
        // Test Hazard Detection
        hazard_detected = 1;
        #10;
        hazard_detected = 0;
        
        // Finish simulation
        $finish;
    end
endmodule
