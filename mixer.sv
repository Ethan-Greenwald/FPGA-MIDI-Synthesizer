module mixer(input clk, input [6:0] master_vol, input [23:0] sample_0, sample_1, sample_2, sample_3, output [23:0] mixed_sample);

	logic [25:0] added_sample;
	
	assign added_sample = ((sample_0 + sample_1 + sample_2 + sample_3) * master_vol)/128;
	assign mixed_sample = added_sample >> 2;
//	assign mixed_sample = sample_0;

/*
	assign mixed_sample = (({ {2{sample_0[23]}}, sample_0[23:2] } 
								+ { {2{sample_1[23]}}, sample_1[23:2] } 
								+ { {2{sample_2[23]}}, sample_2[23:2] }
								+ { {2{sample_3[23]}}, sample_3[23:2] }) * master_vol)/128;
*/
	
endmodule 