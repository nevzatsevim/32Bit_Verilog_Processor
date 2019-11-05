module wm_bypass(rdr, mem_write_adr, opcode_old, opcode_new, pass);

input [4:0] rdr, mem_write_adr, opcode_old, opcode_new;
output pass;
wire op_old_false, op_new_false, adr_false; 


//alu (.data_operandA(opcode_new), .data_operandB(5'b00111), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(op_new_false), .isLessThan(), .overflow());

not_equal (opcode_new, 5'b00111 , op_new_false);
			
//alu (.data_operandA(opcode_old), .data_operandB(5'b01000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(op_old_false), .isLessThan(), .overflow());

not_equal (opcode_old, 5'b01000 , op_old_false);
			
//alu (.data_operandA(mem_write_adr), .data_operandB(rdr), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(adr_false), .isLessThan(), .overflow());

not_equal (mem_write_adr, rdr , adr_false);

and (pass, ~op_new_false, ~op_old_false, ~adr_false);

endmodule