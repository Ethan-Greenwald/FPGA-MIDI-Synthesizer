module square_wave_generator( input clk, reset, input [22:0] period, input [6:0] volume, output[23:0] value);
	
	logic [23:0] counter;
	logic [23:0] init, local_val;
	assign init = period/2;
	assign value = (local_val*volume)/127;
	
	always_ff @(posedge clk) begin
		//on reset, counter goes to max value and output set to 0
		if(reset) begin
			counter <= init;
			local_val <= {1'b1, {23{1'b0}}};//{1'b1, {23{1'b0}}};
		end
		else begin
			if(counter == 0) begin	//reached end of 1/2 cycle --> flip output
				local_val <= ~local_val;
				counter <= init;
			end
			else								//count down otherwise
				counter <= counter - 1;
		end
	end
endmodule

