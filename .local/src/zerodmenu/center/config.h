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
/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom     */
static int centered = 1;                    /* -c option; centers dmenu on screen */
static int min_width = 0;                    /* minimum width when centered */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
	"CaskaydiaCove Nerd Font:size=12:antialias=true:autohint=true"
};

static const char *prompt      = NULL;      /* -p  option; prompt to the left of input field */
static const char *colors[SchemeLast][2] = {
        /*                            fg         bg    */
	[SchemeNorm] =          { "#b3b3b3", "#080808" },
	[SchemeSel] =           { "#080808", "#e5e5e5" },
	[SchemeSelHighlight] =  { "#b3b3b3", "#1a1a1a" },
	[SchemeNormHighlight] = { "#b3b3b3", "#1a1a1a" },
	[SchemeOut] =           { "#b3b3b3", "#080808" },
	[SchemeOutHighlight] =  { "#080808", "#e5e5e5" },
};
/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines      = 12;
/* -h option; minimum height of a menu line */
static unsigned int lineheight = 49;
static unsigned int min_lineheight = 49;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " /?\"&[]";

