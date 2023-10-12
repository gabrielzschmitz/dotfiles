/* .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// draw.h
*/
#ifndef DRAW_H_
#define DRAW_H_
#include <ncurses.h>

/* Print the empty dashboard */
extern void printEmptyDash(WIN  *);
extern void printDash(appData *, WIN *, projectlist *);

/* Print the Main Menu */
extern void printMainMenu(appData  *, WIN  *, projectlist *);
/* Print the Todos */
extern void printTodos(appData *, WIN *, projectlist *);

/* Print a window border */
extern void printWINBorder(WIN  *, int );

/* Print app bar */
extern void printBar(appData *, projectlist *);
extern void printInputMode(appData *);
extern void printTime(appData *);

#endif

