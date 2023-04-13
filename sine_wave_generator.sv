module sine_wave_generator( input clk, reset, input [22:0] period, input [6:0] volume, output[23:0] value);

	logic [23:0] local_val;
	logic [7:0] cycles_to_inc, count;
	logic [13:0] phase;
	
	assign value = (2 * local_val * volume)/'d127;
	assign cycles_to_inc = period/16384;

	full_sin_rom(.clock(clk), .address(phase), .q(local_val));
	
	always_ff @(posedge clk) begin
		if(reset) begin
			phase <= 0;
			count <= 0;
		end
		else begin
			if(count == cycles_to_inc) begin
				phase <= phase + 1;
				count <= 0;
			end
			else
				count <= count + 1;
		end
	end
endmodule

//
//module sine_ROM(input clk, input [10:0] phase, output [23:0] data);
//	logic [13:0] addr;
//	logic [23:0] rom_data;
//	sin_rom ROM(.address(addr), .clock(clk), .q(rom_data));
//	
//	always_comb begin
//		if(phase < 11025) begin
//			addr = phase;
//			data = rom_data;
//		end
//		else if(phase < 22050) begin
//			addr = 22050 - phase;
//			data = rom_data;
//		end
//		else if(phase < 33075) begin
//			addr = phase - 22050;
//			data = -rom_data;
//		end
//		else begin
//			addr = 44100 - phase;
//			data = -rom_data;
//		end
//	end
//	
//endmodule 