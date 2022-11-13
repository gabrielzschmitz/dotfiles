#         .             .              .		  
#         |             |              |           .	  
# ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
# | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
# `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
#  ,|							  
#  `'							  
#  Makefile
#
typer.c: typer.c.o util.o
	gcc -lcurses -o typer.c typer.c.o util.o

typer.c.o: typer.c.c util.h
	gcc -lcurses -c -g typer.c.c

util.o: util.c util.h
	gcc -lcurses -c -g util.c

clean:
	rm -rf typer.c

