`timescale 1ns/1ps
`include "writeback.v"
module writeback_tb;
    reg MemtoReg_reg;
    reg Regwrite_reg;
    reg [63:0] ex_alu_result;
    reg [63:0] mem_data;
    wire [63:0] registerout;

    // Instantiate the module
    writeback uut (
        .MemtoReg_reg(MemtoReg_reg),
        .Regwrite_reg(Regwrite_reg),
        .ex_alu_result(ex_alu_result),
        .mem_data(mem_data),
        .registerout(registerout)
    );

    initial begin
        // Initialize inputs
        MemtoReg_reg = 0;
        Regwrite_reg = 0;
        ex_alu_result = 64'hA5A5A5A5A5A5A5A5;
        mem_data = 64'h5A5A5A5A5A5A5A5A;

        // Test case 1: Both control signals are 0
        #10;
        $display("TC1: registerout = %h (Expected: 0000000000000000)", registerout);
        
        // Test case 2: MemtoReg_reg = 1, Regwrite_reg = 0
        MemtoReg_reg = 1;
        Regwrite_reg = 0;
        #10;
        $display("TC2: registerout = %h (Expected: 5A5A5A5A5A5A5A5A)", registerout);
        
        // Test case 3: MemtoReg_reg = 0, Regwrite_reg = 1
        MemtoReg_reg = 0;
        Regwrite_reg = 1;
        #10;
        $display("TC3: registerout = %h (Expected: A5A5A5A5A5A5A5A5)", registerout);
        
        // Test case 4: Both MemtoReg_reg and Regwrite_reg are 1
        MemtoReg_reg = 1;
        Regwrite_reg = 1;
        #10;
        $display("TC4: registerout = %h (Expected: 5A5A5A5A5A5A5A5A)", registerout);
        
        // Finish simulation
        $finish;
    end
endmodule