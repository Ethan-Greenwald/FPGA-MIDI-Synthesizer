/*
This module implements the I2S protocol.
Inputs are a master clock (50MHz)
and a 16-bit precicision sample.

This constructs the I2S waveform to communicate
mono audio. The data_in is copied to both L and R
channels.

#################
This will be wired to the SGTL5000 chip via 
top-level .SV file
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

/*
module I2S_interface #(parameter SAMPLE_SIZE=24)(
	input LRCLK, SCLK,
	input [SAMPLE_SIZE-1:0] data_in,
	output SDATA );
	 
	 logic [SAMPLE_SIZE-1:0] left, right;
	 
	 always_ff @(posedge SCLK) begin
		if(LRCLK) begin
			left <= data_in[SAMPLE_SIZE-1];
			SDATA <= right[SAMPLE_SIZE-1];
			right <= {right[SAMPLE_SIZE-2:0], 1'b0};
		end
		else begin
			right <= data_in;
			SDATA <= left[SAMPLE_SIZE-1];
			left <= {left[SAMPLE_SIZE-2:0], 1'b0};
		end
	 end
	
	
endmodule
*/