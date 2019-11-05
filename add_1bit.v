module add_1bit(a, b, cin, sum, cout);
	input a, b, cin;
	output sum, cout;
	wire w1, w2, w3;
	
	xor first_xor(w1, a, b);
   xor second_xor(sum, cin, w1);
	
   or first_or(cout, w2, w3);
	
	and first_and(w2, cin, w1);
	and second_and(w3, a, b);
	
	
endmodule 