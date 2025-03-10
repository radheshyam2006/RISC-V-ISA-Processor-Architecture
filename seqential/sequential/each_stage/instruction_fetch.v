module instruction_fetch (                         
    input [31:0] pc,       
    output reg [31:0] instruction
);
    reg [31:0] inst_mem [0:255]; // 256 x 32-bit instruction memory

    initial begin
        // Initialize all memory to avoid x's in simulatio
        // Assuming registers are already loaded with values:
        // x1 = a, x2 = b, x3 = c, x4 = d
        // Results will be stored in:
        // x5 = e, x6 = f
        /*if(x1>=x2) x5=x3-x2; else x5=x3+x2; if(x2!=x3) x6=x3&x2; else x6=x3|x4 */

        // inst_mem[4] = 32'b0000000_00001_00010_101_00100_1111111;
        inst_mem[0] = 32'b0000000_00010_00001_100_0011_0_1100011; // beq x1, x2, +6 (if a >= b, jump to inst_mem[3])
        inst_mem[1] = 32'b0000000_00010_00011_000_00101_0110011; // add x5, x3, x2 (e = c + b)
        inst_mem[2] = 32'b0000000_00000_00000_000_0010_0_1100011; // beq x0, x0, +4 (unconditional jump)
        inst_mem[3] = 32'b0100000_00010_00011_000_00101_0110011; // sub x5, x3, x2 (e = c - b)(x3-x2)
        
        inst_mem[4] = 32'b0000000_00011_00010_001_0011_0_1100011; // bne x2, x3, +6 (if c != b, jump to inst_mem[7])
        inst_mem[5] = 32'b0000000_00100_00011_110_00110_0110011; // or x6, x3, x4 (f = c | d)
        inst_mem[6] = 32'b0000000_00000_00000_000_0010_0_1100011; // beq x0, x0, +4 (unconditional jump)
        inst_mem[7] = 32'b0000000_00010_00011_111_00110_0110011; // and x6, x3, x2 (f = c & b)
        inst_mem[8] = 32'b0000000_00001_00010_101_00100_1111111;

    end

    always @(*) begin
        instruction = inst_mem[pc >> 2]; // Divide by 4 to get the index

        $display("\nFetching instruction at Address: %d", pc/4);
        $display("Instruction: %b", instruction);
        // $display("Opcode: %b | RD: x%d | Funct3: %b | RS1: x%d | RS2: x%d | Funct7: %b", 
        //          instruction[6:0], instruction[11:7], instruction[14:12], 
        //          instruction[19:15], instruction[24:20], instruction[31:25]);
    end
endmodule
