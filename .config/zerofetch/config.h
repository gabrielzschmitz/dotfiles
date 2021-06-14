// Change the ASCII Art
#include "partix.h"
// Define the ASCII color
#define COLORA "\e[1;96m"
// Define the Title color
#define COLORT "\e[1;97m"
// Define the Functions colors
#define COLOR "\e[1;94m"

#define CONFIG \
{ \
   /* name            function                 	cached */\
    { "",             get_title,               	false }, \
    { "os: ",         get_os,                  	true  }, \
    { "kernel: ",     get_kernel,              	true  }, \
    { "pkgs: ",       get_packages_pacman,      true  }, \
    { "uptime: ",     get_uptime,              	true  }, \
    { "memory: ",     get_memory,              	false }, \
    { "",             get_colors1,             	false }, \
    { "",             get_colors2,             	false }, \
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
//    { "shell: ",      get_shell,             		false },
//    { "terminal: ",   get_terminal,          		false },
//    { "host: ",       get_host,                	true  },
//    { "cpu: ",        get_cpu,                	true  },
//    { "battery: ",    get_battery_percentage,  	false },
//    { "resolution: ", get_resolution,        		false },
//    { "disk: ",       get_disk_usage_root,        	false },
//    { "disk: ",       get_disk_usage_home,        	false },
