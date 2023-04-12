module sawtooth_wave_generator( input clk, reset, input [22:0] period, input [6:0] volume, output[23:0] value);
	
	logic [23:0] increment;
	
	//2*period -> octave too low. period -> octave too high
	assign increment = 'd33554431/period;//(max-min)/period = ((2^24 - 1) + (2^24))/period

	
	logic [23:0] local_val;
	assign value = (local_val * volume)/'d127;
	
	always_ff @(posedge clk) begin
		if(reset) begin
			local_val <= {1'b1, {23{1'b0}}};
		end
		else
			local_val <= local_val + increment;
	end
endmodule
