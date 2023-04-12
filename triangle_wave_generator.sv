`define get_frequency(freq) \
		440 * (1'b1 << ((freq - 69)/12))
module triangle_wave_generator( input clk, reset, input [6:0] MIDI_freq, volume, output[23:0] value);
	
	logic [23:0] counter;
	logic [23:0] init;
	logic [23:0] increment;
	logic updown; //1 -> up; 0 -> down;
	
	assign init = 25000000/`get_frequency(MIDI_freq); 	//period/2 [clock cycles]
	assign increment = 'd33554431/init;						//(max-min)/(period/2) = ((2^24 - 1) + (2^24))/init

	
	logic [23:0] local_val;
	assign value = (local_val * volume)/'d127;
	
	always_ff @(posedge clk) begin
		if(reset) begin
			counter <= init;
			local_val <= {1'b1, {23{1'b0}}};//;24'b100000000000000000000000
			updown <= 1;
		end
		else begin
			if(counter == 0) begin	//reached end of period -> reset to 0
				updown <= ~updown;	//flip direction of triangle wave
				counter <= init;
			end
			else begin								//count down otherwise
				counter <= counter - 1;
				local_val <= updown ? local_val + increment : local_val - increment;	//+ or - increment based on updown
			end
		end
	end
endmodule
