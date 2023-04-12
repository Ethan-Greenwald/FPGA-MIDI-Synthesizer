`define get_frequency(freq) \
		440 * (1'b1 << ((freq - 69)/12))
module sine_wave_generator( input clk, reset, input [6:0] MIDI_freq, volume, output[23:0] value);

	logic [23:0] local_val;
	assign value = local_val << 4;//(local_val * volume)/'d127;
	
	logic [23:0] period, phase_inc;
	
	logic [15:0] phase;
	
	assign period = 50000000/`get_frequency(MIDI_freq);	//period [clock cycles]
	assign phase_inc = 44100/period;
	
	sine_ROM ROM( .clk(clk), .phase(phase), .data(local_val));
	
	always_ff @(posedge clk) begin
		//on reset, counter goes to max value and output set to 0
		if(reset) begin
			phase <= 0;
		end
		else begin
			if(phase > 44100)
				phase <= phase + phase_inc - 44100;
			else
				phase <= phase + phase_inc;
		end
	end
endmodule


module sine_ROM(input clk, input [15:0] phase, output [23:0] data);

// need to modify quarter_sin.hex to meet .hex specifications in order to use ROM IP: https://www.intel.com/content/www/us/en/support/programmable/articles/000076770.html
// https://www.intel.com/content/www/us/en/programmable/quartushelp/17.0/reference/glossary/def_hexfile.htm
// or use .mif: https://www.intel.com/content/www/us/en/programmable/quartushelp/17.0/reference/glossary/def_mif.htm
//	logic [13:0] addr;
//	logic [23:0] rom_data;
//	rom ROM(.address(addr), .clock(clk), .q(rom_data));
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
	
	
	logic [23:0] ROM [11025];
	initial $readmemh("quarter_sin.hex", ROM);
	
	
	always_ff @ (posedge clk) begin
		if(phase < 11025)						// 1st quadrant
			data = ROM[phase];
		else if(phase < 22050)				// 2nd quadrant
			data = ROM[22050 - phase];
		else if(phase < 33075)				// 3rd quadrant
			data = -ROM[phase - 22050];
		else										// 4th quadrant
			data = -ROM[44100 - phase];
	end
	
endmodule 