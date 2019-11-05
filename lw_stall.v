module lw_stall(rd, rs, rt, opcode_old, opcode_new, stall);

input [4:0] rd, rs, rt, opcode_old, opcode_new;
output stall;
wire lw_no, alu0_no, alu1_no, alu_yes, op_yes, rs_rd_no, rt_rd_no, reg_yes; 

alu (.data_operandA(opcode_old), .data_operandB(5'b01000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(lw_no), .isLessThan(), .overflow());
			
alu (.data_operandA(opcode_new), .data_operandB(5'b00000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(alu0_no), .isLessThan(), .overflow());
			
alu (.data_operandA(opcode_new), .data_operandB(5'b00101), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(alu1_no), .isLessThan(), .overflow());

alu (.data_operandA(rd), .data_operandB(rs), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(rs_rd_no), .isLessThan(), .overflow());

alu (.data_operandA(rd), .data_operandB(rt), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(rt_rd_no), .isLessThan(), .overflow());

or (alu_yes, ~alu0_no, ~alu1_no);
and (op_yes, alu_yes, ~lw_no);

or (reg_yes, ~rs_rd_no, ~rt_rd_no);
and (stall,  reg_yes, op_yes);

endmodule
