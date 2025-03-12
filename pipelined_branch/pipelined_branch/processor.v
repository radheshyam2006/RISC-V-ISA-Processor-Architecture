`timescale 1ns / 1ps
module processor (
    input clk
);
    reg [31:0] pc;

    // Pipeline registers (reg because they store values between cycles)
    reg [31:0] if_id_instruction;
    reg pc_write,if_id_write;
   // wire pc_write_wire,if_id_write_wire;
    reg [4:0] if_id_rs1, if_id_rs2, if_id_rd;
    reg signed [63:0] if_id_rs1_val, if_id_rs2_val, if_id_imm;
    reg  branch_hazard ;
    reg [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    reg signed [63:0] id_ex_rs1_val, id_ex_rs2_val, id_ex_imm;
    reg id_ex_Memread, id_ex_Memwrite, id_ex_MemtoReg, id_ex_Regwrite;
    reg alu_src;
    reg [3:0] alu_op;
    reg branch;
    
    reg [4:0] ex_mem_rd;
    reg signed [63:0] ex_mem_rs2, ex_mem_alu_result;
    reg ex_mem_Memread, ex_mem_Memwrite, ex_mem_MemtoReg, ex_mem_Regwrite;
    reg id_ex_Memread_dup;
    reg [4:0] id_ex_rd_dup;
    reg [4:0] mem_wb_rd;
    reg signed [63:0] mem_wb_alu_result, mem_wb_mem_data;
    reg mem_wb_RegWrite, mem_wb_MemtoReg;

    reg [63:0] register_file [0:31];

    wire [31:0] if_instruction;
    wire id_ex_Memread_wire, id_ex_Memwrite_wire, id_ex_MemtoReg_wire, id_ex_Regwrite_wire;
    wire [4:0] id_ex_rs1_wire, id_ex_rs2_wire, id_ex_rd_wire;
    wire alu_src_wire;
    wire [3:0] alu_op_wire;
    wire branch_wire;
    wire signed [63:0] id_ex_imm_wire;
    reg signed [63:0] operandA, operandB;
    
    wire signed [63:0] ex_mem_alu_result_wire;
    wire [4:0] ex_mem_rd_wire;
    wire ex_mem_Memwrite_wire, ex_mem_Memread_wire, ex_mem_MemtoReg_wire ,ex_mem_Regwrite_wire, ex_mem_overflow_wire;
    // reg [1:0] forwardA ,forwardB;
    wire [4:0] mem_wb_rd_wire;
    wire signed [63:0] mem_wb_alu_result_wire, mem_wb_mem_data_wire;
    wire mem_wb_RegWrite_wire, mem_wb_MemtoReg_wire;

    wire wb_RegWrite_wire;
    wire [4:0] wb_rd_wire;
    wire signed [63:0] wb_registerout_wire;
    wire flush;
    reg wb_RegWrite;
    reg [4:0] wb_rd;
    reg signed [63:0] wb_registerout;
    reg [4:0] if_id_rs1_dummy,if_id_rs2_dummy;
    reg signed [63:0] ex_mem_alu_result_dummy,mem_wb_mem_data_dummy;
//     wire  id_write ,ex_write, mem_write, wb_write;
//    initial begin
//     pc = 0;
//     if_id_instruction = 0;
//     if_id_rs1 = 0;
//     if_id_rs2 = 0;
//     if_id_rd = 0;
//     if_id_rs1_val = 0;
//     if_id_rs2_val = 0;
//     if_id_imm = 0;

//     id_ex_rs1 = 0;
//     id_ex_rs2 = 0;
//     id_ex_rd = 0;
//     id_ex_rs1_val = 0;
//     id_ex_rs2_val = 0;
//     id_ex_imm = 0;
//     id_ex_Memread = 0;
//     id_ex_Memwrite = 0;
//     id_ex_MemtoReg = 0;
//     id_ex_Regwrite = 0;
//     alu_src = 0;
//     alu_op = 4'b0000;
//     branch = 0;

//     ex_mem_rd = 0;
//     ex_mem_rs2 = 0;
//     ex_mem_alu_result = 0;
//     ex_mem_Memread = 0;
//     ex_mem_Memwrite = 0;
//     ex_mem_MemtoReg = 0;
//     ex_mem_Regwrite = 0;

//     mem_wb_rd = 0;
//     mem_wb_alu_result = 0;
//     mem_wb_mem_data = 0;
//     mem_wb_RegWrite = 0;
//     mem_wb_MemtoReg = 0;

//     wb_RegWrite = 0;
//     wb_rd = 0;
//     wb_registerout = 0;
// end


    // **Instruction Fetch Stage**
    instruction_fetch if_stage (
        //.pc_write(pc_write),
        .pc(pc),
        .instruction(if_instruction),
       // .if_id_write(if_id_write),
        .clk(clk)
       // .id_write(id_write)
    );

    // always @(posedge clk) begin
    //     if (pc_write) begin
    //         if (if_instruction[6:0] == 7'b1111111)begin
    //             //#25;
    //             $finish;
    //         end
    //         else begin
    //             pc <= pc + 4;
    //         end
    //     end
    // end
    always @(posedge clk) begin
        if (if_id_write) begin
          //  if_id_instruction <= if_instruction;
            if_id_rs1 <= if_instruction[19:15];
            if_id_rs2 <= if_instruction[24:20];
            if_id_rd  <= if_instruction[11:7];
            if_id_imm <= {{53{if_instruction[31]}}, if_instruction[7], if_instruction[30:25], if_instruction[11:8], 1'b0};
            if_id_rs1_dummy = if_instruction[19:15];
            if_id_rs2_dummy = if_instruction[24:20];
             if_id_rs1_val <= register_file[if_id_rs1_dummy];
             if_id_rs2_val <= register_file[if_id_rs2_dummy];
            // if_id_imm     = {{53{if_instruction[31]}}, if_instruction[7], if_instruction[30:25], if_instruction[11:8], 1'b0};
            // if(if_instruction[6:0] == 7'b1100011)begin
            //     branch_hazard = 1;
            // end
            // else begin
            //     branch_hazard = 0; 
            // end
            // if(branch_hazard) begin
            //     if(if_id_rs1_val == if_id_rs2_val) begin
            //         pc <= pc + (imm<<1);
            // end
            // end
            // else begin
            //     if (if_instruction[6:0] == 7'b1111111)begin
            //     //#25;
            //     $finish;
            // end
            //     pc <= pc + 4;
            // end


        end
    end

    always @(posedge clk) begin
        $display("TIME : %0t                          clk  : %b\n",$time,clk);
        $display("INSTRUCTION  FETCH DETAILS \n");
        $display("------------------------------------------------------------------------------------------------");
        $display("time=%0t|PC: %d| if_instruction=%b| pc_write ",$time, pc,if_instruction,pc_write);
        $display("------------------------------------------------------------------------------------------------");
         $display("INSTRUCTION DECODE  DETAILS \n");
        $display("------------------------------------------------------------------------------------------------");
        $display("  IF/ID REGISTER DETAILS \n");
        $display("------------------------------------------------------------------------------------------------");
        // $display("wire--pc=%d|Time: %0t | if_id_instruction=%b  | if_id_rs1=%d | if_id_rs2=%d | if_id_rd=%d | if_id_write=%b", 
            // pc,$time, if_id_instruction, if_id_rs1, if_id_rs2, if_id_rd, if_id_write);
        $display("register-pc=%d|Time: %0t | if_id_instruction=%b  | if_id_rs1=%d | if_id_rs2=%d | if_id_rd=%d | if_id_write=%b| if_id_imm = %d", 
            pc,$time, if_id_instruction, if_id_rs1, if_id_rs2, if_id_rd, if_id_write,if_id_imm);
        $display("------------------------------------------------------------------------------------------------");
        // $display("pc=%d|Time: %0t  | Imm=%d | Control: Branch=%b, ALU_OP=%b, ALU_SRC=%b, id_ex_MemRead=%b, id_ex_MemWrite=%b, id_ex_MemToReg=%b, id_ex_RegWrite=%b", 
        //     pc,$time, branch, alu_op, alu_src);
        $display("------------------------------------------------------------------------------------------------");
        $display("EXECUTION/ ALU  DETAILS \n");
        $display("------------------------------------------------------------------------------------------------");
        $display(" ID/EX  REGISTER DETAILS \n");
        $display("------------------------------------------------------------------------------------------------");
       $display("wire---id_ex_rs1 : %d | id_ex_rs2 : %d | id_ex_rd : %d | id_ex_rs1_val : %d | id_ex_rs2_val : %d | id_ex_imm : %d | id_ex_Memread : %b | id_ex_Memwrite : %b | id_ex_MemtoReg : %b | id_ex_Regwrite : %b | alu_src : %b | alu_op : %b | branch : %b", 
            id_ex_rs1_wire, id_ex_rs2_wire, id_ex_rd_wire, id_ex_rs1_val, id_ex_rs2_val, id_ex_imm_wire, id_ex_Memread_wire, id_ex_Memwrite_wire, id_ex_MemtoReg_wire, id_ex_Regwrite_wire, alu_src_wire, alu_op, branch_wire);
       $display("reg---id_ex_rs1 : %d | id_ex_rs2 : %d | id_ex_rd : %d | id_ex_rs1_val : %d | id_ex_rs2_val : %d | id_ex_imm : %d | id_ex_Memread : %b | id_ex_Memwrite : %b | id_ex_MemtoReg : %b | id_ex_Regwrite : %b | alu_src : %b | alu_op : %b | branch : %b", 
            id_ex_rs1, id_ex_rs2, id_ex_rd, id_ex_rs1_val, id_ex_rs2_val, id_ex_imm, id_ex_Memread, id_ex_Memwrite, id_ex_MemtoReg, id_ex_Regwrite, alu_src, alu_op, branch);
        $display("------------------------------------------------------------------------------------------------");
        // $display("pc=%d|TIME : %0t  || clk : %b  || ALU Result: %d  ||  || ex_mem_Memwrite: %b  || ex_mem_Memread: %b  || ex_mem_MemtoReg: %b  || rd: %b", 
        //      pc,$time, clk, ex_mem_alu_result, ex_mem_Memwrite, ex_mem_Memread, ex_mem_MemtoReg,ex_mem_rd);
        $display("----------------------------------------------------------------------------------------------------------------------------------");
        $display(" EX_MEM REGISTER DETAILS \n");
        $display("------------------------------------------------------------------------------------------------");
        $display("operandA-%d",operandA);
        $display("operandB-%d",operandB);
        $display("wire---operanddummy=%d ex_mem_alu_result : %d | ex_mem_Memwrite : %b | ex_mem_Memread : %b | ex_mem_MemtoReg : %b | ex_mem_Regwrite : %b || ", 
             operandBdummy,ex_mem_alu_result_wire, ex_mem_Memwrite_wire, ex_mem_Memread_wire, ex_mem_MemtoReg_wire, ex_mem_Regwrite_wire);
        $display("reg---ex_mem_rd : %d | ex_mem_rs2 : %d | ex_mem_alu_result : %d | ex_mem_Memwrite : %b | ex_mem_Memread : %b | ex_mem_MemtoReg : %b | ex_mem_Regwrite : %b || forward A : %b | forward B : %b", 
            ex_mem_rd, ex_mem_rs2, ex_mem_alu_result, ex_mem_Memwrite, ex_mem_Memread, ex_mem_MemtoReg, ex_mem_Regwrite, forwardA, forwardB);
        $display("------------------------------------------------------------------------------------------------");
        $display("WRITE BACK DETAILS  \n");
        $display("------------------------------------------------------------------------------------------------");
        $display("wire---pc=%d|TIME : %0t  || clk : %b  || Mem_data: %d  ||  || mem_wb_MemtoReg: %b  || mem_wb_RegWrite: %b  || rd: %b",
             pc,$time, clk, mem_wb_mem_data_wire, mem_wb_MemtoReg_wire, mem_wb_RegWrite_wire, mem_wb_rd_wire);
        $display("reg---pc=%d|TIME : %0t  || clk : %b  || Mem_data: %d  ||  || mem_wb_MemtoReg: %b  || mem_wb_RegWrite: %b  || rd: %b",
             pc,$time, clk, mem_wb_mem_data, mem_wb_MemtoReg, mem_wb_RegWrite, mem_wb_rd);
        $display("------------------------------------------------------------------------------------------------");
        $display("MEM_DATA REGISTER DETAILS \n");
        $display("------------------------------------------------------------------------------------------------");
        $display("wire---mem_wb_rd : %d | mem_wb_alu_result : %d | mem_wb_mem_data : %d | mem_wb_RegWrite : %b | mem_wb_MemtoReg : %b",
            mem_wb_rd_wire, mem_wb_alu_result_wire, mem_wb_mem_data_wire, mem_wb_RegWrite_wire, mem_wb_MemtoReg_wire);
        $display("reg---mem_wb_rd : %d | mem_wb_alu_result : %d | mem_wb_mem_data : %d | mem_wb_RegWrite : %b | mem_wb_MemtoReg : %b",
            mem_wb_rd, mem_wb_alu_result, mem_wb_mem_data, mem_wb_RegWrite, mem_wb_MemtoReg);
        // $display("pc=%d|TIME : %0t  || clk : %b  || wb_RegWrite: %b  || wb_rd: %d  || wb_registerout: %d", 
        //      pc,$time, clk, wb_RegWrite, wb_rd, wb_registerout);
        $display("------------------------------------------------------------------------------------------------");


        $display("------------------------------------------------------------------------------------------------");
        $display(" HAZARD DETAILS DETAILS \n"                                                                      );
        $display("id_ex_memread : %b ||  id_ex_rd : %d || if_id_rs1 : %d || if_id_rs2 : %d || hazard_detected : %d", 
            id_ex_Memread, id_ex_rd, if_id_rs1, if_id_rs2, hazard_detected);

        $display("------------------------------------------------------------------------------------------------");
        $display(" BRANCH DETAILS \n");
        $display("if_id_rs1_val : %d || if_id_rs2_val : %d  | flush : %b\n ", if_id_rs1_val, if_id_rs2_val, flush);
        $display("alu_result : %d",ex_mem_alu_result_dummy);
        $display("------------------------------------------------------------------------------------------------");


    end   

    // **IF/ID Pipeline Register**
    wire hazard_detected_wire;
    reg hazard_detected;
    Hazard hazard (
        .id_ex_MemRead(id_ex_Memread),
        .id_ex_Rd(id_ex_rd),
        .if_id_Rs1(if_id_rs1),
        .if_id_Rs2(if_id_rs2),
        .hazard_detected(hazard_detected_wire)
    );
    always @(*) begin
        hazard_detected = hazard_detected_wire;
        if(hazard_detected == 1)
        begin
        pc_write = ~hazard_detected_wire;
        if_id_write = ~hazard_detected_wire;
        end
        else  if(hazard_detected == 0)
        begin
        pc_write = 1;
        if_id_write = 1;
        end
    end
    

    // // **Instruction Decode Stage**
    decode id_stage (
       // .id_write(id_write),
       .hazard_detected(hazard_detected),
        .instruction(if_id_instruction),
        .id_ex_MemRead(id_ex_Memread),
        .id_ex_Rd(id_ex_rd),
        .if_id_Rs1(if_id_rs1),
        .if_id_Rs2(if_id_rs2),
        .if_id_rs1_val(if_id_rs1_val),
        .if_id_rs2_val(if_id_rs2_val),
        .alu_result(ex_mem_alu_result_dummy),
        .mem_data(mem_wb_mem_data_dummy),
        .ex_mem_rd(ex_mem_rd),
       // .PCWrite(pc_write_wire),
       // .IF_ID_Write(if_id_write_wire),
        .id_ex_Memread(id_ex_Memread_wire),
        .id_ex_MemtoReg(id_ex_MemtoReg_wire),
        .id_ex_Regwrite(id_ex_Regwrite_wire),
        .id_ex_Memwrite(id_ex_Memwrite_wire),
        .id_ex_rs1(id_ex_rs1_wire),
        .id_ex_rs2(id_ex_rs2_wire),
        .id_ex_rd(id_ex_rd_wire),
        .alu_src(alu_src_wire),
        .alu_op(alu_op_wire),
        .branch(branch_wire),
        .imm(id_ex_imm_wire),
        .clk(clk),
        .flush(flush)
        //.ex_write(ex_write)
    );
    // always @(*)begin
    //      alu_src = alu_src_wire;
    //     alu_op = alu_op_wire;
    //     branch = branch_wire;
    // // end
    // always @(*)begin
    //    id_ex_Memread_dup = id_ex_Memread_wire;
    //    id_ex_rd_dup = id_ex_rd_wire;

    // end
    always @(posedge clk) begin
        if(pc > 132)
        begin
            $finish;
        end
        if(flush == 1)
        begin
            if_id_instruction <= 0;
            if_id_rs1 <= 0;
            if_id_rs2 <= 0;
            if_id_rs1_val <= 0;
            if_id_rs2_val <= 0;
            if_id_imm <= 0;
            if(pc_write)
            begin
                pc <= pc + (if_id_imm<<1) -4;
            end
        end
        else
        begin
            if(if_id_write)
            begin
                if_id_instruction <= if_instruction;
                if_id_rs1 <= if_instruction[19:15];
                if_id_rs2 <= if_instruction[24:20];
                if_id_rd  <= if_instruction[11:7];
                if_id_imm <= {{53{if_instruction[31]}}, if_instruction[7], if_instruction[30:25], if_instruction[11:8], 1'b0};
                if_id_rs1_val <= register_file[if_id_rs1];
                if_id_rs2_val <= register_file[if_id_rs2];
            end
        end
           // if_id_instruction = if_instruction;
            if(pc_write)
            begin
                if(if_instruction[6:0] == 7'b1111111 || pc > 132)begin
                    //#25;
                    $finish;
                end
                else begin
                pc <= pc + 4;
            end
        end
        // if_id_write = if_id_write_wire;
        // pc_write = pc_write_wire;
        id_ex_rs1 <= id_ex_rs1_wire;
        id_ex_rs2 <= id_ex_rs2_wire;
        id_ex_rd  <= id_ex_rd_wire;
        id_ex_rs1_val <= register_file[id_ex_rs1_wire];
        id_ex_rs2_val <= register_file[id_ex_rs2_wire];
        id_ex_imm <= id_ex_imm_wire;
        id_ex_Memread <= id_ex_Memread_wire;
        id_ex_Memwrite <= id_ex_Memwrite_wire;
        id_ex_MemtoReg <= id_ex_MemtoReg_wire;
        id_ex_Regwrite <= id_ex_Regwrite_wire;
        alu_src = alu_src_wire;
        alu_op = alu_op_wire;
        branch = branch_wire;
    end
    wire [1:0] forwardA ,forwardB;   
     forwarding_unit fwd_unit (
        .EX_MEM_RegWrite(ex_mem_Regwrite),
        .MEM_WB_RegWrite(mem_wb_RegWrite),
        .EX_MEM_Rd(ex_mem_rd),
        .MEM_WB_Rd(mem_wb_rd),
        .ID_EX_Rs1(id_ex_rs1),
        .ID_EX_Rs2(id_ex_rs2),
        .ForwardA(forwardA),
        .ForwardB(forwardB)
    );
    reg [63:0]operandBdummy;
    always @(*) begin
        // Determine operandA based on ForwardA
        case (forwardA)
            2'b00: operandA = id_ex_rs1_val;          // No forwarding
            2'b01: operandA = mem_wb_mem_data;         // Forward from MEM/WB stage
            2'b10: operandA = ex_mem_alu_result;  // Forward from EX/MEM stage
            default: operandA = id_ex_rs1_val;        // Default to register value
        endcase

        // Determine operandB based on ForwardB
        case (forwardB)
            2'b00: operandBdummy =id_ex_rs2_val;  // Use rs2_val or immediate
            2'b01: operandBdummy = mem_wb_mem_data;         // Forward from MEM/WB stage
            2'b10: operandBdummy = ex_mem_alu_result;  // Forward from EX/MEM stage
            default: operandBdummy = id_ex_rs2_val;        // Default to register value
        endcase
        case(alu_src)
            1'b0: operandB = operandBdummy;
            1'b1: operandB = id_ex_imm;
        endcase

    end


    // **Execute Stage**
    ex_stage execute_stage (
        .operandA(operandA),
        .operandB(operandB),
        .alu_op(alu_op),
        .clk(clk),
        .id_ex_Memwrite(id_ex_Memwrite),
        .id_ex_Memread(id_ex_Memread),
        .id_ex_MemtoReg(id_ex_MemtoReg),
        .id_ex_Regwrite(id_ex_Regwrite),
        .id_ex_rd(id_ex_rd),
        .imm(id_ex_imm),
        .alu_src(alu_src),
        .branch(branch),
        .ex_mem_alu_result(ex_mem_alu_result_wire),
        .ex_mem_rd(ex_mem_rd_wire),
        .ex_mem_Memwrite(ex_mem_Memwrite_wire),
        .ex_mem_Memread(ex_mem_Memread_wire),
        .ex_mem_MemtoReg(ex_mem_MemtoReg_wire),
        .ex_mem_Regwrite(ex_mem_Regwrite_wire),
        .ex_mem_overflow(ex_mem_overflow_wire)
    );
    // reg ex_mem__rs2_val;
    // always @(*) begin
    //     ex_mem__rs2_val = operandB;
    // end
    always @(*) begin
         ex_mem_alu_result_dummy = ex_mem_alu_result_wire;
        mem_wb_mem_data_dummy = mem_wb_mem_data_wire;
    end
    always @(posedge clk) begin
        ex_mem_rs2 <= operandBdummy;
    end
    always @(posedge clk) begin
        ex_mem_rd <= ex_mem_rd_wire;
        ex_mem_alu_result <= ex_mem_alu_result_wire;
        ex_mem_Memwrite <= ex_mem_Memwrite_wire;
        ex_mem_Memread <= ex_mem_Memread_wire;
        ex_mem_MemtoReg <= ex_mem_MemtoReg_wire;
        ex_mem_Regwrite <= ex_mem_Regwrite_wire;
    end
    // always@(posedge clk) begin
    //     if()
    // end

    // **Memory Stage**
    memory mem_stage (
        .clk(clk),
       // .memwrite(mem_write),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_Memwrite(ex_mem_Memwrite),
        .ex_mem_Memread(ex_mem_Memread),
        .ex_mem_MemtoReg(ex_mem_MemtoReg),
        .ex_mem_Regwrite(ex_mem_Regwrite),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_rs2(ex_mem_rs2),
        .mem_wb_rd(mem_wb_rd_wire),
        .mem_wb_MemtoReg(mem_wb_MemtoReg_wire),
        .mem_wb_alu_result(mem_wb_alu_result_wire),
        .mem_wb_mem_data(mem_wb_mem_data_wire),
        .mem_wb_RegWrite(mem_wb_RegWrite_wire)
       // .wb_write(wb_write)
    );

    always @(posedge clk ) begin
        mem_wb_rd <= mem_wb_rd_wire;
        mem_wb_MemtoReg <= mem_wb_MemtoReg_wire;
        mem_wb_alu_result <= mem_wb_alu_result_wire;
        mem_wb_mem_data <= mem_wb_mem_data_wire;
        mem_wb_RegWrite <= mem_wb_RegWrite_wire;
    end

    // // **Writeback Stage**
    writeback wb_stage (
        .clk(clk),
        //.wb_write(wb_write),
        .mem_wb_MemtoReg(mem_wb_MemtoReg),
        .mem_wb_RegWrite(mem_wb_RegWrite),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_mem_data(mem_wb_mem_data),
        .wb_RegWrite(wb_RegWrite_wire),
        .wb_rd(wb_rd_wire),
        .wb_registerout(wb_registerout_wire)
    );

    always @(* ) begin
        wb_RegWrite = wb_RegWrite_wire;
        wb_rd = wb_rd_wire;
        wb_registerout = wb_registerout_wire;

        if (wb_RegWrite) begin
            register_file[wb_rd] = wb_registerout;
            //$display("Register x[%d] Updated: %d", wb_rd, wb_registerout);
        end
    end

endmodule
