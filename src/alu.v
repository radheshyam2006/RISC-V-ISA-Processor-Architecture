`include "and_xor_or.v"
`include "sll_srl_sra.v"
`include "stl_stlu.v"
// `include "adder_substractor.v"


module alu (
    input  [63:0] A, B,
    input  [3:0]  alu_op,  // 4-bit opcode
    output reg [63:0] result // Must be "reg" for assignment inside always block
);
    wire [63:0] add_sub_out, sll_out, slt_out;
    wire [63:0] xor_out, srl_out, sra_out, or_out, and_out;
    wire cout;
    wire sltu_out;

    // Instantiate ALU operation modules
    add_sub_64bit ADD_SUB (.A(A), .B(B), .M(alu_op[3]), .S(add_sub_out), .Cout(cout));
    sll SLL_UNIT (.rs1(A), .rs2(B[5:0]), .result(sll_out));
    slt SLT_UNIT (.A(A), .B(B), .Dest(slt_out));
    sltu SLTU_UNIT (.A(A), .B(B), .Dest(sltu_out));
    xor_64bit XOR_UNIT (.A(A), .B(B), .Y(xor_out));
    srl SRL_UNIT (.rs1(A), .rs2(B[5:0]), .result(srl_out));
    sra SRA_UNIT (.rs1(A), .rs2(B[5:0]), .result(sra_out));
    or_64bit OR_UNIT (.A(A), .B(B), .Y(or_out));
    and_64bit AND_UNIT (.A(A), .B(B), .Y(and_out));

    // Multiplexer to select the output based on opcode
    always @(*) begin
        case (alu_op)
            4'b0000: result = add_sub_out;  // ADD
            4'b1000: result = add_sub_out;  // SUB (since M=1 for subtraction)
            4'b0001: result = sll_out;      // SLL
            4'b0010: result = {63'b0,slt_out};      // SLT
            4'b0011: result = {63'b0,sltu_out};     // SLTU
            4'b0100: result = xor_out;      // XOR
            4'b0101: result = srl_out;      // SRL
            4'b1101: result = sra_out;      // SRA
            4'b0110: result = or_out;       // OR
            4'b0111: result = and_out;      // AND
            default: result = 64'b0;        // Default to zero
        endcase
    end
endmodule


module alu_tb;
    reg [63:0] A, B;
    reg [3:0] alu_op;
    wire [63:0] result;

    // Instantiate the ALU
    alu uut (
        .A(A), 
        .B(B), 
        .alu_op(alu_op), 
        .result(result)
    );

    initial begin
        // Monitor values
        $monitor("Time=%0t A=%h B=%h ALU_OP=%b Result=%h", $time, A, B, alu_op, result);
        
        // Test ADD (opcode 0000)
        A = 64'h10; B = 64'h20; alu_op = 4'b0000;
        #10;
        
        // Test SUB (opcode 1000)
        A = 64'h30; B = 64'h10; alu_op = 4'b1000;
        #10;
        
        // Test SLL (opcode 0001)
        A = 64'h1; B = 64'h2; alu_op = 4'b0001;
        #10;
        
        // Test SLT (opcode 0010)
        A = 64'h5; B = 64'hA; alu_op = 4'b0010;
        #10;
        
        // Test SLTU (opcode 0011)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0; alu_op = 4'b0011;
        #10;
        
        // Test XOR (opcode 0100)
        A = 64'hF0F0F0F0F0F0F0F0; B = 64'h0F0F0F0F0F0F0F0F; alu_op = 4'b0100;
        #10;
        
        // Test SRL (opcode 0101)
        A = 64'h8000000000000000; B = 64'h1; alu_op = 4'b0101;
        #10;
        
        // Test SRA (opcode 1101)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'h1; alu_op = 4'b1101;
        #10;
        
        // Test OR (opcode 0110)
        A = 64'hAAAA_AAAA_AAAA_AAAA; B = 64'h5555_5555_5555_5555; alu_op = 4'b0110;
        #10;
        
        // Test AND (opcode 0111)
        A = 64'hFFFF_FFFF_FFFF_FFFF; B = 64'h0F0F_0F0F_0F0F_0F0F; alu_op = 4'b0111;
        #10;
        
        // Finish simulation
        $finish;
    end
endmodule
