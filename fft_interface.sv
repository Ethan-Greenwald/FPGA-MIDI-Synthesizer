module fft_interface(input clk, input [23:0] sample, output hs, vs, output [7:0] Red, Green, Blue);

	
	logic sink_sop, sink_eop, sink_ready, source_valid, source_sop, source_eop;
	logic [1:0] source_error;
	logic [7:0] load_counter, buffer_counter;
	logic [23:0] source_real, source_imag, buffer_input;
	logic [8:0] fftpts_out;
	
	/* Handles start and end of packet signals going into FFT */
	always_ff @(posedge clk) begin
		load_counter <= load_counter + 1;
		if(load_counter == 8'd255)
			sink_eop <= 1;
		if(load_counter == 0) begin
			sink_eop <= 0;
			sink_sop <= 1;
		end
		if(load_counter == 8'b1)
			sink_sop <= 0;
			
	end
	
	
	logic [7:0] fft_buffer [256];
	always_ff @(posedge clk) begin
		if(source_sop)
			buffer_counter <= 0;
		else
			buffer_counter <= buffer_counter + 1;
		fft_buffer[buffer_counter] <= buffer_input;
	end
	
	logic [46:0] real_sq, imag_sq;
	always_comb begin
		real_sq = source_real * source_real;
		imag_sq = source_imag * source_imag;
		buffer_input = (real_sq + imag_sq) >> 40;
	end
	
	fft FFT(.clk(clk), .reset_n(1), .sink_valid(1), .sink_ready(sink_ready), .sink_error(2'b0), .sink_sop(sink_sop), .sink_eop(sink_eop), 
			  .sink_real(sample), .sink_imag(0), .fftpts_in({1'b1, {7{1'b0}}}), .inverse(0), .source_valid(source_valid), 
			  .source_ready(1), .source_error(source_error), .source_sop(source_sop), .source_eop(source_eop),
			  .source_real(source_real), .source_imag(source_imag), .fftpts_out(fftpts_out));
			  
	/*########## VGA STUFF ##########*/
	logic blank, sync, pixel_clk;
	logic [9:0] DrawX, DrawY;
	
	vga_controller VGA( .Clk(clk), .Reset(0), .hs(hs), .vs(vs), .pixel_clk(pixel_clk), .blank(blank), .sync(sync), .DrawX(DrawX), .DrawY(DrawY));

	always_ff @(posedge pixel_clk) begin
		if(blank) begin
			Red = 8'b0;
			Blue = 8'b0;
			Green = 8'b0;
		end
		else begin
			if(fft_buffer[DrawX >> 1] >= (480 - DrawY)) begin	//If current frequency is higher than current row, draw foreground
				Red   = 8'd232;
				Blue  = 8'd74;
				Green = 8'd39;
			end
			else begin
				Red = 8'd19;
				Blue = 8'd41;
				Green = 8'd75;
			end
		end
	end
												  
endmodule
