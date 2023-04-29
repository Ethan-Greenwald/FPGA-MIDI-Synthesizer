module note_table(input [6:0] MIDI_freq, output [23:0] period, output [3:0] note_name, octave, partial);

	logic [3:0] note;
	logic flat;
	
	assign octave = MIDI_freq/12 - 1;
	
	always_comb begin
		note = MIDI_freq % 12;
		unique case(note)
			'd0: 	begin note_name = 'hC; flat = 0; end
			'd1: 	begin note_name = 'hD; flat = 1; end
			'd2: 	begin note_name = 'hD; flat = 0; end
			'd3: 	begin note_name = 'hE; flat = 1; end
			'd4: 	begin note_name = 'hE; flat = 0; end
			'd5: 	begin note_name = 'hF; flat = 0; end
			'd6: 	begin note_name = 'h6; flat = 1; end
			'd7: 	begin note_name = 'h6; flat = 0; end
			'd8: 	begin note_name = 'hA; flat = 1; end
			'd9: 	begin note_name = 'hA; flat = 0; end
			'd10: begin note_name = 'hB; flat = 1; end
			'd11: begin note_name = 'hB; flat = 0; end
		endcase
		if(flat)
			partial = 'hB;
		else
			partial = 'h0;
	end
endmodule 