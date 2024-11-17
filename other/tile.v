`define RESOLUTION_WIDTH 160
`define RESOLUTION_HEIGHT 120
`define COLUMN_WIDTH 35
`define COLUMN_HEIGHT (`RESOLUTION_HEIGHT / 6)
`define BORDER_WIDTH 4

module tile (
    input CLOCK_50,
    input tileShiftEnable,
    input [7:0] xStart,
    input [6:0] yStart_in,
    output reg [6:0] drawTop,
    output reg [6:0] eraseBottom,
    output reg drawEnable,
    output reg continueDraw,
    output reg eraseEnable,
    output reg continueErase,
    output reg continueDrawTop,
    output reg continueEraseBottom,
    output reg finished,
    output reg [7:0] xCount,
    output reg [6:0] yCount,
    output reg plot,
    output reg [2:0] VGA_COLOR,
    output reg [7:0] VGA_X,
    output reg [6:0] VGA_Y
);

  parameter XSIZE = `COLUMN_WIDTH - 1, YSIZE = `COLUMN_HEIGHT;
  reg [6:0] yStart;

  always @(posedge CLOCK_50) begin
    yStart <= yStart_in;
    if (tileShiftEnable) begin
      if (eraseBottom < `RESOLUTION_HEIGHT && yStart < `RESOLUTION_HEIGHT - YSIZE) begin
        eraseBottom <= yStart;
      end else begin
        if (eraseBottom < `RESOLUTION_HEIGHT) begin
          eraseBottom <= eraseBottom + 1;
          continueEraseBottom <= 1'b1;
          finished <= 1'b0;
          if (eraseBottom == `RESOLUTION_HEIGHT - 1) begin
            drawTop <= 7'd0;
            eraseBottom <= 7'd0;
            drawEnable <= 1'b1;
            finished <= 1'b1;
          end
        end
      end

      if (drawTop < YSIZE - 2) begin
        finished <= 1'b0;
        drawTop <= drawTop + 1;
        continueDrawTop <= 1'b1;
      end else if (yStart < `RESOLUTION_HEIGHT - YSIZE) begin
        finished <= 1'b0;
        eraseEnable <= 1'b1;
      end
    end
  end

  always @(posedge CLOCK_50) begin
    if (eraseEnable) begin
      if (yStart < `RESOLUTION_HEIGHT - YSIZE) begin
        xCount <= xStart;
        yCount <= yStart;
        plot <= 1'b0;
        continueErase <= 1'b1;
        eraseEnable <= 1'b0;
        VGA_COLOR <= 3'b000;
      end
    end else if (continueErase) begin
      VGA_X <= xCount;
      VGA_Y <= yCount;
      VGA_COLOR <= 3'b000;
      plot <= 1'b1;

      xCount <= xCount + 1;

      if ((xCount - xStart) == XSIZE) begin
        continueErase <= 1'b0;
        if (yCount < `RESOLUTION_HEIGHT - YSIZE) begin
          yStart <= yStart + 1;
          drawEnable <= 1'b1;
        end
      end
    end else if (continueEraseBottom) begin
      VGA_X <= xCount;
      VGA_Y <= eraseBottom;
      VGA_COLOR <= 3'b000;
      plot <= 1'b1;

      xCount <= xCount + 1;

      if (xCount - xStart == XSIZE) begin
        continueEraseBottom <= 1'b0;
        finished <= 1'b1;
        xCount <= xStart;
      end
    end else if (drawEnable) begin
      xCount <= xStart;
      yCount <= yStart;
      plot <= 1'b0;
      drawEnable <= 1'b0;
      VGA_COLOR <= 3'b111;
      continueDrawTop <= 1'b1;
    end else if (continueDrawTop) begin
      VGA_X <= xCount;
      VGA_Y <= drawTop;
      VGA_COLOR <= 3'b111;
      plot <= 1'b1;

      xCount <= xCount + 1;

      if (drawTop == (YSIZE - 2)) begin
        continueDrawTop <= 1'b0;
        continueDraw <= 1'b1;
        xCount <= xStart;
      end else if (xCount - xStart == XSIZE) begin
        continueDrawTop <= 1'b0;
        finished <= 1'b1;
        xCount <= xStart;
      end
    end else if (continueDraw) begin
      VGA_X <= xCount;
      VGA_Y <= yCount + YSIZE - 2;
      VGA_COLOR <= 3'b111;
      plot <= 1'b1;

      xCount <= xCount + 1;

      if ((xCount - xStart) == XSIZE) begin
        continueDraw <= 1'b0;
        finished <= 1'b1;
      end
    end
  end

endmodule
