module writeback (
    input clk,
   // input wb_write,         // Control signal from WB stage
    input mem_wb_MemtoReg,   // Control signal from MEM/WB pipeline register
    input mem_wb_RegWrite,   // Register write control signal from MEM/WB
    input [4:0] mem_wb_rd,   // Destination register from MEM/WB stage
    input [63:0] mem_wb_alu_result,  // ALU result from MEM/WB stage
    input [63:0] mem_wb_mem_data,    // Memory data from MEM/WB stage

    output reg wb_RegWrite,  // Forwarded RegWrite control signal
    output reg [4:0] wb_rd,  
    output reg [63:0] wb_registerout 
);

    // Initialize registers to avoid unknown states
    // initial begin
    //     wb_RegWrite = 0;
    //     wb_rd = 5'b00000;
    //     wb_registerout = 64'd0;
    // end

    always @(*) begin
        //if(wb_write)
        //begin
        wb_RegWrite = mem_wb_RegWrite;
        wb_rd = mem_wb_rd;

        if (mem_wb_MemtoReg) begin
            wb_registerout = mem_wb_mem_data;  // Write memory data to register
        end else begin
            wb_registerout = mem_wb_alu_result;  // Write ALU result to register
        end
            // $display("Time: %0t | clk: %b | wb_RegWrite: %b | wb_rd: %d | wb_registerout: %d", 
            //      $time, clk, wb_RegWrite, wb_rd, wb_registerout);
 //   end
    end

endmodule
