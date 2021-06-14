CFLAGS=-O2 -Wall -Wextra -lX11
PREFIX=$(HOME)/.local
CACHE=$(shell if [ "$$XDG_CACHE_HOME" ]; then echo "$$XDG_CACHE_HOME"; else echo "$$HOME"/.cache; fi)

all: zerofetch

clean:
	rm -f zerofetch $(CACHE)/zerofetch

zerofetch: zerofetch.c zerofetch.h config.h
	$(eval battery_path := $(shell ./battery_config.sh))
	$(CC) zerofetch.c -o zerofetch $(CFLAGS) -D $(battery_path)
	strip zerofetch

install: zerofetch
	mkdir -p $(PREFIX)/bin
	install zerofetch $(PREFIX)/bin/zerofetch
