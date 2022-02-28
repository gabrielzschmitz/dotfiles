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
static const char *background_color = "#080808";
static const char *border_color = "#080808";
static const char *font_color = "#b3b3b3";
static const char *font_pattern = "FiraCode Nerd Font:size=10:antialias=true:autohint=true";
static unsigned line_spacing = 5;
static unsigned int padding = 10;
static const int use_primary_monitor = 1;

static unsigned int width = 250;
static unsigned int border_size = 0;
static unsigned int pos_x = 10;
static unsigned int pos_y = 10;

enum corners { TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT };
enum corners corner = BOTTOM_LEFT;

static unsigned int duration = 5; /* in seconds */

#define DISMISS_BUTTON Button1
#define ACTION_BUTTON Button3

