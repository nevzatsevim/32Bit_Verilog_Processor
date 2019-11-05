module counter_m(clock, reset, out);
input clock, reset;
   output [5:0] out;
   wire [5:0] next;
wire w1,w2,w3,w4,w5,w6;
wire nr;
wire stop;

and (stop, ~out[0], ~out[1], ~out[2], ~out[3], ~out[4], out[5]);

add_1bit add_1(out[0], 1'b1, 1'b0, next[0],w1);
my_dff df0(.d(next[0]&~stop), .clk(clock), .clr(reset), .en(1'b1), .q(out[0]));

add_1bit add_2(out[1], 1'b0, w1, next[1], w2);
my_dff df1(.d(next[1]&~stop), .clk(clock), .clr(reset), .en(1'b1), .q(out[1]));

add_1bit add_3(out[2], 1'b0, w2, next[2], w3);
my_dff df2(.d(next[2]&~stop), .clk(clock), .clr(reset), .en(1'b1), .q(out[2]));

add_1bit add_4(out[3], 1'b0, w3, next[3], w4);
my_dff df3(.d(next[3]&~stop), .clk(clock), .clr(reset), .en(1'b1), .q(out[3]));

add_1bit add_5(out[4], 1'b0, w4, next[4], w5);
my_dff df4(.d(next[4]&~stop), .clk(clock), .clr(reset), .en(1'b1), .q(out[4]));


add_1bit add_6(out[5], 1'b0, w5, next[5], w6);
my_dff df5(.d(next[5]|stop), .clk(clock), .clr(reset), .en(1'b1), .q(out[5]));


endmodule