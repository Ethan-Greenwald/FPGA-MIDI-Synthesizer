/*
This module implements the I2S protocol.
Inputs are a master clock (50MHz)
and a 24-bit precicision sample.

This constructs the I2S waveform to communicate
mono audio. The data_in is copied to both L and R
channels.

This is wired to the SGTL5000 chip in synthesizer.sv (top-level)

*/
module I2S_interface(
	input LRCLK, SCLK,
	input [23:0] data_in,
	output SDATA );
	 
	 logic [23:0] left, right;
	 
	 always_ff @(posedge SCLK) begin
		if(LRCLK) begin
			left <= data_in[23];
			SDATA <= right[23];
			right <= {right[22:0], 1'b0};
		end
		else begin
			right <= data_in;
			SDATA <= left[23];
			left <= {left[22:0], 1'b0};
		end
	 end
	
	
endmodule

module small_I2S_interface(
	input LRCLK, SCLK,
	input [17:0] data_in,
	output SDATA );
	 
	 logic [17:0] left, right;
	 
	 always_ff @(posedge SCLK) begin
		if(LRCLK) begin
			left <= data_in[17];
			SDATA <= right[17];
			right <= {right[16:0], 1'b0};
		end
		else begin
			right <= data_in;
			SDATA <= left[17];
			left <= {left[16:0], 1'b0};
		end
	 end
	
	
endmodule
