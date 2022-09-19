HDF ?= ../../soc/fpga.xsa

# shortcut to build PetaLinux project including boot files
build-boot:
	$(MAKE) build
	$(MAKE) package-boot

.PHONY: build-boot
