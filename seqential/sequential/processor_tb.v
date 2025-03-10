`timescale 1ns / 1ps

module processor_tb();

    reg clk;
    reg [1:0] instr_count = 0; // Counter for executed instructions
    wire [31:0] pc;
    wire [31:0] if_instruction;
    wire [63:0] ex_alu_result;
    wire [63:0] mem_data;
    integer i;

    // Instantiate the processor module
    processor uut (
        .clk(clk)
    );

    always #10 clk = ~clk; // Generate clock with 20ns period (10ns high, 10ns low)
    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, processor_tb);
    end
    // Initialize testbench
    initial begin
        clk = 1'b0;
        instr_count = 0; 
        // Initialize registers manually
        uut.register_file[0] = 64'h0000;
        uut.register_file[1] = 64'h0001;
        uut.register_file[2] = 64'h0010;
        uut.register_file[3] = 64'h0010;
        uut.register_file[4] = 64'h0010;
        //uut.register_file[5] = 64'h0000;
       // uut.register_file[6] = 64'h0001;
        // uut.register_file[3] = 64'h0009;
        // uut.register_file[15] = 64'h0000;
        // uut.register_file[16] = 64'h0001;
        // uut.register_file[14] = 64'h0002;
        uut.pc = 32'h0000;

        // Wait for a few clock cycles to observe operations
        #10; // Ensure initial values are set before first display
    end

    // Display values only on the positive edge of clk
    always @(posedge clk) begin
        $display("Register x1 : %d | x2 : %d |x3  : %d |x4 : %d |x5 : %d |x6 : %d | PC : %d |", 
                 uut.register_file[1], uut.register_file[2],uut.register_file[3],uut.register_file[4],uut.register_file[5],uut.register_file[6],uut.pc);
        $display("----------------------------------------------------------------------------------------------------------------------------------");
    end
    
    
    initial begin
        #200; // Run simulation for a few cycles
        $finish;
    end

endmodule