module mixer(input clk, sample_clock, input [6:0] master_vol, reverb, input [23:0] sample_0, sample_1, sample_2, sample_3, output [23:0] mixed_sample);

	logic [25:0] added_sample, delay_k, delay_2k;
	
	assign added_sample = ((sample_0 + sample_1 + sample_2 + sample_3) * master_vol)/128;
//	assign mixed_sample = added_sample >> 2;
	
	logic [25:0] buffer [512];
	always_ff @(posedge sample_clock) begin
		buffer[0] <= added_sample;
		for(int i = 0; i < 510; i++)
			buffer[i+1] <= buffer[i];
	end
	
	always_comb begin
		delay_k = buffer[reverb << 1];
		delay_2k = buffer[reverb << 2];
		mixed_sample = (added_sample + (delay_k << 2)/5 + (delay_2k >> 1)) >> 2;	//x[n] + 0.8x[n-k] + 0.5x[n-2k]
//		mixed_sample = delay_k >> 2;
	end
	

	
endmodule 