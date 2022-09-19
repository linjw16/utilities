ARGIN ?= 1
# 目标外不能调用命令
ifeq ($(ARGIN), 1)
	# @echo "I am super!"
endif

include header.mk

.PHONY: clean
clean: 
	@echo "Cleaning..."


.PHONY: test
test:
	@echo "testing..."
# ifeq不能缩进
ifeq ($(ARGIN), 1)
	@echo "ifeq($$(ARGIN), 1)"
endif


python, py:
	python test.py


# 在子目录执行 TOPTARGETS 命令
TOPTARGETS := all clean
SUBDIRS := $(wildcard */.)
.PHONY: $(TOPTARGETS) $(SUBDIRS)
$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)