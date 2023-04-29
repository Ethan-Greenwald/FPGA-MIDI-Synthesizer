module mixer(input clk, sample_clk, input [6:0] master_vol, input [7:0] reverb_strength, input [23:0] sample_0, sample_1, sample_2, sample_3, output [23:0] mixed_sample);

//	logic [25:0] added_sample;
	
	assign mixed_sample = ((sample_0 + sample_1 + sample_2 + sample_3) * master_vol) >> 11;///128;
//	assign mixed_sample = added_sample >> 2;

	logic[23:0] delay_k, delay_2k;
	logic [23:0] buffer [512];
	logic [8:0] index;
	always_ff @(posedge sample_clk) begin
		for(int i = 0; i < 510; i++)	//shift buffer
			buffer[i+1] <= buffer[i];
	end
	
	assign delay_k = buffer[reverb_strength];
	assign delay_2k = buffer[reverb_strength << 1];
	
	
endmodule 