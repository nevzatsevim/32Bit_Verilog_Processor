module bex_pass(bex_now, opcode_old, ret_adr, pass);

input [4:0] opcode_old, ret_adr;
input bex_now;
output pass;

wire bex_true, alu_no, addi_no, setx_no, ret_no, opcode_case;

not_equal (bex_now, 1'b0 , bex_true);

not_equal (opcode_old, 5'b00000 , alu_no);
not_equal (opcode_old, 5'b00101 , addi_no);
not_equal (opcode_old, 5'b10101 , setx_no);

not_equal (ret_adr, 5'b11110, ret_no);

or (opcode_case, ~alu_no, ~addi_no, ~setx_no);
and (pass, opcode_case, ~ret_adr, bex_true);

endmodule

