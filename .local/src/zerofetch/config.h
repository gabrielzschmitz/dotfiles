// Change the ASCII Art
#include "artix.h"
// 90 black; 91 red; 92 green; 93 yellow; 94 blue; 95 magenta; 96 cyan; 97 white
// Define the ASCII color
#define COLORA "\e[1;94m"
// Define the Functions colors
#define COLOR "\e[1;96m"
// Define the Title color
#define COLORT "\e[1;97m"

#define CONFIG \
{ \
   /* name            function                 	cached */\
    { "",    	      get_title,               	false }, \
    { " ~ ",         get_os,                  	false }, \
    { " ~ ",         get_kernel,              	false }, \
    { " ~ ",         get_packages_pacman,      false }, \
    { " ~ ",         get_battery_percentage,  	false }, \
    { " ~ ",         get_shell,             	false }, \
    { "",             get_colors1,             	false }, \
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

//    { "",             spacer,                 	false },
//    { "",             get_bar,                 	false },
//    { "terminal: ",   get_terminal,          		false },
//    { "host: ",       get_host,                	true  },
//    { "cpu: ",        get_cpu,                	true  },
//    { "mem ",         get_memory,              	false },
//    { "battery: ",    get_battery_percentage,  	false },
//    { "resolution: ", get_resolution,        		false },
//    { "disk: ",       get_disk_usage_root,        	false },
//    { "disk: ",       get_disk_usage_home,        	false },
//    { "",             get_colors2,             	false },
