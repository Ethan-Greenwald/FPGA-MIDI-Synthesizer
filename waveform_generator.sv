module waveform_generator( input clk, reset, input [1:0] wave_select, input [7:0] vibrato, input [15:0] note_vol, output [23:0] sample);

	logic [23:0] sq_wv_value, saw_wv_value, tri_wv_value, sine_wv_value;
	
	logic [22:0] MIDI_ROM [128];
	logic [22:0] period;
	
	initial $readmemh("MIDI_freq_to_period.txt", MIDI_ROM);
	assign period = MIDI_ROM[note_vol[14:8]] + ((vibrato -64)* 6000 >> 7);
	
	sawtooth_wave_generator saw_wv(  .clk, .reset, .period, .volume(note_vol[7:0]), .value(saw_wv_value));
	square_wave_generator 	sq_wv (  .clk, .reset, .period, .volume(note_vol[7:0]), .value(sq_wv_value));
	triangle_wave_generator tri_wv(  .clk, .reset, .period, .volume(note_vol[7:0]), .value(tri_wv_value));	
//	sine_wave_generator 		sine_wv( .clk, .reset, .period, .volume(note_vol[7:0]), .value(sine_wv_value));
	
	
	always_comb begin
		case(wave_select)
			2'b00: 	sample = sq_wv_value;
			2'b01: 	sample = saw_wv_value;
			2'b10: 	sample = tri_wv_value;
//			2'b11:	sample = sine_wv_value;
			default:	sample = sq_wv_value;
		endcase
	end
	
endmodule 