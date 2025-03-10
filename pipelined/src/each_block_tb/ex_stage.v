// `include "add.v"
// `include "sub.v"
// `include "and.v"
// `include "or.v"
// `include "xor.v"
// `include "sll.v"
// `include "slt.v"
// `include "sltu.v"
// `include "srl.v"
// `include "sra.v"
// `include "compartor.v"

module ex_stage (
    input signed [63:0] operandA,
    input signed [63:0] operandB,
    input [3:0] alu_op,
    input clk,
    input id_ex_Memwrite,
    input id_ex_Memread,
    input id_ex_MemtoReg,
    input id_ex_Regwrite,
    input [4:0] id_ex_rd,
    input signed [63:0] imm,
    input alu_src,
    input signed branch,
    output reg signed [63:0] ex_mem_alu_result,
    output reg [4:0] ex_mem_rd,
    output reg ex_mem_Memwrite,
    output reg ex_mem_Memread,
    output reg ex_mem_MemtoReg,
    output reg ex_mem_Regwrite,
    output reg ex_mem_overflow
   // input [31:0] pc
);
    
   

    // Determine operandA based on forwarding conditions


  //  wire signed [63:0] operandB = (alu_src) ? imm : rs2_val;
    wire [63:0] add_result, sub_result, and_result, or_result, xor_result;
    wire [63:0] shifted_left, shifted_right_logical, shifted_right_arithmetic;
    wire lt_signed, lt_unsigned, comparator_result;
    wire add_overflow, sub_overflow, shift_overflow;
    add adder_inst (.reg1(operandA), .reg2(operandB), .reg3(add_result), .overflow(add_overflow));
    sub sub_inst (.reg1(operandA), .reg2(operandB), .reg3(sub_result), .overflow(sub_overflow));
    and_gate and_inst (.reg1(operandA), .reg2(operandB), .reg3(and_result));
    or_gate or_inst (.reg1(operandA), .reg2(operandB), .reg3(or_result));
    xor_gate xor_inst (.reg1(operandA), .reg2(operandB), .reg3(xor_result));
    left_shifter left_shift_inst (.data_in(operandA), .shift_amt(operandB[5:0]), .data_out(shifted_left), .overflow(shift_overflow));
    right_shifter_logical right_shift_log_inst (.data_in(operandA), .shift_amt(operandB[5:0]), .data_out(shifted_right_logical));
    right_shifter_arithmetic right_shift_arith_inst (.data_in(operandA), .shift_amt(operandB[5:0]), .data_out(shifted_right_arithmetic));
    signed_lt_comparator slt_inst (.reg1(operandA), .reg2(operandB), .lt(lt_signed));
    unsigned_lt_comparator ult_inst (.reg1(operandA), .reg2(operandB), .lt(lt_unsigned));
    compartor comp_inst (.reg1(operandA), .reg2(operandB), .eq(comparator_result));

    always @(* ) begin
        case (alu_op)
            4'b0000: {ex_mem_alu_result, ex_mem_overflow} <= {and_result, 1'b0};
            4'b0001: {ex_mem_alu_result, ex_mem_overflow} <= {or_result, 1'b0};
            4'b0010: {ex_mem_alu_result, ex_mem_overflow} <= {add_result, add_overflow};
            4'b0011: {ex_mem_alu_result, ex_mem_overflow} <= {shifted_left, shift_overflow};
            4'b0100: {ex_mem_alu_result, ex_mem_overflow} <= {shifted_right_logical, 1'b0};
            4'b0101: {ex_mem_alu_result, ex_mem_overflow} <= {shifted_right_arithmetic, 1'b0};
            4'b0110: {ex_mem_alu_result, ex_mem_overflow} <= {sub_result, sub_overflow};
            4'b0111: {ex_mem_alu_result, ex_mem_overflow} <= {{63'b0, lt_unsigned}, 1'b0};
            4'b1000: {ex_mem_alu_result, ex_mem_overflow} <= {{63'b0, lt_signed}, 1'b0};
            4'b1001: {ex_mem_alu_result, ex_mem_overflow} <= {xor_result, 1'b0};
            4'b1010: {ex_mem_alu_result, ex_mem_overflow} <= {{63'b0, comparator_result}, 1'b0};
            4'b1011: {ex_mem_alu_result, ex_mem_overflow} <= {{63'b0, ~comparator_result}, 1'b0};
            default: {ex_mem_alu_result, ex_mem_overflow} <= {64'bx, 1'bx};
        endcase
        ex_mem_Memwrite <= id_ex_Memwrite;
        ex_mem_Memread <= id_ex_Memread;
        ex_mem_MemtoReg <= id_ex_MemtoReg;
        ex_mem_Regwrite <= id_ex_Regwrite;
        ex_mem_rd <= id_ex_rd;
    end
endmodule
