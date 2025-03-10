`timescale 1ns / 1ps
`include "decode.v"
module decode_tb();

    reg [31:0] instruction;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7, opcode;
    wire branch, alu_src, memread, memwrite, memtoreg, regwrite;
    wire [3:0] alu_op;
    wire [63:0] imm;

    // Instantiate the module
    decode uut (
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .branch(branch),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .imm(imm),
        .memread(memread),
        .memwrite(memwrite),
        .memtoreg(memtoreg),
        .regwrite(regwrite)
    );

    initial begin
        // R-type Instructions (Register-Register)
        instruction = 32'b0000000_00001_00010_000_00011_0110011; // add x3, x1, x2
        #10;
        instruction = 32'b0100000_00001_00010_000_00011_0110011; // sub x3, x1, x2
        #10;
        instruction = 32'b0000000_00001_00010_110_00011_0110011; // or x3, x1, x2
        #10;

        // I-type Instructions (Immediate-based operations)
        instruction = 32'b000000000101_00001_000_00010_0010011; // addi x2, x1, 5
        #10;
        instruction = 32'b000000000101_00001_110_00010_0010011; // ori x2, x1, 5
        #10;
        instruction = 32'b000000000101_00001_100_00010_0010011; // xori x2, x1, 5
        #10;

        // S-type Instructions (Store Doubleword)
        instruction = 32'b0000000_00010_00011_011_00100_0100011; // sd x2, 4(x3)
        #10;
        instruction = 32'b0000000_00100_00011_011_00100_0100011; // sd x4, 4(x3)
        #10;

        // I-type Instructions (Load Doubleword)
        instruction = 32'b000000000100_00011_011_00010_0000011; // ld x2, 4(x3)
        #10;
        instruction = 32'b000000000100_00011_011_00100_0000011; // ld x4, 4(x3)
        #10;


        // SB-type Instructions (Branch operations)
        instruction = 32'b0000000_00001_00010_000_0001_0_1100011; // beq x1, x2, +6
        #10;
        instruction = 32'b0000000_00001_00010_001_0001_0_1100011; // bne x1, x2, +6
        #10;
        instruction = 32'b0000000_00001_00010_101_0001_0_1100011; // bge x1, x2, +6
        #10;

        // Undefined instruction (to test default case)
        instruction = 32'b1111111_11111_11111_111_11111_1111111; 
        #10;

        $finish;
    end

endmodule
