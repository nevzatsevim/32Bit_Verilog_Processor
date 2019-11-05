module mx_bypass(rd, rs, rd_old, opcode_old, opcode_new, pass, sw_prob_adr, sw_prob_val);

input [4:0] rd, rs, rd_old, opcode_old, opcode_new;
output pass, sw_prob_adr, sw_prob_val;
wire lw_current_no, sw_current_no, alu_prew_no, addi_prew_no, rs_rd_no, rd_rd_no, lw_yes, case_yes, op_yes; 

//the current opcode values

//alu (.data_operandA(opcode_new), .data_operandB(5'b01000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(lw_current_no), .isLessThan(), .overflow());

not_equal (opcode_new, 5'b01000 , lw_current_no);

//alu (.data_operandA(opcode_new), .data_operandB(5'b00111), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(sw_current_no), .isLessThan(), .overflow());

not_equal (opcode_new, 5'b00111 , sw_current_no);

//mem stage opcode values

//alu (.data_operandA(opcode_old), .data_operandB(5'b00000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(alu_prew_no), .isLessThan(), .overflow());

not_equal (opcode_old, 5'b00000 , alu_prew_no);
			
//alu (.data_operandA(opcode_old), .data_operandB(5'b00101), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(addi_prew_no), .isLessThan(), .overflow());

not_equal (opcode_old, 5'b00101 , addi_prew_no);


//compare reg values

//alu (.data_operandA(rd_old), .data_operandB(rs), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(rs_rd_no), .isLessThan(), .overflow());

not_equal (rd_old, rs , rs_rd_no);

//alu (.data_operandA(rd), .data_operandB(rd_old), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(rd_rd_no), .isLessThan(), .overflow());

not_equal (rd, rd_old , rd_rd_no);

and (sw_prob_val, ~rd_rd_no, ~sw_current_no);
and (sw_prob_adr, ~rs_rd_no, ~sw_current_no);
and (lw_yes, ~rs_rd_no, ~lw_current_no);

or (case_yes, sw_prob_adr, sw_prob_val, lw_yes);

or (op_yes, ~alu_prew_no, ~addi_prew_no);
and (pass, op_yes, case_yes);

endmodule