#         .             .              .		  
#         |             |              |           .	  
# ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
# | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
# `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
#  ,|							  
#  `'							  
# Makefile

include config.mk

all: doit

doit: doit.o anim.o draw.o input.o update.o util.o

doit.o: doit.c doit.h anim.h draw.h input.h update.h util.c config.h

anim.o: anim.h

draw.o: draw.h

input.o: input.h

update.o: update.h

util.o: util.h

clean:
	rm -rf doit *.o

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	mkdir -p /home/gabrielzschmitz/${APPDIR}
	cp -f doit ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/doit

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/doit
	rm -rf ${DESTDIR}${PREFIX}/share/doit

