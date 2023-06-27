# (C) 2023 Michael Schaeferling, Augsburg University of Applied Sciences


GHDL=ees-ghdl
#GHDL=/opt/ghdl/bin/ghdl


all: prog



#~ .PHONY: sim
#~ sim: random.vhdl algorithmus.vhdl reaction.vhdl reaction_tb.vhdl
#~ 	$(GHDL) -a $^
#~ 	time $(GHDL) -r reaction_tb --wave=reaction_tb.ghw
#~ 	#gtkwave -A reaction_tb.ghw reaction_tb.sav &


#~ .PHONY: sim_algo
#~ sim_algo: random.vhdl algorithmus.vhdl algorithmus_tb.vhdl
#~ 	$(GHDL) -a $^
#~ 	$(GHDL) -r algorithmus_tb --wave=algorithmus_tb.ghw
#~ 	gtkwave -A algorithmus_tb.ghw algorithmus_tb.sav &



##### Synthesis & implementation (Xilinx) #####

.PHONY: syn
syn: reaction.bit

reaction.bit: zybo-reaction.xdc reaction.vhdl algorithmus.vhdl random.vhdl
	ees-synthesize -b $^

.PHONY: prog
prog: reaction.bit
	ees-program $^



##### Clean #####

clean:
	$(GHDL) --remove || true
	rm -fr *.ghw *.o *.dcp *.bit *.log reaction-ees reaction*-synthesize.tcl reaction*-program.tcl usage_statistics_webtalk.* .Xil

