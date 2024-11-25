# stop any simulation that is currently running
quit -sim

# if simulating with a MIF file, copy it to the working folder. Assumes image.colour.mif
if {[file exists ../ram19200x3.mif]} {
	file delete ram19200x3.mif
	file copy ../ram19200x3.mif .
}

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../display.v ../ram19200x3.v
# compile the Verilog code of the testbench
vlog *.v
# start the Simulator, including some libraries that may be needed
vsim work.testbench -Lf 220model -Lf altera_mf_ver -Lf verilog
# show waveforms specified in wave.do
do wave.do
# advance the simulation the desired amount of time
run 5000000 ns
