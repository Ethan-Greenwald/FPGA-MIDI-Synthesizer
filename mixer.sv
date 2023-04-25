module mixer(input clk, input [6:0] master_vol, input [7:0] reverb_strength, input [23:0] sample_0, sample_1, sample_2, sample_3, output [23:0] mixed_sample);

//	logic [25:0] added_sample;
	
	assign mixed_sample = ((sample_0 + sample_1 + sample_2 + sample_3) * master_vol) >> 11;///128;
//	assign mixed_sample = added_sample >> 2;
	
	
endmodule 