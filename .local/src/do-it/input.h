/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// input.h
*/
#ifndef INPUT_H_
#define INPUT_H_
#include <ncurses.h>

/* Defining some ASCII Keys */
# define ESC 27
# define ENTER 10
# define CTRLC 3
# define CTRLP 16
# define CTRLX 24
# define CTRLR 18
# define CTRLF 6
# define CTRLW 23
# define CTRLT 20

/* Handle user input and app state */
extern void handleInputs(appData *, projectlist *);

/* Handle input at the main menu */
extern void dashboardInput(appData *, char , projectlist *);
extern void mainMenuInput(appData *, char , projectlist *);

#endif

