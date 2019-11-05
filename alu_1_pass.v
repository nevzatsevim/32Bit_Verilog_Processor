module alu_1_pass(rd, rs, rt, opcode_old, opcode_new, pass, problem_rs, problem_rt);

input [4:0] rd, rs, rt, opcode_old, opcode_new;
output pass, problem_rs, problem_rt;
wire alu_current_no, addi_current_no, alu_prew_no, addi_prew_no, rs_rd_no, rt_rd_no, case_1_yes, case_2_yes, reg_yes;
//the current opcode values

//alu (.data_operandA(opcode_new), .data_operandB(5'b00000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(alu_current_no), .isLessThan(), .overflow());

not_equal (opcode_new, 5'b00000 , alu_current_no);
			
//alu (.data_operandA(opcode_new), .data_operandB(5'b00101), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(addi_current_no), .isLessThan(), .overflow());

not_equal (opcode_new, 5'b00101 , addi_current_no);
			
//mem stage opcode values
			
//alu (.data_operandA(opcode_old), .data_operandB(5'b00000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(alu_prew_no), .isLessThan(), .overflow());

not_equal (opcode_old, 5'b00000 , alu_prew_no);
			
//alu (.data_operandA(opcode_old), .data_operandB(5'b00101), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(addi_prew_no), .isLessThan(), .overflow());

not_equal (opcode_old, 5'b00101 , addi_prew_no);

//register comparison

//alu (.data_operandA(rd), .data_operandB(rs), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(rs_rd_no), .isLessThan(), .overflow());

not_equal (rd, rs , rs_rd_no);

//alu (.data_operandA(rd), .data_operandB(rt), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(rt_rd_no), .isLessThan(), .overflow());

not_equal (rd, rt , rt_rd_no);

or (case_1_yes, ~alu_current_no, ~addi_current_no);
or (case_2_yes, ~alu_prew_no, ~addi_prew_no);
or (reg_yes, ~rs_rd_no, ~rt_rd_no);
and (pass, case_1_yes, case_2_yes, reg_yes);

assign problem_rs = ~rs_rd_no;
assign problem_rt = ~rt_rd_no;

endmodule