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
#include "util.h"
#include <curses.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

void setColor(short int fg, short int bg, chtype attr){
    chtype color = COLOR_PAIR(bg*PALLETE_SIZE + fg + 1);
    color |= attr;
    attrset(color);
}

void randomizeWords(int n, gameData * gameData){
    int i;
    srand(time(0));
    for (i = 0; i < n; i++){
        gameData->X[i] = rand () %996;
    }
    gameData->needToRandomize = 0;
}

void printWordsAtWindow(int n, gameData * game){
    clear();
    int i, K;

    if (game->firstLineColor == 0)
        setColor(COLOR_WHITE, COLOR_BLACK, A_ITALIC);
    if (game->firstLineColor == 1)
        setColor(COLOR_GREEN, COLOR_BLACK, A_BOLD);
    if (game->firstLineColor == 2)
            setColor(COLOR_RED, COLOR_BLACK, A_UNDERLINE);
    for (i = 0, K = 0; i < 8; i++){
        mvprintw(((game->y / 2) - 1), (((game->x / 2) - 27) + K), "%s", game->correctWords[game->X[i]]);
        K+=(strlen(game->correctWords[game->X[i]]) + 1);
    }

    if (game->secondLineColor == 0)
        setColor(COLOR_WHITE, COLOR_BLACK, A_ITALIC);
    if (game->secondLineColor == 1)
        setColor(COLOR_GREEN, COLOR_BLACK, A_BOLD);
    if (game->secondLineColor == 2)
        setColor(COLOR_RED, COLOR_BLACK, A_UNDERLINE);
    for (i = 8, K = 0; i < 16; i++){
        mvprintw((game->y / 2), (((game->x / 2) - 27) + K), "%s", game->correctWords[game->X[i]]);
        K+=(strlen(game->correctWords[game->X[i]]) + 1);
    }

    setColor(COLOR_WHITE, COLOR_BLACK, A_ITALIC);
    for (i = 16, K = 0; i < 24; i++){
        mvprintw(((game->y / 2) +1), (((game->x / 2) - 27) + K), "%s", game->correctWords[game->X[i]]);
        K+=(strlen(game->correctWords[game->X[i]]) + 1);
    }
}

void printLogo(gameData * game){
    setColor(COLOR_CYAN, COLOR_BLACK, A_BOLD);
    mvprintw(((game->y / 2) - 9), ((game->x / 2) - 31), "    .");
    mvprintw(((game->y / 2) - 8), ((game->x / 2) - 31), "  .o8");
    mvprintw(((game->y / 2) - 7), ((game->x / 2) - 31), ".o888oo oooo    ooo oo.ooooo.   .ooooo.  oooo d8b      .ooooo.");
    mvprintw(((game->y / 2) - 6), ((game->x / 2) - 31), "  888    `88.  .8\'   888\' `88b d88\' `88b `888\"\"8P     d88\' `\"Y8");
    mvprintw(((game->y / 2) - 5), ((game->x / 2) - 31), "  888     `88..8\'    888   888 888ooo888  888         888");
    mvprintw(((game->y / 2) - 4), ((game->x / 2) - 31), "  888 .    `888\'     888   888 888    .o  888     .o. 888   .o8");
    mvprintw(((game->y / 2) - 3), ((game->x / 2) - 31), "  \"888\"     .8\'      888bod8P\' `Y8bod8P\' d888b    Y8P `Y8bod8P\'");
    mvprintw(((game->y / 2) - 2), ((game->x / 2) - 31), "        .o..P\'       888");
    mvprintw(((game->y / 2) - 1), ((game->x / 2) - 31), "        `Y8P\'       o888o");
}

char** readFileOfWords(gameData * game){
    FILE *fptr;
    fptr = fopen("./dictionary", "r");

    int aux = 0;
    int i;

    char tenK [10000];

    while ((aux = fscanf (fptr, "%s", tenK)) == 1)
        game->NW++;

    fseek(fptr, 0, SEEK_SET);

    char **correctWords = malloc(sizeof(char*)*game->NW);

    for (i = 0; i < game->NW; i++){
        fscanf(fptr, "%s", tenK);
        int size = strlen(tenK);
        char *p = malloc(size + 1);
        strcpy(p, tenK);
        correctWords[i] = p;
    }
    return correctWords;
    fclose(fptr);
}

char** readInputedWords(gameData * game){
    FILE *fptr;
    fptr = fopen("./gameinput", "r");;

    int aux = 0;
    int i;
    game->LIW++;
    game->NIW = 0;

    char words [100000];

    while ((aux = fscanf (fptr, "%s", words)) == 1){
        game->NIW++;
    }

    fseek(fptr, 0, SEEK_SET);

    char **inputedWords = malloc(sizeof(char*)*game->NIW);

    for (i = 0; i <= game->NIW; i++){
        fscanf(fptr, "%s", words);
        int size = strlen(words);
        char *p = malloc(size - 1);
        strcpy(p, words);
        inputedWords[i] = p;
    }
    return inputedWords;
    fclose(fptr);
}

void compareInputAndCorrect(gameData * game){
    int i, K;

    if(strcmp(game->correctWords[game->X[game->LIW]], game->inputedWords[game->LIW]) == 0){
        setColor(COLOR_GREEN, COLOR_BLACK, A_BOLD);
        if (game->LIW < 8){
            for (i = 0, K = 0; i < game->NIW; i++){
                mvprintw(((game->y / 2) - 1), (((game->x / 2) - 27) + K), "%s", game->correctWords[game->X[i]]);
                K+=(strlen(game->correctWords[game->X[i]]) + 1);
            }
        }
        if (game->LIW < 16){
            for (i = 8, K = 0; i < game->NIW; i++){
                mvprintw((game->y / 2), (((game->x / 2) - 27) + K), "%s", game->correctWords[game->X[i]]);
                K+=(strlen(game->correctWords[game->X[i]]) + 1);
                game->firstLineColor = 1;
            }
        }
        if (game->LIW < 24){
            for (i = 16, K = 0; i < game->NIW; i++){
                mvprintw(((game->y / 2) + 1), (((game->x / 2) - 27) + K), "%s", game->correctWords[game->X[i]]);
                K+=(strlen(game->correctWords[game->X[i]]) + 1);
                game->firstLineColor = 1;
                game->secondLineColor = 1;
            }
        }
    }
    else{
        setColor(COLOR_RED, COLOR_BLACK, A_UNDERLINE);
        if (game->LIW < 8){
            for (i = 0, K = 0; i < game->NIW; i++){
                mvprintw(((game->y / 2) - 1), (((game->x / 2) - 27) + K), "%s", game->correctWords[game->X[i]]);
                K+=(strlen(game->correctWords[game->X[i]]) + 1);
            }
        }
        if (game->LIW < 16){
            for (i = 8, K = 0; i < game->NIW; i++){
                mvprintw((game->y / 2), (((game->x / 2) - 27) + K), "%s", game->correctWords[game->X[i]]);
                K+=(strlen(game->correctWords[game->X[i]]) + 1);
                game->firstLineColor = 2;
            }
        }
        if (game->LIW < 24){
            for (i = 16, K = 0; i < game->NIW; i++){
                mvprintw(((game->y / 2) + 1), (((game->x / 2) - 27) + K), "%s", game->correctWords[game->X[i]]);
                K+=(strlen(game->correctWords[game->X[i]]) + 1);
                game->firstLineColor = 2;
                game->secondLineColor = 2;
            }
        }
    }
}

void addToMistakes(gameData * game){
    if(strcmp(game->correctWords[game->X[game->LIW]], game->inputedWords[game->LIW]) != 0){
        game->wrongWords++;
    }
    else
        game->rightWords++;
}

void freeMemory(gameData * game, int w){
    if(w == 1){
        for (int p = 0; p < game->NW; p++){
            free(game->correctWords[p]);
        }
        free(game->correctWords);
    }
    else if(w == 2){
        for (int p = 0; p < game->LIW; p++){
            free(game->inputedWords[p]);
        }
        free(game->inputedWords);
    }
}

void printMainMenu(gameData * game){
    printLogo(game);
    setColor(COLOR_WHITE, COLOR_BLACK, A_BOLD);
    mvprintw(((game->y / 2) + 3), ((game->x / 2) - 7), "enter to start");
    mvprintw(((game->y / 2) + 4), ((game->x / 2) - 7), "ctrl+x to exit");
}

void timer(gameData * game){
    int sec = 30;
    clock_t end = clock() + sec * (CLOCKS_PER_SEC);
    if(clock() < end) {
        game->timer++;
        setColor(COLOR_WHITE, COLOR_BLACK, COLOR_WHITE);
        mvprintw(((game->y / 2) - 3), ((game->x / 2) - 27), "%ds", (game->timer / 16));
    }
}

void printStats(gameData * game){
    float inClock = game->timer;
    float inMin = (inClock / 1000);
    float raw = ((game->LIW) / inMin);
    float wpm = ((game->LIW - game->wrongWords) / inMin);
    //int consistensy = ((game->wrongWords / (game->LIW + 1)) * 100);
    printLogo(game);
    setColor(COLOR_GREEN, COLOR_BLACK, A_BOLD);
    mvprintw(((game->y / 2) + 3), ((game->x / 2) - 9), "wpm %.0f      raw %.0f", wpm, raw);
    setColor(COLOR_BLUE, COLOR_BLACK, A_BOLD);
    mvprintw(((game->y / 2) + 5), ((game->x / 2) - 11), "words %d      time %ds", game->LIW + 1, game->timer / 16);
    setColor(COLOR_RED, COLOR_BLACK, A_BOLD);
    mvprintw(((game->y / 2) + 7), ((game->x / 2) - 5), "mistakes %d", game->wrongWords);
    setColor(COLOR_WHITE, COLOR_BLACK, A_BOLD);
    mvprintw(((game->y / 2) + 9), ((game->x / 2) - 9), "ctrl+r to reset it");
    mvprintw(((game->y / 2) + 10), ((game->x / 2) - 7), "ctrl+x to exit");
}

void getWindowSize(gameData * game){
    getmaxyx(stdscr, game->y, game->x);
}

