module decode (
    input [31:0] instruction,
    input clk,
    input id_ex_MemRead,
    input [4:0] id_ex_Rd,
    input [4:0] if_id_Rs1,
    input [4:0] if_id_Rs2,
    input signed [63:0] if_id_rs1_val,
    input signed [63:0] if_id_rs2_val,
    input hazard_detected,
    input signed  [63:0] alu_result,
    input signed [63:0] mem_data,
    input [4:0] ex_mem_rd,
  //  output reg PCWrite,
   // output reg IF_ID_Write,
    output reg id_ex_Memread,
    output reg id_ex_MemtoReg,
    output reg id_ex_Regwrite,
    output reg id_ex_Memwrite,
    output reg id_ex_write,
    output reg [4:0] id_ex_rs1,
    output reg [4:0] id_ex_rs2,
    output reg [4:0] id_ex_rd,
    output reg [6:0] opcode,
    output reg alu_src,
    output reg [3:0] alu_op,
    output reg branch,
    output reg [63:0] imm,
    output reg flush
);
 reg Control;
    initial begin
        Control = 1'b1;
    end
    


    // NOT gates for control signals
    // not n1(PCWrite, hazard_detected);
    // not n2(IF_ID_Write, hazard_detected);
    // not n3(Control, hazard_detected);

    reg [6:0] funct7;
    reg [2:0] funct3;
    
    always @(* ) begin
      //  PCWrite = ~hazard_detected;
       // IF_ID_Write = ~hazard_detected;
        Control = ~hazard_detected;
        $display("Control Mux : %b",Control);
        // Extract fields from instruction
        opcode = instruction[6:0];
        id_ex_rd = instruction[11:7];
        funct3 = instruction[14:12];
        funct7 = instruction[31:25];
        id_ex_rs1 = instruction[19:15];
        id_ex_rs2 = instruction[24:20];

        // Initialize control signals
        branch = 0;
        alu_op = 4'b0000;
        alu_src = 0;
        imm = 64'b0;
        id_ex_Memwrite = 0;
        id_ex_MemtoReg = 0;
        id_ex_Memread = 0;
        id_ex_Regwrite = 0;
        id_ex_write = 0;
        if(Control) begin
          
        // Decode based on opcode
        case (opcode)
            7'b0110011: begin // R-type
                id_ex_Regwrite = 1;
                case (funct3)
                    3'b000: begin
                        case (funct7)
                            7'b0000000: alu_op = 4'b0010; // ADD
                            7'b0100000: alu_op = 4'b0110; // SUB
                        endcase
                    end
                    3'b001: alu_op = 4'b0011; // SLL
                    3'b100: alu_op = 4'b1001; // XOR
                    3'b101: begin
                        case (funct7)
                            7'b0000000: alu_op = 4'b0100; // SRL
                            7'b0100000: alu_op = 4'b0101; // SRA
                        endcase
                    end
                    3'b110: alu_op = 4'b0001; // OR
                    3'b111: alu_op = 4'b0000; // AND
                endcase
            end
            7'b0000011: begin // Load Instructions (I-type)
                id_ex_Memread = 1;
                id_ex_MemtoReg = 1;
                id_ex_Regwrite = 1;
                alu_src = 1;
                imm = {{52{instruction[31]}}, instruction[31:20]}; // Sign-extend
                alu_op = 4'b0010; // Load operations
            end
            7'b0010011: begin // I-type
                id_ex_Regwrite = 1;
                alu_src = 1;
                imm = {{52{instruction[31]}}, instruction[31:20]}; // Sign-extend
                case (funct3)
                    3'b000: alu_op = 4'b0010; // ADDI
                    3'b001: alu_op = 4'b0011; // SLLI
                    3'b100: alu_op = 4'b1001; // XORI
                    3'b101: begin
                        case (funct7)
                            7'b0000000: alu_op = 4'b0100; // SRLI
                            7'b0100000: alu_op = 4'b0101; // SRAI
                        endcase
                    end
                    3'b110: alu_op = 4'b0001; // ORI
                    3'b111: alu_op = 4'b0000; // ANDI
                endcase
            end
            7'b1100011: begin // Branch
                branch = 1;
                alu_src = 0;
                imm = {{53{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; 
                if(if_id_Rs1 == ex_mem_rd || if_id_Rs2 == ex_mem_rd)
                begin
                   if(if_id_rs1_val == mem_data  || if_id_rs2_val  == mem_data)
                     begin
                          flush = 1;
                     end
                end
                else if((if_id_Rs1 == id_ex_Rd) ||( if_id_Rs2 == id_ex_Rd))
                begin
                   if(if_id_rs1_val ==alu_result || if_id_rs2_val==alu_result)
                     begin
                          flush = 1;
                     end
                end
               else  if(if_id_rs1_val == if_id_rs2_val)
                begin
                    flush = 1;
                end
                else
                begin
                    flush = 0;
                end
                case (funct3)
                    3'b000: alu_op = 4'b1010; // BEQ
                    3'b001: alu_op = 4'b1011; // BNE
                    3'b100: alu_op = 4'b1010; // SLT
                    3'b101: alu_op = 4'b1010; // BGE
                    3'b111: alu_op = 4'b0111; // BGEU
                endcase
            end
            7'b0100011: begin // S-type (Store)
                id_ex_Memwrite = 1;
                alu_src = 1;
                imm = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]}; // Sign-extend
                alu_op = 4'b0010; // Store operations
            end
            default: begin
                // Default case for undefined instructions
                branch = 0;
                alu_op = 4'b0000;
                alu_src = 0;
                imm = 64'b0;
                id_ex_Memread = 0;
                id_ex_MemtoReg = 0;
                id_ex_Regwrite = 0;
                id_ex_Memwrite = 0;
            end
        endcase
        end
    //    always @(posedge clk) begin
    //       $display("Control Mux : %b",Control);
    //     end
        // Debugging output
        // $display("pc=%d|Time: %0t | Instr=%b | Opcode=%b | RD=%d | Funct3=%b | RS1=%d | RS2=%d | Funct7=%b | Imm=%d | Control: Branch=%b, ALU_OP=%b, ALU_SRC=%b, MemRead=%b, MemWrite=%b, MemToReg=%b, RegWrite=%b", 
        //     pc,$time, instruction, opcode, id_ex_rd, funct3, id_ex_rs1, id_ex_rs2, funct7, imm, branch, alu_op, alu_src, id_ex_Memread, id_ex_Memwrite, id_ex_MemtoReg, id_ex_Regwrite);
    end

endmodule
