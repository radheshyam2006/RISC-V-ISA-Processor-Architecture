module instruction_fetch (   
    input pc_write,                      
    input [31:0] pc,       
    output reg [31:0] instruction,
   // input if_id_write,
    input clk
   // output id_write
);
    reg [31:0] inst_mem [0:255]; // 256 x 32-bit instruction memory

    initial begin
        // Initialize all memory to avoid x's in simulation
     // Storing instructions sequentially in a 2D array
        //60-address of exit
        inst_mem[0] = 32'b00000000000001111011000110000011; // ld x3, 0(x15)    x3-a=0
        inst_mem[1] = 32'b00000000100001111011001000000011; // ld x4, 16(x15)  
        inst_mem[2] = 32'b00000001000001111011111100000011; // ld x30, 32(x15)
 // ld x30, 16(x15)

  // ld x30, 16(x15) // ld x30, 16(x14)   x6=n
        inst_mem[3] = 32'b0_000000_01010_11110_000_01110_1100011; // beq x10 x30
        inst_mem[4]=  32'b0000000_00100_00011_000_00111_0110011 ;// add x7 x3 x4 
        inst_mem[5] = 32'b0000000_00000_00100_000_00011_0110011; // add x3, x4, x0 
        inst_mem[6] = 32'b0000000_00000_00111_000_00100_0110011; // add x4, x7, x0
        inst_mem[7] = 32'b000000000001_01010_000_01011_0010011; // add x11, x10, 1
        inst_mem[8] = 32'b0000000_00000_01011_000_01010_0110011; // add x10, x11, x0
         inst_mem[9] = 32'b1_111111_00000_00000_000_1010_1_1100011; // beq x0, x0, -6 // beq x0, x0, -5
        inst_mem[16] = 32'b11111111111111111111111111111111; // EXIT (111111 opcode for finish)  
             // beq x1, x2, +6 (if a >= b, jump to inst_mem[3])
    //    inst_mem[1] = 32'b000000000000_00000_011_00111_0000011; // ld x7, 0(x0)
        //  inst_mem[1] = 32'b0000000_00000_00111_000_00011_0110011; // add  x3 x7 x0
        // inst_mem[6] = 32'b0000000_00000_00000_000_0010_0_1100011; // beq x0, x0, +4 (unconditional jump)
        // inst_mem[7] = 32'b0000000_00010_00011_111_00110_0110011; // and x6, x3, x2 (f = c & b)
        //  inst_mem[2] = 32'b0000000_00001_00010_101_00111_1111100;
        // inst_mem[2] = 32'b0000000_00000_00000_000_0010_0_1100011; // beq x0, x0, +4 (unconditional jump)
        // inst_mem[3] = 32'b0100000_00010_00011_000_00101_0110011; // sub x5, x3, x2 (e = c - b)(x3-x2)
        
        // inst_mem[4] = 32'b0000000_00011_00010_001_0011_0_1100011; // bne x2, x3, +6 (if c != b, jump to inst_mem[7])
        // inst_mem[1] = 32'b0100000_00100_00011_000_00110_0110011; // sub x6 x3 x4
        // inst_mem[0] = 32'b0000000_00110_00010_000_00111_0110011; // add  x7 x2 x6
       // inst_mem[9] = 32'b0000000_00001_00010_101_00111_1111111;
    end
   // reg id_write_reg;
   // and(pc_up,branch,ex_alu_result[0]);
    always @(*) begin
        //if(if_id_write) begin
            instruction = inst_mem[pc >> 2]; // Divide by 4 to get the index
            // $display("TIME : %0t  || clk : %b",$time, clk);
            // $display("\nFetching instruction at Address: %d",  pc/4);
            // $display("Instruction: %b", instruction);
            //id_write_reg = 1;
          //  end
    end
   // assign id_write = id_write_reg;
endmodule