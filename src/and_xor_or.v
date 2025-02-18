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
