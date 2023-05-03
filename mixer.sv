module mixer(input clk, sample_clock, input [6:0] master_vol, reverb, input [23:0] sample_0, sample_1, sample_2, sample_3, output [23:0] mixed_sample);

	logic [23:0] added_sample, delay_k, delay_2k;
	
	assign added_sample = (((sample_0 >> 2) + (sample_1 >> 2) + (sample_2 >> 2) + (sample_3 >> 2)) * master_vol)/(128);	//add generated samples and scale by master_vol
	
	/* Circular buffer to store last 512 samples for reverb effect*/
	logic [23:0] buffer [512];
	always_ff @(posedge sample_clock) begin
		buffer[0] <= added_sample;
		for(int i = 0; i < 510; i++)
			buffer[i+1] <= buffer[i];
	end
	always_comb begin
			delay_k = buffer[reverb << 1];
			delay_2k = buffer[reverb << 2];
	end
	
	/* Implement reverb effect */
	always_comb begin
		if(reverb != 0) 
			mixed_sample = (added_sample + (delay_k >> 1) + (delay_2k >> 1)) >> 2;	//x[n] + 0.5x[n-k] + 0.5x[n-2k]
		else
			mixed_sample = added_sample;
	end
	

	
endmodule 