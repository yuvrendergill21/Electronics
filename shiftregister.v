//Implementing the shiftregister
module shiftregister(SW, LEDR, KEY);
	input [9:0] SW;
	input [3:0] KEY;
	output [9:0] LEDR;
	
	shifter8Bit shifter(
								.LoadVal(SW[7:0]),
								.reset_n(SW[9]),
								.Load_n(~KEY[1]),
								.ShiftRight(~KEY[2]),
								.ASR(~KEY[3]),
								.clk(~KEY[0]),
								.Q(LEDR[7:0])
								);
endmodule 
	
//===================================================================================
//Implementing the 8 bit shifter
module shifter8Bit(LoadVal, Load_n, ShiftRight, ASR, clk, reset_n, Q);
	input [7:0] LoadVal;
	input Load_n, ShiftRight, ASR, clk, reset_n;
	output [7:0] Q;
	wire asr_out;
	
	ASRcircuit asr1(.asr(ASR), .first(LoadVal[7]), .ASRout(asr_out));
	
	shifterBit s7(.load_val(LoadVal[7]), .in(asr_out), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(Q[7]));
	
	shifterBit s6(.load_val(LoadVal[6]), .in(Q[7]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(Q[6]));

	shifterBit s5(.load_val(LoadVal[5]), .in(Q[6]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(Q[5]));
	
	shifterBit s4(.load_val(LoadVal[4]), .in(Q[5]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(Q[4]));
	
	shifterBit s3(.load_val(LoadVal[3]), .in(Q[4]),.load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(Q[3]));
	
	shifterBit s2(.load_val(LoadVal[2]), .in(Q[3]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(Q[2]));
					
	shifterBit s1(.load_val(LoadVal[1]), .in(Q[2]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(Q[1]));
	
	shifterBit s0(.load_val(LoadVal[0]), .in(Q[1]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(Q[0]));

endmodule 

//==================================================================================
//Implementing ASR circuit
module ASRcircuit(asr, first, ASRout);
	input asr, first;
	output ASRout;
	reg ASRout;
	
	always @(*)
		
		begin
			if (asr == 1'b0)
				ASRout = 1'b0;
			else
				ASRout = first;
		end
endmodule

//===================================================================================
//Implementing single bit shifter
module shifterBit(load_val, in, shift, load_n, clk, reset_n, out);
	input load_val, in, shift, load_n, clk, reset_n;
	output out;
	wire mux1_to_mux2;
	wire mux2_to_flipflop;
	wire flipflop_to_mux1;
	assign out = flipflop_to_mux1;
	
	mux2to1 mux1(.x(in), .y(flipflop_to_mux1), .s(shift), .m(mux1_to_mux2));
	
	mux2to1 mux2(.x(mux1_to_mux2), .y(load_val), .s(load_n), .m(mux2_to_flipflop));
	
	flipflop flipflop1(.d(mux2_to_flipflop), .clock(clk), .reset_n(reset_n), .q(flipflop_to_mux1));
	
endmodule

//===============================================================================================
// Implementing flipflop

module flipflop(d, clock, reset_n, q);
		input d; // Data input fr the given register
		input clock; //Clock signal
		input reset_n; //to reset the register 
		output q; // output of the register. 
		
		reg q;
		
		always @(posedge clock)
		
		begin
			if (reset_n == 1'b0)
				q <= 0;
			else
				q <= d;
		end
endmodule 

//=======================================================================================================
//Implementing mux2to1

module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
    // OR
    // assign m = s ? y : x;
endmodule 