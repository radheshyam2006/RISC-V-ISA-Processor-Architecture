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
        uut.register_file[0] = 32'd0; // x0 = 0
        uut.register_file[10] = 32'd2; // x10 = 2
        uut.register_file[15] = 32'd0; // x14 = 0
      //  uut.register_file[30] = 32'd5;
      //  uut.register_file[4] = 32'd1;
        //uut.register_file[5] = 64'h0000;
       // uut.register_file[6] = 64'h0001;
        // uut.register_file[3] = 64'h0009;
        // uut.register_file[15] = 64'h0000;
        // uut.register_file[16] = 64'h0001;
        // uut.register_file[14] = 64'h0002;

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
        uut.ex_mem_alu_result_dummy = 64'd0;
        uut.mem_wb_mem_data_dummy = 64'd0;
        #5;
    end

    // Display register values
    always @(posedge clk) begin
        $display(" TB OUTPUT---00000000000000000000000000000000000000000000000000000000000000000000000000000 ");
        $display("----------------------------------------------------------------------------------------------------------------------------------");
        $display("time : %0t ||Register x10 : %d | x2 : %d | x3 : %d | x4 : %d | x5 : %d | x6 : %d | x7 : %d || PC : %d |time=%0t, x30 : %d", 
                $time, uut.register_file[10], uut.register_file[2], uut.register_file[3], uut.register_file[4], uut.register_file[5], uut.register_file[6], uut.register_file[7], uut.pc, $time, uut.register_file[30]);
        $display("----------------------------------------------------------------------------------------------------------------------------------");
    end
    
    // initial begin
    //     #100; // Run simulation for a few cycles
    //     $finish;
    // end
endmodule
