`define get_frequency(freq) \
		440 * (1'b1 << ((freq - 69)/12))
module sawtooth_wave_generator( input clk, reset, input [6:0] MIDI_freq, volume, output[23:0] value);
	
	logic [23:0] counter;
	logic [23:0] init;
	logic [23:0] increment;
	assign init = 50000000/`get_frequency(MIDI_freq); //period [clock cycles]
	assign increment = 'd33554431/init;//(max-min)/period = ((2^24 - 1) + (2^24))/period
	
	/*
	need to get increment value; increment every X clock cycles and go back to min value if counter reaches 0
	*/
	
	logic [23:0] local_val;
	assign value = (local_val * volume)/'d127;
	
	always_ff @(posedge clk) begin
		//on reset, counter goes to max value and output set to 0
		if(reset) begin
			counter <= init;
			local_val <= 24'b100000000000000000000000;//{1'b0, 23{1'b1}};
		end
		else begin
			if(counter == 0) begin	//reached end of period -> reset to 0
				local_val <= 24'b100000000000000000000000;
				counter <= init;
			end
			else begin								//count down otherwise
				counter <= counter - 1;
				local_val <= local_val + increment;
			end
		end
	end
endmodule
