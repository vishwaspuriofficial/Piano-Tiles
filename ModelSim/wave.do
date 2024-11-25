onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
add wave -noupdate -label KEY -radix binary /testbench/KEY
add wave -noupdate -label VGA_X -radix hexadecimal /testbench/VGA_X
add wave -noupdate -label VGA_Y -radix hexadecimal /testbench/VGA_Y
add wave -noupdate -label VGA_COLOR -radix hexadecimal /testbench/VGA_COLOR
add wave -noupdate -label plot -radix binary /testbench/plot
add wave -noupdate -divider display
add wave -noupdate -label Address -radix hexadecimal /testbench/U1/Address
add wave -noupdate -label startedOnce -radix binary /testbench/U1/startedOnce
add wave -noupdate -label x_count -radix hexadecimal /testbench/U1/x_count
add wave -noupdate -label y_count -radix hexadecimal /testbench/U1/y_count
add wave -noupdate -label LFSR -radix hexadecimal /testbench/U1/lfsr
add wave -noupdate -label globalSpeed -radix hexadecimal /testbench/U1/globalSpeed
add wave -noupdate -label timeBetweenTile -radix hexadecimal /testbench/U1/timeBetweenTile
add wave -noupdate -label nextTileEnable -radix binary /testbench/U1/nextTileEnable
add wave -noupdate -label nextTileTime -radix hexadecimal /testbench/U1/nextTileTime
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {120 ns}
