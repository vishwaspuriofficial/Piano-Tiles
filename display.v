`define RESOLUTION_WIDTH 160 // Width of the screen
`define RESOLUTION_HEIGHT 120 // Height of the screen
`define COLUMN_WIDTH 35 
`define COLUMN_HEIGHT (`RESOLUTION_HEIGHT / 6)     // Height of each row 
`define BORDER_WIDTH 4       // Width of each border line
`define TILES 3'b000 //Black 
`define BACKGROUND 3'b111 //WHITE
`define BOUNDARY 3'b100 //RED
`define BORDER 3'b010 //GREEN
`define GAMEOVER 3'b001 //BLUE


//DESIM
module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR, HEX0, HEX1);
//BOARD
// module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR, VGA_R, VGA_G, VGA_B,
//                 VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, HEX0, HEX1);
	
	// Initialize starting tile positions and VGA/draw states
	input CLOCK_50;	
	input [7:0] SW;
	input [3:0] KEY;
	output reg [7:0] VGA_X;                     
	output reg [6:0] VGA_Y;                     
	output reg [2:0] VGA_COLOR;                 
	output reg plot;                           
	output [9:0] LEDR;
	output [6:0] HEX1, HEX0;

	//BOARD
	// output [7:0] VGA_R;
	// output [7:0] VGA_G;
	// output [7:0] VGA_B;
	// output VGA_HS;
	// output VGA_VS;
	// output VGA_BLANK_N;
	// output VGA_SYNC_N;
	// output VGA_CLK; 

	parameter XSIZE = `COLUMN_WIDTH-1, YSIZE = `COLUMN_HEIGHT;
	
	// This is the blueprint for 1 tile falling down (on loop for all 4 columns)
	// Different flags to indicate which display stage the tile is at
	reg drawEnable;
	reg continueDraw;
	reg eraseEnable;
	reg continueErase;
	
	reg continueDrawTop;
	reg onScreen;
	
	reg [6:0] drawTop;
	
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
	reg onScreen2;
	
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
	reg gameOver;
	reg enableBackground;
	reg startedOnce;
	reg [7:0] x_count = 0;
    reg [6:0] y_count = 0;

	//Scoring System
	reg [7:0] score;
	reg col1pressed, col2pressed, col3pressed, col4pressed;

	reg tile1scored;
	reg tile2scored;
	
	//Next tile timing system
	reg [25:0] nextTileTime; // number of clock cycles between this tile and the next

	// A few important constants
	reg [21:0] globalSpeed;
	reg [25:0] timeBetweenTile;

	//Random
	reg [1:0] random_column;
	reg [23:0] lfsr;

	initial
	begin
		lfsr = 24'h800001;
		gameOn <= 1;
		gameOver <= 0;
		enableBackground <= 0;
		startedOnce <= 0;

		// DESIM
		globalSpeed <= 22'd1000;
		timeBetweenTile <= 26'd100000;
		// 22'd4000 is standard for DESim (for globalSpeed)
		//BOARD
		// globalSpeed <= 22'd416666;
		// timeBetweenTile <= 26'd50000000; // corresponds to 1 second between each tile
		// 22'd416666 corresponds to roughly 20px/second
		// 22'd208333 corresponds to roughly 120px/second

		score <= 0;

		xStart <= `BORDER_WIDTH;
		yStart <= 7'd0;
		drawTop <= 0;
		drawEnable <= 1; // Makes the top line get drawn in
		tile1scored <= 0;
		finished1 <= 0;
		onScreen <= 1;
		
		xStart2 <= 8'd0;
		yStart2 <= 7'd0;
		drawTop2 <= 0;
		drawEnable2 <= 0;
		tile2scored <= 0;
		finished2 <= 0;
		onScreen2 <= 0;
		
		// xStart3 <= 8'd82;
		// yStart3 <= 7'd0;
		// drawTop3 <= 0;
		// drawEnable3 <= 1;
		
		// xStart4 <= 8'd121;
		// yStart4 <= 7'd0;
		// drawTop4 <= 0;
		// drawEnable4 <= 1;

    //  finished1 <= 1;
    //  finished2 <= 1;
     finished3 <= 1;
     finished4 <= 1;
	end
	
	// Updates for tile movement
	reg [21:0] fast_count;
	//DESIM
	assign tileShiftEnable = fast_count == globalSpeed; // Tile speed
	assign nextTileEnable = nextTileTime == timeBetweenTile; // Time between each tile

	//BOARD
	//    vga_adapter VGA (
    //   .resetn(KEY[0]),
    //   .clock(CLOCK_50),
    //   .colour(VGA_COLOR),
    //   .x(VGA_X),
    //   .y(VGA_Y),
    //   .plot(plot),
    //   .VGA_R(VGA_R),
    //   .VGA_G(VGA_G),
    //   .VGA_B(VGA_B),
    //   .VGA_HS(VGA_HS),
    //   .VGA_VS(VGA_VS),
    //   .VGA_BLANK_N(VGA_BLANK_N),
    //   .VGA_SYNC_N(VGA_SYNC_N),
    //   .VGA_CLK(VGA_CLK));
    //   defparam VGA.RESOLUTION = "160x120";
    //   defparam VGA.MONOCHROME = "FALSE";
    //   defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    //   defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
	always@ (negedge KEY[3])
	begin
		if (KEY[3] == 0)
			if (~gameOver)
				col1pressed <= 1;
			else
				gameOver <= 0;
	end
	always@ (negedge KEY[2])
	begin
		if (KEY[2] == 0)
			if (~gameOver)
				col2pressed <= 1;
			else
				gameOver <= 0;
	end
	always@ (negedge KEY[1])
	begin
		if (KEY[1] == 0)
			if (~gameOver)
				col3pressed <= 1;
			else
				gameOver <= 0;
	end
	always@ (negedge KEY[0])
	begin
		if (KEY[0] == 0)
			if (~gameOver)
				col4pressed <= 1;
			else
				gameOver <= 0;
	end

	always @(posedge CLOCK_50) begin
        lfsr <= {lfsr[22:0], lfsr[23] ^ lfsr[22] ^ lfsr[17] ^ lfsr[16]};
    end


	always@ (posedge CLOCK_50)
	begin
		
		if (gameOn & ~startedOnce)
		begin
			enableBackground <= 1;
			startedOnce <= 1;

			score <= 0;
			fast_count <= 1;
			nextTileTime <= 1;
		end

		if (enableBackground)
		begin
			//Code for Black Background + Border Lines
			plot <= 1;
			if ( 
				(x_count >= 0 && x_count < `BORDER_WIDTH) ||
				(x_count >= `COLUMN_WIDTH + `BORDER_WIDTH && x_count < `COLUMN_WIDTH + 2 * `BORDER_WIDTH) || 
				(x_count >= 2*`COLUMN_WIDTH + 2* `BORDER_WIDTH && x_count < 2*`COLUMN_WIDTH + 3*`BORDER_WIDTH) ||
				(x_count >= 3*`COLUMN_WIDTH + 3*`BORDER_WIDTH && x_count < 3*`COLUMN_WIDTH + 4*`BORDER_WIDTH) ||
				(x_count >= 4*`COLUMN_WIDTH + 4*`BORDER_WIDTH && x_count < 4*`COLUMN_WIDTH + 5*`BORDER_WIDTH)
			) begin
				VGA_COLOR <= `BORDER;
			end else begin
				VGA_COLOR <= `BACKGROUND;
			end

			// Increment x_count for each pixel
			x_count <= x_count + 1;
			nextTileTime <= 1;

			// Checks for right edge
			if (x_count == `RESOLUTION_WIDTH -1) begin 
				x_count <= 0;
				y_count <= y_count + 1;
			end

			// Checks for bottom edge (Corrected line)
			if (y_count == `RESOLUTION_HEIGHT - 1) begin
				VGA_COLOR <= `BOUNDARY;
			end

			if (x_count == (`RESOLUTION_WIDTH - 1) & y_count == (`RESOLUTION_HEIGHT - 1)) begin
				enableBackground <= 0;
				nextTileTime <= 1;
			end

			// Assign the counters to VGA_X and VGA_Y
			VGA_X <= x_count;
			VGA_Y <= y_count;
		end

		if (gameOn & ~enableBackground & startedOnce) 
		begin
			
		// Score updates
		if (col1pressed)
		begin
			if (yStart > `RESOLUTION_HEIGHT - YSIZE & onScreen & xStart == `BORDER_WIDTH)
			begin
				if (~tile1scored)
					score <= score + 1;
				tile1scored <= 1;
			end
			else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == `BORDER_WIDTH)
			begin
				if (~tile2scored)
					score <= score + 1;
				tile2scored <= 1;
			end
			else
				gameOver <= 1;
			col1pressed <= 0;
		end

		if (col2pressed)
		begin
			if (yStart > `RESOLUTION_HEIGHT - YSIZE & onScreen & xStart == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
			begin
				if (~tile1scored)
					score <= score + 1;
				tile1scored <= 1;
			end
			else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
			begin
				if (~tile2scored)
					score <= score + 1;
				tile2scored <= 1;
			end
			else
				gameOver <= 1;
			col2pressed <= 0;
		end

		if (col3pressed)
		begin
			if (yStart > `RESOLUTION_HEIGHT - YSIZE & onScreen & xStart == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
			begin
				if (~tile1scored)
					score <= score + 1;
				tile1scored <= 1;
			end
			else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
			begin
				if (~tile2scored)
					score <= score + 1;
				tile2scored <= 1;
			end
			else
				gameOver <= 1;
			col3pressed <= 0;
		end

		if (col4pressed)
		begin
			if (yStart > `RESOLUTION_HEIGHT - YSIZE & onScreen & xStart == (4*`BORDER_WIDTH)+(3*`COLUMN_WIDTH))
			begin
				if (~tile1scored)
					score <= score + 1;
				tile1scored <= 1;
			end
			else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == (4*`BORDER_WIDTH)+(3*`COLUMN_WIDTH))
			begin
				if (~tile2scored)
					score <= score + 1;
				tile2scored <= 1;
			end
			else
				gameOver <= 1;
			col4pressed <= 0;
		end

		// if (col1pressed | col2pressed | col3pressed | col4pressed) begin
			
		// 	if (yStart > `RESOLUTION_HEIGHT - YSIZE & onScreen & xStart == `BORDER_WIDTH)
		// 	begin
		// 		if (~tile1scored)
		// 			score = score + 1;
		// 		tile1scored <= 1;
		// 		col1pressed <= 0;
		// 	end
		// 	else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == `BORDER_WIDTH)
		// 	begin
		// 		if (~tile2scored)
		// 			score = score + 1;
		// 		tile2scored <= 1;
		// 		col1pressed <= 0;
		// 	end

		// 	else if (yStart > `RESOLUTION_HEIGHT - YSIZE & onScreen & xStart == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
		// 	begin
		// 		if (~tile1scored)
		// 			score = score + 1;
		// 		tile1scored <= 1;
		// 		col2pressed <= 0;
		// 	end
		// 	else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
		// 	begin
		// 		if (~tile2scored)
		// 			score = score + 1;
		// 		tile2scored <= 1;
		// 		col2pressed <= 0;
		// 	end

		// 	else if (yStart > `RESOLUTION_HEIGHT - YSIZE & onScreen & xStart == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
		// 	begin
		// 		if (~tile1scored)
		// 			score = score + 1;
		// 		tile1scored <= 1;
		// 		col3pressed <= 0;
		// 	end
		// 	else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
		// 	begin
		// 		if (~tile2scored)
		// 			score = score + 1;
		// 		tile2scored <= 1;
		// 		col3pressed <= 0;
		// 	end
			
		// 	else if (yStart > `RESOLUTION_HEIGHT - YSIZE & onScreen & xStart == (4*`BORDER_WIDTH)+(3*`COLUMN_WIDTH))
		// 	begin
		// 		if (~tile1scored)
		// 			score = score + 1;
		// 		tile1scored <= 1;
		// 		col4pressed <= 0;
		// 	end
		// 	else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == (4*`BORDER_WIDTH)+(3*`COLUMN_WIDTH))
		// 	begin
		// 		if (~tile2scored)
		// 			score = score + 1;
		// 		tile2scored <= 1;
		// 		col4pressed <= 0;
		// 	end
		// 	else
		// 		gameOver <= 1;
		// end

		//Game Over Check
	if (yStart >= 55 && ~onScreen && ~tile1scored) begin
		gameOver <= 1;
	end
	if (yStart2 >= 55 && ~onScreen2 && ~tile2scored) begin
		gameOver <= 1;
	end

		// Tile generation
		if (nextTileEnable)
		begin
			random_column = lfsr[1:0]; 
			nextTileTime <= 1;

			// For first tile
			if (~onScreen)
			begin
				case (random_column)
                    2'b00: xStart <= `BORDER_WIDTH;
                    2'b01: xStart <= (2*`BORDER_WIDTH) + `COLUMN_WIDTH;
                    2'b10: xStart <= (3*`BORDER_WIDTH) + (2*`COLUMN_WIDTH);
                    2'b11: xStart <= (4*`BORDER_WIDTH) + (3*`COLUMN_WIDTH);
                endcase
				yStart <= 7'd0;
				drawTop <= 0;
				drawEnable <= 1;
				tile1scored <= 0;
				finished1 <= 0;
				onScreen <= 1;
			end

			// For second tile
			else if (~onScreen2)
			begin
				case (random_column)
                    2'b00: xStart2 <= `BORDER_WIDTH;
                    2'b01: xStart2 <= (2*`BORDER_WIDTH) + `COLUMN_WIDTH;
                    2'b10: xStart2 <= (3*`BORDER_WIDTH) + (2*`COLUMN_WIDTH);
                    2'b11: xStart2 <= (4*`BORDER_WIDTH) + (3*`COLUMN_WIDTH);
                endcase
				yStart2 <= 7'd0;
				drawTop2 <= 0;
				drawEnable2 <= 1;
				tile2scored <= 0;
				finished2 <= 0;
				onScreen2 <= 1;
			end
		end
		else
		begin
			nextTileTime <= nextTileTime + 1;
		end
		
		// animation updates
		if (tileShiftEnable)
		begin
			fast_count <= 22'd1;
			
			// First tile
			if (drawTop < YSIZE - 1 & onScreen)
			begin
				finished1 <= 0;
				drawTop <= drawTop + 1;
				drawEnable <= 1;
			end
			else if (yStart < `RESOLUTION_HEIGHT - 1 & onScreen)
			begin
				yStart <= yStart + 1;
				finished1 <= 0;
				eraseEnable <= 1;
			end
			else if (yStart == `RESOLUTION_HEIGHT - 1) // Puts the animation in a loop
			begin
				finished1 <= 1;
				onScreen <= 0;
			end
			
			// Second tile
			if (drawTop2 < YSIZE - 1 & onScreen2)
			begin
				finished2 <= 0;
				drawTop2 <= drawTop2 + 1;
				drawEnable2 <= 1;
			end
			else if (yStart2 < `RESOLUTION_HEIGHT - 1 & onScreen2)
			begin
				yStart2 <= yStart2 + 1;
				finished2 <= 0;
				eraseEnable2 <= 1;
			end
			else if (yStart2 == `RESOLUTION_HEIGHT - 1) // Puts the animation in a loop
			begin
				finished2 <= 1;
				onScreen2 <= 0;
			end
			
			// // Third tile
			// if (eraseBottom3 < 121 & yStart3 < 120 - YSIZE)
			// begin
			// 	eraseBottom3 <= yStart3;
			// end
			// else
			// begin
			// 	if (eraseBottom3 < 121)
			// 	begin
			// 		eraseBottom3 <= eraseBottom3 + 1;
			// 		continueEraseBottom3 <= 1;
			// 		finished3 <= 0;
					
			// 		if (eraseBottom3 == 120) // Puts the animation on loop
			// 		begin
			// 			if (xStart3 == `BORDER_WIDTH)
			// 				xStart3 <= (2*`BORDER_WIDTH)+`COLUMN_WIDTH;
			// 			else if (xStart3 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
			// 				xStart3 <= 8'd82;
			// 			else if (xStart3 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
			// 				xStart3 <= 8'd121;
			// 			else
			// 				xStart3 <= `BORDER_WIDTH;
			// 			yStart3 <= 7'd0;
			// 			drawTop3 <= 0;
			// 			eraseBottom3 <= 0;
			// 			drawEnable3 <= 1;
			// 		end
			// 	end
			// end
			
			// if (drawTop3 < YSIZE - 2)
			// begin
			// 	finished3 <= 0;
			// 	drawTop3 <= drawTop3 + 1;
			// 	continueDrawTop3 <= 1;
			// end
			// else if (yStart3 < 120 - YSIZE)
			// begin
			// 	finished3 <= 0;
			// 	eraseEnable3 <= 1;
			// end
			
			// // Fourth tile
			// if (eraseBottom4 < 121 & yStart4 < 120 - YSIZE)
			// begin
			// 	eraseBottom4 <= yStart4;
			// end
			// else
			// begin
			// 	if (eraseBottom4 < 121)
			// 	begin
			// 		eraseBottom4 <= eraseBottom4 + 1;
			// 		continueEraseBottom4 <= 1;
			// 		finished4 <= 0;
					
			// 		if (eraseBottom4 == 120) // Puts the animation on loop
			// 		begin
			// 			if (xStart4 == `BORDER_WIDTH)
			// 				xStart4 <= (2*`BORDER_WIDTH)+`COLUMN_WIDTH;
			// 			else if (xStart4 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
			// 				xStart4 <= 8'd82;
			// 			else if (xStart4 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
			// 				xStart4 <= 8'd121;
			// 			else
			// 				xStart4 <= `BORDER_WIDTH;
			// 			yStart4 <= 7'd0;
			// 			drawTop4 <= 0;
			// 			eraseBottom4 <= 0;
			// 			drawEnable4 <= 1;
			// 		end
			// 	end
			// end
			
			// if (drawTop4 < YSIZE - 2)
			// begin
			// 	finished4 <= 0;
			// 	drawTop4 <= drawTop4 + 1;
			// 	continueDrawTop4 <= 1;
			// end
			// else if (yStart4 < 120 - YSIZE)
			// begin
			// 	finished4 <= 0;
			// 	eraseEnable4 <= 1;
			// end
			
		end
		else
		begin
			fast_count <= fast_count + 22'd1;
		end

		
		// Draw a black tile ontop of the old white tile
		// First tile
		if (eraseEnable)
		begin
			xCount <= xStart;
			yCount <= yStart - 1;
			plot <= 0;
			continueErase <= 1;
			eraseEnable <= 0;
			VGA_COLOR <= `BACKGROUND;

			fast_count <= 22'd1; // No updates for fast_count
		end
		
		else if (continueErase) // Erases top of tile
		begin
			VGA_X <= xCount;
			VGA_Y <= yCount;
			VGA_COLOR <= `BACKGROUND;
			plot <= 1;
			
			xCount <= xCount + 1;
			
			if ((xCount - xStart) == XSIZE)
			begin
				continueErase <= 0;

				if (yStart < `RESOLUTION_HEIGHT - YSIZE + 1)
					drawEnable <= 1;
				else
					finished1 <= 1;
			end
		end
		
		// Tile drawings
		if (drawEnable) // Enables the draw top flag to create illusion of tile going on the screen
		begin
			xCount <= xStart;
			yCount <= yStart;
			plot <= 0;
			drawEnable <= 0;
			VGA_COLOR <= `TILES;
			if (drawTop < YSIZE - 1)
				continueDrawTop <= 1;
			else
				continueDraw <= 1;
			
			fast_count <= 22'd1;
		end
		
		else if (continueDrawTop)
		begin
			VGA_X <= xCount;
			VGA_Y <= drawTop;
			VGA_COLOR <= `TILES;
			plot <= 1;
			
			xCount <= xCount + 1;
			
			if (xCount - xStart == XSIZE)
			begin
				xCount <= xStart;
				continueDrawTop <= 0;
				finished1 <= 1;
			end
		end
		
		else if (continueDraw) 
		begin
			VGA_X <= xCount;
			VGA_Y <= yCount + YSIZE - 2;
			VGA_COLOR <= `TILES;
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
			xCount2 <= xStart2;
			yCount2 <= yStart2 - 1;
			plot <= 0;
			continueErase2 <= 1;
			eraseEnable2 <= 0;
			VGA_COLOR <= `BACKGROUND;

			fast_count <= 22'd1; // No updates for fast_count
		end
		
		else if (continueErase2 & finished1) // Erases top of tile
		begin
			VGA_X <= xCount2;
			VGA_Y <= yCount2;
			VGA_COLOR <= `BACKGROUND;
			plot <= 1;
			
			xCount2 <= xCount2 + 1;
			
			if ((xCount2 - xStart2) == XSIZE)
			begin
				continueErase2 <= 0;

				if (yStart2 < `RESOLUTION_HEIGHT - YSIZE + 1)
					drawEnable2 <= 1;
				else
					finished2 <= 1;
			end
		end
		
		// Tile drawings
		if (drawEnable2 & finished1) // Enables the draw top flag to create illusion of tile going on the screen
		begin
			xCount2 <= xStart2;
			yCount2 <= yStart2;
			plot <= 0;
			drawEnable2 <= 0;
			VGA_COLOR <= `TILES;
			if (drawTop2 < YSIZE - 1)
				continueDrawTop2 <= 1;
			else
				continueDraw2 <= 1;
			
			fast_count <= 22'd1;
		end
		
		else if (continueDrawTop2 & finished1)
		begin
			VGA_X <= xCount2;
			VGA_Y <= drawTop2;
			VGA_COLOR <= `TILES;
			plot <= 1;
			
			xCount2 <= xCount2 + 1;
			
			if (xCount2 - xStart2 == XSIZE)
			begin
				xCount2 <= xStart2;
				continueDrawTop2 <= 0;
				finished2 <= 1;
			end
		end
		
		else if (continueDraw2 & finished1) 
		begin
			VGA_X <= xCount2;
			VGA_Y <= yCount2 + YSIZE - 2;
			VGA_COLOR <= `TILES;
			plot <= 1;
			
			xCount2 <= xCount2 + 1;
			
			if ((xCount2 - xStart2) == XSIZE)
			begin
				continueDraw2 <= 0;
				finished2 <= 1;
			end
			
		end
		
		// // Third tile
		// if (eraseEnable3 & finished2 & finished1)
		// begin
		// 	if (yStart3 < 120 - YSIZE)
		// 	begin
		// 		xCount3 <= xStart3;
		// 		yCount3 <= yStart3;
		// 		plot <= 0;
		// 		continueErase3 <= 1;
		// 		eraseEnable3 <= 0;
		// 		VGA_COLOR <= `BACKGROUND;
		// 	end
		// 	fast_count <= 22'd1; // No updates for fast_count
		// end
		
		// else if (continueErase3 & finished2 & finished1) // Erases top of tile
		// begin
		// 	VGA_X <= xCount3;
		// 	VGA_Y <= yCount3;
		// 	VGA_COLOR <= `BACKGROUND;
		// 	plot <= 1;
			
		// 	xCount3 <= xCount3 + 1;
			
		// 	if ((xCount3 - xStart3) == XSIZE)
		// 	begin
		// 		continueErase3 <= 0;
				
		// 		if (yCount3 < 120)
		// 		begin
		// 			yStart3 <= yStart3 + 1;
		// 			drawEnable3 <= 1;
		// 		end
		// 	end
		// end
		
		// else if (continueEraseBottom3 & finished2 & finished1) // Erases tile from top to bottom, one row at a time
		// begin
		
		// 	VGA_X <= xCount3;
		// 	VGA_Y <= eraseBottom3;
		// 	VGA_COLOR <= `BACKGROUND;
		// 	if (eraseBottom3 < 121)
		// 		plot <= 1;
		// 	else
		// 		plot <= 0;
			
		// 	xCount3 <= xCount3 + 1;
			
		// 	if (xCount3 - xStart3 == XSIZE)
		// 	begin
		// 		continueEraseBottom3 <= 0;
		// 		finished3 <= 1;
		// 		xCount3 <= xStart3;
		// 	end
		// end
		
		// // Tile drawings
		// if (drawEnable3 & finished2 & finished1) // Enables the draw top flag to create illusion of tile going on the screen
		// begin
		// 	xCount3 <= xStart3;
		// 	yCount3 <= yStart3;
		// 	plot <= 0;
		// 	drawEnable3 <= 0;
		// 	VGA_COLOR <= `TILES;
		// 	continueDrawTop3 <= 1;
			
		// 	fast_count <= 22'd1;
		// end
		
		// else if (continueDrawTop3 & finished2 & finished1)
		// begin
		// 	VGA_X <= xCount3;
		// 	VGA_Y <= drawTop3;
		// 	VGA_COLOR <= `TILES;
		// 	if (drawTop3 < YSIZE - 2)
		// 		plot <= 1;
		// 	else
		// 		plot <= 0;
			
		// 	xCount3 <= xCount3 + 1;
			
		// 	if (drawTop3 == (YSIZE - 2))
		// 	begin
		// 		continueDrawTop3 <= 0;
		// 		continueDraw3 <= 1;
		// 		xCount3 <= xStart3;
		// 	end
			
		// 	else if (xCount3 - xStart3 == XSIZE)
		// 	begin
		// 		continueDrawTop3 <= 0;
		// 		finished3 <= 1;
		// 		xCount3 <= xStart3;
		// 	end
		// end
		
		// else if (continueDraw3 & finished2 & finished1) 
		// begin
		// 	VGA_X <= xCount3;
		// 	VGA_Y <= yCount3 + YSIZE - 2;
		// 	VGA_COLOR <= `TILES;
		// 	plot <= 1;
			
		// 	xCount3 <= xCount3 + 1;
			
		// 	if ((xCount3 - xStart3) == XSIZE)
		// 	begin
		// 		continueDraw3 <= 0;
		// 		finished3 <= 1;
		// 	end
		// end
		
		// // Fourth tile
		// if (eraseEnable4 & finished3 & finished2 & finished1)
		// begin
		// 	if (yStart4 < 120 - YSIZE)
		// 	begin
		// 		xCount4 <= xStart4;
		// 		yCount4 <= yStart4;
		// 		plot <= 0;
		// 		continueErase4 <= 1;
		// 		eraseEnable4 <= 0;
		// 		VGA_COLOR <= `BACKGROUND;
		// 	end
		// 	fast_count <= 22'd1; // No updates for fast_count
		// end
		
		// else if (continueErase4 & finished3 & finished2 & finished1) // Erases top of tile
		// begin
		// 	VGA_X <= xCount4;
		// 	VGA_Y <= yCount4;
		// 	VGA_COLOR <= `BACKGROUND;
		// 	plot <= 1;
			
		// 	xCount4 <= xCount4 + 1;
			
		// 	if ((xCount4 - xStart4) == XSIZE)
		// 	begin
		// 		continueErase4 <= 0;
				
		// 		if (yCount4 < 120)
		// 		begin
		// 			yStart4 <= yStart4 + 1;
		// 			drawEnable4 <= 1;
		// 		end
		// 	end
		// end
		
		// else if (continueEraseBottom4 & finished3 & finished2 & finished1) // Erases tile from top to bottom, one row at a time
		// begin
		
		// 	VGA_X <= xCount4;
		// 	VGA_Y <= eraseBottom4;
		// 	VGA_COLOR <= `BACKGROUND;
		// 	if (eraseBottom4 < 121)
		// 		plot <= 1;
		// 	else
		// 		plot <= 0;
			
		// 	xCount4 <= xCount4 + 1;
			
		// 	if (xCount4 - xStart4 == XSIZE)
		// 	begin
		// 		continueEraseBottom4 <= 0;
		// 		finished4 <= 1;
		// 		xCount4 <= xStart4;
		// 	end
		// end
		
		// // Tile drawings
		// if (drawEnable4 & finished3 & finished2 & finished1) // Enables the draw top flag to create illusion of tile going on the screen
		// begin
		// 	xCount4 <= xStart4;
		// 	yCount4 <= yStart4;
		// 	plot <= 0;
		// 	drawEnable4 <= 0;
		// 	VGA_COLOR <= `TILES;
		// 	continueDrawTop4 <= 1;
			
		// 	fast_count <= 22'd1;
		// end
		
		// else if (continueDrawTop4 & finished3 & finished2 & finished1)
		// begin
		// 	VGA_X <= xCount4;
		// 	VGA_Y <= drawTop4;
		// 	VGA_COLOR <= `TILES;
		// 	if (drawTop4 < YSIZE - 2)
		// 		plot <= 1;
		// 	else
		// 		plot <= 0;
			
		// 	xCount4 <= xCount4 + 1;
			
		// 	if (drawTop4 == (YSIZE - 2))
		// 	begin
		// 		continueDrawTop4 <= 0;
		// 		continueDraw4 <= 1;
		// 		xCount4 <= xStart4;
		// 	end
			
		// 	else if (xCount4 - xStart4 == XSIZE)
		// 	begin
		// 		continueDrawTop4 <= 0;
		// 		finished4 <= 1;
		// 		xCount4 <= xStart4;
		// 	end
		// end
		
		// else if (continueDraw4 & finished3 & finished2 & finished1) 
		// begin
		// 	VGA_X <= xCount4;
		// 	VGA_Y <= yCount4 + YSIZE - 2;
		// 	VGA_COLOR <= `TILES;
		// 	plot <= 1;
			
		// 	xCount4 <= xCount4 + 1;
			
		// 	if ((xCount4 - xStart4) == XSIZE)
		// 	begin
		// 		continueDraw4 <= 0;
		// 		finished4 <= 1;
		// 	end
		// end


		end 

		else begin
			if (~enableBackground & startedOnce)
			begin
				VGA_COLOR <= `GAMEOVER; // Blue

				// Increment x_count for each pixel
				x_count <= x_count + 1;

				// Checks for right edge
				if (x_count == `RESOLUTION_WIDTH -1) begin 
					x_count <= 0;
					y_count <= y_count + 1;
				end

				if (x_count == (`RESOLUTION_WIDTH - 1) & y_count == (`RESOLUTION_HEIGHT - 1)) begin
					startedOnce <= 0;

					// DESIM
					globalSpeed <= 22'd1000;
					timeBetweenTile <= 26'd100000;
					// 22'd4000 is standard for DESim (for globalSpeed)
					//BOARD
					// globalSpeed <= 22'd416666;
					// timeBetweenTile <= 26'd50000000; // corresponds to 1 second between each tile
					// 22'd416666 corresponds to roughly 20px/second
					// 22'd208333 corresponds to roughly 120px/second

					xStart <= `BORDER_WIDTH;
					yStart <= 7'd0;
					drawTop <= 0;
					drawEnable <= 1; // Makes the top line get drawn in
					tile1scored <= 0;
					finished1 <= 0;
					onScreen <= 1;
					
					xStart2 <= 8'd0;
					yStart2 <= 7'd0;
					drawTop2 <= 0;
					drawEnable2 <= 0;
					tile2scored <= 0;
					finished2 <= 0;
					onScreen2 <= 0;

					fast_count <= 1;
					nextTileTime <= 1;
				end

				// Assign the counters to VGA_X and VGA_Y
				VGA_X <= x_count;
				VGA_Y <= y_count;
			end
		end

		if (gameOver) gameOn <= 0;
		else gameOn <= 1;
	end
	
	// Test/debug code
//  assign LEDR[3:0] = {finished1, finished2, finished3, finished4};
//	assign LEDR[0] = continueDraw;
//  assign LEDR[1] = drawEnable;
//	assign LEDR[2] = plot;
//	assign LEDR[8] = eraseEnable;
//	assign LEDR[4] = tileShiftEnable;
//	assign LEDR[7] = continueEraseBottom;
// assign LEDR[7:0] = x_count;
// assign LEDR[7:1] = xStart2;
// assign LEDR[0] = nextTileEnable;
// assign LEDR[7:0] = score;

seven_seg_decoder display (score[7:0], HEX0, HEX1);
// seven_seg_decoder display (random_column + 8'd48, HEX0, HEX1);

// seven_seg_decoder H0 (yStart[3:0], HEX0);
// seven_seg_decoder H1 (yStart[6:4], HEX1);
// assign LEDR[9:4] = yStart;

// assign LEDR[0] = onScreen;
// assign LEDR[1] = tile1scored;
	
endmodule

module seven_seg_decoder(input [7:0] score_in, output reg [6:0] HEX0, output reg [6:0] HEX1);

    reg [3:0] score_tens;
    reg [3:0] score_ones;

    always @(*) begin

        if (score_in < 10) begin
            score_tens = 4'b0000;
            score_ones = score_in[3:0];
        end else begin
            score_tens = score_in / 10;
            score_ones = score_in % 10;
        end

        case (score_tens)
            4'b0000: HEX1 = 7'b1000000; // 0
            4'b0001: HEX1 = 7'b1111001; // 1
            4'b0010: HEX1 = 7'b0100100; // 2
            4'b0011: HEX1 = 7'b0110000; // 3
            4'b0100: HEX1 = 7'b0011001; // 4
            4'b0101: HEX1 = 7'b0010010; // 5
            4'b0110: HEX1 = 7'b0000010; // 6
            4'b0111: HEX1 = 7'b1111000; // 7
            4'b1000: HEX1 = 7'b0000000; // 8
            4'b1001: HEX1 = 7'b0010000; // 9
            default: HEX1 = 7'b1111111; // Blank (or error) for other values
        endcase

        case (score_ones)
            4'b0000: HEX0 = 7'b1000000; // 0
            4'b0001: HEX0 = 7'b1111001; // 1
            4'b0010: HEX0 = 7'b0100100; // 2
            4'b0011: HEX0 = 7'b0110000; // 3
            4'b0100: HEX0 = 7'b0011001; // 4
            4'b0101: HEX0 = 7'b0010010; // 5
            4'b0110: HEX0 = 7'b0000010; // 6
            4'b0111: HEX0 = 7'b1111000; // 7
            4'b1000: HEX0 = 7'b0000000; // 8
            4'b1001: HEX0 = 7'b0010000; // 9
            default: HEX0 = 7'b1111111;  // Blank (or error) for other values
        endcase


    end
endmodule

