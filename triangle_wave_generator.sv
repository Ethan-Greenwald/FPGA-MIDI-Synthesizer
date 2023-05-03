module triangle_wave_generator( input clk, reset, input [22:0] period, input [6:0] volume, output[23:0] value);
	
	logic [23:0] counter, init, increment, local_val, cycles_to_inc;
	logic updown; //1 -> up; 0 -> down;
//	
//	assign init = period/2; 	//period/2 [clock cycles]
//	assign cycles_to_inc = init/'d33554431;//d33554431 = (max-min)/(period/2) = ((2^24 - 1) + (2^24))/init
//	
//	assign value = (local_val * volume)/128;
//	
//	always_ff @(posedge clk) begin
//		if(reset) begin
//			counter <= 0;
//			local_val <= {1'b1, {23{1'b0}}};//;24'b100000000000000000000000
//			updown <= 1;
//		end
//		else begin
//			if(counter == cycles_to_inc) begin					//if ready to increment...
//				counter <= 0;											//reset counter
//				if(updown) begin										//if going up...
//					if(local_val == {1'b0, {23{1'b1}}}) begin	//check if at top -> switch directions
//						updown <= 0;
//						local_val <= local_val - 1;
//					end
//					else													//otherwise increment
//						local_val <= local_val + 1;
//				end
//				else begin												//if going down
//					if(local_val == {1'b1, {23{1'b0}}}) begin	//check if at bottom -> switch directions
//						updown <= 1;
//						local_val <= local_val + 1;
//					end
//					else
//						local_val <= local_val - 1;				//otherwise decrement
//				end
//				
//			end
//			else															//increment counter if not at cycles_to_inc
//				counter <= counter + 1;
//		end
//	end
	
	assign init = period/2; 	//period/2 [clock cycles]
	assign increment = 'd33554431/init;//d33554431 = (max-min)/(period/2) = ((2^24 - 1) + (2^24))/init
	//inc = 590 for 440 Hz; init = 56,818
	//end value = 16,745,404 < 2^{24} - 1
	
	assign value = (local_val * volume)/128;
	
	always_ff @(posedge clk) begin
		if(reset) begin
			counter <= init;
			local_val <= {1'b1, {23{1'b0}}};//;24'b100000000000000000000000
			updown <= 1;
		end
		else begin
			if(counter == 0) begin	//reached end of period -> reset to 0
				updown <= ~updown;	//flip direction of triangle wave
				counter <= init;
			end
			else begin								//count down otherwise
				counter <= counter - 1;
				local_val <= updown ? local_val + increment : local_val - increment;	//+ or - increment based on updown
			end
		end
	end
endmodule
