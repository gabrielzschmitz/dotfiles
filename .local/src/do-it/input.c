
/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// input.c
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
#include <unistd.h>
#include <sys/types.h>
#include <inttypes.h>

#define CTRL(x)     ((x) & 0x1f)

/* Handle user input and app state */
void handleInputs(appData *app, projectlist *list){
    // Setting delay for ESC key
    ESCDELAY = 25;

    //MEVENT event;
    app->userInput = getch();

    if(app->inputMode == 'n'){
        switch(app->userInput){
            //case KEY_MOUSE:
            //    if(getmouse(&event) == OK)
            //        mouseInput(app, event, key);
	        //    break;

            case ' ':
                if(app->currentWIN == 'd')
                    app->currentWIN = 'm';
                else if(app->currentWIN == 'm')
                    app->currentWIN = 'd';
                else
                    break;
                break;

            case 'a':
                if(app->currentWIN == 'd')
                    dashboardInput(app, 'a', list);
                break;
            case 'A':
                if(app->currentMode == 1 && app->emptyProjects != 1 && 
                    list->projects[app->projectsAmount]->subproject == NULL 
                    && list->projects[app->projectsAmount]->title != NULL)
                    dashboardInput(app, 'A', list);
                break;


            case KEY_UP:
            case 'K':
            case 'k':
                if(app->currentMode == 1 && app->currentWIN == 'd')
                    dashboardInput(app, 'U', list);
                else if(app->currentMode == 1 && app->currentWIN == 'm')
                    mainMenuInput(app, 'U', list);
                break;

            case KEY_DOWN:
            case 'J':
            case 'j':
                if(app->currentMode == 1 && app->currentWIN == 'd')
                    dashboardInput(app, 'D', list);
                else if(app->currentMode == 1 && app->currentWIN == 'm')
                    mainMenuInput(app, 'D', list);
                break;

            case ESC:
            case CTRLC:
            case 'Q':
            case 'q':
                printf("\033[?1003l\n");
                endwin();
                printf("Goodbye!\n");
                exit(EXIT_SUCCESS);
                break;

            case KEY_RESIZE:
                endwin();
                initScreen();
                getWindowSize(app);
                clear();
                refresh();
                break;

            default:
                break;
        }
    }
    else if(app->inputMode == 'i'){
        if(app->insertProjectTitle == 1 && app->userInput != -1 && app->userInput != KEY_RESIZE && app->userInput != KEY_MOUSE){
            inputProjectTitle(app, list);
        }
        if(app->insertSubprojectTitle == 1 && app->userInput != -1 && app->userInput != KEY_RESIZE && app->userInput != KEY_MOUSE){
            inputSubprojectTitle(app, list);
        }
    }

    /* Throws away any typeahead that has been typed by
     * the user and has not yet been read by the program */
    flushinp();
}

/* Handle input at the main menu */
void dashboardInput(appData *app, char key, projectlist *list){
    switch(key){
        case 'a':
            addProjectTitle(app, list);
            break;
        case 'A':
            addSubprojectTitle(app, list);
            break;
        case 'U':
            if(app->currentProject > 0)
                app->currentProject -= 1;
            break;
        case 'D':
            if(app->currentProject < app->projectsAmount)
                app->currentProject += 1;
            break;
        default:
            break;
    }
}

void mainMenuInput(appData *app, char key, projectlist *list){
    switch(key){
        case 'U':
            if(app->currentTodo > 0)
                app->currentTodo -= 1;
            break;
        case 'D':
            if(app->currentTodo < list->projects[app->currentProject]->todosAmount - 1)
                app->currentTodo += 1;
            break;
        default:
            break;
    }
}

