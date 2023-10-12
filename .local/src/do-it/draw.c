/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// draw.c
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
#include <inttypes.h>

/* Print the empty dashboard */
void printEmptyDash(WIN *dash){
    const char* messages[] = {
        "No projects yet?",
        "try creating one",
        "by pressing 'a'"
    };

    const int length = (sizeof(messages) / sizeof(messages[0]));

    setColor(COLOR_WHITE, COLOR_BLACK, A_BOLD);
    for (int i = 0; i < length; i++)
        printfCenter(i - 1, dash->middley, dash->middlex, messages[i]);
}

/* Print the Main Menu */
void printMainMenu(appData *app, WIN *main, projectlist *list){
    const int starty = main->middley;
    const int startx = main->middlex;
    const int datelength = strlen(app->date) / 2;
    
    setColor(COLOR_BLACK, COLOR_BLACK, A_BOLD);
    printfCenter(-8, starty, startx, "Procrastination makes easy things hard");
    printfCenter(-7, starty, startx, "and hard things harder");

    printCat(app, main);

    setColor(COLOR_YELLOW, COLOR_BLACK, A_BOLD);
    mvprintw(starty + 4, startx - datelength + 1, "󰸗 %s", app->date);

    setColor(COLOR_RED, COLOR_BLACK, A_BOLD);
    mvprintw(starty + 7, startx - 8, "󱎫 Overdue Tasks : %d", app->overdueTasks);
    setColor(COLOR_YELLOW, COLOR_BLACK, A_BOLD);
    mvprintw(starty + 8, startx - 8, "󰏫 Pending Tasks : %d", app->pendingTasks);
    setColor(COLOR_GREEN, COLOR_BLACK, A_BOLD);
    mvprintw(starty + 9, startx - 8, "󰄳 Tasks Done    : %d", app->tasksDone);
}

/* Print the Todos */
void printTodos(appData *app, WIN *main, projectlist *list){
    int const MAXLength = main->width;
    int const startx = main->startx;

    int line = 1;
    for(int j = 0; j < list->projects[app->currentProject]->todosAmount; j++) {
        int titleLength = strlen(list->projects[app->currentProject]->todos[j]->title);
        int i = 0;

        while(i < titleLength && i < MAXLength){
            if(list->projects[app->currentProject]->todos[j]->check == 100){
                setColor(COLOR_GREEN, COLOR_BLACK, A_BOLD);
                mvprintw(line, startx + 5, "󰄲 ");
            }
            else if(list->projects[app->currentProject]->todos[j]->check == 50){
                setColor(COLOR_YELLOW, COLOR_BLACK, A_BOLD);
                mvprintw(line, startx + 5, "󰡖 ");
            }
            else{
                setColor(COLOR_RED, COLOR_BLACK, A_BOLD);
                mvprintw(line, startx + 5, "󰄱 ");
            }

            if(app->currentTodo == j){
                setColor(COLOR_WHITE, COLOR_BLACK, A_BOLD);
                mvprintw(line, startx + 2, " ");
            }
            else{
                setColor(COLOR_BLACK, COLOR_BLACK, A_NORMAL);
            }
            mvprintw(line, i + startx + 8, "%c", list->projects[app->currentProject]->todos[j]->title[i]);

            if(strcmp("none", list->projects[app->currentProject]->todos[j]->deadline) != 0){
                mvprintw(line, (MAXLength + startx) - 16, "󰃭 ");
                mvprintw(line, (MAXLength + startx) - 16 + 3, "%s", list->projects[app->currentProject]->todos[j]->deadline);
            }
            if(list->projects[app->currentProject]->todos[j]->urgency == 5){
                setColor(COLOR_MAGENTA, COLOR_BLACK, A_NORMAL);
                mvprintw(line, (MAXLength + startx) - 3, "󰎱 ");
            }
            else if(list->projects[app->currentProject]->todos[j]->urgency == 4){
                setColor(COLOR_RED, COLOR_BLACK, A_NORMAL);
                mvprintw(line, (MAXLength + startx) - 3, "󰎭 ");
            }
            else if(list->projects[app->currentProject]->todos[j]->urgency == 3){
                setColor(COLOR_YELLOW, COLOR_BLACK, A_NORMAL);
                mvprintw(line, (MAXLength + startx) - 3, "󰎪 ");
            }
            else if(list->projects[app->currentProject]->todos[j]->urgency == 2){
                setColor(COLOR_GREEN, COLOR_BLACK, A_NORMAL);
                mvprintw(line, (MAXLength + startx) - 3, "󰎧 ");
            }
            else{
                setColor(COLOR_GREEN, COLOR_BLACK, A_NORMAL);
                mvprintw(line, (MAXLength + startx) - 3, "󰎤 ");
            }
            i++;
        }
        line++;
    }
}

/* Print a window border */
void printWINBorder(WIN *win, int highlight){
    const int x = win->startx;
    const int y = win->starty;
    const int w = win->width;
    const int h = win->height;

    if (highlight == 0)
        setColor(COLOR_WHITE, COLOR_BLACK, A_NORMAL);
    else
        setColor(COLOR_CYAN, COLOR_BLACK, A_BOLD);

    mvaddch(y, x, ACS_ULCORNER);
    mvaddch(y, x + w, ACS_URCORNER);
    mvaddch(y + h, x, ACS_LLCORNER);
    mvaddch(y + h, x + w, ACS_LRCORNER);
    mvhline(y, x + 1, ACS_HLINE, w - 1);
    mvhline(y + h, x + 1, ACS_HLINE, w - 1);
    mvvline(y + 1, x, ACS_VLINE, h - 1);
    mvvline(y + 1, x + w, ACS_VLINE, h - 1);
}

void printBar(appData *app, projectlist *list){
    printInputMode(app);
    printTime(app);
    if(app->insertProjectTitle == 1){
        setColor(COLOR_BLACK, COLOR_BLACK, A_BOLD);
        mvprintw(app->y - 1, 10, "Adding new project: %s▏", list->projects[app->projectsAmount]->title);
    }
    if(app->insertSubprojectTitle == 1){
        setColor(COLOR_BLACK, COLOR_BLACK, A_BOLD);
        mvprintw(app->y - 1, 10, "Adding new subproject: %s▏", list->projects[app->projectsAmount]->subproject->title);
    }
}
void printInputMode(appData *app){
    const int y = app->y - 1;
    if(app->inputMode == 'n'){
        setColor(COLOR_WHITE, COLOR_GREEN, A_BOLD);
        mvprintw(y, 0, " NORMAL ");
        return;
    }
    else if(app->inputMode == 'i'){
        setColor(COLOR_WHITE, COLOR_CYAN, A_BOLD);
        mvprintw(y, 0, " INSERT ");
        return;
    }
    else if(app->inputMode == 'r'){
        setColor(COLOR_WHITE, COLOR_MAGENTA, A_BOLD);
        mvprintw(y, 0, " REPLACE ");
        return;
    }
    else if(app->inputMode == 'c'){
        setColor(COLOR_WHITE, COLOR_MAGENTA, A_BOLD);
        mvprintw(y, 0, " COMMAND ");
        return;
    }
    else
        return;
}

void printTime(appData *app){
    const int y = app->y - 1;
    const int x = app->x - 9;
    setColor(COLOR_WHITE, COLOR_MAGENTA, A_BOLD);
    mvprintw(y, x, " 󰥔 %s ", app->time);
}

/* Print the DashBoard projects */
void printDash(appData *app, WIN *dash, projectlist *list) {
    // size of the dashboard
    int const MAXLength = dash->width;

    int line = 1;
    // loop through all the projects
    for (int j = 0; j <= app->projectsAmount; j++) {
        int titleLength = strlen(list->projects[j]->title);
        int i = 0;
        int selected = 0;
        // print the first line 
        while(i < titleLength && i < MAXLength - selected){
            if(app->currentProject == j){
                selected = 5;
                setColor(COLOR_WHITE, COLOR_BLACK, A_BOLD);
                if(list->projects[j]->subproject != NULL)
                    mvprintw(line, 2, " ");
                else
                    mvprintw(line, 2, " ");
                mvprintw(line, i + 5, "%c", list->projects[j]->title[i]);

            }else{
                selected = 0;
                setColor(COLOR_BLACK, COLOR_BLACK, A_NORMAL);
                mvprintw(line, i + 5, "%c", list->projects[j]->title[i]);
            }
            i++;
        }
        // wrap the title if it exceeds MAXLength
        while(i < titleLength){
            line++;
            int remainingLength = MAXLength;
            while (i < titleLength && remainingLength > 0){
                if(app->currentProject == j)
                    setColor(COLOR_WHITE, COLOR_BLACK, A_BOLD);
                else
                    setColor(COLOR_BLACK, COLOR_BLACK, A_NORMAL);
                mvprintw(line, 2 + MAXLength - remainingLength, "%c", list->projects[j]->title[i]);
                i++;
                remainingLength--;
            }
        }
        line++;
        if(list->projects[j]->subproject != NULL){
            i = 0;
            selected = 4;
            int subtitleLength = strlen(list->projects[j]->subproject->title);
            while(i < subtitleLength && i < MAXLength - selected){
                if(app->currentProject == j){
                    selected = 7;
                    setColor(COLOR_WHITE, COLOR_BLACK, A_BOLD);
                    mvprintw(line, i + 7, "%c", list->projects[j]->subproject->title[i]);
                }
                else if(app->currentProject != j){
                    selected = 4;
                    setColor(COLOR_BLACK, COLOR_BLACK, A_NORMAL);
                    mvprintw(line, i + 7, "%c", list->projects[j]->subproject->title[i]);
                }
                i++;
            }
            while(i < subtitleLength){
                line++;
                int remainingLength = MAXLength + 2;
                while (i < subtitleLength && remainingLength > 0){
                    if(app->currentProject == j)
                        setColor(COLOR_WHITE, COLOR_BLACK, A_BOLD);
                    else
                        setColor(COLOR_BLACK, COLOR_BLACK, A_NORMAL);
                    mvprintw(line, 4 + MAXLength - remainingLength, "%c", list->projects[j]->subproject->title[i]);
                    i++;
                    remainingLength--;
                }
            }
            line++;
        }
    }
}

