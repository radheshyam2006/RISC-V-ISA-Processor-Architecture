module Hazard(
    input id_ex_MemRead,      // Memory read signal from ID/EX pipeline register
    input [4:0] id_ex_Rd,     // Destination register in ID/EX stage
    input [4:0] if_id_Rs1,    // Source register 1 in IF/ID stage
    input [4:0] if_id_Rs2,    // Source register 2 in IF/ID stage
    output hazard_detected    // Hazard detection signal
);

    wire id_ex_Rd_nonzero;
    wire id_ex_Rd_eq_Rs1;
    wire id_ex_Rd_eq_Rs2;
    wire hazard_Rs1, hazard_Rs2;

    // Extend to 64-bit using wires
    wire [63:0] id_ex_Rdd  = {59'b0, id_ex_Rd}; 
    wire [63:0] if_id_Rs1d = {59'b0, if_id_Rs1};
    wire [63:0] if_id_Rs2d = {59'b0, if_id_Rs2};

    // Check if id_ex_Rd is not zero using OR gates
    or or1(id_ex_Rd_nonzero, id_ex_Rd[0], id_ex_Rd[1], id_ex_Rd[2], id_ex_Rd[3], id_ex_Rd[4]);

    // Instantiate comparators to check equality
    compartor comp1 (.reg1(id_ex_Rdd), .reg2(if_id_Rs1d), .eq(id_ex_Rd_eq_Rs1));
    compartor comp2 (.reg1(id_ex_Rdd), .reg2(if_id_Rs2d), .eq(id_ex_Rd_eq_Rs2));

    // Hazard detected if (MemRead & nonzero Rd & Rd matches Rs1)
    and and1(hazard_Rs1, id_ex_MemRead, id_ex_Rd_nonzero, id_ex_Rd_eq_Rs1);

    // Hazard detected if (MemRead & nonzero Rd & Rd matches Rs2)
    and and2(hazard_Rs2, id_ex_MemRead, id_ex_Rd_nonzero, id_ex_Rd_eq_Rs2);

    // Final hazard detection (if either case is true)
    or or2(hazard_detected, hazard_Rs1, hazard_Rs2);

endmodule
