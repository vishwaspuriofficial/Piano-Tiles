`define RESOLUTION_WIDTH 160 // Width of the screen
`define RESOLUTION_HEIGHT 120 // Height of the screen
`define COLUMN_WIDTH ((`RESOLUTION_WIDTH - 3 * `BORDER_WIDTH) / 4)  
`define COLUMN_HEIGHT (`RESOLUTION_HEIGHT / 4)     // Height of each row 
`define BORDER_WIDTH 1       // Width of each border line

module initial(CLOCK_50, SW, KEY, HEX3, HEX2, HEX1, HEX0, VGA_X, VGA_Y, VGA_COLOR, plot);
	
	input CLOCK_50;	
	input [7:0] SW;
	input [3:0] KEY;
    output [6:0] HEX3, HEX2, HEX1, HEX0;
	output reg [7:0] VGA_X;                    
	output reg [6:0] VGA_Y;                     
	output reg [2:0] VGA_COLOR;                
	output reg plot;                           
	
    // Counters for X and Y coordinates
    reg [7:0] x_count = 0;
    reg [6:0] y_count = 0;

    // Instantiate the tile generators
    tile_generator tile_inst_0 (.CLOCK_50(CLOCK_50), .VGA_X(VGA_X), .VGA_Y(VGA_Y), .column(0), .tile_color(tile_color_out_0), .tile_plot(tile_plot_out_0));
    tile_generator tile_inst_1 (.CLOCK_50(CLOCK_50), .VGA_X(VGA_X), .VGA_Y(VGA_Y), .column(1), .tile_color(tile_color_out_1), .tile_plot(tile_plot_out_1));
    // tile_generator tile_inst_2 (.CLOCK_50(CLOCK_50), .VGA_X(VGA_X), .VGA_Y(VGA_Y), .column(2), .tile_color(tile_color_out_2), .tile_plot(tile_plot_out_2));
    tile_generator tile_inst_3 (.CLOCK_50(CLOCK_50), .VGA_X(VGA_X), .VGA_Y(VGA_Y), .column(3), .tile_color(tile_color_out_3), .tile_plot(tile_plot_out_3));


    // Generate VGA_X, VGA_Y, and plot signals
    always @(posedge CLOCK_50) begin
        plot <= 1'b1;

        // Determine if the current pixel is on a black vertical line
        if ( 
             (x_count >= `COLUMN_WIDTH + 1              && x_count < `COLUMN_WIDTH + `BORDER_WIDTH + 1) || 
             (x_count >= 2*`COLUMN_WIDTH + `BORDER_WIDTH + 1 && x_count < 2*`COLUMN_WIDTH + 2*`BORDER_WIDTH + 1) ||
             (x_count >= 3*`COLUMN_WIDTH + 2*`BORDER_WIDTH + 1 && x_count < 3*`COLUMN_WIDTH + 3*`BORDER_WIDTH + 1)
           ) begin
            VGA_COLOR <= 3'b010; // Black for the vertical lines
        end else begin
            VGA_COLOR <= 3'b111; // White for the rest of the screen
        end

        // Prioritize drawing the tiles if tile_plot is high
        if (tile_plot_out_0) VGA_COLOR <= tile_color_out_0;
        if (tile_plot_out_1) VGA_COLOR <= tile_color_out_1; 
        // if (tile_plot_out_2) VGA_COLOR <= tile_color_out_2; 
        if (tile_plot_out_3) VGA_COLOR <= tile_color_out_3; 

        // Increment x_count for each pixel
        x_count <= x_count + 1;

        // Checks for right edge
        if (x_count == `RESOLUTION_WIDTH -1) begin 
            x_count <= 0;
            y_count <= y_count + 1;
        end

        // Checks for bottom edge (Corrected line)
        if (y_count == `RESOLUTION_HEIGHT) begin
            y_count <= 0;
        end

        // Assign the counters to VGA_X and VGA_Y
        VGA_X <= x_count;
        VGA_Y <= y_count;
    end
endmodule

module tile_generator(
    input CLOCK_50,
    input [7:0] VGA_X,
    input [6:0] VGA_Y,
    input [1:0] column,   
    output reg [2:0] tile_color,
    output reg tile_plot
);

    // Internal signals for tile position
    reg [7:0] tile_x; 
    reg [6:0] tile_y = 0;

    // Calculate tile_x based on the column input
    always @(*) begin
        if (column == 0) begin
            // For column 0, make sure it starts exactly at 0 and has increased width
            tile_x = 0;  // Starts at 0
        end else begin
            // Calculate positions for other columns normally
            tile_x = column * (`COLUMN_WIDTH + `BORDER_WIDTH) - `BORDER_WIDTH;
        end
    end

    always @(posedge CLOCK_50) begin
        // Check if we are within the tile's boundaries
        if (column == 0) begin
            // Special case for column 0, extending width by 1
            if (VGA_X >= tile_x && VGA_X < tile_x + `COLUMN_WIDTH + 1 && 
                VGA_Y >= tile_y && VGA_Y < tile_y + `COLUMN_HEIGHT) begin
                tile_color <= 3'b000; // Set tile color (e.g., black)
                tile_plot <= 1'b1;    // Enable plotting for the tile
            end else begin
                tile_color <= 3'b000; // Default color outside the tile
                tile_plot <= 1'b0;    // Disable plotting outside the tile
            end
        end else begin
            // Regular behavior for other columns
            if (VGA_X >= tile_x && VGA_X < tile_x + `COLUMN_WIDTH && 
                VGA_Y >= tile_y && VGA_Y < tile_y + `COLUMN_HEIGHT) begin
                tile_color <= 3'b000; // Set tile color (e.g., black)
                tile_plot <= 1'b1;    // Enable plotting for the tile
            end else begin
                tile_color <= 3'b000; // Default color outside the tile
                tile_plot <= 1'b0;    // Disable plotting outside the tile
            end
        end
    end

endmodule

