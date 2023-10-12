/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// util.h
*/
#ifndef UTIL_H_
#define UTIL_H_
#include <ncurses.h>

/* Defining the colors pallete size */
#define PALLETE_SIZE (COLOR_WHITE - COLOR_BLACK + 1)

/* Initialize screen with some little configs */
extern void initScreen(void);
/* Set text foreground and background colors */
extern void setColor(short int , short int , chtype );
/* Get the window size */
extern void getWindowSize(appData *);
/* Print at the center of given (x,y) */
extern void printfCenter(int , int , int , const char *);
/* Allocate memory than copy macro to string */
extern char * createString(const char *);
/* Create a new project */
extern void addProjectTitle(appData *, projectlist *);
extern void addSubprojectTitle(appData *, projectlist *);
/* Function to create a new project */
extern project *createProject();
/* Function to create a new project list */
extern projectlist *createProjectList(projectlist *);
/* Function to deserialize a file */
extern void deserializeProjects(FILE *, project *, int , projectlist *, appData *);
/* Function to serialize a todo item */
extern void serializeTodoItem(FILE *, todo *, int );
/* Function to serialize a project */
extern void serializeProject(FILE *, project *, int );
/* Input project title */
extern void inputSubprojectTitle(appData *, projectlist *);
extern void inputProjectTitle(appData *, projectlist *);
/* Set the project folder and files */
extern void createProjectFile(appData * app);

#endif

