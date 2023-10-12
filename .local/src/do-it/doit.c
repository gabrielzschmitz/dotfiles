/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
//  doit.c
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
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <locale.h>
#include <unistd.h>

#define FPS 60

/* Initialize window */
void refreshWIN(WIN *win, int h, int w, int y, int x){
	win->height = h;
	win->width = w;
	win->starty = y;	
	win->startx = x;
    win->middley = (h >> 1) + y;
    win->middlex = (w >> 1) + x;
}

/* Initialize variables */
void initApp(appData *app, projectlist *list){
    /* One second based in the grames per second */
    app->sfps = sqrt(FPS);
    
    /* Animation variables */
    app->frameTimer = 0;
    app->framems = 0;
    app->logoFrame = 0;

    /* Get todays date (18 = max length) */
    time_t time_raw_format = time(NULL);
    struct tm *ptr_time = localtime(&time_raw_format);
    if(strftime(app->date, 18, "%A, %b %d", ptr_time) == 0)
        perror("Couldn't get current date");

    /* Task variables */
    app->overdueTasks = 0;
    app->pendingTasks = 0;
    app->tasksDone= 0;
    app->projectsAmount = 0;
    app->todosAmount = 0;
    app->projectIndex = 0;
    
    /* Misc variables */
    app->currentTodo = 0;
    app->currentProject = 0;
    app->emptyProjects = 1;
    app->menuPos = 0;
    app->currentMode = 0;
    app->currentWIN = 'd';
    app->inputMode = 'n';
    app->insertSubprojectTitle = 0;
    app->insertProjectTitle = 0;
    app->inputLength = 0;

    /* File variables */
    app->appDir = createString(APPDIR);
    app->projectsFile = createString(PROJECTSFILE);

    createProjectFile(app);
    list->projects[0] = createProject();
    FILE *projectsFile = fopen(app->projectsFile, "r");
    if(projectsFile != NULL){
        deserializeProjects(projectsFile, list->projects[0], 0, list, app);
        app->emptyProjects = 0;
    }
    fclose(projectsFile);
}

/* Update variables */
void doUpdate(appData *app, WIN *dash, WIN *main, projectlist *list){
    /* Get X and Y total window size */
    getWindowSize(app);

    /* Update all the app modes */
    switch(app->currentMode){
        case 0:
            updateTime(app);
            updateMainMenu(app);
            break;
        case 1:
            break;
        default:
            break;
    }

    /* Initialize and refresh windows sizes */
    refreshWIN(dash, (app->y - 2), (app->x >> 2), 0, 0);
    refreshWIN(main, (app->y - 2), ((app->x - dash->width) - 2), 0, (dash->width + 1));
}

/* Print at screen */
void drawScreen(appData *app, WIN *dash, WIN *main, projectlist *list){
    erase();

    switch(app->currentMode){
        case 0:
            if(app->emptyProjects == 1)
                printEmptyDash(dash);
            printMainMenu(app, main, list);
            printWINBorder(dash, (app->currentWIN == 'd'));
            printWINBorder(main, (app->currentWIN == 'm'));
            printBar(app, list);
            break;
        case 1:
            printDash(app, dash, list);
            printTodos(app, main, list);
            printWINBorder(dash, (app->currentWIN == 'd'));
            printWINBorder(main, (app->currentWIN == 'm'));
            printBar(app, list);
            break;
        default:
            break;
    }
    refresh();
}

/* Putting it all together */
int main(int argc, char *argv[]){
    /* Enable Emojis */
    setlocale(LC_CTYPE, "");

    /* Creating the app struct */
    appData app;
    projectlist list;
    WIN dash;
    WIN main;

    /* Initializing the app */
    initScreen();
    createProjectList(&list);
    initApp(&app, &list);
    getWindowSize(&app);

    /* Main app loop */
    while(1){
        handleInputs(&app, &list);
        doUpdate(&app, &dash, &main, &list);
        drawScreen(&app, &dash, &main, &list);

        /* Setting the screen refresh rate to 60 */
        napms(1000 / FPS);
    }

    /* Makes terminal stop reporting mouse movement events */
    printf("\033[?1003l\n");

    /* Endding the screen created at initScreen */
    endwin();

    return 0;
}

