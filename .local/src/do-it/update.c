/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// update.c
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

/* Update time */
void updateTime(appData *app){
    time_t time_raw_format = time(NULL);
    struct tm *ptr_time = localtime(&time_raw_format);
    if(strftime(app->time, 6, "%H:%M", ptr_time) == 0)
        perror("Couldn't get current date");
}

/* Mode 0 (Main Menu) */
void updateMainMenu(appData *app) {
    frameTimer(app);

    /* Cat Animation */
    /* 0(1s), 1(1s), 2(1s), 3(15s) */
    if(app->frameTimer >= (15 * app->sfps))
        app->frameTimer = 0;
    int frame = app->frameTimer / app->sfps;
    if(app->frameTimer / app->sfps < 3) app->logoFrame = frame;
    else app->logoFrame = 3;

    if(app->emptyProjects != 1) app->currentMode = 1;
}

