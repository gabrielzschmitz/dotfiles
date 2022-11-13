/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
//  typer.c.c
*/
#include <curses.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "util.h"

# define ESC 27
# define ENTER 10
# define CTRLR 18
# define CTRLX 24

// Inicie a tela com cores, teclado habilitado e mais outras pequenas configurações
void initScreen(){
#ifdef XCURSES
    Xinitscr(argc, argv);
#else
    initscr();
#endif
    use_default_colors();
    if (has_colors()){
        int bg = 0, fg = 0;
        start_color();
        for(bg = COLOR_BLACK; bg <= COLOR_WHITE; bg++)
            for(fg = COLOR_BLACK; fg <= COLOR_WHITE; fg++)
                init_pair(bg*PALLETE_SIZE + fg + 1, fg, -1);
    }
    noecho();   // Teclas digitadas pelo usuário não aparecem na tela
    curs_set(0);    // Cursor invisível
    nodelay(stdscr, TRUE);  // Define getch como non-blocking
    timeout(0); // Timeout em 0 determina getch como non-blocking
    keypad(stdscr, TRUE);   // Habilita teclas de function, setas, etc
}

// Configurações do programa
void initGame(gameData * game){
    game->lastKeypress = 0;
    game->needMainMenu = 1;
    game->runGame = 0;
    game->endGame = 0;
    game->needToRandomize = 1;
    game->NW = 0;
    game->firstLineColor = 0;
    game->secondLineColor = 0;
    game->NIW = -1;
    game->LIW = -1;
    game->IC = 0;
    game->correctWords = readFileOfWords(game);
    game->gameInput = fopen("gameinput", "w");
    game->inputFileRefresh = 0;
    game->refreshScreen = 0;
    game->wrongWords = 0;
    game->timer = 0;
}

// Gerencia entradas do usuário e controla o estado interno do programa
void handleInputs(gameData * game){
    game->userInput = getch();

    if(game->currentMode == 2 || game->currentMode == 3){
        if(game->userInput != -1){

            if(game->userInput == ' ' && game->lastKeypress != ' ' && game->userInput != KEY_BACKSPACE){
                fprintf(game->gameInput, "\n");
                fclose(game->gameInput);
                game->inputedWords = readInputedWords(game);
                addToMistakes(game);
                game->inputFileRefresh = 1;
            }

            else if(game->userInput == KEY_BACKSPACE){
                    fseek(game->gameInput, -1, SEEK_END);
                }
            else if((game->userInput != ESC) && (game->userInput != KEY_RESIZE) && (game->userInput != KEY_BACKSPACE)){
                    fprintf(game->gameInput, "%c", game->userInput);
                }

                game->lastKeypress = game->userInput;

        }
    }

    switch(game->userInput){
        case ENTER:
            if(game->currentMode == 1){
                game->runGame = 1;
                game->needMainMenu = 0;
                break;
            }else
                break;

        case CTRLR:
            if(game->currentMode == 4){
                game->runGame = 1;
                game->needMainMenu = 0;
                game->endGame = 0;
                game->refreshScreen = 0;
                game->needToRandomize = 1;
                game->wrongWords = 0;
                game->LIW = -1;
                game->timer = 0;
                game->firstLineColor = 0;
                game->secondLineColor = 0;
                game->currentMode = 2;
                fclose(game->gameInput);
                game->gameInput = fopen("gameinput", "w");
                break;
            }else
                break;

        case ESC:
            if(game->currentMode == 1 || game->currentMode == 2){
                endwin();
                freeMemory(game, 1);
                fclose(game->gameInput);
                system("notify-send 'Goodbye  '");
                printf("Goodbye!  ");
                exit(EXIT_SUCCESS);
                break;
            }else{
                endwin();
                freeMemory(game, 1);
                freeMemory(game, 2);
                fclose(game->gameInput);
                system("notify-send 'Goodbye  '");
                printf("Goodbye!  ");
                exit(EXIT_SUCCESS);
                break;
            }
        case CTRLX:
            if(game->currentMode == 4){
                endwin();
                freeMemory(game, 1);
                freeMemory(game, 2);
                fclose(game->gameInput);
                system("notify-send 'Goodbye  '");
                printf("Goodbye!  ");
                exit(EXIT_SUCCESS);
                break;
            }
            else if(game->currentMode == 1){
                endwin();
                freeMemory(game, 1);
                fclose(game->gameInput);
                system("notify-send 'Goodbye  '");
                printf("Goodbye!  ");
                exit(EXIT_SUCCESS);
                break;
            }else
                break;

        case KEY_RESIZE:
            endwin();   // Finaliza a tela atual
            initScreen();   // Cria uma nova
            getWindowSize(game);
            clear();
            refresh();
            break;
    }
}

// Atualiza as variáveis em tempo real
void doUpdate(gameData * game){
    if(game->needMainMenu == 1)
        game->currentMode = 1;

    if(game->runGame == 1)
        game->currentMode = 2;

    if(game->endGame == 1)
        game->currentMode = 4;

    if(game->needToRandomize == 1){
        randomizeWords(24, game);
        game->needToRandomize = 0;
    }

    if(game->inputFileRefresh == 1){
        fclose(game->gameInput);
        game->gameInput = fopen("./gameinput", "r+");
        fseek(game->gameInput, 0, SEEK_END);
        game->refreshScreen = 1;
        game->inputFileRefresh = 0;
    }

    if(game->refreshScreen == 1){
        game->currentMode = 3;
    }
    
    if(game->LIW == 23){
        game->endGame = 1;
        game->currentMode = 4;
    }

    if(game->timer == (30 * 16)){
        game->endGame = 1;
        game->currentMode = 4;
    }

    getWindowSize(game);

}

// Imprime na tela
void drawScreen(gameData * game){
    clear();

    switch(game->currentMode){
        case 1:
            printMainMenu(game);
            break;
        case 2:
            printWordsAtWindow(24, game);
            break;
        case 3:
            printWordsAtWindow(24, game);
            compareInputAndCorrect(game);
            timer(game);
            break;
        case 4:
            printStats(game);
            break;
    }

    refresh();
}

// Colocando tudo junto
int main(int argc, char *argv[]){
    // Estrutura com dados internos da aplicação
    gameData game;

    // Inicializa a tela pelo Curses e o estado inicial da aplicação
    initScreen();
    initGame(&game);

    // Laço principal sem retorno, pode ser removido para exibição direta de informação na tela
    while(1){
        // Gerencia entradas do usuário pelo teclado
        handleInputs(&game);

        // Gerencia lógica da aplicação
        doUpdate(&game);

        // Atualiza a tela
        drawScreen(&game);

        // Controla o FPS da aplicação
        napms(60);
    }

    // Encerra a tela inicializada em initScreen
    endwin();

    // Retorna 0 para demonstrar que o programa foi executado corretamente
    return 0;
}

