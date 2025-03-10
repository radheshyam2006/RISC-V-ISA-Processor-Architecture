module writeback(
    input MemtoReg_reg,
    input Regwrite_reg,
    input [63:0] ex_alu_result,
    input [63:0] mem_data,
    output reg [63:0] registerout
);
always @(*) begin
    if (MemtoReg_reg) begin
         registerout = mem_data;
    end else if (Regwrite_reg) begin
         registerout = ex_alu_result;
    end
    else begin
        registerout = 64'b0;
    end
end
endmodule