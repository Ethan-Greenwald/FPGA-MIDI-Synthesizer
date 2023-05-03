module sine_wave_generator(input clk, reset, input [22:0] period, input [6:0] volume, output[23:0] value);

    logic [10:0] cycles_to_inc, count;
	 logic [23:0] local_val, phase_reg, inc_value;
    logic [12:0] phase;
	 
	 assign value = (local_val * volume)/128;
	 
//    assign cycles_to_inc = period/8192;// >> 12; // divide by 4096
	assign inc_value = (8192 << 11)/period;	//upper 13 is int, lower 11 is decimal

	 sine_rom ROM( .address(phase), .clock(clk), .q(local_val));

	 
    always_ff @(posedge clk) begin
        if(reset) begin
            phase_reg <= 0;
        end
        else begin
            phase_reg <= phase_reg + inc_value;
        end
    end
	 
	 assign phase = phase_reg[23:11];

endmodule
