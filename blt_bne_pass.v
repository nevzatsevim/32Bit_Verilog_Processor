module blt_bne_pass(b_now, opcode_old, rd_now, rs_now, pass, prob_rs, prob_rd, ret_adr);

input [4:0] opcode_old, rd_now, rs_now, ret_adr;
input b_now;
output pass, prob_rd, prob_rs;

wire gen_pass, opcode_case, b_true, rd_no, rs_no, alu_no, addi_no;

not_equal (b_now, 1'b0 , b_true);

not_equal (rd_now, ret_adr , rd_no);
not_equal (rs_now, ret_adr , rs_no);

not_equal (opcode_old, 5'b00000 , alu_no);
not_equal (opcode_old, 5'b00101 , addi_no);


or (opcode_case, ~alu_no, ~addi_no);
or (gen_pass, ~rd_no, ~rs_no);
and (pass, gen_pass, opcode_case, b_true);

assign prob_rs = ~rs_no;
assign prob_rd = ~rd_no;

endmodule

