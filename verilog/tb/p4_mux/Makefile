# Copyright (c) 2021 Alex Forencich
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 0

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

export PORTS ?= 4

DUT      = p4_mux
WRAPPER  = $(DUT)_wrap_$(PORTS)
TOPLEVEL = $(WRAPPER)
MODULE   = testbench
VERILOG_SOURCES += $(WRAPPER).v
VERILOG_SOURCES += ../../rtl/$(DUT).v
VERILOG_SOURCES += ../../lib/axis/rtl/axis_arb_mux.v
VERILOG_SOURCES += ../../lib/axis/rtl/axis_mux.v
VERILOG_SOURCES += ../../lib/axis/rtl/arbiter.v
VERILOG_SOURCES += ../../lib/axis/rtl/priority_encoder.v

# module parameters
export PARAM_DATA_WIDTH ?= 8
export PARAM_KEEP_ENABLE ?= $(shell expr $(PARAM_DATA_WIDTH) \> 8 )
export PARAM_KEEP_WIDTH ?= $(shell expr \( $(PARAM_DATA_WIDTH) + 7 \) / 8 )
export PARAM_ID_ENABLE ?= 1
export PARAM_S_ID_WIDTH ?= 8
export PARAM_M_ID_WIDTH ?= $(shell python -c "print($(PARAM_S_ID_WIDTH) + ($(PORTS)-1).bit_length())")
export PARAM_DEST_ENABLE ?= 1
export PARAM_DEST_WIDTH ?= 8
export PARAM_USER_ENABLE ?= 1
export PARAM_USER_WIDTH ?= 1
export PARAM_LAST_ENABLE ?= 1
export PARAM_UPDATE_TID ?= 1
export PARAM_ARB_TYPE_ROUND_ROBIN ?= 0
export PARAM_ARB_LSB_HIGH_PRIORITY ?= 1

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += -P $(TOPLEVEL).DATA_WIDTH=$(PARAM_DATA_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).KEEP_ENABLE=$(PARAM_KEEP_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).KEEP_WIDTH=$(PARAM_KEEP_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).ID_ENABLE=$(PARAM_ID_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).M_ID_WIDTH=$(PARAM_M_ID_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).S_ID_WIDTH=$(PARAM_S_ID_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).DEST_ENABLE=$(PARAM_DEST_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).DEST_WIDTH=$(PARAM_DEST_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).USER_ENABLE=$(PARAM_USER_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).USER_WIDTH=$(PARAM_USER_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).LAST_ENABLE=$(PARAM_LAST_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).UPDATE_TID=$(PARAM_UPDATE_TID)
	COMPILE_ARGS += -P $(TOPLEVEL).ARB_TYPE_ROUND_ROBIN=$(PARAM_ARB_TYPE_ROUND_ROBIN)
	COMPILE_ARGS += -P $(TOPLEVEL).ARB_LSB_HIGH_PRIORITY=$(PARAM_ARB_LSB_HIGH_PRIORITY)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif
else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += -GDATA_WIDTH=$(PARAM_DATA_WIDTH)
	COMPILE_ARGS += -GKEEP_ENABLE=$(PARAM_KEEP_ENABLE)
	COMPILE_ARGS += -GKEEP_WIDTH=$(PARAM_KEEP_WIDTH)
	COMPILE_ARGS += -GID_ENABLE=$(PARAM_ID_ENABLE)
	COMPILE_ARGS += -GM_ID_WIDTH=$(PARAM_M_ID_WIDTH)
	COMPILE_ARGS += -GS_ID_WIDTH=$(PARAM_S_ID_WIDTH)
	COMPILE_ARGS += -GDEST_ENABLE=$(PARAM_DEST_ENABLE)
	COMPILE_ARGS += -GDEST_WIDTH=$(PARAM_DEST_WIDTH)
	COMPILE_ARGS += -GUSER_ENABLE=$(PARAM_USER_ENABLE)
	COMPILE_ARGS += -GUSER_WIDTH=$(PARAM_USER_WIDTH)
	COMPILE_ARGS += -GLAST_ENABLE=$(PARAM_LAST_ENABLE)
	COMPILE_ARGS += -GUPDATE_TID=$(PARAM_UPDATE_TID)
	COMPILE_ARGS += -GARB_TYPE_ROUND_ROBIN=$(PARAM_ARB_TYPE_ROUND_ROBIN)
	COMPILE_ARGS += -GARB_LSB_HIGH_PRIORITY=$(PARAM_ARB_LSB_HIGH_PRIORITY)

	ifeq ($(WAVES), 1)
		COMPILE_ARGS += --trace-fst
	endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

$(WRAPPER).v: $(DUT)_wrap.py
	./$< -p $(PORTS)

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	@rm -rf iverilog_dump.v
	@rm -rf dump.fst $(TOPLEVEL).fst
	@rm -rf *_wrap_*.v
	@rm *.xml
	@rm __pycache__/ -r
