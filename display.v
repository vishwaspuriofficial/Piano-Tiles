`define RESOLUTION_WIDTH 160 // Width of the screen
`define RESOLUTION_HEIGHT 120 // Height of the screen
`define COLUMN_WIDTH 35 
`define COLUMN_HEIGHT (`RESOLUTION_HEIGHT / 4)     // Height of each row 
`define BORDER_WIDTH 4       // Width of each border line
`define TILES 3'b000 //Black 
`define BACKGROUND 3'b111 //WHITE
`define BOUNDARY 3'b100 //RED
`define BORDER 3'b010 //GREEN
`define GAMEOVER 3'b001 //BLUE
`define CLICKED_COLOUR 3'b001 //BLUE


//DESIM
// module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR, HEX0, HEX1);
//BOARD
module display(CLOCK_50, SW, KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR, VGA_R, VGA_G, VGA_B,
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, HEX0, HEX1, HEX4, HEX5, PS2_CLK, PS2_DAT);

	// Initialize starting tile positions and VGA/draw states
	input CLOCK_50;	
	input [7:0] SW;
	input [3:0] KEY;
	output reg [7:0] VGA_X;                     
	output reg [6:0] VGA_Y;                     
	output reg [2:0] VGA_COLOR;                 
	output reg plot;                           
	output [9:0] LEDR;
	output [6:0] HEX1, HEX0, HEX4, HEX5;
	inout				PS2_CLK;
	inout				PS2_DAT;


	//BOARD
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK; 

	parameter XSIZE = `COLUMN_WIDTH-1, YSIZE = `COLUMN_HEIGHT;

	// Memory
	wire Write;
	reg [14:0] Address;
	wire [2:0] DataIn, DataOut;

	// instantiate memory module
	// module ram19200x3 (address, clock, data, wren, q);
	ram19200x3 U1 (Address, CLOCK_50, DataIn, Write, DataOut);
	
	// This is the blueprint for 1 tile falling down (on loop for all 4 columns)
	// Different flags to indicate which display stage the tile is at
	reg drawEnable;
	reg continueDraw;
	reg eraseEnable;
	reg continueErase;
	reg replaceTile1;
	reg continueReplace;
	
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
	reg replaceTile2;
	reg continueReplace2;
	
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
	reg replaceTile3;
	reg continueReplace3;
	
	reg continueDrawTop3;
	reg onScreen3;
	
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
	reg replaceTile4;
	reg continueReplace4;
	
	reg continueDrawTop4;
	reg onScreen4;
	
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
	reg [7:0] highScore;
	reg col1pressed, col2pressed, col3pressed, col4pressed;

	reg tile1scored;
	reg tile2scored;
	reg tile3scored;
	reg tile4scored;
	
	//Next tile timing system
	reg [25:0] nextTileTime; // number of clock cycles between this tile and the next

	// A few important constants
	reg [21:0] globalSpeed;
	reg [25:0] timeBetweenTile;

	//Random
	reg [1:0] random_column;
	reg [23:0] lfsr;

	//Keyboard
	wire ps2_key_pressed;
	wire [7:0] ps2_key_data; 
	reg [3:0] last_key; 

	reg [1:0] pressed;

	initial
	begin
		lfsr = 24'h800001;
		gameOn <= 1;
		gameOver <= 0;
		enableBackground <= 0;
		startedOnce <= 0;
		Address <= 0;

		pressed <= 2'b01;

		// DESIM
		// globalSpeed <= 22'd1000;
		// timeBetweenTile <= 26'd100000;
		// 22'd4000 is standard for DESim (for globalSpeed)
		//BOARD
		globalSpeed <= 22'd416666;
		timeBetweenTile <= 26'd50000000; // corresponds to 1 second between each tile
		// 22'd416666 corresponds to roughly 1 second for a tile to cross the screen
		// 22'd208333 corresponds to roughly 0.5 seconds for a tile to cross the screen

		score <= 0;
		highScore <= 0;

		xStart <= `BORDER_WIDTH;
		yStart <= 7'd0;
		drawTop <= 0;
		drawEnable <= 1; // Makes the top line get drawn in
		tile1scored <= 0;
		finished1 <= 0;
		onScreen <= 1;
		replaceTile1 <= 0;
		
		xStart2 <= 8'd0;
		yStart2 <= 7'd0;
		drawTop2 <= 0;
		drawEnable2 <= 0;
		tile2scored <= 0;
		finished2 <= 0;
		onScreen2 <= 0;
		replaceTile2 <= 0;
		
		xStart3 <= 8'd0;
		yStart3 <= 7'd0;
		drawTop3 <= 0;
		drawEnable3 <= 0;
		tile3scored <= 0;
		finished3 <= 0;
		onScreen3 <= 0;
		replaceTile3 <= 0;
		
		xStart4 <= 8'd0;
		yStart4 <= 7'd0;
		drawTop4 <= 0;
		drawEnable4 <= 0;
		tile4scored <= 0;
		finished4 <= 0;
		onScreen4 <= 0;
		replaceTile4 <= 0;

	end
	
	// Updates for tile movement and speed
	reg [21:0] fast_count;
	reg [25:0] second_count;

	assign tileShiftEnable = fast_count > globalSpeed; // Tile speed
	assign nextTileEnable = nextTileTime > timeBetweenTile; // Time between each tile

	//DESIM
	// assign secondEnable = second_count == 150000;

	//BOARD
	assign secondEnable = second_count == 50000000;

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


	//Keyboard
	PS2_Controller PS2 (
		.CLOCK_50(CLOCK_50),
		.reset(~KEY[0]),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.received_data(ps2_key_data),
		.received_data_en(ps2_key_pressed)
	);

	reg key3resetpress;
	reg key2resetpress;
	reg key1resetpress;
	reg key0resetpress;

	reg key3pressed;
	reg key2pressed;
	reg key1pressed;
	reg key0pressed;

	always @(posedge CLOCK_50) begin
        lfsr <= {lfsr[22:0], lfsr[23] ^ lfsr[22] ^ lfsr[17] ^ lfsr[16]};
    end

	// always @(posedge ps2_key_pressed) begin
		
	// end

	always@ (posedge CLOCK_50) begin

		if (ps2_key_pressed & ps2_key_data == 8'hF0)
		begin
			pressed <= 0;
			last_key <= 4'b1111;
		end
		else if (ps2_key_pressed & (pressed == 2'b00 | pressed == 2'b01))
		begin
			if (pressed == 2'b01)
			begin
				
				case (ps2_key_data)
					8'h1C: last_key[3] <= 0;
					8'h1B: last_key[2] <= 0;
					8'h23: last_key[1] <= 0;
					8'h2B: last_key[0] <= 0;
				endcase
			end
			
			pressed <= pressed + 1;
		end
		
		
		// Key press logic (same as negedge presses)
		if (last_key[3] == 0 & key3resetpress == 0)
		begin
			key3pressed <= 1;
			key3resetpress <= 1;
		end
		if (last_key[3] == 1)
		begin
			key3resetpress <= 0;
		end

		if (last_key[2] == 0 & key2resetpress == 0)
		begin
			key2pressed <= 1;
			key2resetpress <= 1;
		end
		if (last_key[2] == 1)
		begin
			key2resetpress <= 0;
		end

		if (last_key[1] == 0 & key1resetpress == 0)
		begin
			key1pressed <= 1;
			key1resetpress <= 1;
		end
		if (last_key[1] == 1)
		begin
			key1resetpress <= 0;
		end

		if (last_key[0] == 0 & key0resetpress == 0)
		begin
			key0pressed <= 1;
			key0resetpress <= 1;
		end
		if (last_key[0] == 1)
		begin
			key0resetpress <= 0;
		end


		if (key3pressed)
		begin
			if (~gameOver)
				col1pressed <= 1;
			else
				gameOver <= 0;
			key3pressed <= 0;
		end
		
		if (key2pressed) 
		begin
			if (~gameOver)
				col2pressed <= 1;
			else
				gameOver <= 0;
			key2pressed <= 0;
		end

		if (key1pressed) 
		begin
			if (~gameOver)
				col3pressed <= 1;
			else
				gameOver <= 0;
			key1pressed <= 0;
		end

		if (key0pressed) 
		begin
			if (~gameOver)
				col4pressed <= 1;
			else
				gameOver <= 0;
			key0pressed <= 0;
		end

		if (gameOn & ~startedOnce)
		begin
			enableBackground <= 1;
			startedOnce <= 1;

			score <= 0;
			fast_count <= 1;
			nextTileTime <= 1;
			second_count <= 1;
			Address <= 0;
			y_count <= 0;
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
				y_count <= 0;
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
				begin
					score <= score + 1;
					replaceTile1 <= 1;
				end
				tile1scored <= 1;
			end
			else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == `BORDER_WIDTH)
			begin
				if (~tile2scored)
				begin
					score <= score + 1;
					replaceTile2 <= 1;
				end
				tile2scored <= 1;
			end
			else if (yStart3 > `RESOLUTION_HEIGHT - YSIZE & onScreen3 & xStart3 == `BORDER_WIDTH)
			begin
				if (~tile3scored)
				begin
					score <= score + 1;
					replaceTile3 <= 1;
				end
				tile3scored <= 1;
			end
			else if (yStart4 > `RESOLUTION_HEIGHT - YSIZE & onScreen4 & xStart4 == `BORDER_WIDTH)
			begin
				if (~tile4scored)
				begin
					score <= score + 1;
					replaceTile4 <= 1;
				end
				tile4scored <= 1;
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
				begin
					score <= score + 1;
					replaceTile1 <= 1;
				end
				tile1scored <= 1;
			end
			else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
			begin
				if (~tile2scored)
				begin
					score <= score + 1;
					replaceTile2 <= 1;
				end
				tile2scored <= 1;
			end
			else if (yStart3 > `RESOLUTION_HEIGHT - YSIZE & onScreen3 & xStart3 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
			begin
				if (~tile3scored)
				begin
					score <= score + 1;
					replaceTile3 <= 1;
				end
				tile3scored <= 1;
			end
			else if (yStart4 > `RESOLUTION_HEIGHT - YSIZE & onScreen4 & xStart4 == (2*`BORDER_WIDTH)+`COLUMN_WIDTH)
			begin
				if (~tile4scored)
				begin
					score <= score + 1;
					replaceTile4 <= 1;
				end
				tile4scored <= 1;
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
				begin
					score <= score + 1;
					replaceTile1 <= 1;
				end
				tile1scored <= 1;
			end
			else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
			begin
				if (~tile2scored)
				begin
					score <= score + 1;
					replaceTile2 <= 1;
				end
				tile2scored <= 1;
			end
			else if (yStart3 > `RESOLUTION_HEIGHT - YSIZE & onScreen3 & xStart3 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
			begin
				if (~tile3scored)
				begin
					score <= score + 1;
					replaceTile3 <= 1;
				end
				tile3scored <= 1;
			end
			else if (yStart4 > `RESOLUTION_HEIGHT - YSIZE & onScreen4 & xStart4 == (3*`BORDER_WIDTH)+(2*`COLUMN_WIDTH))
			begin
				if (~tile4scored)
				begin
					score <= score + 1;
					replaceTile4 <= 1;
				end
				tile4scored <= 1;
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
				begin
					score <= score + 1;
					replaceTile1 <= 1;
				end
				tile1scored <= 1;
			end
			else if (yStart2 > `RESOLUTION_HEIGHT - YSIZE & onScreen2 & xStart2 == (4*`BORDER_WIDTH)+(3*`COLUMN_WIDTH))
			begin
				if (~tile2scored)
				begin
					score <= score + 1;
					replaceTile2 <= 1;
				end
				tile2scored <= 1;
			end
			else if (yStart3 > `RESOLUTION_HEIGHT - YSIZE & onScreen3 & xStart3 == (4*`BORDER_WIDTH)+(3*`COLUMN_WIDTH))
			begin
				if (~tile3scored)
				begin
					score <= score + 1;
					replaceTile3 <= 1;
				end
				tile3scored <= 1;
			end
			else if (yStart4 > `RESOLUTION_HEIGHT - YSIZE & onScreen4 & xStart4 == (4*`BORDER_WIDTH)+(3*`COLUMN_WIDTH))
			begin
				if (~tile4scored)
				begin
					score <= score + 1;
					replaceTile4 <= 1;
				end
				tile4scored <= 1;
			end
			else
				gameOver <= 1;
			col4pressed <= 0;
		end

	// Replace Tile colour with clicked colour
	// Tile 1
	if (replaceTile1)
	begin
		xCount <= xStart;
		yCount <= yStart;
		plot <= 0;
		continueReplace <= 1;
		replaceTile1 <= 0;
		VGA_COLOR <= `CLICKED_COLOUR;
	end

	else if (continueReplace) 
	begin
		VGA_X <= xCount;
		VGA_Y <= yCount;
		VGA_COLOR <= `CLICKED_COLOUR;
		plot <= 1;
		
		xCount <= xCount + 1;
		
		if ((xCount - xStart) == XSIZE)
		begin
			yCount <= yCount + 1;
			xCount <= xStart;
		end

		if (yCount == (`RESOLUTION_HEIGHT - 2) & (xCount - xStart) == XSIZE)
		begin
			continueReplace <= 0;
		end
	end

	// Tile 2
	if (replaceTile2)
	begin
		xCount2 <= xStart2;
		yCount2 <= yStart2;
		plot <= 0;
		continueReplace2 <= 1;
		replaceTile2 <= 0;
		VGA_COLOR <= `CLICKED_COLOUR;
	end

	else if (continueReplace2) 
	begin
		VGA_X <= xCount2;
		VGA_Y <= yCount2;
		VGA_COLOR <= `CLICKED_COLOUR;
		plot <= 1;
		
		xCount2 <= xCount2 + 1;
		
		if ((xCount2 - xStart2) == XSIZE)
		begin
			yCount2 <= yCount2 + 1;
			xCount2 <= xStart2;
		end

		if (yCount2 == (`RESOLUTION_HEIGHT - 2) & (xCount2 - xStart2) == XSIZE)
		begin
			continueReplace2 <= 0;
		end
	end

	// Tile 3
	if (replaceTile3)
	begin
		xCount3 <= xStart3;
		yCount3 <= yStart3;
		plot <= 0;
		continueReplace3 <= 1;
		replaceTile3 <= 0;
		VGA_COLOR <= `CLICKED_COLOUR;
	end

	else if (continueReplace3) 
	begin
		VGA_X <= xCount3;
		VGA_Y <= yCount3;
		VGA_COLOR <= `CLICKED_COLOUR;
		plot <= 1;
		
		xCount3 <= xCount3 + 1;
		
		if ((xCount3 - xStart3) == XSIZE)
		begin
			yCount3 <= yCount3 + 1;
			xCount3 <= xStart3;
		end

		if (yCount3 == (`RESOLUTION_HEIGHT - 2) & (xCount3 - xStart3) == XSIZE)
		begin
			continueReplace3 <= 0;
		end
	end
	
	// Tile 4
	if (replaceTile4)
	begin
		xCount4 <= xStart4;
		yCount4 <= yStart4;
		plot <= 0;
		continueReplace4 <= 1;
		replaceTile4 <= 0;
		VGA_COLOR <= `CLICKED_COLOUR;
	end

	else if (continueReplace4) 
	begin
		VGA_X <= xCount4;
		VGA_Y <= yCount4;
		VGA_COLOR <= `CLICKED_COLOUR;
		plot <= 1;
		
		xCount4 <= xCount4 + 1;
		
		if ((xCount4 - xStart4) == XSIZE)
		begin
			yCount4 <= yCount4 + 1;
			xCount4 <= xStart4;
		end

		if (yCount4 == (`RESOLUTION_HEIGHT - 2) & (xCount4 - xStart4) == XSIZE)
		begin
			continueReplace4 <= 0;
		end
	end

		//Game Over Check
	if (yStart >= 55 && ~onScreen && ~tile1scored) begin
		gameOver <= 1;
	end
	if (yStart2 >= 55 && ~onScreen2 && ~tile2scored) begin
		gameOver <= 1;
	end
	if (yStart3 >= 55 && ~onScreen3 && ~tile3scored) begin
		gameOver <= 1;
	end
	if (yStart4 >= 55 && ~onScreen4 && ~tile4scored) begin
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

			// For third tile
			else if (~onScreen3)
			begin
				case (random_column)
                    2'b00: xStart3 <= `BORDER_WIDTH;
                    2'b01: xStart3 <= (2*`BORDER_WIDTH) + `COLUMN_WIDTH;
                    2'b10: xStart3 <= (3*`BORDER_WIDTH) + (2*`COLUMN_WIDTH);
                    2'b11: xStart3 <= (4*`BORDER_WIDTH) + (3*`COLUMN_WIDTH);
                endcase
				yStart3 <= 7'd0;
				drawTop3 <= 0;
				drawEnable3 <= 1;
				tile3scored <= 0;
				finished3 <= 0;
				onScreen3 <= 1;
			end

			// For third tile
			else if (~onScreen4)
			begin
				case (random_column)
                    2'b00: xStart4 <= `BORDER_WIDTH;
                    2'b01: xStart4 <= (2*`BORDER_WIDTH) + `COLUMN_WIDTH;
                    2'b10: xStart4 <= (3*`BORDER_WIDTH) + (2*`COLUMN_WIDTH);
                    2'b11: xStart4 <= (4*`BORDER_WIDTH) + (3*`COLUMN_WIDTH);
                endcase
				yStart4 <= 7'd0;
				drawTop4 <= 0;
				drawEnable4 <= 1;
				tile4scored <= 0;
				finished4 <= 0;
				onScreen4 <= 1;
			end
		end
		else
		begin
			nextTileTime <= nextTileTime + 1;
		end

		// Speed updates
		if (secondEnable)
		begin
			second_count <= 26'd1;

			//DESIM
			// if (globalSpeed >= 500)
			// 	globalSpeed <= globalSpeed - 100;

			// if (timeBetweenTile >= 35000)
			// 	timeBetweenTile <= timeBetweenTile - 15000;

			//BOARD
			if (globalSpeed >= 228333)
				globalSpeed <= globalSpeed - 2000;

			if (timeBetweenTile >= 13250000)
				timeBetweenTile <= timeBetweenTile - 750000;

		end
		else
		begin
			second_count <= second_count + 1;
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
			
			// Third tile
			if (drawTop3 < YSIZE - 1 & onScreen3)
			begin
				finished3 <= 0;
				drawTop3 <= drawTop3 + 1;
				drawEnable3 <= 1;
			end
			else if (yStart3 < `RESOLUTION_HEIGHT - 1 & onScreen3)
			begin
				yStart3 <= yStart3 + 1;
				finished3 <= 0;
				eraseEnable3 <= 1;
			end
			else if (yStart3 == `RESOLUTION_HEIGHT - 1) // Puts the animation in a loop
			begin
				finished3 <= 1;
				onScreen3 <= 0;
			end
			
			// Fourth tile
			if (drawTop4 < YSIZE - 1 & onScreen4)
			begin
				finished4 <= 0;
				drawTop4 <= drawTop4 + 1;
				drawEnable4 <= 1;
			end
			else if (yStart4 < `RESOLUTION_HEIGHT - 1 & onScreen4)
			begin
				yStart4 <= yStart4 + 1;
				finished4 <= 0;
				eraseEnable4 <= 1;
			end
			else if (yStart4 == `RESOLUTION_HEIGHT - 1) // Puts the animation in a loop
			begin
				finished4 <= 1;
				onScreen4 <= 0;
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
		
		// Third tile
		if (eraseEnable3 & finished1 & finished2)
		begin
			xCount3 <= xStart3;
			yCount3 <= yStart3 - 1;
			plot <= 0;
			continueErase3 <= 1;
			eraseEnable3 <= 0;
			VGA_COLOR <= `BACKGROUND;

			fast_count <= 22'd1; // No updates for fast_count
		end
		
		else if (continueErase3 & finished1 & finished2) // Erases top of tile
		begin
			VGA_X <= xCount3;
			VGA_Y <= yCount3;
			VGA_COLOR <= `BACKGROUND;
			plot <= 1;
			
			xCount3 <= xCount3 + 1;
			
			if ((xCount3 - xStart3) == XSIZE)
			begin
				continueErase3 <= 0;

				if (yStart3 < `RESOLUTION_HEIGHT - YSIZE + 1)
					drawEnable3 <= 1;
				else
					finished3 <= 1;
			end
		end
		
		// Tile drawings
		if (drawEnable3 & finished1 & finished2) // Enables the draw top flag to create illusion of tile going on the screen
		begin
			xCount3 <= xStart3;
			yCount3 <= yStart3;
			plot <= 0;
			drawEnable3 <= 0;
			VGA_COLOR <= `TILES;
			if (drawTop3 < YSIZE - 1)
				continueDrawTop3 <= 1;
			else
				continueDraw3 <= 1;
			
			fast_count <= 22'd1;
		end
		
		else if (continueDrawTop3 & finished1 & finished2)
		begin
			VGA_X <= xCount3;
			VGA_Y <= drawTop3;
			VGA_COLOR <= `TILES;
			plot <= 1;
			
			xCount3 <= xCount3 + 1;
			
			if (xCount3 - xStart3 == XSIZE)
			begin
				xCount3 <= xStart3;
				continueDrawTop3 <= 0;
				finished3 <= 1;
			end
		end
		
		else if (continueDraw3 & finished1 & finished2) 
		begin
			VGA_X <= xCount3;
			VGA_Y <= yCount3 + YSIZE - 2;
			VGA_COLOR <= `TILES;
			plot <= 1;
			
			xCount3 <= xCount3 + 1;
			
			if ((xCount3 - xStart3) == XSIZE)
			begin
				continueDraw3 <= 0;
				finished3 <= 1;
			end
			
		end

		// Fourth tile
		if (eraseEnable4 & finished1 & finished2 & finished3)
		begin
			xCount4 <= xStart4;
			yCount4 <= yStart4 - 1;
			plot <= 0;
			continueErase4 <= 1;
			eraseEnable4 <= 0;
			VGA_COLOR <= `BACKGROUND;

			fast_count <= 22'd1; // No updates for fast_count
		end
		
		else if (continueErase4 & finished1 & finished2 & finished3) // Erases top of tile
		begin
			VGA_X <= xCount4;
			VGA_Y <= yCount4;
			VGA_COLOR <= `BACKGROUND;
			plot <= 1;
			
			xCount4 <= xCount4 + 1;
			
			if ((xCount4 - xStart4) == XSIZE)
			begin
				continueErase4 <= 0;

				if (yStart4 < `RESOLUTION_HEIGHT - YSIZE + 1)
					drawEnable4 <= 1;
				else
					finished4 <= 1;
			end
		end
		
		// Tile drawings
		if (drawEnable4 & finished1 & finished2 & finished3) // Enables the draw top flag to create illusion of tile going on the screen
		begin
			xCount4 <= xStart4;
			yCount4 <= yStart4;
			plot <= 0;
			drawEnable4 <= 0;
			VGA_COLOR <= `TILES;
			if (drawTop4 < YSIZE - 1)
				continueDrawTop4 <= 1;
			else
				continueDraw4 <= 1;
			
			fast_count <= 22'd1;
		end
		
		else if (continueDrawTop4 & finished1 & finished2 & finished3)
		begin
			VGA_X <= xCount4;
			VGA_Y <= drawTop4;
			VGA_COLOR <= `TILES;
			plot <= 1;
			
			xCount4 <= xCount4 + 1;
			
			if (xCount4 - xStart4 == XSIZE)
			begin
				xCount4 <= xStart4;
				continueDrawTop4 <= 0;
				finished4 <= 1;
			end
		end
		
		else if (continueDraw4 & finished1 & finished2 & finished3) 
		begin
			VGA_X <= xCount4;
			VGA_Y <= yCount4 + YSIZE - 2;
			VGA_COLOR <= `TILES;
			plot <= 1;
			
			xCount4 <= xCount4 + 1;
			
			if ((xCount4 - xStart4) == XSIZE)
			begin
				continueDraw4 <= 0;
				finished4 <= 1;
			end
			
		end

		end 

		else begin
			if (~enableBackground & startedOnce)
			begin
				// VGA_COLOR <= `GAMEOVER; // Blue
				Address <= Address + 1;
				VGA_COLOR <= DataOut;

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
					// globalSpeed <= 22'd1000;
					// timeBetweenTile <= 26'd100000;
					// 22'd4000 is standard for DESim (for globalSpeed)

					//BOARD
					globalSpeed <= 22'd416666;
					timeBetweenTile <= 26'd50000000; // corresponds to 1 second between each tile
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

					xStart3 <= 8'd0;
					yStart3 <= 7'd0;
					drawTop3 <= 0;
					drawEnable3 <= 0;
					tile3scored <= 0;
					finished3 <= 0;
					onScreen3 <= 0;

					xStart4 <= 8'd0;
					yStart4 <= 7'd0;
					drawTop4 <= 0;
					drawEnable4 <= 0;
					tile4scored <= 0;
					finished4 <= 0;
					onScreen4 <= 0;

					fast_count <= 1;
					nextTileTime <= 1;
					second_count <= 1;
				end

				// Assign the counters to VGA_X and VGA_Y
				VGA_X <= x_count;
				VGA_Y <= y_count;
			end
		end

		if (gameOver) gameOn <= 0;
		else gameOn <= 1;
		if (score > highScore) highScore <= score;

		if (KEY[0] == 0)
		begin
			highScore <= 0;
			score <= 0;
		end

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

// assign LEDR[3:0] = last_key;
// assign LEDR[5:4] = pressed;

seven_seg_decoder display (score[7:0], HEX0, HEX1);
seven_seg_decoder display2 (highScore[7:0], HEX4, HEX5);
// seven_seg_decoder display (random_column + 8'd48, HEX0, HEX1);

// seven_seg_decoder H0 (yStart[3:0], HEX0);
// seven_seg_decoder H1 (yStart[6:4], HEX1);
// assign LEDR[9:4] = yStart;

// assign LEDR[0] = onScreen;
// assign LEDR[1] = tile1scored;
// assign LEDR[0] = test;
	
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

