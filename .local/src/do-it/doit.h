/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// doit.h
*/
#ifndef DOIT_H_
#define DOIT_H_
#include <ncurses.h>

/* Defining some limits */
#define MAXPROJECTS 25
#define MAXTODOS 25
#define INPUTMAXLENGTH 64

/* Defining files specifics */
#define INDENTATION_SPACES "  "
#define PROJECT_CHAR '+'

// Defining the todo's struct
typedef struct todo todo;
struct todo{
    char *title;
    char deadline[9];
    int urgency;
    int check;
};

// Defining the projects struct
typedef struct project project;
struct project{
    char *title;
    int todosAmount;
    todo *todos[MAXTODOS];
    struct project *subproject;
};

// Defining the projects struct
typedef struct projectlist projectlist;
struct projectlist{
    project *projects[MAXPROJECTS];
};


/* Defining the window struct */
typedef struct WIN WIN;
struct WIN{
	int startx, starty;
	int height, width;
	int middlex, middley;
};

/* Defining the app struct */
typedef struct appData appData;
struct appData{
    int currentProject;
    int emptyProjects;
    int currentTodo;
    int todosAmount;
    int projectsAmount;
    int projectIndex;
    int inputLength;
    int insertSubprojectTitle;
    int insertProjectTitle;
    char inputMode;
    char *appDir;
    char *projectsFile;
    char currentWIN;
    int overdueTasks;
    int pendingTasks;
    int tasksDone;
    char time[6];
    char date[18];
    int menuPos;
    int framems;
    int frameTimer;
    int logoFrame;
    int sfps;
    int userInput;
    int currentMode;
    int middlex;
    int middley;
    int x;
    int y;
};

/* Initialize window */
extern void initWIN(WIN *, int , int , int , int );

/* Initialize variables */
extern void initApp(appData *, projectlist *);

/* Update variables */
extern void doUpdate(appData *, WIN *, WIN *, projectlist *);

/* Print at screen */
extern void drawScreen(appData *, WIN *, WIN *, projectlist *);

/* Putting it all together */
extern int main(int , char *[]);

#endif

