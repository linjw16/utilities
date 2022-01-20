
all:
	python test.py

test:
ifeq ($(ARGIN),1)
	@echo "I am super!"
endif
