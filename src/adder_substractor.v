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

module testing_adder_subtractor;
    reg [63:0] A, B;
    reg M;
    wire [63:0] S;
    wire Cout;
    
    add_sub_64bit DUT (.A(A), .B(B), .M(M), .S(S), .Cout(Cout));

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, testing_adder_subtractor);
        
        $monitor("Time: %0t | A = %d | B = %d | M = %d | S = %d | Cout = %d", $time, A, B, M, S, Cout);

        A = 64'h0000000000000001; B = 64'h0000000000000001; M = 0; #10; // 1 + 1 = 2
        A = 64'h0000000000000003; B = 64'h0000000000000001; M = 0; #10; // 3 + 1 = 4
        A = 64'h000000000000000F; B = 64'h000000000000000F; M = 0; #10; // 15 + 15 = 30
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001; M = 0; #10; // Max + 1 (Overflow)
        A = 64'h000000000000000A; B = 64'h0000000000000005; M = 1; #10; // 10 - 5 = 5
        A = 64'h0000000000000010; B = 64'h0000000000000008; M = 1; #10; // 16 - 8 = 8
        A = 64'h00000000000000FF; B = 64'h0000000000000001; M = 1; #10; // 255 - 1 = 254
        A = 64'h0000000000000000; B = 64'h0000000000000001; M = 1; #10; // 0 - 1 = -1 (two's complement)
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFE; M = 1; #10; // Max - (Max - 1) = 1
        A = 64'h8000000000000000; B = 64'h0000000000000001; M = 1; #10; // -Max - 1

        $finish;
    end
endmodule
