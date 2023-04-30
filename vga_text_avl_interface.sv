/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);


//put other local variables here
//port A is for AVL bus; port B is for local VGA read
logic [11:0] VRAM_ADDR;
logic [31:0] VRAM_WRITEDATA, VRAM_READDATA, read_data;

vram VRAM(.address_a(AVL_ADDR), .address_b(VRAM_ADDR), .byteena_a(AVL_BYTE_EN), .clock(CLK), .data_a(AVL_WRITEDATA), .data_b(VRAM_WRITEDATA), 
			.rden_a(AVL_CS & AVL_READ & ~AVL_ADDR[11]), .rden_b(1'b1), .wren_a(AVL_CS & AVL_WRITE & ~AVL_ADDR[11]), .wren_b(1'b0), .q_a(read_data), .q_b(VRAM_READDATA));

/* Local reg file for the color palette */
logic [31:0] color_palette [8];

always_ff @(posedge CLK) begin
	if(AVL_WRITE & AVL_ADDR[11])
		color_palette[AVL_ADDR - 'h800] <= AVL_WRITEDATA;
		
		
	if(AVL_READ & (AVL_ADDR[11] == 0))
		AVL_READDATA  <= read_data;
	else
		AVL_READDATA <= color_palette[AVL_ADDR - 'h800];
end			
			
			
//Declare submodules..e.g. VGA controller, ROMS, etc
logic pixel_clk, blank, sync;
logic [9:0] DrawX, DrawY;
vga_controller da_vga_controller( .Clk(CLK), .Reset(RESET), .hs(hs), .vs(vs), .pixel_clk(pixel_clk), .blank(blank), .sync(sync), .DrawX(DrawX), .DrawY(DrawY));

logic [10:0] FONT_ADDR;
logic [7:0] FONT_DATA;
logic value;
font_rom da_font_rom( .addr(FONT_ADDR), .data(FONT_DATA));


//handle drawing (may either be combinational or sequential - or both).
logic [2:0] CharX;
logic [3:0] CharY;
logic [6:0] GridX;
logic [4:0] GridY;
logic [6:0] character;
logic [3:0] bkg_idx, fgd_idx;
logic [11:0] bkg_color, fgd_color;
logic invert;

always_comb
begin
	CharX = DrawX[2:0];
	CharY = DrawY[3:0];	//get specific pixel within glyph
	GridX = DrawX >> 3;	
	GridY = DrawY >> 4;	//gets the specific row and column in the VGA grid
	VRAM_ADDR = (GridY * 40)+ (GridX>>1); //word = (row * words_per_row) + (column / columns_per_word)
end
	
always_comb begin
	//extract invert flag and character keycode from read word (VGA_READDATA)
	unique case (GridX[0])
		'h0: 	begin 
					invert = 	VRAM_READDATA[15];
					character = VRAM_READDATA[14:8];
					bkg_idx =   VRAM_READDATA[3:0];
					fgd_idx =   VRAM_READDATA[7:4];
				end
				
		'h1: 	begin 
					invert = 	VRAM_READDATA[31];
					character = VRAM_READDATA[30:24];
					bkg_idx =   VRAM_READDATA[19:16];
					fgd_idx =   VRAM_READDATA[23:20];
				end
	endcase
end



always_comb begin
	FONT_ADDR = (character << 4) + CharY;
	value = FONT_DATA[-CharX]^invert;
	if(bkg_idx[0] == 0)
		bkg_color = color_palette[bkg_idx >> 1][12:1];
	else
		bkg_color = color_palette[bkg_idx >> 1][24:13];
	
	if(fgd_idx[0] == 0)
		fgd_color = color_palette[fgd_idx >> 1][12:1];
	else
		fgd_color = color_palette[fgd_idx >> 1][24:13];
end

always_ff @(posedge pixel_clk)
begin
	
	if (blank == 0) begin
		red = 4'h0;
		green = 4'h0;
		blue = 4'h0;
	end
	else begin
		unique case(value)
		//Background
		'h0: begin 
			  red =   bkg_color[11:8];
			  green = bkg_color[7:4];
			  blue =  bkg_color[3:0];
			  end
			  
		//Foreground
		'h1: begin 
			  red =   fgd_color[11:8];
			  green = fgd_color[7:4];
			  blue =  fgd_color[3:0];
			  end
		endcase
	end
end


endmodule
