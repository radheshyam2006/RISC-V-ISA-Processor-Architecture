module full_adder(input ai, input bi, input ci, output si, output co);
    wire xor1_out, and1_out, and2_out;

    xor (xor1_out, ai, bi);
    xor (si, xor1_out, ci);

    and (and1_out, ai, bi);
    and (and2_out, xor1_out, ci);
    
    or (co, and1_out, and2_out);
endmodule

module add_sub_64bit(input [63:0] A, input [63:0] B, input M, output [63:0] S, output Cout);
    wire [63:0] B_mux;
    wire [63:0] C; 

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin: adder_chain
            xor (B_mux[i], B[i], M); // Invert B if M=1 (for subtraction)

            if (i == 0) begin
                full_adder FA (.ai(A[i]), .bi(B_mux[i]), .ci(M), .si(S[i]), .co(C[i]));
            end else begin
                full_adder FA (.ai(A[i]), .bi(B_mux[i]), .ci(C[i-1]), .si(S[i]), .co(C[i]));
            end
        end
    endgenerate

    assign Cout = C[63]; // Final carry-out
endmodule

module and_64bit(input [63:0] A, input [63:0] B, output [63:0] Y);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin: bitwise_and
            and (Y[i], A[i], B[i]);
        end
    endgenerate
endmodule

module or_64bit(input [63:0] A, input [63:0] B, output [63:0] Y);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin: bitwise_or
            or (Y[i], A[i], B[i]);
        end
    endgenerate
endmodule

module xor_64bit(input [63:0] A, input [63:0] B, output [63:0] Y);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin: bitwise_xor
            xor (Y[i], A[i], B[i]);
        end
    endgenerate
endmodule


module mux_64bit (
    input [63:0] in0, in1,
    input sel,
    output [63:0] out
);
    genvar i;
    wire [63:0] sel_and_in1, not_sel_and_in0;
    wire not_sel;

    not (not_sel, sel);

    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_logic
            and (sel_and_in1[i], sel, in1[i]);
            and (not_sel_and_in0[i], not_sel, in0[i]);
            or (out[i], sel_and_in1[i], not_sel_and_in0[i]);
        end
    endgenerate
endmodule


module sll (
    input [63:0] rs1,
    input [5:0] rs2,
    output [63:0] result
);
    wire [63:0] mux1_output, mux2_output, mux3_output, mux4_output, mux5_output, mux6_output;

    mux_64bit mux1 (
        .in0(rs1),
        .in1({rs1[31:0], 32'b0}),  
        .sel(rs2[5]),
        .out(mux1_output)
    );

    mux_64bit mux2 (
        .in0(mux1_output),
        .in1({mux1_output[47:0], 16'b0}),
        .sel(rs2[4]),
        .out(mux2_output)
    );

    mux_64bit mux3 (
        .in0(mux2_output),
        .in1({mux2_output[55:0], 8'b0}),  
        .sel(rs2[3]),
        .out(mux3_output)
    );

    mux_64bit mux4 (
        .in0(mux3_output),
        .in1({mux3_output[59:0], 4'b0}),  
        .sel(rs2[2]),
        .out(mux4_output)
    );

    mux_64bit mux5 (
        .in0(mux4_output),
        .in1({mux4_output[61:0], 2'b0}),  
        .sel(rs2[1]),
        .out(mux5_output)
    );

    mux_64bit mux6 (
        .in0(mux5_output),
        .in1({mux5_output[62:0], 1'b0}),
        .sel(rs2[0]),
        .out(mux6_output)
    );

   assign result = mux6_output;
endmodule


module srl (
    input [63:0] rs1,
    input [5:0] rs2,
    output [63:0] result
);
    wire [63:0] mux1_output, mux2_output, mux3_output, mux4_output, mux5_output, mux6_output;

    mux_64bit mux1 (
        .in0(rs1),
        .in1({32'b0, rs1[63:32]}),  
        .sel(rs2[5]),
        .out(mux1_output)
    );

    mux_64bit mux2 (
        .in0(mux1_output),
        .in1({16'b0, mux1_output[63:16]}),  
        .sel(rs2[4]),
        .out(mux2_output)
    );

    mux_64bit mux3 (
        .in0(mux2_output),
        .in1({8'b0, mux2_output[63:8]}),  
        .sel(rs2[3]),
        .out(mux3_output)
    );

    mux_64bit mux4 (
        .in0(mux3_output),
        .in1({4'b0, mux3_output[63:4]}),  
        .sel(rs2[2]),
        .out(mux4_output)
    );

    mux_64bit mux5 (
        .in0(mux4_output),
        .in1({2'b0, mux4_output[63:2]}),  
        .sel(rs2[1]),
        .out(mux5_output)
    );

    mux_64bit mux6 (
        .in0(mux5_output),
        .in1({1'b0, mux5_output[63:1]}), 
        .sel(rs2[0]),
        .out(mux6_output)
    );

    assign result = mux6_output;
endmodule

module sra (
    input [63:0] rs1,
    input [5:0] rs2,
    output [63:0] result
);
    wire [63:0] mux1_output, mux2_output, mux3_output, mux4_output, mux5_output, mux6_output;
    wire sign = rs1[63]; // Sign bit

    mux_64bit mux1 (
        .in0(rs1),
        .in1({{32{sign}}, rs1[63:32]}),  
        .sel(rs2[5]),
        .out(mux1_output)
    );

    mux_64bit mux2 (
        .in0(mux1_output),
        .in1({{16{sign}}, mux1_output[63:16]}), 
        .sel(rs2[4]),
        .out(mux2_output)
    );

    mux_64bit mux3 (
        .in0(mux2_output),
        .in1({{8{sign}}, mux2_output[63:8]}), 
        .sel(rs2[3]),
        .out(mux3_output)
    );

    mux_64bit mux4 (
        .in0(mux3_output),
        .in1({{4{sign}}, mux3_output[63:4]}), 
        .sel(rs2[2]),
        .out(mux4_output)
    );

    mux_64bit mux5 (
        .in0(mux4_output),
        .in1({{2{sign}}, mux4_output[63:2]}),  
        .sel(rs2[1]),
        .out(mux5_output)
    );

    mux_64bit mux6 (
        .in0(mux5_output),
        .in1({{1{sign}}, mux5_output[63:1]}), 
        .sel(rs2[0]),
        .out(mux6_output)
    );

    assign result = mux6_output;
endmodule


module slt (
    input [63:0] A, B,
    output [63:0] Dest
);
    wire [63:0] S;
    wire Cout;
    wire sign_A, sign_B, sign_S, not_sign_B, xor_signs, term1, term2;

    add_sub_64bit sub_unit (.A(A), .B(B), .M(1'b1), .S(S), .Cout(Cout));

    assign sign_A = A[63];
    assign sign_B = B[63];
    assign sign_S = S[63];

    not (not_sign_B, sign_B);
    and (term1, sign_A, not_sign_B);
    xor (xor_signs, sign_A, sign_B);
    not (term2_not, xor_signs);
    and (term2, term2_not, sign_S);
    or (Dest[0], term1, term2);

    assign Dest[63:1] = 63'b0;
endmodule


module sltu (
    input  [63:0] A, B,
    output        Dest
);
    wire [63:0] less_than;

    assign less_than[0] = ~A[0] & B[0]; 

    genvar i;
    generate
        for (i = 1; i < 64; i = i + 1) begin : compare_loop
            assign less_than[i] = (~A[i] & B[i]) | (less_than[i-1] & ~(A[i] ^ B[i]));
        end
    endgenerate

    assign Dest = less_than[63];

endmodule


module alu (
    input  [63:0] A, B,
    input  [3:0]  alu_op,  
    output reg [63:0] result,
    output wire Cout,
    output wire overflow    

);
    wire [63:0] add_sub_out, sll_out, slt_out;
    wire [63:0] xor_out, srl_out, sra_out, or_out, and_out;
    wire cout;
    wire sltu_out;

    add_sub_64bit ADD_SUB (.A(A), .B(B), .M(alu_op[3]), .S(add_sub_out), .Cout(cout));
    slt SLT_UNIT (.A(A), .B(B), .Dest(slt_out));
    sltu SLTU_UNIT (.A(A), .B(B), .Dest(sltu_out));
    sll SLL_UNIT (.rs1(A), .rs2(B[5:0]), .result(sll_out));
    srl SRL_UNIT (.rs1(A), .rs2(B[5:0]), .result(srl_out));
    sra SRA_UNIT (.rs1(A), .rs2(B[5:0]), .result(sra_out));
    or_64bit OR_UNIT (.A(A), .B(B), .Y(or_out));
    and_64bit AND_UNIT (.A(A), .B(B), .Y(and_out));
    xor_64bit XOR_UNIT (.A(A), .B(B), .Y(xor_out));
    assign overflow = (alu_op == 4'b0000) ? ((~A[63] & ~B[63] & add_sub_out[63]) | (A[63] & B[63] & ~add_sub_out[63])) : 
                   (alu_op == 4'b1000) ? ((~A[63] & B[63] & add_sub_out[63]) | (A[63] & ~B[63] & ~add_sub_out[63])) : 1'b0;
    assign Cout = cout;

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

`timescale 1ns / 1ps

module alu_tb;
    reg signed [63:0] A, B; // Signed for all except SLTU
    reg [3:0] alu_op;
    wire signed [63:0] result;
    wire cout, overflow;
    wire sltu_out;

    // Instantiate ALU
    alu uut (
        .A(A), 
        .B(B), 
        .alu_op(alu_op), 
        .result(result),
        .Cout(cout),
        .overflow(overflow)
    );

    initial begin
        $dumpfile("alu_waveform.vcd");  // For waveform analysis
        $dumpvars(0, alu_tb);
        $monitor(" A=%b | B=%d | ALU_OP=%b | Result=%b ", A, B, alu_op, result);
        
        //  **Addition Tests**
        A = 64'sd10; B = 64'sd20; alu_op = 4'b0000; #10; // 10 + 20 = 30
        A = 64'sd500; B = -64'sd250; alu_op = 4'b0000; #10; // 500 + (-250) = 250
        A = 64'sd9223372036854775807; B = 64'sd1; alu_op = 4'b0000; #10; // Max + 1 (Overflow)
        A = 64'h0000000000000001; B = 64'h0000000000000001; alu_op = 4'b0000 ; #10; // 1 + 1 = 2
        A = 64'h0000000000000003; B = 64'h0000000000000001; alu_op = 4'b0000; #10; // 3 + 1 = 4
        A = 64'h000000000000000F; B = 64'h000000000000000F; alu_op = 4'b0000; #10; // 15 + 15 = 30
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001; alu_op = 4'b0000; #10; // Max + 1 (Overflow)
        
        
        //  **Subtraction Tests**
        A = 64'sd30; B = 64'sd10; alu_op = 4'b1000; #10; // 30 - 10 = 20
        A = 64'sd0; B = 64'sd1; alu_op = 4'b1000; #10; // 0 - 1 = -1
        A = -64'sd1; B = 64'sd1; alu_op = 4'b1000; #10; // -1 - 1 = -2
        A = -64'sd9223372036854775808; B = 64'sd1; alu_op = 4'b1000; #10; // Min - 1 (Overflow)
        A = 64'h000000000000000A; B = 64'h0000000000000005; alu_op = 4'b1000 ; #10; // 10 - 5 = 5
        A = 64'h0000000000000010; B = 64'h0000000000000008; alu_op = 4'b1000 ; #10; // 16 - 8 = 8
        A = 64'h00000000000000FF; B = 64'h0000000000000001; alu_op = 4'b1000 ; #10; // 255 - 1 = 254
        A = 64'h0000000000000000; B = 64'h0000000000000001; alu_op = 4'b1000 ; #10; // 0 - 1 = -1 (two's complement)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFE; alu_op = 4'b1000 ; #10; // Max - (Max - 1) = 1
        A = 64'h8000000000000000; B = 64'h0000000000000001; alu_op = 4'b1000 ; #10; // -Max - 1

        //  **Shift Operations**
        A = 64'sd1; B = 64'sd2; alu_op = 4'b0001; #10; // SLL (1 << 2) = 
        A = 64'h0000000000000001; B = 64'b000001;alu_op = 4'b0001;  #10; // Shift left 1
        A = 64'h0000000000000001; B = 64'b000100;alu_op = 4'b0001;  #10; // Shift left 16
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'b000010;alu_op = 4'b0001;  #10; // Shift right 2 (All 1s)
        A = 64'h8000000000000000; B = 64'b000001;alu_op = 4'b0001;  #10; // Arithmetic Right Shift (Negative)
        A = 64'h8000000000000000; B = 64'b000100;alu_op = 4'b0001;  #10; // Arithmetic Right Shift by 16
        A = 64'h7FFFFFFFFFFFFFFF; B = 64'b000010;alu_op = 4'b0001;  #10; // Shift right 2 (All 1s except MSB)
        A = 64'hAAAAAAAAAAAAAAAA; B = 64'b000011;alu_op = 4'b0001;  #10; // Pattern Shift Check
        A = 64'h00000000000000FF; B = 64'b001100;alu_op = 4'b0001;  #10; // Shift left 12
        A = 64'h8000000000000000; B = 64'b001111;alu_op = 4'b0001;  #10; // Maximum shift (all cases)
        A = -64'sd8; B = 64'sd2; alu_op = 4'b1101; #10; // SRA (-8 >> 2) = -2
        A = 64'h0000000000000001; B = 64'b000100;alu_op = 4'b1101;  #10; // Shift left 16
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'b000010;alu_op = 4'b1101;  #10; // Shift right 2 (All 1s)
        A = 64'h0000000000000001; B = 64'b000001;alu_op = 4'b1101;  #10; // Shift left 1
        A = 64'h8000000000000000; B = 64'b000001;alu_op = 4'b1101;  #10; // Arithmetic Right Shift (Negative)
        A = 64'h8000000000000000; B = 64'b000100;alu_op = 4'b1101;  #10; // Arithmetic Right Shift by 16
        A = 64'h7FFFFFFFFFFFFFFF; B = 64'b000010;alu_op = 4'b1101;  #10; // Shift right 2 (All 1s except MSB)
        A = 64'hAAAAAAAAAAAAAAAA; B = 64'b000011;alu_op = 4'b1101;  #10; // Pattern Shift Check
        A = 64'h00000000000000FF; B = 64'b001100;alu_op = 4'b1101;  #10; // Shift left 12
        A = 64'h8000000000000000; B = 64'b001111;alu_op = 4'b1101;  #10; // Maximum shift (all cases)
        A = 64'sd16; B = 64'sd2; alu_op = 4'b0101; #10; // SRL (16 >> 2) = 4
        A = 64'h0000000000000001; B = 64'b000001;alu_op = 4'b0101;  #10; // Shift left 1
        A = 64'h0000000000000001; B = 64'b000100;alu_op = 4'b0101;  #10; // Shift left 16
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'b000010;alu_op = 4'b0101;  #10; // Shift right 2 (All 1s)
        A = 64'h8000000000000000; B = 64'b000001;alu_op = 4'b0101;  #10; // Arithmetic Right Shift (Negative)
        A = 64'h8000000000000000; B = 64'b000100;alu_op = 4'b0101;  #10; // Arithmetic Right Shift by 16
        A = 64'h7FFFFFFFFFFFFFFF; B = 64'b000010;alu_op = 4'b0101;  #10; // Shift right 2 (All 1s except MSB)
        A = 64'hAAAAAAAAAAAAAAAA; B = 64'b000011;alu_op = 4'b0101;  #10; // Pattern Shift Check
        A = 64'h00000000000000FF; B = 64'b001100;alu_op = 4'b0101;  #10; // Shift left 12
        A = 64'h8000000000000000; B = 64'b001111;alu_op = 4'b0101;  #10; // Maximum shift (all cases)

        //  **Bitwise Operations**
        A = 64'shF0F0F0F0F0F0F0F0; B = 64'sh0F0F0F0F0F0F0F0F; alu_op = 4'b0100; #10; // XOR
        A = 64'shAAAAAAAAAAAAAAAA; B = 64'sh5555555555555555; alu_op = 4'b0110; #10; // OR
        A = 64'shFFFFFFFFFFFFFFFF; B = 64'sh0F0F0F0F0F0F0F0F; alu_op = 4'b0111; #10; // AND

        //  **Comparison (Signed SLT)**
        A = 64'sd5; B = 64'sd10; alu_op = 4'b0010; #10; // SLT (5 < 10) = 1
        A = -64'sd1; B = 64'sd1; alu_op = 4'b0010; #10; // SLT (-1 < 1) = 1
        A = 64'sd1; B = -64'sd1; alu_op = 4'b0010; #10; // SLT (1 < -1) = 0
        A = 64'h0000000000000000; B = 64'h0000000000000001; #10; // A = 0, B = 1 (Both SLT & SLTU should be 1)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001; #10; // A = -1, B = 1 (SLT = 1, SLTU = 0)
        A = 64'h0000000000000001; B = 64'hFFFFFFFFFFFFFFFF; #10; // A = 1, B = -1 (SLT = 0, SLTU = 1)
        A = 64'h8000000000000000; B = 64'h0000000000000001; #10; // A = Most Negative (-2^63), B = 1 (SLT = 1)
        A = 64'h7FFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF; #10; // A = Max Positive, B = -1 (SLT = 0)
        A = 64'h8000000000000000; B = 64'h7FFFFFFFFFFFFFFF; #10; // A = -2^63, B = 2^63-1 (SLT = 1, SLTU = 1)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFE; #10; // A = -1, B = -2 (SLT = 0)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF; #10; // A = B = -1 (SLT = 0, SLTU = 0)

        // **Comparison (Unsigned SLTU)**
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000000; alu_op = 4'b0011; #10; // SLTU (Max < 0) = 0
        A = 64'h0000000000000001; B = 64'hFFFFFFFFFFFFFFFF; alu_op = 4'b0011; #10; // SLTU (1 < Max) = 1
        A = 64'hFFFFFFFFFFFFFFFE; B = 64'hFFFFFFFFFFFFFFFF; alu_op = 4'b0011; #10; // SLTU (Max-1 < Max) = 1
        A = 64'h0000000000000000; B = 64'h0000000000000001; #10; // A = 0, B = 1 (Both SLT & SLTU should be 1)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001; #10; // A = -1, B = 1 (SLT = 1, SLTU = 0)
        A = 64'h0000000000000001; B = 64'hFFFFFFFFFFFFFFFF; #10; // A = 1, B = -1 (SLT = 0, SLTU = 1)
        A = 64'h8000000000000000; B = 64'h0000000000000001; #10; // A = Most Negative (-2^63), B = 1 (SLT = 1)
        A = 64'h7FFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF; #10; // A = Max Positive, B = -1 (SLT = 0)
        A = 64'h8000000000000000; B = 64'h7FFFFFFFFFFFFFFF; #10; // A = -2^63, B = 2^63-1 (SLT = 1, SLTU = 1)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFE; #10; // A = -1, B = -2 (SLT = 0)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF; #10; // A = B = -1 (SLT = 0, SLTU = 0)

        $finish;
    end
endmodule



// module slt (
//     input [63:0] A, B,
//     output [63:0] Dest
// );
//     wire [63:0] S;
//     wire Cout;

//     // Subtract: A - B
//     add_sub_64bit sub_unit (.A(A), .B(B), .M(1'b1), .S(S), .Cout(Cout));

//     // Assign Dest directly
//     assign Dest = (A[63] & ~B[63]) | (~(A[63] ^ B[63]) & S[63]);
// endmodule


// module test_slt_sltu;
//     reg [63:0] A, B;
//     wire [63:0] slt_out;
//     wire sltu_out;

//     // Instantiate SLT and SLTU modules
//     slt slt_inst (.A(A), .B(B), .Dest(slt_out));
//     sltu sltu_inst (.A(A), .B(B), .Dest(sltu_out));

//     initial begin
//         $dumpfile("waveform.vcd");
//         $dumpvars(0, test_slt_sltu);
//         $monitor("Time: %0t | A = %d | B = %d | SLT = %d | SLTU = %d", $time, A, B, slt_out, sltu_out);

//         // Corner Test Cases
//         A = 64'h0000000000000000; B = 64'h0000000000000001; #10; // A = 0, B = 1 (Both SLT & SLTU should be 1)
//         A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001; #10; // A = -1, B = 1 (SLT = 1, SLTU = 0)
//         A = 64'h0000000000000001; B = 64'hFFFFFFFFFFFFFFFF; #10; // A = 1, B = -1 (SLT = 0, SLTU = 1)
//         A = 64'h8000000000000000; B = 64'h0000000000000001; #10; // A = Most Negative (-2^63), B = 1 (SLT = 1)
//         A = 64'h7FFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF; #10; // A = Max Positive, B = -1 (SLT = 0)
//         A = 64'h8000000000000000; B = 64'h7FFFFFFFFFFFFFFF; #10; // A = -2^63, B = 2^63-1 (SLT = 1, SLTU = 1)
//         A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFE; #10; // A = -1, B = -2 (SLT = 0)
//         A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF; #10; // A = B = -1 (SLT = 0, SLTU = 0)

//         $finish;
//     end
// endmodule



// module mux_64bit (
//     input [63:0] in0, in1,
//     input sel,
//     output [63:0] out
// );
//     assign out = sel ? in1 : in0;
// endmodule

// module testing_adder_subtractor;
//     reg [63:0] A, B;
//     reg M;
//     wire [63:0] S;
//     wire Cout;
    
//     add_sub_64bit DUT (.A(A), .B(B), .M(M), .S(S), .Cout(Cout));

//     initial begin
//         $dumpfile("waveform.vcd");
//         $dumpvars(0, testing_adder_subtractor);
        
//         $monitor("Time: %0t | A = %d | B = %d | M = %d | S = %d | Cout = %d", $time, A, B, M, S, Cout);

//         A = 64'h0000000000000001; B = 64'h0000000000000001; M = 0; #10; // 1 + 1 = 2
//         A = 64'h0000000000000003; B = 64'h0000000000000001; M = 0; #10; // 3 + 1 = 4
//         A = 64'h000000000000000F; B = 64'h000000000000000F; M = 0; #10; // 15 + 15 = 30
//         A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001; M = 0; #10; // Max + 1 (Overflow)
//         A = 64'h000000000000000A; B = 64'h0000000000000005; M = 1; #10; // 10 - 5 = 5
//         A = 64'h0000000000000010; B = 64'h0000000000000008; M = 1; #10; // 16 - 8 = 8
//         A = 64'h00000000000000FF; B = 64'h0000000000000001; M = 1; #10; // 255 - 1 = 254
//         A = 64'h0000000000000000; B = 64'h0000000000000001; M = 1; #10; // 0 - 1 = -1 (two's complement)
//         A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFE; M = 1; #10; // Max - (Max - 1) = 1
//         A = 64'h8000000000000000; B = 64'h0000000000000001; M = 1; #10; // -Max - 1

//         $finish;
//     end
// endmodule



// module test_shift_operations;
//     reg [63:0] A;
//     reg [5:0] shift_amount;
//     wire [63:0] SLL_result, SRL_result, SRA_result;

//     // Instantiate SLL, SRL, and SRA modules
//     sll sll_inst (.rs1(A), .rs2(shift_amount), .result(SLL_result));
//     srl srl_inst (.rs1(A), .rs2(shift_amount), .result(SRL_result));
//     sra sra_inst (.rs1(A), .rs2(shift_amount), .result(SRA_result));

//     initial begin
//         $dumpfile("waveform.vcd");  // Generate VCD file for GTKWave
//         $dumpvars(0, test_shift_operations);

//         // Display results in terminal
//         $monitor("Time = %0t | A = %b | Shift = %d | SLL = %b | SRL = %b | SRA = %b", 
//                  $time, A, shift_amount, SLL_result, SRL_result, SRA_result);

//         // Test Cases
//         A = 64'h0000000000000001; shift_amount = 6'b000001; #10; // Shift left 1
//         A = 64'h0000000000000001; shift_amount = 6'b000100; #10; // Shift left 16
//         A = 64'hFFFFFFFFFFFFFFFF; shift_amount = 6'b000010; #10; // Shift right 2 (All 1s)
//         A = 64'h8000000000000000; shift_amount = 6'b000001; #10; // Arithmetic Right Shift (Negative)
//         A = 64'h8000000000000000; shift_amount = 6'b000100; #10; // Arithmetic Right Shift by 16
//         A = 64'h7FFFFFFFFFFFFFFF; shift_amount = 6'b000010; #10; // Shift right 2 (All 1s except MSB)
//         A = 64'hAAAAAAAAAAAAAAAA; shift_amount = 6'b000011; #10; // Pattern Shift Check
//         A = 64'h00000000000000FF; shift_amount = 6'b001100; #10; // Shift left 12
//         A = 64'h8000000000000000; shift_amount = 6'b001111; #10; // Maximum shift (all cases)

//         $finish;
//     end
// endmodule