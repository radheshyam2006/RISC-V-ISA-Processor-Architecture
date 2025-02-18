// module mux_64bit (
//     input [63:0] in0, in1,
//     input sel,
//     output [63:0] out
// );
//     assign out = sel ? in1 : in0;
// endmodule

module mux_64bit (
    input [63:0] in0, in1,
    input sel,
    output [63:0] out
);
    genvar i;
    wire [63:0] sel_and_in1, not_sel_and_in0;
    wire not_sel;

    // Compute ~sel
    not (not_sel, sel);

    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_logic
            // Compute sel & in1[i]
            and (sel_and_in1[i], sel, in1[i]);

            // Compute ~sel & in0[i]
            and (not_sel_and_in0[i], not_sel, in0[i]);

            // Compute final out[i] = (sel & in1[i]) | (~sel & in0[i])
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

    // Shift by 32 if rs2[5] is set
    mux_64bit mux1 (
        .in0(rs1),
        .in1({rs1[31:0], 32'b0}),  
        .sel(rs2[5]),
        .out(mux1_output)
    );

    // Shift by 16 if rs2[4] is set
    mux_64bit mux2 (
        .in0(mux1_output),
        .in1({mux1_output[47:0], 16'b0}),
        .sel(rs2[4]),
        .out(mux2_output)
    );

    // Shift by 8 if rs2[3] is set
    mux_64bit mux3 (
        .in0(mux2_output),
        .in1({mux2_output[55:0], 8'b0}),  
        .sel(rs2[3]),
        .out(mux3_output)
    );

    // Shift by 4 if rs2[2] is set
    mux_64bit mux4 (
        .in0(mux3_output),
        .in1({mux3_output[59:0], 4'b0}),  
        .sel(rs2[2]),
        .out(mux4_output)
    );

    // Shift by 2 if rs2[1] is set
    mux_64bit mux5 (
        .in0(mux4_output),
        .in1({mux4_output[61:0], 2'b0}),  
        .sel(rs2[1]),
        .out(mux5_output)
    );

    // Shift by 1 if rs2[0] is set
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

    // Shift by 32 if rs2[4] is set
    mux_64bit mux1 (
        .in0(rs1),
        .in1({32'b0, rs1[63:32]}),  
        .sel(rs2[5]),
        .out(mux1_output)
    );

    // Shift by 16 if rs2[3] is set
    mux_64bit mux2 (
        .in0(mux1_output),
        .in1({16'b0, mux1_output[63:16]}),  
        .sel(rs2[4]),
        .out(mux2_output)
    );

    // Shift by 8 if rs2[2] is set
    mux_64bit mux3 (
        .in0(mux2_output),
        .in1({8'b0, mux2_output[63:8]}),  
        .sel(rs2[3]),
        .out(mux3_output)
    );

    // Shift by 4 if rs2[1] is set
    mux_64bit mux4 (
        .in0(mux3_output),
        .in1({4'b0, mux3_output[63:4]}),  
        .sel(rs2[2]),
        .out(mux4_output)
    );

    // Shift by 2 if rs2[0] is set
    mux_64bit mux5 (
        .in0(mux4_output),
        .in1({2'b0, mux4_output[63:2]}),  
        .sel(rs2[1]),
        .out(mux5_output)
    );

    // Shift by 1 if rs2[0] is set
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

    // Shift by 32 if rs2[4] is set
    mux_64bit mux1 (
        .in0(rs1),
        .in1({{32{sign}}, rs1[63:32]}),  
        .sel(rs2[5]),
        .out(mux1_output)
    );

    // Shift by 16 if rs2[3] is set
    mux_64bit mux2 (
        .in0(mux1_output),
        .in1({{16{sign}}, mux1_output[63:16]}), 
        .sel(rs2[4]),
        .out(mux2_output)
    );

    // Shift by 8 if rs2[2] is set
    mux_64bit mux3 (
        .in0(mux2_output),
        .in1({{8{sign}}, mux2_output[63:8]}), 
        .sel(rs2[3]),
        .out(mux3_output)
    );

    // Shift by 4 if rs2[1] is set
    mux_64bit mux4 (
        .in0(mux3_output),
        .in1({{4{sign}}, mux3_output[63:4]}), 
        .sel(rs2[2]),
        .out(mux4_output)
    );

    // Shift by 2 if rs2[0] is set
    mux_64bit mux5 (
        .in0(mux4_output),
        .in1({{2{sign}}, mux4_output[63:2]}),  
        .sel(rs2[1]),
        .out(mux5_output)
    );

    // Shift by 1 if rs2[0] is set
    mux_64bit mux6 (
        .in0(mux5_output),
        .in1({{1{sign}}, mux5_output[63:1]}), 
        .sel(rs2[0]),
        .out(mux6_output)
    );

    assign result = mux6_output;
endmodule


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
//         $monitor("Time = %0t | A = %b | Shift = %d | SLL = %d | SRL = %d | SRA = %d", 
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