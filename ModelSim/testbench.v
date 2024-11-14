`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 20;

    reg CLOCK_50;	
	reg [7:0] SW;
	reg [3:0] KEY;
    wire [6:0] HEX3, HEX2, HEX1, HEX0;
	wire [7:0] VGA_X;
	wire [6:0] VGA_Y;
	wire [2:0] VGA_COLOR;

	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end

	initial begin
        SW[0] <= 1'b0;
        #10 SW[0] <= 1'b1;
	end // initial

	display U1 (CLOCK_50, SW[7:0], KEY, VGA_X, VGA_Y, VGA_COLOR, plot, LEDR);

endmodule
