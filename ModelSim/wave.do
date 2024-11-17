onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
add wave -noupdate -label VGA_X -radix hexadecimal /testbench/VGA_X
add wave -noupdate -label VGA_Y -radix hexadecimal /testbench/VGA_Y
add wave -noupdate -label VGA_COLOR -radix hexadecimal /testbench/VGA_COLOR
add wave -noupdate -label plot -radix binary /testbench/plot
add wave -noupdate -divider display
add wave -noupdate -label x_count -radix hexadecimal /testbench/U1/x_count
add wave -noupdate -label y_count -radix hexadecimal /testbench/U1/y_count
add wave -noupdate -label xCount -radix hexadecimal /testbench/U1/xCount
add wave -noupdate -label yCount -radix hexadecimal /testbench/U1/yCount
add wave -noupdate -label drawTop -radix hexadecimal /testbench/U1/drawTop
add wave -noupdate -label drawEnable -radix binary /testbench/U1/drawEnable
add wave -noupdate -label continueDrawTop -radix binary /testbench/U1/continueDrawTop
add wave -noupdate -label continueDraw -radix binary /testbench/U1/continueDraw
add wave -noupdate -label eraseEnable -radix binary /testbench/U1/eraseEnable
add wave -noupdate -label continueErase -radix binary /testbench/U1/continueErase
add wave -noupdate -label xCount2 -radix hexadecimal /testbench/U1/xCount2
add wave -noupdate -label yCount2 -radix hexadecimal /testbench/U1/yCount2
add wave -noupdate -label xCount3 -radix hexadecimal /testbench/U1/xCount3
add wave -noupdate -label yCount3 -radix hexadecimal /testbench/U1/yCount3
add wave -noupdate -label xCount4 -radix hexadecimal /testbench/U1/xCount4
add wave -noupdate -label yCount4 -radix hexadecimal /testbench/U1/yCount4
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
