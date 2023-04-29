module sine_wave_generator(input clk, reset, input [22:0] period, input [6:0] volume, output[23:0] value);

    logic [10:0] cycles_to_inc, count;
	 logic [23:0] local_val;
    logic [11:0] phase;
	 
	 assign value = local_val;//(local_val * volume) >> 7;
	 
    assign cycles_to_inc = period/16384;// >> 12; // divide by 4096

	 sine_rom ROM( .address(phase), .clock(clk), .q(local_val));

	 
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
