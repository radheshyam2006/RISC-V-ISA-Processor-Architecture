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
    wire [63:0] C; // Carry chain

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

module slt (
    input [63:0] A, B,
    output [63:0] Dest
);
    wire [63:0] S;
    wire Cout;
    wire sign_A, sign_B, sign_S, not_sign_B, xor_signs, term1, term2;

    // Subtract: A - B
    add_sub_64bit sub_unit (.A(A), .B(B), .M(1'b1), .S(S), .Cout(Cout));

    assign sign_A = A[63];
    assign sign_B = B[63];
    assign sign_S = S[63];

    // Compute ~B[63]
    not (not_sign_B, sign_B);

    // Compute A[63] & ~B[63]
    and (term1, sign_A, not_sign_B);

    // Compute A[63] ^ B[63]
    xor (xor_signs, sign_A, sign_B);

    // Compute ~(A[63] ^ B[63]) & S[63]
    not (term2_not, xor_signs);
    and (term2, term2_not, sign_S);

    // Compute final Dest
    or (Dest[0], term1, term2);

    // Extend result to 64 bits (all other bits = 0)
    assign Dest[63:1] = 63'b0;

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


module sltu (
    input  [63:0] A, B,
    output        Dest
);
    wire [63:0] less_than;

    assign less_than[0] = ~A[0] & B[0]; // First bit comparison

    genvar i;
    generate
        for (i = 1; i < 64; i = i + 1) begin : compare_loop
            assign less_than[i] = (~A[i] & B[i]) | (less_than[i-1] & ~(A[i] ^ B[i]));
        end
    endgenerate

    assign Dest = less_than[63];

endmodule




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
//         $monitor("A = %d | B = %d | SLT = %d | SLTU = %d", A, B, slt_out, sltu_out);

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

