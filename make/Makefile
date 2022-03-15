ARGIN ?= 1
# 目标外不能调用命令
ifeq ($(ARGIN), 1)
	# @echo "I am super!"
endif


python, py:
	python test.py

test:
	@echo "I am super!"

# ifeq不能缩进
ifeq ($(ARGIN), 1)
	@echo "I am super!"
endif


# 在子目录执行 TOPTARGETS 命令
TOPTARGETS := all clean
SUBDIRS := $(wildcard */.)
.PHONY: $(TOPTARGETS) $(SUBDIRS)
$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)