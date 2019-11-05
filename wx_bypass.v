module wx_bypass(rd, rs, rd_old, opcode_old, opcode_new, opcode_dec, pass, weird_stall, dec_rs, dec_rt, sw_prob_adr, sw_prob_val);

input [4:0] rd, rs, rd_old, opcode_old, opcode_new, opcode_dec, dec_rs, dec_rt;
output pass, weird_stall, sw_prob_adr, sw_prob_val;
wire lw_current_no, sw_current_no, alu_prew_no, addi_prew_no, lw_prew_no, rs_rd_no, rd_rd_no, sw_yes, lw_yes, case_yes, op_yes; 
wire lw_no_decode, alu_no_decode, addi_no_decode, decode_case, dec_no_rt, dec_no_rs, stall_case, dec_reg_yes;


//the current opcode values

//alu (.data_operandA(opcode_new), .data_operandB(5'b01000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(lw_current_no), .isLessThan(), .overflow());

not_equal (opcode_new, 5'b01000 , lw_current_no);

//alu (.data_operandA(opcode_new), .data_operandB(5'b00111), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(sw_current_no), .isLessThan(), .overflow());

not_equal (opcode_new, 5'b00111 , sw_current_no);

//write stage opcode values

//alu (.data_operandA(opcode_old), .data_operandB(5'b00000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(alu_prew_no), .isLessThan(), .overflow());

not_equal (opcode_old, 5'b00000 , alu_prew_no);
			
//alu (.data_operandA(opcode_old), .data_operandB(5'b00101), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(addi_prew_no), .isLessThan(), .overflow());

not_equal (opcode_old, 5'b00101 , addi_prew_no);

//alu (.data_operandA(opcode_old), .data_operandB(5'b01000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(lw_prew_no), .isLessThan(), .overflow());

not_equal (opcode_old, 5'b01000 , lw_prew_no);


//compare reg values

//alu (.data_operandA(rd_old), .data_operandB(rs), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(rs_rd_no), .isLessThan(), .overflow());

not_equal (rd_old, rs , rs_rd_no);

//alu (.data_operandA(rd), .data_operandB(rd_old), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(rd_rd_no), .isLessThan(), .overflow());

not_equal (rd, rd_old, rd_rd_no);


//decode opcode values

//alu (.data_operandA(opcode_dec), .data_operandB(5'b00000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(alu_no_decode), .isLessThan(), .overflow());

not_equal (opcode_dec, 5'b00000, alu_no_decode);

//alu (.data_operandA(opcode_dec), .data_operandB(5'b00101), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(addi_no_decode), .isLessThan(), .overflow());

not_equal (opcode_dec, 5'b00101, addi_no_decode);

//alu (.data_operandA(opcode_dec), .data_operandB(5'b01000), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(lw_no_decode), .isLessThan(), .overflow());

not_equal (opcode_dec, 5'b01000, lw_no_decode);

//decode reg comparison

//alu (.data_operandA(dec_rs), .data_operandB(rd), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(dec_no_rs), .isLessThan(), .overflow());

not_equal (dec_rs, rd, dec_no_rs);

//alu (.data_operandA(dec_rt), .data_operandB(rd), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(dec_no_rt), .isLessThan(), .overflow());

not_equal (dec_rt, rd, dec_no_rt);

wire w0, w1;

or  (decode_case, ~alu_no_decode, ~addi_no_decode, lw_no_decode);
or  (w0, ~addi_no_decode, ~addi_no_decode);
and (w1, w0, ~dec_no_rt);
or  (dec_reg_yes, w1, ~dec_no_rs);

and (stall_case, decode_case, ~lw_current_no);
and (weird_stall, stall_case, dec_reg_yes);

and (sw_prob_val, ~rd_rd_no, ~sw_current_no);
and (sw_prob_adr, ~rs_rd_no, ~sw_current_no);
and (lw_yes, ~rs_rd_no, ~lw_current_no);

or  (case_yes, sw_prob_adr, sw_prob_val, lw_yes);

or  (op_yes, ~alu_prew_no, ~addi_prew_no, ~lw_prew_no);
and (pass, op_yes, case_yes);

endmodule