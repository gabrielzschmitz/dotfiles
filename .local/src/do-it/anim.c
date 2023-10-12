/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// anim.c
*/
#include "doit.h"
#include "anim.h"
#include "draw.h"
#include "input.h"
#include "update.h"
#include "util.h"
#include "config.h"
#include <ncurses.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <locale.h>

/* Time the animations frames */
void frameTimer(appData *app) {
    const clock_t sec = 60 * CLOCKS_PER_SEC;
    const clock_t time = clock() + sec;

    if (clock() < time) {
        if (++app->framems >= app->sfps) {
            app->framems = 0;
            app->frameTimer++;
        }
    }
}

void printCat(appData *app, WIN *win){
    const char* logoFrames[] = {
        "  |\\      _,,,--,,_  ,)  ",
        "  /,`.-'`'   -,  ;-;;'   ",
        " |,4-  ) )-,_ ) /\\       ",
        "'---''(_/--' (_/-'       ",

        "  |\\      _,,,---,,_     ",
        "  /,`.-'`'    -.  ;-;;,_ ",
        " |,4-  ) )-,_..;\\ (  `'-'",
        "'---''(_/--'  `-'\\_)     ",

        "  |\\      _,,,,--,,_     ",
        "  /,`.-'`'    -,  ;-;,   ",
        " |,4-  ) ),,__ ) /;  ;;  ",
        "'---''(.'--'  (.'`.)     ",

        "  |\\      _,,,,--,,_     ",
        "  /,`.-'`'    -,  \\-;,   ",
        " |,4-  ) ),,__ ,\\ (  ;;  ",
        "'---''(.'--'  `-'`.)`'   "
    };

    int frameIndex = app->logoFrame * 4;
    int starty = win->middley - 2;
    int startx = win->middlex - 12 + 1;

    setColor(COLOR_WHITE, COLOR_BLACK, A_BOLD);
    for (int i = 0; i < 4; i++)
        mvprintw(starty + i, startx, "%s", logoFrames[frameIndex + i]);

    setColor(COLOR_BLACK, COLOR_BLACK, A_BOLD);
    mvprintw(win->middley, win->middlex - 9 + 1, "4");
}

