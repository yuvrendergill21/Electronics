//====================================================================================
// Top module to connect the modules to fpga board.

module more_decoder(SW, KEY, CLOCK_50 LEDR);
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	output [9:0]LEDR;
	
	connector c1(.character(SW[2:0]), .start(KEY[1]), .clock(CLOCK_50), .reset_n(KEY[0]), .Out(LEDR[0]));
	
endmodule


//=====================================================================================
// A connector circuit to bind all the modules together

module connector(character, start, clock, reset_n, Out);
	input [2:0] character;
	input start, clock, reset_n;
	output Out;
	wire enable;
	wire [13:0] lut_out;
	wire [27:0] counter_out;
	assign clock_shifter = (counter_out == 0 ? 1 : 0);
	wire shifter_out;
	assign Out = shifter_out
	
	//A counter that counts at the frequency of 0.5 seconds. 
	RDcounter counter(.d({1'b0, 27'd99999999}), .clock(clock), .reset_n(reset_n), .enable(enable), .q(counter_out));
	
	// A lookup table to get the required alphabet's binary codein the connector to put it in the shifter
	lookup_table lut(.select(character[2:0]), .Out(lut_out[13:0]));
	
	//A shifter which takes parallel load from lut and spills one bit at a time.
	shifter14Bit shifter(.LoadVal(lut_out), .load_n(start), .ShiftRight(1'b1), .ASR(1'b0), .clk(clock_shifter), .reset_n(reset_n), .Q(shifter_out));
endmodule

//=====================================================================================
//A lookup table to store different alphabetsand their binary pattern reperesentation.

module lookup_table(select, Out);
	input [1:0] select;
	output [13:0] Out;
	
	reg [13:0] Out;
	
	always @(*)
		begin
			case(select)
			3'b000: Out = 14'b00000000010101; //Binary pattern for S
			3'b001: Out = 14'b00000000000111; //Binary pattern for T
			3'b010: Out = 14'b00000001110101; //Binary pattern for U
			3'b011: Out = 14'b00000111010101; //Binary pattern for V
			3'b100: Out = 14'b00000111011101; //Binary pattern for W
			3'b101: Out = 14'b00011101010111; //Binary pattern for X
			3'b110: Out = 14'b01110111010111; //Binary pattern for Y
			3'b111: Out = 14'b00010101110111; //Binary pattern for Z
			endcase
		end
endmodule 


//======================================================================================
//A rate divider counter 

module RDcounter(load, clock, reset_n, enable, q);
	input [27:0] load;
	input clock;
	input reset_n;
	input enable;
	output [27:0] q;
	
	reg [27:0] q;
	
	always @(posedge clock)
	begin 
		if (reset_n == 1'b0) begin
			q <= 0;
		end
		else if (enable == 1'b1)
			begin
				if (q == 0)
					q <= load;
				else 
					q <= q - 1'b1;
			end
	end
endmodule 

//===========================================================================================================================================
//Implementing a shifter.

//===========================================================================================================================================
// ** Implementing the 14 bit shifter
module shifter14Bit(LoadVal, Load_n, ShiftRight, ASR, clk, reset_n, Q);
	input [13:0] LoadVal;
	input Load_n, ShiftRight, ASR, clk, reset_n;
	output Q;
	wire asr_out;
	wire [13:0] out;
	assign Q = out[0];
	
	ASRcircuit asr1(.asr(ASR), .first(LoadVal[13]), .ASRout(asr_out));
	
	shifterBit s13(.load_val(LoadVal[13]), .in(asr_out), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[13]));
	
	shifterBit s12(.load_val(LoadVal[12]), .in(out[13]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[12]));
	
	shifterBit s11(.load_val(LoadVal[11]), .in(out[12]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[11]));
	
	shifterBit s10(.load_val(LoadVal[10]), .in(out[11]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[10]));
	
	shifterBit s9(.load_val(LoadVal[9]), .in(out[10]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[9]));
	
	shifterBit s8(.load_val(LoadVal[8]), .in(out[9]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[8]));
	
	shifterBit s7(.load_val(LoadVal[7]), .in(out[8]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[7]));
	
	shifterBit s6(.load_val(LoadVal[6]), .in(out[7]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[6]));

	shifterBit s5(.load_val(LoadVal[5]), .in(out[6]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[5]));
	
	shifterBit s4(.load_val(LoadVal[4]), .in(out[5]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[4]));
	
	shifterBit s3(.load_val(LoadVal[3]), .in(out[4]),.load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[3]));
	
	shifterBit s2(.load_val(LoadVal[2]), .in(out[3]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[2]));
					
	shifterBit s1(.load_val(LoadVal[1]), .in(out[2]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[1]));
	
	shifterBit s0(.load_val(LoadVal[0]), .in(out[1]), .load_n(Load_n), .shift(ShiftRight), .clk(clk), .reset_n(reset_n), .out(out[0]));

endmodule 

//==================================================================================
// ** Implementing ASR circuit

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
// ** Implementing single bit shifter
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
// ** Implementing flipflop

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
// ** Implementing mux2to1

module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
    // OR
    // assign m = s ? y : x;
endmodule 

// End of Morse Decoder.
//=============================================================================================================xx