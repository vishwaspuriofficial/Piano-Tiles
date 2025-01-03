// `define RESOLUTION_WIDTH 160 // Width of the screen
// `define RESOLUTION_HEIGHT 120 // Height of the screen
// `define COLUMN_WIDTH 35 
// `define COLUMN_HEIGHT (`RESOLUTION_HEIGHT / 6)     // Height of each row 
// `define BORDER_WIDTH 4       // Width of each border line

// //DESIM
// // module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR);
// //BOARD
// module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR, VGA_R, VGA_G, VGA_B,
//                 VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	
// 	// Initialize starting tile positions and VGA/draw states
// 	input CLOCK_50;	
// 	input [7:0] SW;
// 	input [3:0] KEY;
// 	output reg [7:0] VGA_X;                     
// 	output reg [6:0] VGA_Y;                     
// 	output reg [2:0] VGA_COLOR;                 
// 	output reg plot;                           
// 	output [9:0] LEDR;

// 	//BOARD
// 	output [7:0] VGA_R;
// 	output [7:0] VGA_G;
// 	output [7:0] VGA_B;
// 	output VGA_HS;
// 	output VGA_VS;
// 	output VGA_BLANK_N;
// 	output VGA_SYNC_N;
// 	output VGA_CLK; 

// 	parameter XSIZE = `COLUMN_WIDTH-1, YSIZE = `COLUMN_HEIGHT;
	
// 	// This is the blueprint for 1 tile falling down (on loop for all 4 columns)
// 	// Different flags to indicate which display stage the tile is at
// 	reg drawEnable;
// 	reg continueDraw;
// 	reg eraseEnable;
// 	reg continueErase;
	
// 	reg continueDrawTop;
// 	reg continueEraseBottom;
	
// 	reg [6:0] drawTop;
// 	reg [6:0] eraseBottom;
	
// 	reg [7:0] xStart;
// 	reg [6:0] yStart;
	
// 	reg [7:0] xCount;
// 	reg [6:0] yCount;
	
// 	reg finished1;
	
// 	// Second tile
// 	reg drawEnable2;
// 	reg continueDraw2;
// 	reg eraseEnable2;
// 	reg continueErase2;
	
// 	reg continueDrawTop2;
// 	reg continueEraseBottom2;
	
// 	reg [6:0] drawTop2;
// 	reg [6:0] eraseBottom2;
	
// 	reg [7:0] xStart2;
// 	reg [6:0] yStart2;
	
// 	reg [7:0] xCount2;
// 	reg [6:0] yCount2;
	
// 	reg finished2;
	
// 	// Third tile
// 	reg drawEnable3;
// 	reg continueDraw3;
// 	reg eraseEnable3;
// 	reg continueErase3;
	
// 	reg continueDrawTop3;
// 	reg continueEraseBottom3;
	
// 	reg [6:0] drawTop3;
// 	reg [6:0] eraseBottom3;
	
// 	reg [7:0] xStart3;
// 	reg [6:0] yStart3;
	
// 	reg [7:0] xCount3;
// 	reg [6:0] yCount3;
	
// 	reg finished3;
	
// 	// Fourth tile
// 	reg drawEnable4;
// 	reg continueDraw4;
// 	reg eraseEnable4;
// 	reg continueErase4;
	
// 	reg continueDrawTop4;
// 	reg continueEraseBottom4;
	
// 	reg [6:0] drawTop4;
// 	reg [6:0] eraseBottom4;
	
// 	reg [7:0] xStart4;
// 	reg [6:0] yStart4;
	
// 	reg [7:0] xCount4;
// 	reg [6:0] yCount4;
	
// 	reg finished4;

// 	//Screen Control + Draw
// 	reg gameOn;
// 	reg enableBackground;
// 	reg startedOnce;
// 	reg [7:0] x_count = 0;
//     reg [6:0] y_count = 0;
	
// 	initial
// 	begin
// 		gameOn <= SW[0];
// 		enableBackground <= 0;
// 		startedOnce <= 0;

// 		xStart <= `BORDER_WIDTH;
// 		yStart <= 7'd0;
// 		drawTop <= 0;
// 		eraseBottom <= 0;
// 		drawEnable <= 1;
		
// //		xStart2 <= (2*`BORDER_WIDTH)+`COLUMN_WIDTH;
// //		yStart2 <= 7'd0;
// //		drawTop2 <= 0;
// //		eraseBottom2 <= 0;
// //		drawEnable2 <= 1;
// //		
// //		xStart3 <= (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH);
// //		yStart3 <= 7'd0;
// //		drawTop3 <= 0;
// //		eraseBottom3 <= 0;
// //		drawEnable3 <= 1;
// //		
// //		xStart4 <= `RESOLUTION_HEIGHT+1;
// //		yStart4 <= 7'd0;
// //		drawTop4 <= 0;
// //		eraseBottom4 <= 0;
// //		drawEnable4 <= 1;

// //      finished1 <= 1;
// //      finished2 <= 1;
// //      finished3 <= 1;
// //      finished4 <= 1;
// 	end
	
// 	// Updates for tile movement
// 	reg [21:0] fast_count;
// 	//DESIM
// 	// assign tileShiftEnable = fast_count == 22'd4000; 

// 	//BOARD
// 	assign tileShiftEnable = fast_count == 22'd416666; 
// 	// 22'd2500000 corresponds to roughly 20px/second
// 	// 22'd416666 corresponds to roughly `RESOLUTION_HEIGHTpx/second

// 	//BOARD
// 	   vga_adapter VGA (
//        .resetn(KEY[0]),
//        .clock(CLOCK_50),
//        .colour(VGA_COLOR),
//        .x(VGA_X),
//        .y(VGA_Y),
//        .plot(plot),
//        .VGA_R(VGA_R),
//        .VGA_G(VGA_G),
//        .VGA_B(VGA_B),
//        .VGA_HS(VGA_HS),
//        .VGA_VS(VGA_VS),
//        .VGA_BLANK_N(VGA_BLANK_N),
//        .VGA_SYNC_N(VGA_SYNC_N),
//        .VGA_CLK(VGA_CLK));
//        defparam VGA.RESOLUTION = "160x120";
//        defparam VGA.MONOCHROME = "FALSE";
//        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
//        defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
	
// 	always@ (posedge CLOCK_50)
// 	begin
		
		// if (gameOn & ~startedOnce)
		// begin
		// 	enableBackground <= 1;
		// 	startedOnce <= 1;
		// end

		// if (enableBackground)
		// begin
		// 	//Code for Black Background + Border Lines
		// 	// Determine if the current pixel is on a black vertical line
		// 	plot <= 1;
		// 	if ( 
		// 		(x_count >= 0 && x_count < `BORDER_WIDTH) ||
		// 		(x_count >= `COLUMN_WIDTH + `BORDER_WIDTH && x_count < `COLUMN_WIDTH + 2 * `BORDER_WIDTH) || 
		// 		(x_count >= 2*`COLUMN_WIDTH + 2* `BORDER_WIDTH && x_count < 2*`COLUMN_WIDTH + 3*`BORDER_WIDTH) ||
		// 		(x_count >= 3*`COLUMN_WIDTH + 3*`BORDER_WIDTH && x_count < 3*`COLUMN_WIDTH + 4*`BORDER_WIDTH) ||
		// 		(x_count >= 4*`COLUMN_WIDTH + 4*`BORDER_WIDTH && x_count < 4*`COLUMN_WIDTH + 5*`BORDER_WIDTH)
		// 	) begin
		// 		VGA_COLOR <= 3'b010; // Blue for the vertical lines
		// 	end else begin
		// 		VGA_COLOR <= 3'b000; // Black for the rest of the screen
		// 	end

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

		// 	if (x_count == (`RESOLUTION_WIDTH - 1) & y_count == (`RESOLUTION_HEIGHT - 1)) begin
		// 		enableBackground <= 0;
		// 	end

		// 	// Assign the counters to VGA_X and VGA_Y
		// 	VGA_X <= x_count;
		// 	VGA_Y <= y_count;
		// end

		// if (gameOn & ~enableBackground & startedOnce) 
		// begin
		
// 		// fast_count updates
// 		if (tileShiftEnable)
// 		begin
// 			fast_count <= 22'd1;
			
// 			// First tile
// 			if (eraseBottom < `RESOLUTION_HEIGHT+1 & yStart < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				eraseBottom <= yStart;
// 			end
// 			else
// 			begin
// 				if (eraseBottom < `RESOLUTION_HEIGHT+1)
// 				begin
// 					eraseBottom <= eraseBottom + 1;
// 					continueEraseBottom <= 1;
// 					finished1 <= 0;
					
// 					if (eraseBottom == `RESOLUTION_HEIGHT) // Puts the animation on loop
// 					begin
// 						if (xStart == `BORDER_WIDTH)
// 							xStart <= (2*`BORDER_WIDTH)+`COLUMN_WIDTH;
// 						else if (xStart == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
// 							xStart <= (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH);
// 						else if (xStart == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
// 							xStart <= `RESOLUTION_HEIGHT+1;
// 						else
// 							xStart <= `BORDER_WIDTH;
// 						yStart <= 7'd0;
// 						drawTop <= 0;
// 						eraseBottom <= 0;
// 						drawEnable <= 1;
// 					end
// 				end
// 			end
			
// 			if (drawTop < YSIZE - 2)
// 			begin
// 				finished1 <= 0;
// 				drawTop <= drawTop + 1;
// 				continueDrawTop <= 1;
// 			end
// 			else if (yStart < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				finished1 <= 0;
// 				eraseEnable <= 1;
// 			end
			
// 			// Second tile
// 			if (eraseBottom2 < `RESOLUTION_HEIGHT+1 & yStart2 < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				eraseBottom2 <= yStart2;
// 			end
// 			else
// 			begin
// 				if (eraseBottom2 < `RESOLUTION_HEIGHT+1)
// 				begin
// 					eraseBottom2 <= eraseBottom2 + 1;
// 					continueEraseBottom2 <= 1;
// 					finished2 <= 0;
					
// 					if (eraseBottom2 == `RESOLUTION_HEIGHT) // Puts the animation on loop
// 					begin
// 						if (xStart2 == `BORDER_WIDTH)
// 							xStart2 <= (2*`BORDER_WIDTH)+`COLUMN_WIDTH;
// 						else if (xStart2 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
// 							xStart2 <= (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH);
// 						else if (xStart2 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
// 							xStart2 <= `RESOLUTION_HEIGHT+1;
// 						else
// 							xStart2 <= `BORDER_WIDTH;
// 						yStart2 <= 7'd0;
// 						drawTop2 <= 0;
// 						eraseBottom2 <= 0;
// 						drawEnable2 <= 1;
// 					end
// 				end
// 			end
			
// 			if (drawTop2 < YSIZE - 2)
// 			begin
// 				finished2 <= 0;
// 				drawTop2 <= drawTop2 + 1;
// 				continueDrawTop2 <= 1;
// 			end
// 			else if (yStart2 < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				finished2 <= 0;
// 				eraseEnable2 <= 1;
// 			end
			
// 			// Third tile
// 			if (eraseBottom3 < `RESOLUTION_HEIGHT+1 & yStart3 < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				eraseBottom3 <= yStart3;
// 			end
// 			else
// 			begin
// 				if (eraseBottom3 < `RESOLUTION_HEIGHT+1)
// 				begin
// 					eraseBottom3 <= eraseBottom3 + 1;
// 					continueEraseBottom3 <= 1;
// 					finished3 <= 0;
					
// 					if (eraseBottom3 == `RESOLUTION_HEIGHT) // Puts the animation on loop
// 					begin
// 						if (xStart3 == `BORDER_WIDTH)
// 							xStart3 <= (2*`BORDER_WIDTH)+`COLUMN_WIDTH;
// 						else if (xStart3 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
// 							xStart3 <= (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH);
// 						else if (xStart3 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
// 							xStart3 <= `RESOLUTION_HEIGHT+1;
// 						else
// 							xStart3 <= `BORDER_WIDTH;
// 						yStart3 <= 7'd0;
// 						drawTop3 <= 0;
// 						eraseBottom3 <= 0;
// 						drawEnable3 <= 1;
// 					end
// 				end
// 			end
			
// 			if (drawTop3 < YSIZE - 2)
// 			begin
// 				finished3 <= 0;
// 				drawTop3 <= drawTop3 + 1;
// 				continueDrawTop3 <= 1;
// 			end
// 			else if (yStart3 < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				finished3 <= 0;
// 				eraseEnable3 <= 1;
// 			end
			
// 			// Fourth tile
// 			if (eraseBottom4 < `RESOLUTION_HEIGHT+1 & yStart4 < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				eraseBottom4 <= yStart4;
// 			end
// 			else
// 			begin
// 				if (eraseBottom4 < `RESOLUTION_HEIGHT+1)
// 				begin
// 					eraseBottom4 <= eraseBottom4 + 1;
// 					continueEraseBottom4 <= 1;
// 					finished4 <= 0;
					
// 					if (eraseBottom4 == `RESOLUTION_HEIGHT) // Puts the animation on loop
// 					begin
// 						if (xStart4 == `BORDER_WIDTH)
// 							xStart4 <= (2*`BORDER_WIDTH)+`COLUMN_WIDTH;
// 						else if (xStart4 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
// 							xStart4 <= (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH);
// 						else if (xStart4 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
// 							xStart4 <= `RESOLUTION_HEIGHT+1;
// 						else
// 							xStart4 <= `BORDER_WIDTH;
// 						yStart4 <= 7'd0;
// 						drawTop4 <= 0;
// 						eraseBottom4 <= 0;
// 						drawEnable4 <= 1;
// 					end
// 				end
// 			end
			
// 			if (drawTop4 < YSIZE - 2)
// 			begin
// 				finished4 <= 0;
// 				drawTop4 <= drawTop4 + 1;
// 				continueDrawTop4 <= 1;
// 			end
// 			else if (yStart4 < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				finished4 <= 0;
// 				eraseEnable4 <= 1;
// 			end
			
// 		end
// 		else
// 		begin
// 			fast_count <= fast_count + 22'd1;
// 		end
		
// 		// Draw a black tile ontop of the old white tile
// 		// First tile
// 		if (eraseEnable)
// 		begin
// 			if (yStart < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				xCount <= xStart;
// 				yCount <= yStart;
// 				plot <= 0;
// 				continueErase <= 1;
// 				eraseEnable <= 0;
// 				VGA_COLOR <= 3'b000;
// 			end
// 			fast_count <= 22'd1; // No updates for fast_count
// 		end
		
// 		else if (continueErase) // Erases top of tile
// 		begin
// 			VGA_X <= xCount;
// 			VGA_Y <= yCount;
// 			VGA_COLOR <= 3'b000;
// 			plot <= 1;
			
// 			xCount <= xCount + 1;
			
// 			if ((xCount - xStart) == XSIZE)
// 			begin
// 				continueErase <= 0;
				
// 				if (yCount < `RESOLUTION_HEIGHT)
// 				begin
// 					yStart <= yStart + 1;
// 					drawEnable <= 1;
// 				end
// 			end
// 		end
		
// 		else if (continueEraseBottom) // Erases tile from top to bottom, one row at a time
// 		begin
		
// 			VGA_X <= xCount;
// 			VGA_Y <= eraseBottom;
// 			VGA_COLOR <= 3'b000;
// 			if (eraseBottom < `RESOLUTION_HEIGHT+1)
// 				plot <= 1;
// 			else
// 				plot <= 0;
			
// 			xCount <= xCount + 1;
			
// 			if (xCount - xStart == XSIZE)
// 			begin
// 				continueEraseBottom <= 0;
// 				finished1 <= 1;
// 				xCount <= xStart;
// 			end
// 		end
		
// 		// Tile drawings
// 		if (drawEnable) // Enables the draw top flag to create illusion of tile going on the screen
// 		begin
// 			xCount <= xStart;
// 			yCount <= yStart;
// 			plot <= 0;
// 			drawEnable <= 0;
// 			VGA_COLOR <= 3'b111;
// 			continueDrawTop <= 1;
			
// 			fast_count <= 22'd1;
// 		end
		
// 		else if (continueDrawTop)
// 		begin
// 			VGA_X <= xCount;
// 			VGA_Y <= drawTop;
// 			VGA_COLOR <= 3'b111;
// 			if (drawTop < YSIZE - 2)
// 				plot <= 1;
// 			else
// 				plot <= 0;
			
// 			xCount <= xCount + 1;
			
// 			if (drawTop == (YSIZE - 2))
// 			begin
// 				continueDrawTop <= 0;
// 				continueDraw <= 1;
// 				xCount <= xStart;
// 			end
			
// 			else if (xCount - xStart == XSIZE)
// 			begin
// 				continueDrawTop <= 0;
// 				finished1 <= 1;
// 				xCount <= xStart;
// 			end
// 		end
		
// 		else if (continueDraw) 
// 		begin
// 			VGA_X <= xCount;
// 			VGA_Y <= yCount + YSIZE - 2;
// 			VGA_COLOR <= 3'b111;
// 			plot <= 1;
			
// 			xCount <= xCount + 1;
			
// 			if ((xCount - xStart) == XSIZE)
// 			begin
// 				continueDraw <= 0;
// 				finished1 <= 1;
// 			end
			
// 		end
		
// 		// Second tile
// 		if (eraseEnable2 & finished1)
// 		begin
// 			if (yStart2 < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				xCount2 <= xStart2;
// 				yCount2 <= yStart2;
// 				plot <= 0;
// 				continueErase2 <= 1;
// 				eraseEnable2 <= 0;
// 				VGA_COLOR <= 3'b000;
// 			end
// 			fast_count <= 22'd1; // No updates for fast_count
// 		end
		
// 		else if (continueErase2 & finished1) // Erases top of tile
// 		begin
// 			VGA_X <= xCount2;
// 			VGA_Y <= yCount2;
// 			VGA_COLOR <= 3'b000;
// 			plot <= 1;
			
// 			xCount2 <= xCount2 + 1;
			
// 			if ((xCount2 - xStart2) == XSIZE)
// 			begin
// 				continueErase2 <= 0;
				
// 				if (yCount2 < `RESOLUTION_HEIGHT)
// 				begin
// 					yStart2 <= yStart2 + 1;
// 					drawEnable2 <= 1;
// 				end
// 			end
// 		end
		
// 		else if (continueEraseBottom2 & finished1) // Erases tile from top to bottom, one row at a time
// 		begin
		
// 			VGA_X <= xCount2;
// 			VGA_Y <= eraseBottom2;
// 			VGA_COLOR <= 3'b000;
// 			if (eraseBottom2 < `RESOLUTION_HEIGHT+1)
// 				plot <= 1;
// 			else
// 				plot <= 0;
			
// 			xCount2 <= xCount2 + 1;
			
// 			if (xCount2 - xStart2 == XSIZE)
// 			begin
// 				continueEraseBottom2 <= 0;
// 				finished2 <= 1;
// 				xCount2 <= xStart2;
// 			end
// 		end
		
// 		// Tile drawings
// 		if (drawEnable2 & finished1) // Enables the draw top flag to create illusion of tile going on the screen
// 		begin
// 			xCount2 <= xStart2;
// 			yCount2 <= yStart2;
// 			plot <= 0;
// 			drawEnable2 <= 0;
// 			VGA_COLOR <= 3'b111;
// 			continueDrawTop2 <= 1;
			
// 			fast_count <= 22'd1;
// 		end
		
// 		else if (continueDrawTop2 & finished1)
// 		begin
// 			VGA_X <= xCount2;
// 			VGA_Y <= drawTop2;
// 			VGA_COLOR <= 3'b111;
// 			if (drawTop2 < YSIZE - 2)
// 				plot <= 1;
// 			else
// 				plot <= 0;
			
// 			xCount2 <= xCount2 + 1;
			
// 			if (drawTop2 == (YSIZE - 2))
// 			begin
// 				continueDrawTop2 <= 0;
// 				continueDraw2 <= 1;
// 				xCount2 <= xStart2;
// 			end
			
// 			else if (xCount2 - xStart2 == XSIZE)
// 			begin
// 				continueDrawTop2 <= 0;
// 				finished2 <= 1;
// 				xCount2 <= xStart2;
// 			end
// 		end
		
// 		else if (continueDraw2 & finished1) 
// 		begin
// 			VGA_X <= xCount2;
// 			VGA_Y <= yCount2 + YSIZE - 2;
// 			VGA_COLOR <= 3'b111;
// 			plot <= 1;
			
// 			xCount2 <= xCount2 + 1;
			
// 			if ((xCount2 - xStart2) == XSIZE)
// 			begin
// 				continueDraw2 <= 0;
// 				finished2 <= 1;
// 			end
// 		end
		
// 		// Third tile
// 		if (eraseEnable3 & finished2 & finished1)
// 		begin
// 			if (yStart3 < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				xCount3 <= xStart3;
// 				yCount3 <= yStart3;
// 				plot <= 0;
// 				continueErase3 <= 1;
// 				eraseEnable3 <= 0;
// 				VGA_COLOR <= 3'b000;
// 			end
// 			fast_count <= 22'd1; // No updates for fast_count
// 		end
		
// 		else if (continueErase3 & finished2 & finished1) // Erases top of tile
// 		begin
// 			VGA_X <= xCount3;
// 			VGA_Y <= yCount3;
// 			VGA_COLOR <= 3'b000;
// 			plot <= 1;
			
// 			xCount3 <= xCount3 + 1;
			
// 			if ((xCount3 - xStart3) == XSIZE)
// 			begin
// 				continueErase3 <= 0;
				
// 				if (yCount3 < `RESOLUTION_HEIGHT)
// 				begin
// 					yStart3 <= yStart3 + 1;
// 					drawEnable3 <= 1;
// 				end
// 			end
// 		end
		
// 		else if (continueEraseBottom3 & finished2 & finished1) // Erases tile from top to bottom, one row at a time
// 		begin
		
// 			VGA_X <= xCount3;
// 			VGA_Y <= eraseBottom3;
// 			VGA_COLOR <= 3'b000;
// 			if (eraseBottom3 < `RESOLUTION_HEIGHT+1)
// 				plot <= 1;
// 			else
// 				plot <= 0;
			
// 			xCount3 <= xCount3 + 1;
			
// 			if (xCount3 - xStart3 == XSIZE)
// 			begin
// 				continueEraseBottom3 <= 0;
// 				finished3 <= 1;
// 				xCount3 <= xStart3;
// 			end
// 		end
		
// 		// Tile drawings
// 		if (drawEnable3 & finished2 & finished1) // Enables the draw top flag to create illusion of tile going on the screen
// 		begin
// 			xCount3 <= xStart3;
// 			yCount3 <= yStart3;
// 			plot <= 0;
// 			drawEnable3 <= 0;
// 			VGA_COLOR <= 3'b111;
// 			continueDrawTop3 <= 1;
			
// 			fast_count <= 22'd1;
// 		end
		
// 		else if (continueDrawTop3 & finished2 & finished1)
// 		begin
// 			VGA_X <= xCount3;
// 			VGA_Y <= drawTop3;
// 			VGA_COLOR <= 3'b111;
// 			if (drawTop3 < YSIZE - 2)
// 				plot <= 1;
// 			else
// 				plot <= 0;
			
// 			xCount3 <= xCount3 + 1;
			
// 			if (drawTop3 == (YSIZE - 2))
// 			begin
// 				continueDrawTop3 <= 0;
// 				continueDraw3 <= 1;
// 				xCount3 <= xStart3;
// 			end
			
// 			else if (xCount3 - xStart3 == XSIZE)
// 			begin
// 				continueDrawTop3 <= 0;
// 				finished3 <= 1;
// 				xCount3 <= xStart3;
// 			end
// 		end
		
// 		else if (continueDraw3 & finished2 & finished1) 
// 		begin
// 			VGA_X <= xCount3;
// 			VGA_Y <= yCount3 + YSIZE - 2;
// 			VGA_COLOR <= 3'b111;
// 			plot <= 1;
			
// 			xCount3 <= xCount3 + 1;
			
// 			if ((xCount3 - xStart3) == XSIZE)
// 			begin
// 				continueDraw3 <= 0;
// 				finished3 <= 1;
// 			end
// 		end
		
// 		// Fourth tile
// 		if (eraseEnable4 & finished3 & finished2 & finished1)
// 		begin
// 			if (yStart4 < `RESOLUTION_HEIGHT - YSIZE)
// 			begin
// 				xCount4 <= xStart4;
// 				yCount4 <= yStart4;
// 				plot <= 0;
// 				continueErase4 <= 1;
// 				eraseEnable4 <= 0;
// 				VGA_COLOR <= 3'b000;
// 			end
// 			fast_count <= 22'd1; // No updates for fast_count
// 		end
		
// 		else if (continueErase4 & finished3 & finished2 & finished1) // Erases top of tile
// 		begin
// 			VGA_X <= xCount4;
// 			VGA_Y <= yCount4;
// 			VGA_COLOR <= 3'b000;
// 			plot <= 1;
			
// 			xCount4 <= xCount4 + 1;
			
// 			if ((xCount4 - xStart4) == XSIZE)
// 			begin
// 				continueErase4 <= 0;
				
// 				if (yCount4 < `RESOLUTION_HEIGHT)
// 				begin
// 					yStart4 <= yStart4 + 1;
// 					drawEnable4 <= 1;
// 				end
// 			end
// 		end
		
// 		else if (continueEraseBottom4 & finished3 & finished2 & finished1) // Erases tile from top to bottom, one row at a time
// 		begin
		
// 			VGA_X <= xCount4;
// 			VGA_Y <= eraseBottom4;
// 			VGA_COLOR <= 3'b000;
// 			if (eraseBottom4 < `RESOLUTION_HEIGHT+1)
// 				plot <= 1;
// 			else
// 				plot <= 0;
			
// 			xCount4 <= xCount4 + 1;
			
// 			if (xCount4 - xStart4 == XSIZE)
// 			begin
// 				continueEraseBottom4 <= 0;
// 				finished4 <= 1;
// 				xCount4 <= xStart4;
// 			end
// 		end
		
// 		// Tile drawings
// 		if (drawEnable4 & finished3 & finished2 & finished1) // Enables the draw top flag to create illusion of tile going on the screen
// 		begin
// 			xCount4 <= xStart4;
// 			yCount4 <= yStart4;
// 			plot <= 0;
// 			drawEnable4 <= 0;
// 			VGA_COLOR <= 3'b111;
// 			continueDrawTop4 <= 1;
			
// 			fast_count <= 22'd1;
// 		end
		
// 		else if (continueDrawTop4 & finished3 & finished2 & finished1)
// 		begin
// 			VGA_X <= xCount4;
// 			VGA_Y <= drawTop4;
// 			VGA_COLOR <= 3'b111;
// 			if (drawTop4 < YSIZE - 2)
// 				plot <= 1;
// 			else
// 				plot <= 0;
			
// 			xCount4 <= xCount4 + 1;
			
// 			if (drawTop4 == (YSIZE - 2))
// 			begin
// 				continueDrawTop4 <= 0;
// 				continueDraw4 <= 1;
// 				xCount4 <= xStart4;
// 			end
			
// 			else if (xCount4 - xStart4 == XSIZE)
// 			begin
// 				continueDrawTop4 <= 0;
// 				finished4 <= 1;
// 				xCount4 <= xStart4;
// 			end
// 		end
		
// 		else if (continueDraw4 & finished3 & finished2 & finished1) 
// 		begin
// 			VGA_X <= xCount4;
// 			VGA_Y <= yCount4 + YSIZE - 2;
// 			VGA_COLOR <= 3'b111;
// 			plot <= 1;
			
// 			xCount4 <= xCount4 + 1;
			
// 			if ((xCount4 - xStart4) == XSIZE)
// 			begin
// 				continueDraw4 <= 0;
// 				finished4 <= 1;
// 			end
// 		end

// 		end 

// 		else begin
			// if (~enableBackground & startedOnce)
			// begin
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
// 		end

// 		gameOn <= SW[0];
// 	end
	
// 	// Test/debug code
// //  assign LEDR[3:0] = {finished1, finished2, finished3, finished4};
// //	assign LEDR[0] = continueDraw;
// //  assign LEDR[1] = drawEnable;
// //	assign LEDR[2] = plot;
// //	assign LEDR[8] = eraseEnable;
// //	assign LEDR[4] = tileShiftEnable;
// //	assign LEDR[7] = continueEraseBottom;
// // assign LEDR[7:0] = x_count;
// // assign LEDR[0] = enableBackground;
	
// endmodule

`define RESOLUTION_WIDTH 160
`define RESOLUTION_HEIGHT 120
`define COLUMN_WIDTH 35
`define COLUMN_HEIGHT (`RESOLUTION_HEIGHT / 6)
`define BORDER_WIDTH 4

//DESIM
module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR);
//BOARD
// module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR, VGA_R, VGA_G, VGA_B,
//                 VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	
	// Initialize starting tile positions and VGA/draw states
	input CLOCK_50;	
	input [7:0] SW;
	input [3:0] KEY;
	output reg [7:0] VGA_X;                     
	output reg [6:0] VGA_Y;                     
	output reg [2:0] VGA_COLOR;                 
	output reg plot;                           
	output [9:0] LEDR;

	//BOARD
	// output [7:0] VGA_R;
	// output [7:0] VGA_G;
	// output [7:0] VGA_B;
	// output VGA_HS;
	// output VGA_VS;
	// output VGA_BLANK_N;
	// output VGA_SYNC_N;
	// output VGA_CLK; 

	parameter XSIZE = `COLUMN_WIDTH - 1, YSIZE = `COLUMN_HEIGHT;

	reg gameOn;
	reg enableBackground;
	reg startedOnce;
	reg [7:0] x_count = 0;
	reg [6:0] y_count = 0;
	reg [21:0] fast_count;
	wire tileShiftEnable;
	assign tileShiftEnable = (fast_count == 22'd416666);

	//BOARD
	// vga_adapter VGA (
	//    .resetn(KEY[0]),
	//    .clock(CLOCK_50),
	//    .colour(VGA_COLOR),
	//    .x(VGA_X),
	//    .y(VGA_Y),
	//    .plot(plot),
	//    .VGA_R(VGA_R),
	//    .VGA_G(VGA_G),
	//    .VGA_B(VGA_B),
	//    .VGA_HS(VGA_HS),
	//    .VGA_VS(VGA_VS),
	//    .VGA_BLANK_N(VGA_BLANK_N),
	//    .VGA_SYNC_N(VGA_SYNC_N),
	//    .VGA_CLK(VGA_CLK)
	// );
	// defparam VGA.RESOLUTION = "160x120";
	// defparam VGA.MONOCHROME = "FALSE";
	// defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	
	
	reg tile tiles [3:0]; 
    reg [7:0] xStarts [3:0] = {`BORDER_WIDTH, (`COLUMN_WIDTH + 2 * `BORDER_WIDTH),
                                            (2 * `COLUMN_WIDTH + 3 * `BORDER_WIDTH), (3 * `COLUMN_WIDTH + 4 * `BORDER_WIDTH)};
    wire [3:0] plot_temp; // Array of plot signals
    reg finished [3:0]; // Finished status for each tile
    reg tileShiftEnable_individual [3:0];
    wire [7:0] VGA_X_temp_wire;
    wire [6:0] VGA_Y_temp_wire;
    wire [2:0] VGA_COLOR_temp_wire;
    reg VGA_X_temp;
    reg VGA_Y_temp;
    reg VGA_COLOR_temp;

	integer i;
	initial
	begin
		gameOn <= SW[0];
		enableBackground <= 0;
		startedOnce <= 0;
		for (i = 0; i < 4; i = i + 1) begin
            finished[i] <= 1'b1;
        end
	end



	genvar col;
    generate
        for (col = 0; col < 4; col = col + 1) begin : col_loop
            tile tiles[col] (
                .CLOCK_50(CLOCK_50),
                .tileShiftEnable(tileShiftEnable_individual[col]),
                .xStart(xStarts[col]),
                .yStart_in(7'd0),
                .plot(plot_temp[col]),
                .VGA_COLOR(tiles[col].VGA_COLOR),
                .VGA_X(tiles[col].VGA_X),
                .VGA_Y(tiles[col].VGA_Y)
            );
        end
    endgenerate

    assign plot = |plot_temp;

always @(*) begin // Combinatorial logic for VGA signal selection
        VGA_X_temp = VGA_X_temp_wire;
        VGA_Y_temp = VGA_Y_temp_wire;
        VGA_COLOR_temp = VGA_COLOR_temp_wire;
    end

    assign VGA_X_temp_wire = (plot_temp[0]) ? tiles[0].VGA_X : (plot_temp[1] ? tiles[1].VGA_X : (plot_temp[2] ? tiles[2].VGA_X : (plot_temp[3] ? tiles[3].VGA_X : 8'd0)));
    assign VGA_Y_temp_wire = (plot_temp[0]) ? tiles[0].VGA_Y : (plot_temp[1] ? tiles[1].VGA_Y : (plot_temp[2] ? tiles[2].VGA_Y : (plot_temp[3] ? tiles[3].VGA_Y : 7'd0)));
    assign VGA_COLOR_temp_wire = (plot_temp[0]) ? tiles[0].VGA_COLOR : (plot_temp[1] ? tiles[1].VGA_COLOR : (plot_temp[2] ? tiles[2].VGA_COLOR : (plot_temp[3] ? tiles[3].VGA_COLOR : 3'd0)));

	always @(posedge CLOCK_50) begin
		if (gameOn & ~startedOnce) begin
			enableBackground <= 1;
			startedOnce <= 1;
		end

		if (enableBackground) begin
			plot <= 1'b1;
			VGA_COLOR <= (
				(x_count < `BORDER_WIDTH) ||
				(x_count >= `COLUMN_WIDTH + `BORDER_WIDTH && x_count < `COLUMN_WIDTH + 2 * `BORDER_WIDTH) ||
				(x_count >= 2 * `COLUMN_WIDTH + 2 * `BORDER_WIDTH && x_count < 2 * `COLUMN_WIDTH + 3 * `BORDER_WIDTH) ||
				(x_count >= 3 * `COLUMN_WIDTH + 3 * `BORDER_WIDTH && x_count < 3 * `COLUMN_WIDTH + 4 * `BORDER_WIDTH) ||
				(x_count >= 4 * `COLUMN_WIDTH + 4 * `BORDER_WIDTH && x_count < 4 * `COLUMN_WIDTH + 5 * `BORDER_WIDTH)
			) ? 3'b010 : 3'b000;

			x_count <= x_count + 1;
			if (x_count == `RESOLUTION_WIDTH - 1) begin
				x_count <= 0;
				y_count <= y_count + 1;
			end
			if (x_count == (`RESOLUTION_WIDTH - 1) && y_count == (`RESOLUTION_HEIGHT - 1)) begin
				enableBackground <= 0;
			end
			VGA_X <= x_count;
			VGA_Y <= y_count;

		end else if (gameOn & ~enableBackground & startedOnce) 
		begin
			if (tileShiftEnable) begin
                fast_count <= 22'd1;
				
                for (i = 0; i < 4; i = i + 1) begin
                    tileShiftEnable_individual[i] <= 1'b1;
                end
            end else begin
                fast_count <= fast_count + 22'd1;
                for (i = 0; i < 4; i = i + 1) begin
                    tileShiftEnable_individual[i] <= 1'b0;
                end
            end

            VGA_X <= VGA_X_temp;
            VGA_Y <= VGA_Y_temp;
            VGA_COLOR <= VGA_COLOR_temp;
		end

		else begin
			if (~enableBackground & startedOnce)
			begin
				VGA_COLOR <= 3'b001; // Blue

				// Increment x_count for each pixel
				x_count <= x_count + 1;

				// Checks for right edge
				if (x_count == `RESOLUTION_WIDTH -1) begin 
					x_count <= 0;
					y_count <= y_count + 1;
				end

				// Checks for bottom edge (Corrected line)
				if (x_count == (`RESOLUTION_WIDTH - 1) && y_count == (`RESOLUTION_HEIGHT - 1)) begin
					startedOnce <= 0;
				end

				// Assign the counters to VGA_X and VGA_Y
				VGA_X <= x_count;
				VGA_Y <= y_count;
			end
		end

		gameOn <= SW[0];

	end

endmodule

