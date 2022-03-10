/*
//         .             .              .		  
//         |             |              |           .	  
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
//  ,|							  
//  `'							  
// GITHUB:https://github.com/gabrielzschmitz		  
// INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/   
// DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
*/

/*Color Palette*/
#define RESET   "\033[0m"
#define BLACK   "\033[30m"      /* Black */
#define RED     "\033[31m"      /* Red */
#define GREEN   "\033[32m"      /* Green */
#define YELLOW  "\033[33m"      /* Yellow */
#define BLUE    "\033[34m"      /* Blue */
#define MAGENTA "\033[35m"      /* Magenta */
#define CYAN    "\033[36m"      /* Cyan */
#define WHITE   "\033[37m"      /* White */
#define BOLDBLACK   "\033[1m\033[30m"      /* Bold Black */
#define BOLDRED     "\033[1m\033[31m"      /* Bold Red */
#define BOLDGREEN   "\033[1m\033[32m"      /* Bold Green */
#define BOLDYELLOW  "\033[1m\033[33m"      /* Bold Yellow */
#define BOLDBLUE    "\033[1m\033[34m"      /* Bold Blue */
#define BOLDMAGENTA "\033[1m\033[35m"      /* Bold Magenta */
#define BOLDCYAN    "\033[1m\033[36m"      /* Bold Cyan */
#define BOLDWHITE   "\033[1m\033[37m"      /* Bold White */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define true 1
#define false 0

void clear_terminal(void)
{
    system("clear");
}

void display_time(int x)
{
    int div = x / 60;
    int mod = x % 60;
    char minutes[3] = {(div / 10) + '0', (div % 10) + '0', '\0'};
    char seconds[3] = {(mod / 10) + '0', (mod % 10) + '0', '\0'};

    printf( BOLDBLACK "%s:%s\n" RESET, minutes, seconds);
}

void run(int duration)
{
    int x = 0;
    system("notify-send -t 5750 '華 Work!' 'You need to focus 25 minutes'");

    while (x < (duration * 60)) {
        clear_terminal();
        printf( BOLDMAGENTA " Pomodoro" BOLDWHITE " [%d minutes]\n" RESET, duration);
        display_time(x);
        sleep(1);
        x += 1;
    }
}

void _pause(int duration)
{
    int x = 0;

    while (x < (duration * 60)) {
        clear_terminal();
        printf( BOLDCYAN " Pause" BOLDWHITE " [%d minutes]\n" RESET, duration);
        display_time(x);
        sleep(1);
        x += 1;
    }
}

void _long_pause(int duration)
{
    int x = 0;

    while (x < (duration * 60)) {
        clear_terminal();
        printf( BOLDCYAN " Long pause" BOLDWHITE " [%d minutes]\n" RESET, duration);
        display_time(x);
        sleep(1);
        x += 1;
    }
}

int main(void)
{
    int count_run = 0;

    while (true) {
        run(25);
        count_run += 1;
        if ((count_run > 0) && (count_run % 4 == 0)) {
            system("notify-send -t 5750 ' Pause Break' 'You have 30 minutes'");
            _long_pause(30);
        } else {
            system("notify-send -t 5750 ' Pause Break' 'You have 5 minutes'");
            _pause(5);
        }
    }
    return (0);
}

