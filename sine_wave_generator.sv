module sine_wave_generator( input clk, reset, input [22:0] period, input [6:0] volume, output[23:0] value);

	logic [23:0] local_val;
	logic [7:0] cycles_to_inc, count;
	logic [15:0] phase;
	
	assign value = (local_val * volume)/'d127;
//	assign phase_inc = 44100/period;
	assign cycles_to_inc = period/44100;
	
	sine_ROM ROM( .clk(clk), .phase(phase), .data(local_val));
	
	always_ff @(posedge clk) begin
		if(reset) begin
			phase <= 0;
			count <= 0;
		end
		else begin
			if(count == cycles_to_inc) begin
				phase <= (phase + 1) == 44100 ? 0 : phase + 1;//(phase + 1) % 44100;
				count <= 0;
			end
			else
				count <= count + 1;
		end
	end
endmodule


module sine_ROM(input clk, input [15:0] phase, output [23:0] data);

// need to modify quarter_sin.hex to meet .hex specifications in order to use ROM IP: https://www.intel.com/content/www/us/en/support/programmable/articles/000076770.html
// https://www.intel.com/content/www/us/en/programmable/quartushelp/17.0/reference/glossary/def_hexfile.htm
// or use .mif: https://www.intel.com/content/www/us/en/programmable/quartushelp/17.0/reference/glossary/def_mif.htm
	logic [13:0] addr;
	logic [23:0] rom_data;
	sin_rom ROM(.address(addr), .clock(clk), .q(rom_data));
	
	always_comb begin
		if(phase < 11025) begin
			addr = phase;
			data = rom_data;
		end
		else if(phase < 22050) begin
			addr = 22050 - phase;
			data = rom_data;
		end
		else if(phase < 33075) begin
			addr = phase - 22050;
			data = -rom_data;
		end
		else begin
			addr = 44100 - phase;
			data = -rom_data;
		end
	end
	
	
//	logic [23:0] ROM [11025];
//	initial $readmemh("quarter_sin.txt", ROM);
//	
//	
//	always_ff @ (posedge clk) begin
//		if(phase < 11025)						// 1st quadrant
//			data = ROM[phase];
//		else if(phase < 22050)				// 2nd quadrant
//			data = ROM[22050 - phase];
//		else if(phase < 33075)				// 3rd quadrant
//			data = -ROM[phase - 22050];
//		else										// 4th quadrant
//			data = -ROM[44100 - phase];
//	end
	
endmodule 