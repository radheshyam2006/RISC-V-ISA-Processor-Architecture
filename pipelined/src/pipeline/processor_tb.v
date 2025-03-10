`timescale 1ns / 1ps

module processor_tb();
    reg clk;
    reg [1:0] instr_count = 0;
    wire [31:0] pc;
    wire [31:0] if_instruction;
    wire [63:0] ex_alu_result;
    wire [63:0] mem_data;
    integer i;

    // Control signals
    reg pc_write, if_id_write;

    // Instantiate the processor module
    processor uut (
        .clk(clk)
        
    );

    always #5 clk = ~clk; // Clock generation (20ns period)
    
    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, processor_tb);
    end

    // Initialize testbench
    
    initial begin
        clk = 1'b0;
        instr_count = 0; 
        
        // Initialize registers manually
          // Initialize registers manually
        uut.register_file[0] = 64'd0;
       // uut.register_file[1] = 64'h0001;
     //   uut.register_file[2] = 64'd0;
     //   uut.register_file[6] = 64'd3;
      //  uut.register_file[3] = 64'd14;
       // uut.register_file[4] = 64'd10;
        // uut.register_file[3] = 64'd14;
        // uut.register_file[4] = 64'd0;
      //  uut.register_file[6] = 64'd4;
        uut.register_file[7] = 64'd9;

        uut.pc = 32'h0000;
        uut.pc_write = 1'b1;
        uut.if_id_write = 1'b1;
       // uut.id_ex_write = 1'b0;
        uut.id_ex_Memread = 1'b0;
        uut.if_id_rs1 = 1'b0;
        uut.if_id_rs2 = 1'b0;
        uut.id_ex_rd  =  1'b0; 
        uut.ex_mem_Regwrite = 1'b0;
        uut.mem_wb_RegWrite = 1'b0;
        uut.ex_mem_rd = 1'b0;
        uut.mem_wb_rd = 1'b0;
        uut.branch_hazard = 1'b0;
        #5;
    end

    // Display register values
    always @(posedge clk) begin
        $display(" TB OUTPUT---00000000000000000000000000000000000000000000000000000000000000000000000000000 ");
        $display("----------------------------------------------------------------------------------------------------------------------------------");
        $display("time : %0t ||Register x1 : %d | x2 : %d | x3 : %d | x4 : %d | x5 : %d | x6 : %d | x7 : %d || PC : %d |time=%0t", 
                $time, uut.register_file[1], uut.register_file[2], uut.register_file[3], uut.register_file[4], uut.register_file[5], uut.register_file[6], uut.register_file[7], uut.pc, $time);
        $display("----------------------------------------------------------------------------------------------------------------------------------");
    end
    
    // initial begin
    //     #100; // Run simulation for a few cycles
    //     $finish;
    // end
endmodule
