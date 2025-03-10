module memory (
    input clk,
    //input memwrite,
    input [4:0] ex_mem_rd,
    input ex_mem_Memwrite,
    input ex_mem_Memread,
    input ex_mem_MemtoReg,
    input ex_mem_Regwrite,
    input [63:0] ex_mem_alu_result,
    input [63:0] ex_mem_rs2,
    output reg [4:0] mem_wb_rd,
    output reg mem_wb_MemtoReg,
    output reg [63:0] mem_wb_alu_result,
    output reg [63:0] mem_wb_mem_data,
    output reg mem_wb_RegWrite
);

    reg [63:0] data_memory [0:255]; // Memory array
    reg  wb_write_reg;
    // Initialize memory with sample values
    initial begin
        data_memory[0] = 64'd10;
        data_memory[1] = 64'd90;
        data_memory[2] = 64'd6;
    end

    // Write operation (MEMORY WRITE)
    always @(*) begin
        //if(memwrite)begin
        if (ex_mem_Memwrite) begin
            data_memory[ex_mem_alu_result[7:0]] <= ex_mem_rs2; // Store data
                    //   $display("Time: %0t | Memory Write | Addr: %0d | Data: %0d", 
                    //  $time, ex_mem_alu_result[7:0], ex_mem_rs2);
        end
        mem_wb_rd <= ex_mem_rd;
        mem_wb_MemtoReg <= ex_mem_MemtoReg;
        mem_wb_alu_result <= ex_mem_alu_result;
        mem_wb_RegWrite <= ex_mem_Regwrite;
        if (ex_mem_Memread) begin
            mem_wb_mem_data <= data_memory[ex_mem_alu_result]; // Load data
        end else begin
            mem_wb_mem_data <= 64'd0; // Default value when not reading
        end
        // $display("Time: %0t | clk: %b | MemtoReg: %b | MemRead: %b | MemWrite: %b | rd: %d | ALU_Result: %d | MemData: %d",
        //     $time, clk, mem_wb_MemtoReg, ex_mem_Memread, ex_mem_Memwrite, 
        //      mem_wb_rd, mem_wb_alu_result, mem_wb_mem_data);
        $display("Memory Values: %d, %d, %d", data_memory[0], data_memory[1], data_memory[2]);
    end

    // Read operation & Pipeline Register Updates (MEMORY READ)
    
    //assign wb_write = wb_write_reg;

endmodule
