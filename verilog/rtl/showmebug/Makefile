

DUT ?= test
VERILOG_SOURCES = sequence_detect.v
TESTBENCH ?= $(DUT)_tb.v

.PHONY: clean wave *.out *.vcd

all: wave

%.out:
	iverilog $(TESTBENCH) -y ./ -o $@

%.vcd: a.out
	vvp -n $< -o $@ -ltx2

wave: out.vcd
	gtkwave out.vcd

clean:
	@rm -rf *.vcd *.out