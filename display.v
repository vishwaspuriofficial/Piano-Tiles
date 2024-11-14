`define RESOLUTION_WIDTH 160 // Width of the screen
`define RESOLUTION_HEIGHT 120 // Height of the screen
`define COLUMN_WIDTH ((`RESOLUTION_WIDTH - 3 * `BORDER_WIDTH) / 4)  
`define COLUMN_HEIGHT (`RESOLUTION_HEIGHT / 3)     // Height of each row 
`define BORDER_WIDTH 1       // Width of each border line

//DESIM
// module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR);
//BOARD
module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR, VGA_R, VGA_G, VGA_B,
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	
	// Initialize starting tile positions and VGA/draw states
	input CLOCK_50;	
	input [7:0] SW;
	input [3:0] KEY;
	output reg [7:0] VGA_X;                     // for DESim VGA
	output reg [6:0] VGA_Y;                     // for DESim VGA
	output reg [2:0] VGA_COLOR;                 // for DESim VGA
	output reg plot;                            // for DESim VGA
	output [9:0] LEDR;

	//BOARD
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK; 

	parameter XSIZE = 8'd34, YSIZE = 7'd20;
	
	// This is the blueprint for 1 tile falling down (on loop for all 4 columns)
	// Different flags to indicate which display stage the tile is at
	reg drawEnable;
	reg continueDraw;
	reg eraseEnable;
	reg continueErase;
	
	reg continueDrawTop;
	reg continueEraseBottom;
	
	reg [6:0] drawTop;
	reg [6:0] eraseBottom;
	
	reg [7:0] xStart;
	reg [6:0] yStart;
	
	reg [7:0] xCount;
	reg [6:0] yCount;
	
	reg finished1;
	
	// Second tile
	reg drawEnable2;
	reg continueDraw2;
	reg eraseEnable2;
	reg continueErase2;
	
	reg continueDrawTop2;
	reg continueEraseBottom2;
	
	reg [6:0] drawTop2;
	reg [6:0] eraseBottom2;
	
	reg [7:0] xStart2;
	reg [6:0] yStart2;
	
	reg [7:0] xCount2;
	reg [6:0] yCount2;
	
	reg finished2;
	
	// Third tile
	reg drawEnable3;
	reg continueDraw3;
	reg eraseEnable3;
	reg continueErase3;
	
	reg continueDrawTop3;
	reg continueEraseBottom3;
	
	reg [6:0] drawTop3;
	reg [6:0] eraseBottom3;
	
	reg [7:0] xStart3;
	reg [6:0] yStart3;
	
	reg [7:0] xCount3;
	reg [6:0] yCount3;
	
	reg finished3;
	
	// Fourth tile
	reg drawEnable4;
	reg continueDraw4;
	reg eraseEnable4;
	reg continueErase4;
	
	reg continueDrawTop4;
	reg continueEraseBottom4;
	
	reg [6:0] drawTop4;
	reg [6:0] eraseBottom4;
	
	reg [7:0] xStart4;
	reg [6:0] yStart4;
	
	reg [7:0] xCount4;
	reg [6:0] yCount4;
	
	reg finished4;

	//Screen Control + Draw
	reg gameOn;
	reg enableBackground;
	reg [7:0] x_count = 0;
    reg [6:0] y_count = 0;
	
	initial
	begin
		gameOn <= SW[0];
		enableBackground <= 0;

		xStart <= 8'd4;
		yStart <= 7'd0;
		drawTop <= 0;
		eraseBottom <= 0;
		drawEnable <= 1;
		
		xStart2 <= 8'd43;
		yStart2 <= 7'd0;
		drawTop2 <= 0;
		eraseBottom2 <= 0;
		drawEnable2 <= 1;
		
		xStart3 <= 8'd82;
		yStart3 <= 7'd0;
		drawTop3 <= 0;
		eraseBottom3 <= 0;
		drawEnable3 <= 1;
		
		xStart4 <= 8'd121;
		yStart4 <= 7'd0;
		drawTop4 <= 0;
		eraseBottom4 <= 0;
		drawEnable4 <= 1;

//      finished1 <= 1;
//      finished2 <= 1;
//      finished3 <= 1;
//      finished4 <= 1;
	end
	
	// Updates for tile movement
	reg [21:0] fast_count;
	//DESIM
	// assign tileShiftEnable = fast_count == 22'd4000; 

	//BOARD
	assign tileShiftEnable = fast_count == 22'd416666; 
	// 22'd2500000 corresponds to roughly 20px/second
	// 22'd416666 corresponds to roughly 120px/second

	//BOARD
	   vga_adapter VGA (
       .resetn(KEY[0]),
       .clock(CLOCK_50),
       .colour(VGA_COLOR),
       .x(VGA_X),
       .y(VGA_Y),
       .plot(plot),
       .VGA_R(VGA_R),
       .VGA_G(VGA_G),
       .VGA_B(VGA_B),
       .VGA_HS(VGA_HS),
       .VGA_VS(VGA_VS),
       .VGA_BLANK_N(VGA_BLANK_N),
       .VGA_SYNC_N(VGA_SYNC_N),
       .VGA_CLK(VGA_CLK));
       defparam VGA.RESOLUTION = "160x120";
       defparam VGA.MONOCHROME = "FALSE";
       defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
       defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
	
	always@ (posedge CLOCK_50)
	begin
		if (gameOn)
		// begin
		// 	enableBackground <= 1;
		// end

		// if (gameOn &) 
		// begin

		// 	// //Code for White Background + Border Lines
		// 	// // Determine if the current pixel is on a black vertical line
		// 	// if ( 
		// 	// 	(x_count >= `COLUMN_WIDTH + 1              && x_count < `COLUMN_WIDTH + `BORDER_WIDTH + 1) || 
		// 	// 	(x_count >= 2*`COLUMN_WIDTH + `BORDER_WIDTH + 1 && x_count < 2*`COLUMN_WIDTH + 2*`BORDER_WIDTH + 1) ||
		// 	// 	(x_count >= 3*`COLUMN_WIDTH + 2*`BORDER_WIDTH + 1 && x_count < 3*`COLUMN_WIDTH + 3*`BORDER_WIDTH + 1)
		// 	// ) begin
		// 	// 	VGA_COLOR <= 3'b010; // Green for the vertical lines
		// 	// end else begin
		// 	// 	VGA_COLOR <= 3'b000; // RED for the rest of the screen
		// 	// end

		// 	// // Increment x_count for each pixel
		// 	// x_count <= x_count + 1;

		// 	// // Checks for right edge
		// 	// if (x_count == `RESOLUTION_WIDTH -1) begin 
		// 	// 	x_count <= 0;
		// 	// 	y_count <= y_count + 1;
		// 	// end

		// 	// // Checks for bottom edge (Corrected line)
		// 	// if (y_count == `RESOLUTION_HEIGHT) begin
		// 	// 	y_count <= 0;
		// 	// end

		// 	// // Assign the counters to VGA_X and VGA_Y
		// 	// VGA_X <= x_count;
		// 	// VGA_Y <= y_count;
		// end
		
		// fast_count updates
		if (tileShiftEnable)
		begin
			fast_count <= 22'd1;
			
			// First tile
			if (eraseBottom < 121 & yStart < 120 - YSIZE)
			begin
				eraseBottom <= yStart;
			end
			else
			begin
				if (eraseBottom < 121)
				begin
					eraseBottom <= eraseBottom + 1;
					continueEraseBottom <= 1;
					finished1 <= 0;
					
					if (eraseBottom == 120) // Puts the animation on loop
					begin
						if (xStart == 8'd4)
							xStart <= 8'd43;
						else if (xStart == 8'd43)
							xStart <= 8'd82;
						else if (xStart == 8'd82)
							xStart <= 8'd121;
						else
							xStart <= 8'd4;
						yStart <= 7'd0;
						drawTop <= 0;
						eraseBottom <= 0;
						drawEnable <= 1;
					end
				end
			end
			
			if (drawTop < YSIZE - 2)
			begin
				finished1 <= 0;
				drawTop <= drawTop + 1;
				continueDrawTop <= 1;
			end
			else if (yStart < 120 - YSIZE)
			begin
				finished1 <= 0;
				eraseEnable <= 1;
			end
			
			// Second tile
			if (eraseBottom2 < 121 & yStart2 < 120 - YSIZE)
			begin
				eraseBottom2 <= yStart2;
			end
			else
			begin
				if (eraseBottom2 < 121)
				begin
					eraseBottom2 <= eraseBottom2 + 1;
					continueEraseBottom2 <= 1;
					finished2 <= 0;
					
					if (eraseBottom2 == 120) // Puts the animation on loop
					begin
						if (xStart2 == 8'd4)
							xStart2 <= 8'd43;
						else if (xStart2 == 8'd43)
							xStart2 <= 8'd82;
						else if (xStart2 == 8'd82)
							xStart2 <= 8'd121;
						else
							xStart2 <= 8'd4;
						yStart2 <= 7'd0;
						drawTop2 <= 0;
						eraseBottom2 <= 0;
						drawEnable2 <= 1;
					end
				end
			end
			
			if (drawTop2 < YSIZE - 2)
			begin
				finished2 <= 0;
				drawTop2 <= drawTop2 + 1;
				continueDrawTop2 <= 1;
			end
			else if (yStart2 < 120 - YSIZE)
			begin
				finished2 <= 0;
				eraseEnable2 <= 1;
			end
			
			// Third tile
			if (eraseBottom3 < 121 & yStart3 < 120 - YSIZE)
			begin
				eraseBottom3 <= yStart3;
			end
			else
			begin
				if (eraseBottom3 < 121)
				begin
					eraseBottom3 <= eraseBottom3 + 1;
					continueEraseBottom3 <= 1;
					finished3 <= 0;
					
					if (eraseBottom3 == 120) // Puts the animation on loop
					begin
						if (xStart3 == 8'd4)
							xStart3 <= 8'd43;
						else if (xStart3 == 8'd43)
							xStart3 <= 8'd82;
						else if (xStart3 == 8'd82)
							xStart3 <= 8'd121;
						else
							xStart3 <= 8'd4;
						yStart3 <= 7'd0;
						drawTop3 <= 0;
						eraseBottom3 <= 0;
						drawEnable3 <= 1;
					end
				end
			end
			
			if (drawTop3 < YSIZE - 2)
			begin
				finished3 <= 0;
				drawTop3 <= drawTop3 + 1;
				continueDrawTop3 <= 1;
			end
			else if (yStart3 < 120 - YSIZE)
			begin
				finished3 <= 0;
				eraseEnable3 <= 1;
			end
			
			// Fourth tile
			if (eraseBottom4 < 121 & yStart4 < 120 - YSIZE)
			begin
				eraseBottom4 <= yStart4;
			end
			else
			begin
				if (eraseBottom4 < 121)
				begin
					eraseBottom4 <= eraseBottom4 + 1;
					continueEraseBottom4 <= 1;
					finished4 <= 0;
					
					if (eraseBottom4 == 120) // Puts the animation on loop
					begin
						if (xStart4 == 8'd4)
							xStart4 <= 8'd43;
						else if (xStart4 == 8'd43)
							xStart4 <= 8'd82;
						else if (xStart4 == 8'd82)
							xStart4 <= 8'd121;
						else
							xStart4 <= 8'd4;
						yStart4 <= 7'd0;
						drawTop4 <= 0;
						eraseBottom4 <= 0;
						drawEnable4 <= 1;
					end
				end
			end
			
			if (drawTop4 < YSIZE - 2)
			begin
				finished4 <= 0;
				drawTop4 <= drawTop4 + 1;
				continueDrawTop4 <= 1;
			end
			else if (yStart4 < 120 - YSIZE)
			begin
				finished4 <= 0;
				eraseEnable4 <= 1;
			end
			
		end
		else
		begin
			fast_count <= fast_count + 22'd1;
		end
		
		// Draw a black tile ontop of the old white tile
		// First tile
		if (eraseEnable)
		begin
			if (yStart < 120 - YSIZE)
			begin
				xCount <= xStart;
				yCount <= yStart;
				plot <= 0;
				continueErase <= 1;
				eraseEnable <= 0;
				VGA_COLOR <= 3'b000;
			end
			fast_count <= 22'd1; // No updates for fast_count
		end
		
		else if (continueErase) // Erases top of tile
		begin
			VGA_X <= xCount;
			VGA_Y <= yCount;
			VGA_COLOR <= 3'b000;
			plot <= 1;
			
			xCount <= xCount + 1;
			
			if ((xCount - xStart) == XSIZE)
			begin
				continueErase <= 0;
				
				if (yCount < 120)
				begin
					yStart <= yStart + 1;
					drawEnable <= 1;
				end
			end
		end
		
		else if (continueEraseBottom) // Erases tile from top to bottom, one row at a time
		begin
		
			VGA_X <= xCount;
			VGA_Y <= eraseBottom;
			VGA_COLOR <= 3'b000;
			if (eraseBottom < 121)
				plot <= 1;
			else
				plot <= 0;
			
			xCount <= xCount + 1;
			
			if (xCount - xStart == XSIZE)
			begin
				continueEraseBottom <= 0;
				finished1 <= 1;
				xCount <= xStart;
			end
		end
		
		// Tile drawings
		if (drawEnable) // Enables the draw top flag to create illusion of tile going on the screen
		begin
			xCount <= xStart;
			yCount <= yStart;
			plot <= 0;
			drawEnable <= 0;
			VGA_COLOR <= 3'b111;
			continueDrawTop <= 1;
			
			fast_count <= 22'd1;
		end
		
		else if (continueDrawTop)
		begin
			VGA_X <= xCount;
			VGA_Y <= drawTop;
			VGA_COLOR <= 3'b111;
			if (drawTop < YSIZE - 2)
				plot <= 1;
			else
				plot <= 0;
			
			xCount <= xCount + 1;
			
			if (drawTop == (YSIZE - 2))
			begin
				continueDrawTop <= 0;
				continueDraw <= 1;
				xCount <= xStart;
			end
			
			else if (xCount - xStart == XSIZE)
			begin
				continueDrawTop <= 0;
				finished1 <= 1;
				xCount <= xStart;
			end
		end
		
		else if (continueDraw) 
		begin
			VGA_X <= xCount;
			VGA_Y <= yCount + YSIZE - 2;
			VGA_COLOR <= 3'b111;
			plot <= 1;
			
			xCount <= xCount + 1;
			
			if ((xCount - xStart) == XSIZE)
			begin
				continueDraw <= 0;
				finished1 <= 1;
			end
			
		end
		
		// Second tile
		if (eraseEnable2 & finished1)
		begin
			if (yStart2 < 120 - YSIZE)
			begin
				xCount2 <= xStart2;
				yCount2 <= yStart2;
				plot <= 0;
				continueErase2 <= 1;
				eraseEnable2 <= 0;
				VGA_COLOR <= 3'b000;
			end
			fast_count <= 22'd1; // No updates for fast_count
		end
		
		else if (continueErase2 & finished1) // Erases top of tile
		begin
			VGA_X <= xCount2;
			VGA_Y <= yCount2;
			VGA_COLOR <= 3'b000;
			plot <= 1;
			
			xCount2 <= xCount2 + 1;
			
			if ((xCount2 - xStart2) == XSIZE)
			begin
				continueErase2 <= 0;
				
				if (yCount2 < 120)
				begin
					yStart2 <= yStart2 + 1;
					drawEnable2 <= 1;
				end
			end
		end
		
		else if (continueEraseBottom2 & finished1) // Erases tile from top to bottom, one row at a time
		begin
		
			VGA_X <= xCount2;
			VGA_Y <= eraseBottom2;
			VGA_COLOR <= 3'b000;
			if (eraseBottom2 < 121)
				plot <= 1;
			else
				plot <= 0;
			
			xCount2 <= xCount2 + 1;
			
			if (xCount2 - xStart2 == XSIZE)
			begin
				continueEraseBottom2 <= 0;
				finished2 <= 1;
				xCount2 <= xStart2;
			end
		end
		
		// Tile drawings
		if (drawEnable2 & finished1) // Enables the draw top flag to create illusion of tile going on the screen
		begin
			xCount2 <= xStart2;
			yCount2 <= yStart2;
			plot <= 0;
			drawEnable2 <= 0;
			VGA_COLOR <= 3'b111;
			continueDrawTop2 <= 1;
			
			fast_count <= 22'd1;
		end
		
		else if (continueDrawTop2 & finished1)
		begin
			VGA_X <= xCount2;
			VGA_Y <= drawTop2;
			VGA_COLOR <= 3'b111;
			if (drawTop2 < YSIZE - 2)
				plot <= 1;
			else
				plot <= 0;
			
			xCount2 <= xCount2 + 1;
			
			if (drawTop2 == (YSIZE - 2))
			begin
				continueDrawTop2 <= 0;
				continueDraw2 <= 1;
				xCount2 <= xStart2;
			end
			
			else if (xCount2 - xStart2 == XSIZE)
			begin
				continueDrawTop2 <= 0;
				finished2 <= 1;
				xCount2 <= xStart2;
			end
		end
		
		else if (continueDraw2 & finished1) 
		begin
			VGA_X <= xCount2;
			VGA_Y <= yCount2 + YSIZE - 2;
			VGA_COLOR <= 3'b111;
			plot <= 1;
			
			xCount2 <= xCount2 + 1;
			
			if ((xCount2 - xStart2) == XSIZE)
			begin
				continueDraw2 <= 0;
				finished2 <= 1;
			end
		end
		
		// Third tile
		if (eraseEnable3 & finished2 & finished1)
		begin
			if (yStart3 < 120 - YSIZE)
			begin
				xCount3 <= xStart3;
				yCount3 <= yStart3;
				plot <= 0;
				continueErase3 <= 1;
				eraseEnable3 <= 0;
				VGA_COLOR <= 3'b000;
			end
			fast_count <= 22'd1; // No updates for fast_count
		end
		
		else if (continueErase3 & finished2 & finished1) // Erases top of tile
		begin
			VGA_X <= xCount3;
			VGA_Y <= yCount3;
			VGA_COLOR <= 3'b000;
			plot <= 1;
			
			xCount3 <= xCount3 + 1;
			
			if ((xCount3 - xStart3) == XSIZE)
			begin
				continueErase3 <= 0;
				
				if (yCount3 < 120)
				begin
					yStart3 <= yStart3 + 1;
					drawEnable3 <= 1;
				end
			end
		end
		
		else if (continueEraseBottom3 & finished2 & finished1) // Erases tile from top to bottom, one row at a time
		begin
		
			VGA_X <= xCount3;
			VGA_Y <= eraseBottom3;
			VGA_COLOR <= 3'b000;
			if (eraseBottom3 < 121)
				plot <= 1;
			else
				plot <= 0;
			
			xCount3 <= xCount3 + 1;
			
			if (xCount3 - xStart3 == XSIZE)
			begin
				continueEraseBottom3 <= 0;
				finished3 <= 1;
				xCount3 <= xStart3;
			end
		end
		
		// Tile drawings
		if (drawEnable3 & finished2 & finished1) // Enables the draw top flag to create illusion of tile going on the screen
		begin
			xCount3 <= xStart3;
			yCount3 <= yStart3;
			plot <= 0;
			drawEnable3 <= 0;
			VGA_COLOR <= 3'b111;
			continueDrawTop3 <= 1;
			
			fast_count <= 22'd1;
		end
		
		else if (continueDrawTop3 & finished2 & finished1)
		begin
			VGA_X <= xCount3;
			VGA_Y <= drawTop3;
			VGA_COLOR <= 3'b111;
			if (drawTop3 < YSIZE - 2)
				plot <= 1;
			else
				plot <= 0;
			
			xCount3 <= xCount3 + 1;
			
			if (drawTop3 == (YSIZE - 2))
			begin
				continueDrawTop3 <= 0;
				continueDraw3 <= 1;
				xCount3 <= xStart3;
			end
			
			else if (xCount3 - xStart3 == XSIZE)
			begin
				continueDrawTop3 <= 0;
				finished3 <= 1;
				xCount3 <= xStart3;
			end
		end
		
		else if (continueDraw3 & finished2 & finished1) 
		begin
			VGA_X <= xCount3;
			VGA_Y <= yCount3 + YSIZE - 2;
			VGA_COLOR <= 3'b111;
			plot <= 1;
			
			xCount3 <= xCount3 + 1;
			
			if ((xCount3 - xStart3) == XSIZE)
			begin
				continueDraw3 <= 0;
				finished3 <= 1;
			end
		end
		
		// Fourth tile
		if (eraseEnable4 & finished3 & finished2 & finished1)
		begin
			if (yStart4 < 120 - YSIZE)
			begin
				xCount4 <= xStart4;
				yCount4 <= yStart4;
				plot <= 0;
				continueErase4 <= 1;
				eraseEnable4 <= 0;
				VGA_COLOR <= 3'b000;
			end
			fast_count <= 22'd1; // No updates for fast_count
		end
		
		else if (continueErase4 & finished3 & finished2 & finished1) // Erases top of tile
		begin
			VGA_X <= xCount4;
			VGA_Y <= yCount4;
			VGA_COLOR <= 3'b000;
			plot <= 1;
			
			xCount4 <= xCount4 + 1;
			
			if ((xCount4 - xStart4) == XSIZE)
			begin
				continueErase4 <= 0;
				
				if (yCount4 < 120)
				begin
					yStart4 <= yStart4 + 1;
					drawEnable4 <= 1;
				end
			end
		end
		
		else if (continueEraseBottom4 & finished3 & finished2 & finished1) // Erases tile from top to bottom, one row at a time
		begin
		
			VGA_X <= xCount4;
			VGA_Y <= eraseBottom4;
			VGA_COLOR <= 3'b000;
			if (eraseBottom4 < 121)
				plot <= 1;
			else
				plot <= 0;
			
			xCount4 <= xCount4 + 1;
			
			if (xCount4 - xStart4 == XSIZE)
			begin
				continueEraseBottom4 <= 0;
				finished4 <= 1;
				xCount4 <= xStart4;
			end
		end
		
		// Tile drawings
		if (drawEnable4 & finished3 & finished2 & finished1) // Enables the draw top flag to create illusion of tile going on the screen
		begin
			xCount4 <= xStart4;
			yCount4 <= yStart4;
			plot <= 0;
			drawEnable4 <= 0;
			VGA_COLOR <= 3'b111;
			continueDrawTop4 <= 1;
			
			fast_count <= 22'd1;
		end
		
		else if (continueDrawTop4 & finished3 & finished2 & finished1)
		begin
			VGA_X <= xCount4;
			VGA_Y <= drawTop4;
			VGA_COLOR <= 3'b111;
			if (drawTop4 < YSIZE - 2)
				plot <= 1;
			else
				plot <= 0;
			
			xCount4 <= xCount4 + 1;
			
			if (drawTop4 == (YSIZE - 2))
			begin
				continueDrawTop4 <= 0;
				continueDraw4 <= 1;
				xCount4 <= xStart4;
			end
			
			else if (xCount4 - xStart4 == XSIZE)
			begin
				continueDrawTop4 <= 0;
				finished4 <= 1;
				xCount4 <= xStart4;
			end
		end
		
		else if (continueDraw4 & finished3 & finished2 & finished1) 
		begin
			VGA_X <= xCount4;
			VGA_Y <= yCount4 + YSIZE - 2;
			VGA_COLOR <= 3'b111;
			plot <= 1;
			
			xCount4 <= xCount4 + 1;
			
			if ((xCount4 - xStart4) == XSIZE)
			begin
				continueDraw4 <= 0;
				finished4 <= 1;
			end
		end

		// end else begin
		// 	VGA_COLOR <= 3'b001; // Blue

		// 	// Increment x_count for each pixel
		// 	x_count <= x_count + 1;

		// 	// Checks for right edge
		// 	if (x_count == `RESOLUTION_WIDTH -1) begin 
		// 		x_count <= 0;
		// 		y_count <= y_count + 1;
		// 	end

		// 	// Checks for bottom edge (Corrected line)
		// 	if (y_count == `RESOLUTION_HEIGHT) begin
		// 		y_count <= 0;
		// 	end

		// 	// Assign the counters to VGA_X and VGA_Y
		// 	VGA_X <= x_count;
		// 	VGA_Y <= y_count;
		// end

		// gameOn <= SW[0];
		end
	end
	
	// Test/debug code
//  assign LEDR[3:0] = {finished1, finished2, finished3, finished4};
//	assign LEDR[0] = continueDraw;
// assign LEDR[1] = drawEnable;
//	assign LEDR[2] = plot;
//	assign LEDR[8] = eraseEnable;
//	assign LEDR[4] = tileShiftEnable;
//	assign LEDR[7] = continueEraseBottom;
	
endmodule

