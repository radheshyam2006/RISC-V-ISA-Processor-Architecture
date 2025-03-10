module tb_processor;
    reg [31:0] instruction;
    reg signed [63:0] reg1, reg2;
    wire signed [63:0] result;
    wire overflow;

    processor uut (
        .instruction(instruction),
        .reg1(reg1),
        .reg2(reg2),
        .result(result),
        .overflow(overflow)
    );

    initial begin
         $dumpfile("processor_tb.vcd");  // Specify the output VCD file name
        $dumpvars(0, tb_processor);
         $monitor("Time=%0t | Instr=%b | Reg1=%d | Reg2=%d | Result=%d | Overflow=%b",
         $time, instruction, reg1, reg2, result, overflow);


        // ADD Test Cases
         instruction = {7'b0000000, 5'd3, 5'd2, 3'b000, 5'd1, 7'b0110011};
        reg1 = 64'h7FFFFFFFFFFFFFFF; reg2 = 1; #10; // INT_MAX + 1 (Overflow)
        reg1 = -64'h8000000000000000; reg2 = -1; #10; // INT_MIN - 1
        reg1 = 64'h7FFFFFFFFFFFFFFF; reg2 = -64'h8000000000000000; #10;
        reg1 = -90; reg2 = 40; #10;

        // SUB Test Cases
        instruction = {7'b0100000, 5'd3, 5'd2, 3'b000, 5'd1, 7'b0110011};// SUB
        reg1 = 64'h7FFFFFFFFFFFFFFF; reg2 = -1; #10;
        reg1 = -64'h8000000000000000; reg2 = 1; #10;
        reg1 = -64'h8000000000000000; reg2 = 64'h7FFFFFFFFFFFFFFF; #10;
        reg1 = -50; reg2 = -89; #10;

        // AND/OR/XOR Test Cases
        instruction = {7'b0000000, 5'd3, 5'd2,3'b111, 5'd1, 7'b0110011}; // AND
        reg1 = 64'hFFFF0000FFFF0000; reg2 = 64'h00FF00FF00FF00FF; #10;
        instruction = {7'b0000000, 5'd3, 5'd2, 3'b110, 5'd1, 7'b0110011}; // OR
        reg1 = 64'hFFFF0000FFFF0000; reg2 = 64'h00FF00FF00FF00FF; #10;
        instruction = {7'b0000000, 5'd3, 5'd2, 3'b100, 5'd1, 7'b0110011}; // XOR
        reg1 = 64'hFFFF0000FFFF0000; reg2 = 64'h00FF00FF00FF00FF; #10;
        // Left Shift (SLL)

        instruction = {7'b0000000,5'd3, 5'd2 , 3'b001, 5'd1, 7'b0110011}; // SLL
        reg1 = 64'h7FFFFFFFFFFFFFFF; reg2 = 1; #10;
        reg1 = 1; reg2 = 31; #10;
        reg1 = -64'h7FFFFFFFFFFFFFFF; reg2 = 3; #10;
        reg1 = -1; reg2 = 54; #10;

        // Right Shift Logical (SRL)
       instruction = {7'b0000000, 5'd3, 5'd2, 3'b101, 5'd1, 7'b0110011}; // SRL
        reg1 = 64'h7FFFFFFFFFFFFFFF; reg2 = 1; #10;
        reg1 = 1; reg2 = 62; #10;
        reg1 = -64'h7FFFFFFFFFFFFFFF; reg2 = 62; #10;
        reg1 = -1; reg2 = 45; #10;

        // Right Shift Arithmetic (SRA)
        instruction = {7'b0100000, 5'd3, 5'd2, 3'b101,  5'd1, 7'b0110011}; // SRA
        reg1 = 64'h7FFFFFFFFFFFFFFF; reg2 = 9; #10;
        reg1 = 1; reg2 = 4; #10;
        reg1 = -64'h7FFFFFFFFFFFFFFF; reg2 = 34; #10;
        reg1 = -1; reg2 = 1; #10;

        // Signed Less Than (SLT)
        instruction = {7'b0000000, 5'd3, 5'd2, 3'b010,  5'd1, 7'b0110011}; // SLT
        reg1 = -1; reg2 = -30; #10;
        reg1 = 64'h7FFFFFFFFFFFFFFF; reg2 = -64'h8000000000000000; #10;
        reg1 = 30; reg2 = -15; #10;
        reg1 = -40; reg2 = 50; #10;

        // Unsigned Less Than (SLTU)
        instruction = {7'b0000000, 5'd3, 5'd2, 3'b011,  5'd1, 7'b0110011}; // SLTU
        reg1 = 1; reg2 = 30; #10;
        reg1 = 64'h7FFFFFFFFFFFFFFF; reg2 = 64'h7FFFFFFFFFFFFFFF; #10;
        reg1 = 30; reg2 = 15; #10;
        reg1 = 40; reg2 = 50; #10;

        $finish;
    end

endmodule
