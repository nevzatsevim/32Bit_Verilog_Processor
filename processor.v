/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB,                   // I: Data from port B of regfile
	 
	 
	 test_pc_fetch,
	 test_pc_decode,
	 test_pc_execute,
	 test_reg_write_en,
	 test_result_write,
	 test_result_ex,
	 test_result_mem,
	 test_address_write,
	 test_opcode_decode,
	 test_opcode_execute,
	 test_opcode_mem,
	 test_opcode_write,
	 test_sw_mem_res,
	 test_sw_mem_adr,
	 sw_true_mem_test
);
	 output [31:0] test_result_ex, test_result_mem, test_result_write;
	 output [11:0] test_pc_fetch, test_pc_decode, test_pc_execute;
	 output [4:0] test_opcode_decode, test_opcode_execute, test_opcode_mem, test_opcode_write;  
	 output [4:0] test_address_write;
	 output test_reg_write_en, sw_true_mem_test;
	 output [31:0] test_sw_mem_res, test_sw_mem_adr;
	 
	 
	 
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;
	 
	 //Coding Starts Here
	
	wire [31:0] stall_data;
	assign stall_data = 32'b0;
	wire [31:0] jump_value;
	wire yes_jump;
	wire md_stall;
	
	//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//Fetch//
	
	wire [31:0] w_pc0, w_pc1, w_pc_j, w_pc_stl; 
	
	//first determinde the next instruction
	
	genvar i;
	generate
	for(i = 0; i < 32; i=i+1) begin: program_counter
		my_dff (.q(w_pc0[i]), .d(w_pc_stl[i]), .clk(clock), .en(1'b1), .clr(reset));
	end
	endgenerate
	
	
	alu(.data_operandA(w_pc0), .data_operandB(1'b1), .ctrl_ALUopcode(5'b00000), .ctrl_shiftamt(), .data_result(w_pc1));
	
	mux_2_32bit is_there_jump(.select(yes_jump), .in0(w_pc1), .in1(jump_value), .out(w_pc_j));
	mux_2_32bit is_there_stall(.select(md_stall|wx_stall|mul|div), .in0(w_pc_j), .in1(w_pc0), .out(w_pc_stl));
	
	assign address_imem = w_pc0[11:0];
	assign test_pc_fetch = w_pc0[11:0];
	

	//so the first part determined the next imem adress, now we determine what instruction we have received
	
	wire [31:0] instruction_temp, instruction_tp, instruction_t, instruction_tem, instruction;
	wire [31:0] pc_dec, pc_ex, wq;
	assign wq = {q_imem};
	
	mux_2_32bit (.select(md_stall|yes_jump|mul|div), .in0(wq), .in1(stall_data), .out(instruction_temp));
	mux_2_32bit (.select(wx_stall), .in0(instruction_temp), .in1(instruction), .out(instruction_tp));
	
	genvar f;
   generate
		for(f = 0; f < 32; f=f+1) begin: fetchloop
	my_dff fetchDFF(.q(instruction_t[f]), .d(instruction_tp[f]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff fetchPC(.q(pc_dec[f]), .d(w_pc0[f]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
   

	//Decode//Decode//Decode//Decode//Decode//Decode//Decode//Decode//Decode//Decode//Decode//Decode//Decode//Decode//Decode//Decode
	
	
	assign test_pc_decode = {pc_dec[11:0]};
	assign test_opcode_decode = {opcode};
	
	
	mux_2_32bit (.select(yes_jump|md_stall), .in0(instruction_t), .in1(stall_data), .out(instruction));
	
	wire [4:0] opcode;
	assign opcode = {instruction[31:27]};
	
	//multdiv stall logic
	
	counter_md   md_stal(.clock(clock), .reset(reset), .md(mul|div), .stall(md_stall));
	
	//instruction type R
	
	wire [4:0] rd_R, rs_R, rt_R, shiftamt, ALUop;
	wire [1:0] zeros;
	assign rd_R = {instruction[26:22]};
   assign rs_R = {instruction[21:17]};
   assign rt_R = {instruction[16:12]};
   assign shiftamt = {instruction[11:7]};
   assign ALUop = {instruction[6:2]};
	assign zeros = {instruction[1:0]};
	
	//instruction type I
	wire [4:0] rd_I, rs_I;
	wire [16:0] immed;
	assign rd_I = {instruction[26:22]};
   assign rs_I = {instruction[21:17]};
   assign immed = {instruction[16:0]};
	
	//instruction type J1
	wire [26:0] target;
	assign target = {instruction[26:0]};
	
	//instruction type J2
	wire [4:0] rd_J2;
	wire [1:0] zeros_J2;
	assign rd_J2 = {instruction[26:22]};
   assign zeros_J2 = {instruction[21:0]};
	
	
	//which instruction
	wire alu_t, mul_t, div_t, alu, mul, div, addi, sw, lw, j,bne, jal, jr, blt, bex, setx;
	
	and (alu_t, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);
	and (mul_t, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);
	and (div_t, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);
	and (mul, alu_t, ~ALUop[4], ~ALUop[3], ALUop[2], ALUop[1], ~ALUop[0]);
	and (div, alu_t, ~ALUop[4], ~ALUop[3], ALUop[2], ALUop[1], ALUop[0]);
	and (alu, alu_t, ~mul, ~div);
	and (addi, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
	and (sw, ~opcode[4], ~opcode[3], opcode[2], opcode[1], opcode[0]);
	and (lw, ~opcode[4], opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);
	and (j, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], opcode[0]);
	and (bne, ~opcode[4], ~opcode[3], ~opcode[2], opcode[1], ~opcode[0]);
	and (jal, ~opcode[4], ~opcode[3], ~opcode[2], opcode[1], opcode[0]);
	and (jr, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], ~opcode[0]);
	and (blt, ~opcode[4], ~opcode[3], opcode[2], opcode[1], ~opcode[0]);
	and (bex, opcode[4], ~opcode[3], opcode[2], opcode[1], ~opcode[0]);
	and (setx, opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
	
	//put them through the pipe

	wire alu_true, mul_true, div_true, addi_true, sw_true, lw_true, j_true , bne_true, jal_true, jr_true, blt_true, bex_true, setx_true;
	
	my_dff (.d(alu), .q(alu_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(mul), .q(mul_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(div), .q(div_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(addi), .q(addi_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(sw), .q(sw_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(lw), .q(lw_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(j), .q(j_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(bne), .q(bne_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(jal), .q(jal_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(jr), .q(jr_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(blt), .q(blt_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(bex), .q(bex_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.d(setx), .q(setx_true), .clk(clock), .en(1'b1), .clr(reset));
	
	//Fetch data from the reg file
	
	wire write_en, rd_or_rt;
	wire [4:0]  ctrl_rd_rt, ctrl_rs_rstatus, ctrl_which_reg;
	
	wire [31:0] wire_rd_rt, wire_rs, wire_write;
	
	or (rd_or_rt, mul, div, alu);
	mux_2_5bit  (.select(rd_or_rt), .in0(rd_R), .in1(rt_R), .out(ctrl_rd_rt));
	mux_2_5bit  (.select(bex), .in0(rs_R), .in1(5'b11110), .out(ctrl_rs_rstatus));
	 
	
	//Pass on the valuable data to the pipe as well
	
	wire [31:0] wire_rd_rt_ex, wire_rs_ex;
 
   genvar d;
   generate
   for(d = 0; d < 32; d=d+1) begin: regloop
	my_dff (.q(wire_rd_rt_ex[d]), .d(wire_rd_rt[d]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(wire_rs_ex[d]), .d(wire_rs[d]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
	
  
  //piped R values
  
   wire [4:0] rd_R_ex, rs_R_ex, rt_R_ex, shiftamt_ex, ALUop_ex, opcode_ex;
  
	genvar r;
   generate
   for(r = 0; r < 5; r=r+1) begin: r_values_loop
	my_dff (.q(opcode_ex[r]), .d(opcode[r]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(rd_R_ex[r]), .d(rd_R[r]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(rs_R_ex[r]), .d(rs_R[r]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(rt_R_ex[r]), .d(rt_R[r]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(shiftamt_ex[r]), .d(shiftamt[r]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(ALUop_ex[r]), .d(ALUop[r]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
	
	//piped I values
  
   wire [4:0] rd_I_ex, rs_I_ex;
   wire [16:0] immed_ex;
  
	genvar ii;
   generate
   for(ii = 0; ii < 5; ii=ii+1) begin: i_values_loop1
	my_dff (.q(rd_I_ex[ii]), .d(rd_I[ii]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(rs_I_ex[ii]), .d(rs_I[ii]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
  
  	genvar iii;
   generate
   for(iii = 0; iii < 17; iii=iii+1) begin: i_values_loop2
	my_dff (.q(immed_ex[iii]), .d(immed[iii]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
  
  	//piped j1 values & and nothing needed for j2 ops
	
	wire [26:0] target_ex;
	
	genvar jj;
   generate
   for(jj = 0; jj < 27; jj=jj+1) begin: j1_values
	my_dff (.q(target_ex[jj]), .d(target[jj]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
	
	genvar pcd;
   generate
		for(pcd = 0; pcd < 32; pcd=pcd+1) begin: pc_loop
	my_dff fetchPC(.q(pc_ex[pcd]), .d(pc_dec[pcd]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
	

	//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66
	//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66
	//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66
	//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66//Execute_order_66
	
	 assign test_pc_execute = {pc_ex[11:0]};
	 assign test_opcode_execute = {opcode_ex};
	
	//Alu portion of things, here we check if bypass required and also decide on what to put in alu and muldiv
	
	wire alu1pass, alu2pass, wxpass, mxpass, alu1rs, alu1rt, alu2rs, alu2rt;
	
	
	alu_1_pass    (.rd(main_adr_mem), .rs(rs_R_ex), .rt(rt_R_ex), .opcode_old(opcode_mem), .opcode_new(opcode_ex), .pass(alu1pass), .problem_rs(alu1rs), .problem_rt(alu1rt));
	
	alu_2_pass    (.rd(main_adr_write), .rs(rs_R_ex), .rt(rt_R_ex), .opcode_old(opcode_write), .opcode_new(opcode_ex), .pass(alu2pass), .problem_rs(alu2rs), .problem_rt(alu2rt));
	
	
	wire exeption, md_exc, alu_exc, md_red;
	or (exeption, md_exc, alu_exc);
	wire [31:0] w1, w2, w3, alu_ina, alu_inb, alu_res, md_res;
	wire [4:0] op_eff;
	
	//bypass for input a
	
	mux_2_32bit (.select(alu2pass & alu2rs), .in0(wire_rs_ex), .in1(main_res_write), .out(w1));
	mux_2_32bit (.select(alu1pass & alu1rs), .in0(w1), .in1(mem_value), .out(alu_ina));
	
	//bypass for input b
	
	mux_2_32bit (.select(alu2pass & alu2rt), .in0(wire_rd_rt_ex), .in1(main_res_write), .out(w2));
	mux_2_32bit (.select(alu1pass & alu1rt), .in0(w2), .in1(mem_value), .out(w3));
	mux_2_32bit (.select(addi_true), .in0(w3), .in1(immed_ex), .out(alu_inb));
	
	
	mux_2_32bit (.select(addi_true), .in0(ALUop_ex), .in1(5'b00000), .out(op_eff));
	
	alu  (.data_operandA(alu_ina), .data_operandB(alu_inb), .ctrl_ALUopcode(op_eff), .ctrl_shiftamt(shiftamt_ex), .data_result(alu_res), .isNotEqual(), .isLessThan(), .overflow(alu_exc));
	
	multdiv  (.data_operandA(wire_rs_ex), .data_operandB(wire_rd_rt_ex), .ctrl_MULT(mul_true), .ctrl_DIV(div_true), .clock(clock), .data_result(md_res), .data_exception(md_exc), .data_resultRDY(md_red));
	
	wire ec0, ec1;
	or (ec0, alu_true, addi_true);
	or (ec1, md_exc, alu_exc);
	
	//here we check there is exeption and write the registers accordingly 
	//we also save the md address for 32 loops
	
	genvar l;
   generate
   for(l = 0; l < 5; l=l+1) begin: md_address_save
	my_dff (.q(saved_mul_adr[l]), .d(rd_R_ex[l]), .clk(clock), .en(mul_true|div_true), .clr(reset));
   end
   endgenerate
	
	wire saved_mul, saved_div;
	
	my_dff (.q(saved_mul), .d(mul_true), .clk(clock), .en(mul_true|div_true), .clr(reset));
	my_dff (.q(saved_div), .d(div_true), .clk(clock), .en(mul_true|mul_true), .clr(reset));
	
	wire [4:0] alu_ret_adr, saved_mul_adr, adr_temp;
	wire [31:0] alu_ret_val, z1,z2,z3,z4,z5;
	
	mux_2_5bit  (.select(md_red), .in0(rd_R_ex), .in1(saved_mul_adr), .out(adr_temp));
	mux_2_5bit  (.select(ec0 & ec1), .in0(adr_temp), .in1(5'b11110), .out(alu_ret_adr));
	
	
	mux_2_32bit (.select(ec0 & ec1 & ~ALUop_ex[4]& ~ALUop_ex[3]& ~ALUop_ex[2]& ~ALUop_ex[1]& ~ALUop_ex[0]), .in0(alu_res), .in1(32'b00000000000000000000000000000001), .out(z1));
	mux_2_32bit (.select(ec0 & ec1 & addi_true), .in0(z1), .in1(32'b00000000000000000000000000000010), .out(z2));
	mux_2_32bit (.select(ec0 & ec1 & ~ALUop_ex[4]& ~ALUop_ex[3]& ~ALUop_ex[2]& ~ALUop_ex[1]& ALUop_ex[0]), .in0(z2), .in1(32'b00000000000000000000000000000011), .out(z3));
	mux_2_32bit (.select(ec1 & saved_mul), .in0(md_res), .in1(32'b00000000000000000000000000000100), .out(z4));
	mux_2_32bit (.select(ec1 & saved_div), .in0(z4), .in1(32'b00000000000000000000000000000101), .out(z5));
	
	mux_2_32bit (.select(md_red), .in0(z3), .in1(z5), .out(alu_ret_val));
	
	//lw and sw
	wire wx_stall;
	wire mx_adr, mx_val, wx_adr, wx_val;
	
	mx_bypass     (.rd(rd_R_ex), .rs(rs_R_ex), .rd_old(main_adr_mem), .opcode_old(opcode_mem), .opcode_new(opcode_ex), .pass(mxpass), .sw_prob_adr(mx_adr), .sw_prob_val(mx_val));
	wx_bypass     (.rd(rd_R_ex), .rs(rs_R_ex), .rd_old(main_adr_write), .opcode_old(opcode_write), .opcode_new(opcode_ex), .pass(wxpass), .opcode_dec(opcode), .weird_stall(wx_stall), .dec_rs(rs_R), .dec_rt(rt_R), .sw_prob_adr(wx_adr), .sw_prob_val(wx_val));
	
	
	wire[31:0] bp1, bp2, bp3, bp4, bp5, lw_res, sw_res, sw_adr;
	wire[4:0] lw_adr;
	
	mux_2_32bit (.select(mxpass), .in0(bp1), .in1(mem_value), .out(bp2));
	mux_2_32bit (.select(wxpass), .in0(wire_rs_ex), .in1(main_res_write), .out(bp1));
	
	alu (.data_operandA(bp2), .data_operandB(immed_ex), .ctrl_ALUopcode(5'b00000), .ctrl_shiftamt(), .data_result(lw_res), .isNotEqual(), .isLessThan(), .overflow());
	assign lw_adr = rd_R_ex;
	
	mux_2_32bit (.select(wxpass & wx_adr), .in0(wire_rs_ex), .in1(main_res_write), .out(bp4));
	mux_2_32bit (.select(mxpass & mx_adr), .in0(bp4), .in1(mem_value), .out(bp5));
	
	alu (.data_operandA(bp5), .data_operandB(immed_ex), .ctrl_ALUopcode(5'b00000), .ctrl_shiftamt(), .data_result(sw_adr), .isNotEqual(), .isLessThan(), .overflow());
	
	mux_2_32bit (.select(wxpass & wx_val), .in0(wire_rd_rt_ex), .in1(main_res_write), .out(bp3));
	mux_2_32bit (.select(mxpass & mx_val), .in0(bp3), .in1(mem_value), .out(sw_res));
	
	
	// jump portion of things 
	wire bex_pm, bex_pw, bpass1, bpass2, psmem, pswrite, pdmem, pdwrite;
	wire [31:0] y0,y1;
	wire [31:0] k0,k1,k2,k3;
	
	blt_bne_pass  (.b_now(blt_true|bne_true), .opcode_old(opcode_mem), .rd_now(rd_R_ex), .rs_now(rs_R_ex), .pass(bpass1), .prob_rs(psmem), .prob_rd(pdmem), .ret_adr(main_adr_mem));
	blt_bne_pass  (.b_now(blt_true|bne_true), .opcode_old(opcode_write), .rd_now(rd_R_ex), .rs_now(rs_R_ex), .pass(bpass2), .prob_rs(pswrite), .prob_rd(pdwrite), .ret_adr(main_adr_write));
	
	mux_2_32bit (.select(bpass2 & pswrite), .in0(wire_rs_ex), .in1(main_res_write), .out(k0));
	mux_2_32bit (.select(bpass1 & psmem), .in0(k0), .in1(main_res_mem), .out(k1));
	
	mux_2_32bit (.select(bpass2 & pdwrite), .in0(wire_rd_rt_ex), .in1(main_res_write), .out(k2));
	mux_2_32bit (.select(bpass1 & pdmem), .in0(k2), .in1(main_res_mem), .out(k3));
	
	alu (.data_operandA(k3), .data_operandB(k1), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(bne_test), .isLessThan(blt_test), .overflow());
			
	bex_pass (.bex_now(bex_true), .opcode_old(opcode_mem), .ret_adr(main_adr_mem), .pass(bex_pm));
	bex_pass (.bex_now(bex_true), .opcode_old(opcode_write), .ret_adr(main_adr_write), .pass(bex_pw));
			
	mux_2_32bit (.select(bex_pw), .in0(wire_rs_ex), .in1(main_res_write), .out(y0));
	mux_2_32bit (.select(bex_pm), .in0(y0), .in1(mem_value), .out(y1));		
	not_equal (y1, 32'b0 , bex_test);		
	
	wire bne_test, blt_test, bex_test, b0 ,b1, b2;
	and (b0, bne_test, bne_true);
	and (b1, blt_test, blt_true);
	and (b2, bex_test, bex_true);	
	or (yes_jump, j_true, jal_true, jr_true, b0, b1, b2);
	
	wire [31:0] j0,j1,j2; 
	
		alu (.data_operandA(pc_ex), .data_operandB(32'b00000000000000000000000000000001), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(j0), .isNotEqual(), .isLessThan(), .overflow());
		alu (.data_operandA(j0), .data_operandB(immed_ex), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(j1), .isNotEqual(), .isLessThan(), .overflow());
	
	mux_2_32bit (.select(bne_true | blt_true), .in0(target_ex), .in1(j1), .out(j2));
	mux_2_32bit (.select(jr_true), .in0(j2), .in1(wire_rd_rt_ex), .out(jump_value));
	
	
	//deciding on what value to return
	
	wire[31:0] h0,h1, main_res_ex;
	wire [4:0] c0,c1, main_adr_ex;
	
	mux_2_32bit (.select(jal_true), .in0(alu_ret_val), .in1(j0), .out(h0));
	mux_2_32bit (.select(lw_true), .in0(h0), .in1(lw_res), .out(h1));
	mux_2_32bit (.select(setx_true), .in0(h1), .in1(target_ex), .out(main_res_ex));
	
	mux_2_5bit  (.select(lw_true), .in0(alu_ret_adr), .in1(lw_adr), .out(c0));
	mux_2_5bit  (.select(jal_true), .in0(c0), .in1(5'b11111), .out(c1));
	mux_2_5bit  (.select(setx_true), .in0(c1), .in1(5'b11110), .out(main_adr_ex));
	
	wire write_en_reg_ex;
	or (write_en_reg_ex, alu_true, addi_true, lw_true, jal_true, setx_true);
		
	//and write them trhough the pipe
	assign test_result_ex = {main_res_ex};
	
	
	genvar m;
   generate
   for(m = 0; m < 32; m=m+1) begin: mem_loop1
	my_dff (.q(main_res_mem[m]), .d(main_res_ex[m]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(sw_res_mem[m]), .d(sw_res[m]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(sw_adr_mem[m]), .d(sw_adr[m]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
	
	genvar z;
   generate
   for(z = 0; z < 5; z=z+1) begin: mem_loop2
	my_dff (.q(opcode_mem[z]), .d(opcode_ex[z]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(main_adr_mem[z]), .d(main_adr_ex[z]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(rd_R_mem[z]), .d(rd_R_ex[z]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
	
	my_dff (.q(sw_true_mem), .d(sw_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(lw_true_mem), .d(lw_true), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(write_en_reg_mem), .d(write_en_reg_ex), .clk(clock), .en(1'b1), .clr(reset));
	
	//Memory// Memory// Memory// Memory// Memory// Memory// Memory// Memory// Memory// Memory// Memory// Memory// Memory// Memory// Memory// Memory//
	
	assign test_opcode_mem = {opcode_mem};
	assign test_result_mem = {mem_value};
	assign test_sw_mem_res = {sw_res_mem};
	assign test_sw_mem_adr = {sw_adr_mem};
	assign sw_true_mem_test = {sw_true_mem};
	
	wire [31:0] main_res_mem, sw_res_mem, sw_adr_mem;
	wire [4:0] opcode_mem, main_adr_mem, rd_R_mem;
	wire sw_true_mem, lw_true_mem, write_en_reg_mem; 
	wire wm_pass;
	wire [31:0] mem_value, dmem_adr;
	
	wm_bypass   (.rdr(rd_R_mem), .mem_write_adr(main_adr_write), .opcode_old(opcode_write), .opcode_new(opcode_mem), .pass(wm_pass));
	mux_2_32bit (.select(wm_pass), .in0(sw_res_mem), .in1(main_res_write), .out(data));
	
	assign wren = {sw_true_mem};
	
	
	
	assign address_dmem = {dmem_adr[11:0]};
	
	mux_2_32bit (.select(lw_true_mem), .in0(sw_adr_mem), .in1(main_res_mem), .out(dmem_adr));
	mux_2_32bit (.select(lw_true_mem), .in0(main_res_mem), .in1(q_dmem), .out(mem_value));
	
	
	genvar y;
   generate
   for(y = 0; y < 5; y=y+1) begin: write_loop1
	my_dff (.q(opcode_write[y]), .d(opcode_mem[y]), .clk(clock), .en(1'b1), .clr(reset));
	my_dff (.q(main_adr_write[y]), .d(main_adr_mem[y]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
	
	genvar g;
   generate
   for(g = 0; g < 32; g=g+1) begin: write_loop2
	my_dff (.q(main_res_write[g]), .d(mem_value[g]), .clk(clock), .en(1'b1), .clr(reset));
   end
   endgenerate
	
	my_dff (.q(write_en_reg_write), .d(write_en_reg_mem), .clk(clock), .en(1'b1), .clr(reset));
	
	
	//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write//Write
	
	wire [31:0] main_res_write;
	wire [4:0] opcode_write, main_adr_write;
	wire write_en_reg_write;
	
	assign test_reg_write_en = {write_en_reg_write};
	assign test_opcode_write = {opcode_write};
	assign test_result_write = {main_res_write};
	assign test_address_write = {main_adr_write};
		
	assign ctrl_writeEnable = {write_en_reg_write};
	assign ctrl_readRegA = {ctrl_rd_rt};
	assign ctrl_readRegB = {ctrl_rs_rstatus};
	assign ctrl_writeReg = {main_adr_write};
	assign data_writeReg = {main_res_write};
	assign wire_rd_rt = {data_readRegA};
	assign wire_rs = {data_readRegB};
	
endmodule
