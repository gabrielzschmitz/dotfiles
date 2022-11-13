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
#include <curses.h>

typedef struct gameData gameData;

#define PALLETE_SIZE (COLOR_WHITE - COLOR_BLACK + 1)
struct gameData{
    int needToRandomize;
    int needMainMenu;
    int runGame;
    int lastKeypress;
    int maxPerLine;
    int X[25];
    char **correctWords;
    int currentMode;
    FILE* gameInput;
    int userInput;
    char **inputedWords;
    char **inputAux;
    int NW;
    int NIW;
    int NOW;
    int LIW;
    int IWI;
    int IC;
    int firstLineColor;
    int secondLineColor;
    int inputFileRefresh;
    int refreshScreen;
    int wrongWords;
    int endGame;
    int interval;
    int rightWords;
    int timer;
    int x;
    int y;
};

extern void randomizeWords(int , gameData * );
extern void printWordsAtWindow(int , gameData * );
extern void printLogo(gameData * );
extern char** readFileOfWords(gameData * );
extern char** readInputedWords(gameData * );
extern void setColor(short int , short int , chtype );
extern void compareInputAndCorrect(gameData *);
extern void freeMemory(gameData *, int );
extern void addToMistakes(gameData *);
extern void printMainMenu(gameData *);
extern void printStats(gameData * );
extern void timer(gameData * );
extern void getWindowSize(gameData * );

