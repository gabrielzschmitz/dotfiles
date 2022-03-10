// Change the ASCII Art
#include "artix.h"
// 90 black; 91 red; 92 green; 93 yellow; 94 blue; 95 magenta; 96 cyan; 97 white
// Define the ASCII color
#define COLORA "\e[1;95m"
// Define the Functions colors
#define COLOR "\e[1;91m"
// Define the Title color
#define COLORT "\e[1;97m"

#define CONFIG \
{ \
   /* name              function                cached */\
    { "",    	        spacer,               	false }, \
    { "OS:        ",    get_os,                 false }, \
    { "KERNEL:    ",    get_kernel,             false }, \
    { "UPTIME:    ",    get_uptime,             false }, \
    { "PACKAGES:  ",    get_packages_pacman,    false }, \
    { "SHELL:     ",    get_shell,              false }, \
    { "",               get_colors1,            false }, \
}

#define CPU_CONFIG \
{ \
   REMOVE("(R)"), \
   REMOVE("(TM)"), \
   REMOVE("Dual-Core"), \
   REMOVE("Quad-Core"), \
   REMOVE("Six-Core"), \
   REMOVE("Eight-Core"), \
   REMOVE("Core"), \
   REMOVE("CPU"), \
}

