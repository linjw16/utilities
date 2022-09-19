# Created on Wed Mar 16 2022
# 
# Copyright (c) 2022 IOA UCAS
# 
# @Filename:	 Makefile
# @Author:		 Jiawei Lin
# @Last edit:	 17:01:42
# 

## should be identity to the name defined in .c 
## The output module name. 
MOD_NAME_MK=mymod
MOD_MAJOR_MK=123
MOD_MINOR_MK=456
DEV_NAME_MK=mydev
## The source file name. 
OBJ=hello_dev

ifneq ($(KERNELRELEASE),)
	MOD_NAME ?= $(MOD_NAME_MK)
	$(MOD_NAME)-objs := $(OBJ).o
	obj-m := $(MOD_NAME).o
else
	KERNEL_DIR = /lib/modules/`uname -r`/build
	MODULEDIR := $(shell pwd)

	MOD_NAME ?= $(MOD_NAME_MK)
	MOD_MAJOR ?= $(MOD_MAJOR_MK)
	MOD_MINOR ?= $(MOD_MINOR_MK)
	DEV_NAME ?= $(DEV_NAME_MK)
endif
	
.PHONY: run

run: install.dump main.o
	./main.o
	@dmesg -T | grep $(MOD_NAME)

%.ko:
	@$(MAKE) -C $(KERNEL_DIR) M=$(MODULEDIR) modules

install.dump: $(MOD_NAME).ko
	@insmod $(MOD_NAME).ko
	@cat /proc/devices | grep $(MOD_NAME)
	@mknod /dev/$(DEV_NAME) c $(MOD_MAJOR) $(MOD_MINOR)
	@ls /dev/ | grep $(DEV_NAME)
	@ > install.dump

main.o: 
	@gcc ./hello_main.c -o main.o

uninstall: 
	@rm /dev/$(DEV_NAME) -f
	@rmmod $(MOD_NAME).ko
	@dmesg -C

clean:
	@rm -f *.o .*.o.d *.mod *.mod.c .*.*.cmd *.ko *.dwo *.order *.symvers
	@rm -rf .tmp_versions *.out *.dump
	@clear
	
distclean: clean  uninstall
