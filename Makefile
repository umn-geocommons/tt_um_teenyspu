all:
	iverilog -o sim_teenyspu -I src src/tt_um_teenyspu.v src/teenyspu.v src/qteenyspu.v src/ops_library.v test/tb_tt_um_teenyspu.v
	vvp sim_teenyspu
	echo "Skipping gtkwave for now"
	#gtkwave sim_dump.vcd -S config-signals.tcl
