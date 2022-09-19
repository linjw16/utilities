
## filename: dot/Makefile
## http://www.graphviz.org/Documentation.php

SRC ?= test

.PHONY: view all clean # $(SRC).png

all: view

view: $(SRC).png
	xdg-open $^

%.png:
	dot -Tpng $*.dot -o $@

clean:
	rm *.png -rf