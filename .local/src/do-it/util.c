/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// util.c
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
#include <sys/stat.h>
#include <inttypes.h>

/* Initialize screen with colors, enabled keyboard and another little configs */
void initScreen(void){
#ifdef XCURSES
    Xinitscr(argc, argv);
#else
    initscr();
#endif
    if (has_colors()){
        if(BGTRANSPARENCY == 1)
            use_default_colors();
        int realbg;
        int bg = 0, fg = 0;
        start_color();
        for(bg = COLOR_BLACK; bg <= COLOR_WHITE; bg++)
            for(fg = COLOR_BLACK; fg <= COLOR_WHITE; fg++){
                if(BGTRANSPARENCY == 1)
                    realbg = -1;
                else
                    realbg = bg;
                init_pair(bg*PALLETE_SIZE + fg + 1, fg, realbg);
            }
    }
    /* User input dont appear at screen */
    noecho();
    /* Makes terminal report mouse movement events */
    mousemask(ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, NULL);
    printf("\033[?1003h\n");
    /* User input imediatly avaiable */
    mouseinterval(0);
    raw();
    /* Invisible cursor */
    curs_set(0);
    /* Non-blocking getch */
    nodelay(stdscr, TRUE);
    /* Enable keypad */
    keypad(stdscr, TRUE);
}

/* Set text foreground and background colors */
void setColor(short int fg, short int bg, chtype attr){
    chtype color = COLOR_PAIR(bg*PALLETE_SIZE + fg + 1);
    color |= attr;
    attrset(color);
}

/* Get the window X and Y size */
void getWindowSize(appData *app){
    getmaxyx(stdscr, app->y, app->x);
    app->middlex = app->x >> 1;
    app->middley = app->y >> 1;
}

/* Print at the center of given (x,y) */
void printfCenter(int y, int middley, int middlex, const char *format){
    int formatLength = strlen(format);
    int x = middlex - (formatLength / 2);
    mvprintw(middley + y, x + 1, "%s", format);
}

/* Allocate memory than copy macro to string */
char * createString(const char *string){
    size_t length = strlen(string) + 1;
    char *newString = malloc(length);
    
    if(newString != NULL)
        strncpy(newString, string, length);
    
    return newString;
}

// Function to create a new project
project *createProject(){
    project *newProject = (project *)malloc(sizeof(project));
    newProject->subproject = NULL;
    newProject->title = NULL;
    return newProject;
}

// Function to create a new project list
projectlist *createProjectList(projectlist *list){
    list = (projectlist *)malloc(sizeof(projectlist));
    return list;
}

// Function to deserialize a file
void deserializeProjects(FILE *file, project *proj, int indent, projectlist *list, appData *app){
    int totalIndent = (indent + 1) * strlen(INDENTATION_SPACES);
    int subprojectIndent = (indent + 2) * strlen(INDENTATION_SPACES);
    char line[INPUTMAXLENGTH];

    if(indent == 0 && app->projectsAmount == 0){
        proj->title = (char *)malloc(sizeof(char) * INPUTMAXLENGTH);
        fgets(line, sizeof(line), file);
        sscanf(line + 1, "%[^:]", proj->title);
    }

    proj->todosAmount = 0;
    while(fgets(line, sizeof(line), file)){
        if(strstr(line, "- title:") != NULL){
            proj->todos[proj->todosAmount] = (todo *)malloc(sizeof(todo));
            proj->todos[proj->todosAmount]->title = (char *)malloc(sizeof(char) * INPUTMAXLENGTH);

            strncpy(proj->todos[proj->todosAmount]->title, line + totalIndent + sizeof("- title:"), INPUTMAXLENGTH);
            strtok(proj->todos[proj->todosAmount]->title, "\n");

            fgets(line, sizeof(line), file);
            sscanf(line + totalIndent + sizeof("deadline: "), "%8s", proj->todos[proj->todosAmount]->deadline);

            fgets(line, sizeof(line), file);
            sscanf(line + totalIndent + sizeof("urgency: "), "%d", &(proj->todos[proj->todosAmount]->urgency));
            
            fgets(line, sizeof(line), file);
            sscanf(line + totalIndent + sizeof("check: "), "%d", &(proj->todos[proj->todosAmount]->check));

            proj->todosAmount++;
        }else if(line[subprojectIndent] == PROJECT_CHAR && line[subprojectIndent - 1] == ' '){
            proj->subproject = createProject();
            proj->subproject->title = (char *)malloc(sizeof(char) * INPUTMAXLENGTH);
            sscanf(line + subprojectIndent + 1, "%[^:]", proj->subproject->title);
            deserializeProjects(file, proj->subproject, indent + 1, list, app);
        }
        if(line[0] == PROJECT_CHAR){
            app->projectsAmount = app->projectsAmount + 1;
            list->projects[app->projectsAmount] = createProject();
            list->projects[app->projectsAmount]->title = (char *)malloc(sizeof(char) * INPUTMAXLENGTH);
            sscanf(line + 1, "%[^:]", list->projects[app->projectsAmount]->title);
            deserializeProjects(file, list->projects[app->projectsAmount], 0, list, app);
        }
    }
}

// Function to serialize a todo item
void serializeTodoItem(FILE *file, todo *item, int indent){
    int totalIndent = indent + 1;

    // Print indentation spaces
    for(int i = 0; i < indent; i++)
        fputs(INDENTATION_SPACES, file);
    
    // Print the title
    fprintf(file, "- title: %s\n", item->title);

    // Print indentation spaces for deadline and urgency 
    for(int i = 0; i < totalIndent; i++)
        fputs(INDENTATION_SPACES, file);

    // Print the deadline
    fprintf(file, "deadline: %s\n", item->deadline);

    // Print the urgency (only if indent > 0)
    if(indent > 0){
        for(int i = 0; i < totalIndent; i++)
            fputs(INDENTATION_SPACES, file);

        fprintf(file, "urgency: %d\n", item->urgency);
    }
    // Print the urgency (only if indent > 0)
    if(indent > 0){
        for(int i = 0; i < totalIndent; i++)
            fputs(INDENTATION_SPACES, file);

        fprintf(file, "check: %d\n", item->check);
    }
}

// Function to serialize a project
void serializeProject(FILE *file, project *proj, int indent){
    int totalIndent = indent + 1;

    for(int i = 0; i < indent; i++)
        fputs(INDENTATION_SPACES, file);

    fprintf(file, "%c", PROJECT_CHAR);
    fprintf(file, "%s:\n", proj->title);

    for(int i = 0; i < MAXTODOS && proj->todos[i] != NULL && proj->todos[i]->title != NULL; i++)
        serializeTodoItem(file, proj->todos[i], totalIndent);

    if(proj->subproject != NULL)
        serializeProject(file, proj->subproject, totalIndent);
}

/* Create a new project */
void addProjectTitle(appData *app, projectlist *list){
    app->projectsAmount = app->projectsAmount + 1;
    app->insertProjectTitle = 1;
    app->inputLength = 0;
    app->inputMode = 'i';
    list->projects[app->projectsAmount] = createProject();
    list->projects[app->projectsAmount]->title = (char *)malloc(sizeof(char) * INPUTMAXLENGTH);
    list->projects[app->projectsAmount]->title[0] = '\0';
}

/* Create a new subproject */
void addSubprojectTitle(appData *app, projectlist *list){
    if(list->projects[app->currentProject]->subproject != NULL)
        return;
    app->insertSubprojectTitle = 1;
    app->inputLength = 0;
    app->inputMode = 'i';
    list->projects[app->projectsAmount]->subproject = createProject();
    list->projects[app->projectsAmount]->subproject->title = (char *)malloc(sizeof(char) * INPUTMAXLENGTH);
    list->projects[app->projectsAmount]->subproject->title[0] = '\0';
}

/* Input project title */
void inputProjectTitle(appData *app, projectlist *list){
    if(app->userInput == KEY_BACKSPACE && app->inputLength > 0){
        list->projects[app->projectsAmount]->title[app->inputLength - 1] = '\0';
        app->inputLength -= 1;
    }
    else{
        if(app->userInput == ESC || (app->userInput == ENTER && app->inputLength < 1)){
            app->insertProjectTitle = 0;
            app->inputMode = 'n';
            app->projectsAmount -= 1;
            app->inputLength = 0;
        }
        else{
            list->projects[app->projectsAmount]->title[app->inputLength] = app->userInput;
            list->projects[app->projectsAmount]->title[app->inputLength + 1] = '\0';
            app->inputLength += 1;
            if((app->inputLength > INPUTMAXLENGTH - 1 && app->inputLength > 1) || (app->userInput == ENTER && app->inputLength > 1)){
                app->inputLength = 0;
                app->insertProjectTitle = 0;
                app->inputMode = 'n';
                app->emptyProjects = 0;
            }
        }
    }
}

/* Input subproject title */
void inputSubprojectTitle(appData *app, projectlist *list){
    if(app->userInput == KEY_BACKSPACE && app->inputLength > 0){
        list->projects[app->projectsAmount]->subproject->title[app->inputLength - 1] = '\0';
        app->inputLength -= 1;
    }
    else{
        if(app->userInput == ESC){
            app->insertSubprojectTitle = 0;
            app->inputMode = 'n';
        }
        else if(app->userInput == ENTER){
            if(app->inputLength > 0){
                app->inputLength = 0;
                app->insertSubprojectTitle = 0;
                app->inputMode = 'n';
                app->emptyProjects = 0;
            }
            else{
                list->projects[app->projectsAmount]->subproject->title = NULL;
                list->projects[app->projectsAmount]->subproject = NULL;
                app->inputLength = 0;
                app->insertSubprojectTitle = 0;
                app->inputMode = 'n';
                app->emptyProjects = 0;
            }
        }
        else{
            list->projects[app->projectsAmount]->subproject->title[app->inputLength] = app->userInput;
            list->projects[app->projectsAmount]->subproject->title[app->inputLength + 1] = '\0';
            app->inputLength += 1;
            if(app->inputLength > INPUTMAXLENGTH - 1){
                app->inputLength = 0;
                app->insertSubprojectTitle = 0;
                app->inputMode = 'n';
                app->emptyProjects = 0;
            }
        }
    }
}

/* Set the project folder and files */
void createProjectFile(appData * app){
    /* Get /home/user */
    char * home = getenv("HOME");
    int homeLen = strlen(home);

    /* Set log folder fullpath */
    char * appDir = NULL;
    appDir = malloc(homeLen + sizeof(char) + strlen(app->appDir) + 1);
    strcpy(appDir, home);
    strcat(appDir, "/");
    strcat(appDir, app->appDir);
    app->appDir = appDir;

    /* Set log file fullpath */
    char * projectsFile= NULL;
    projectsFile = malloc(homeLen + sizeof(char) + strlen(app->projectsFile) + 1);
    strcpy(projectsFile, home);
    strcat(projectsFile, "/");
    strcat(projectsFile, app->projectsFile);
    app->projectsFile = projectsFile;

    /* Create log folder */
    mkdir(app->appDir, 0766);

}

