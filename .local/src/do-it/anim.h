/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// anim.h
*/
#ifndef ANIM_H_
#define ANIM_H_
#include <ncurses.h>

/* Time the animations frames */
extern void frameTimer(appData *);

/* Printing the animations frames */
extern void printCat(appData *, WIN *);

#endif

