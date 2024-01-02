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
static const char *background_color = "#1d2021";
static const char *border_color = "#1d2021";
static const char *font_color = "#ebdbb2";
static const char *font_pattern =
    "SpaceMono Nerd Font Mono:size=10:antialias=true:autohint=true";
static unsigned line_spacing = 10;
static unsigned int padding = 15;
static const int use_primary_monitor = 1;

static unsigned int width = 300;
static unsigned int border_size = 0;
static unsigned int pos_x = 810;
static unsigned int pos_y = 52;

enum corners { TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT };
enum corners corner = TOP_LEFT;

static unsigned int duration = 5; /* in seconds */

#define DISMISS_BUTTON Button3
#define ACTION_BUTTON Button1
