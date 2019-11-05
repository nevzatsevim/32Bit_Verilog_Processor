module not_equal(in1, in2 , out);
		
	input [31:0] in1, in2;
	wire [31:0] w;
	output out;
	
	genvar v;
	generate
	for(v = 0; v < 32; v=v+1) begin: xnor_loop
		xnor (w[v], in1[v], in2[v]);
	end
	endgenerate
	
	assign out = ~(w[0] & w[1] & w[2] & w[3] & w[4] & w[5] & w[6] & w[7] &
					  w[8] & w[9] & w[10] & w[11] & w[12] & w[13] & w[14] & w[15] &
					  w[16] & w[17] & w[18] & w[19] & w[20] & w[21] & w[22] & w[23] &
					  w[24] & w[25] & w[26] & w[27] & w[28] & w[29] & w[30] & w[31]);
	
endmodule
	