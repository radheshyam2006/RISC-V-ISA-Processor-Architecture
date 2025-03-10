// `include "instruction_fetch.v"
// `include "decode.v"
// `include "execute_stage.v"
// `include "memory.v"


module processor (
    input clk
);
    wire [31:0]  if_instruction;
    wire signed [63:0] id_rs1_val, id_rs2_val, id_imm, ex_alu_result,mem_data;
    wire [4:0] id_rs1, id_rs2, id_rd;
    wire signed [63:0] imm;
    wire branch, alu_src;   
    wire [3:0] alu_op;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [6:0] opcode;
    wire overflow,Memread,Memwrite,MemtoReg,Regwrite;

    reg [63:0] register_file [0:31];
    reg signed [31:0] pc;
    assign id_rs1_val = register_file[id_rs1];
    assign id_rs2_val = register_file[id_rs2];
    instruction_fetch if_stage (
    .pc(pc),
    .instruction(if_instruction)
    );
    decode id_stage (
    .instruction(if_instruction),
    .rs1(id_rs1),
    .rs2(id_rs2),
    .rd(id_rd),
    .funct3(funct3),
    .funct7(funct7),
    .opcode(opcode),
    .branch(branch),
    .alu_op(alu_op),
    .alu_src(alu_src),
    .imm(imm),
    .memread(Memread),
    .memwrite(Memwrite),
    .memtoreg(MemtoReg),
    .regwrite(Regwrite)
    );
    ex_stage execute_stage (
    .rs1_val(id_rs1_val),
    .rs2_val(id_rs2_val),
    .imm(imm),
    .alu_src(alu_src),
    .alu_op(alu_op),
    .branch(branch),
    .alu_result(ex_alu_result),
    .overflow(overflow)
    );
    memory mem_stage(
    .alu_result(ex_alu_result),
    .memread(Memread),
    .memwrite(Memwrite),
    .rs2(id_rs2_val),
    .mem_data(mem_data)
    );
    //writting back to the register file

    reg Regwrite_reg, MemtoReg_reg;
    always @(*) begin
        Regwrite_reg = Regwrite;   // Latch control signals
        MemtoReg_reg = MemtoReg; 
    end

// Use the latched values in sequential logic
    wire [63:0] registerout1;
    writeback wb_stage (
    .MemtoReg_reg(MemtoReg_reg),
    .Regwrite_reg(Regwrite_reg),
    .ex_alu_result(ex_alu_result),
    .mem_data(mem_data),
    .registerout(registerout1)
    ); 
    always@(*) begin
        register_file[id_rd] = registerout1;
    end

    //updating the pc according to branch
   // wire pc_up;
    and(pc_up,branch,ex_alu_result[0]);
    always @(posedge clk) begin

           if(opcode==7'b1111111)
              $finish;
           else if(pc_up)
            pc=pc+(imm<<1);
           else
            pc = pc + 4;
    end
    always @(posedge clk) begin
        $display("Time: %0t | PC: %0h | Instruction: %0b | ALU Result: %0b | Mem Data: %0h| Branch: %0b|pc_branch: %0b|registerout=%d",
                 $time, pc, if_instruction, ex_alu_result, mem_data,branch,pc_up,registerout1);
    end


endmodule


  



