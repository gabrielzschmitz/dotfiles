#         .             .              .		  
#         |             |              |           .	  
# ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
# | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
# `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
#  ,|							  
#  `'							  
# GITHUB:https://github.com/gabrielzschmitz		  
# INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/   
# DOTFILES:https://github.com/gabrielzschmitz/dotfiles/   
# dmenu - dynamic menu
# See LICENSE file for copyright and license details.

include config.mk

SRC = drw.c dmenucenter.c stest.c util.c
OBJ = $(SRC:.c=.o)

all: options dmenucenter stest

options:
	@echo dmenucenter build options:
	@echo "CFLAGS   = $(CFLAGS)"
	@echo "LDFLAGS  = $(LDFLAGS)"
	@echo "CC       = $(CC)"

.c.o:
	$(CC) -c $(CFLAGS) $<

$(OBJ): arg.h config.h config.mk drw.h

dmenucenter: dmenucenter.o drw.o util.o
	$(CC) -o $@ dmenucenter.o drw.o util.o $(LDFLAGS)

stest: stest.o
	$(CC) -o $@ stest.o $(LDFLAGS)

clean:
	rm -f dmenucenter stest $(OBJ) dmenucenter-$(VERSION).tar.gz *.orig *.rej

dist: clean
	mkdir -p dmenucenter-$(VERSION)
	cp LICENSE Makefile README arg.h config.mk dmenucenter.1\
		drw.h util.h dmenucenter_path dmenu_run stest.1 $(SRC)\
		dmenucenter-$(VERSION)
	tar -cf dmenucenter-$(VERSION).tar dmenucenter-$(VERSION)
	gzip dmenucenter-$(VERSION).tar
	rm -rf dmenucenter-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f dmenucenter dmenucenter_path dmenucenter_run stest $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenucenter
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenucenter_path
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenucenter_run
	chmod 755 $(DESTDIR)$(PREFIX)/bin/stest
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed "s/VERSION/$(VERSION)/g" < dmenucenter.1 > $(DESTDIR)$(MANPREFIX)/man1/dmenucenter.1
	sed "s/VERSION/$(VERSION)/g" < stest.1 > $(DESTDIR)$(MANPREFIX)/man1/stest.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/dmenucenter.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/stest.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dmenucenter\
		$(DESTDIR)$(PREFIX)/bin/dmenucenter_path\
		$(DESTDIR)$(PREFIX)/bin/dmenucenter_run\
		$(DESTDIR)$(PREFIX)/bin/stest\
		$(DESTDIR)$(MANPREFIX)/man1/dmenucenter.1\
		$(DESTDIR)$(MANPREFIX)/man1/stest.1

.PHONY: all options clean dist install uninstall
