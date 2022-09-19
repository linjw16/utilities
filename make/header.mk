



# Comment should have no indent
.PHONY: print


%.t: clean
	@echo "%.t"
	@echo $$\*		 = $* 


print: clean print.t
## 1. 前缀$标识的转义符
# $@ 	目标名
# $* 	这个变量表示目标模式中“%”及其之前的部分。
# $^ 	表示所有的依赖文件
# $+ 	这个变量很像“$^”，也是所有依赖目标的集合。只是它不去除重复的依赖目标。
# $? 	表示比目标还要新的依赖文件列表
# $< 	表示第一个依赖文件
# $% 	当目标是.a、.lib等库文件时，它表示目标名，否则为空。
	@echo $$\@		 = $@ 
	@echo $$\*		 = $* 
	@echo $$^		 = $^ 
	@echo $$+		 = $+ 
	@echo $$\?		 = $? 
	@echo $$\<		 = $< 
	@echo $$%		 = $% 
	@echo $$\x		 = $x 

## 2. 在shell中解析取值的符号
# 在shell中echo * 得到当前目录所有文件。
# 在shell中echo $$ 得到当前的PID，一般用于临时文件的唯一命名。
	@echo \$$$$\?	 = $$? 
	@echo \*		 = *
	@echo \$$$$\$$$$ = $$$$

## 3. 以$()修饰的宏定义
	@echo KERNELRELEASE		 = $(KERNELRELEASE)
	@echo TOPTARGETS		 = $(TOPTARGETS) 
	@echo SUBDIRS			 = $(SUBDIRS)
	@echo MAKE				 = $(MAKE)
	@echo MAKECMDGOALS		 = $(MAKECMDGOALS)
	@echo KERNEL_SRC		 = $(KERNEL_SRC)
	@echo DESTDIR			 = $(DESTDIR)
	@echo PREFIX			 = $(PREFIX)
	@echo CC				 = $(CC)
	@echo @F				 = $(@F)
	@echo LDFLAGS			 = $(LDFLAGS)
	@echo wildcard \*\.mk	 = $(wildcard *.mk)

	@echo shell pwd			 = $(shell pwd)
	@echo PATH = $$PATH

