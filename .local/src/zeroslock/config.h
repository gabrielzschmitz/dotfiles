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
/* user and group to drop privileges to */
static const char *user  = "gabrielzschmitz";
static const char *group = "gabrielzschmitz";

static const char *colorname[NUMCOLS] = {
	[INIT] = "#1d2021",       /* after initialization */
	[INPUT] = "#ebdbb2",    /* during input */
	[FAILED] = "#cc241d",   /* wrong password */
};
/*
 * Xresources preferences to load at startup
 */
ResourcePref resources[] = {
		{ "slockinit",       STRING,  &colorname[INIT] },
		{ "slockinput",       STRING,  &colorname[INPUT] },
		{ "slockfailed",       STRING,  &colorname[FAILED] },
};


/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;

/* time in seconds to cancel lock with mouse movement */
static const int timetocancel = 15;

/* time in seconds before the monitor shuts down */
static const int monitortime = 300;

/* insert grid pattern with scale 1:1, the size can be changed with logosize */
static const int logosize = 25;
/* grid width and height for right center alignment */
static const int logow = 12;
static const int logoh = 6;

static XRectangle rectangles[9] = {
	/* x    y       w       h */
	{ 0,    3,      1,      3 },
	{ 1,    3,      2,      1 },
	{ 0,    5,      8,      1 },
	{ 3,    0,      1,      5 },
	{ 5,    3,      1,      2 },
	{ 7,    3,      1,      2 },
	{ 8,    3,      4,      1 },
	{ 9,    4,      1,      2 },
	{ 11,   4,      1,      2 },
};

/*Enable blur*/
#define BLUR
/*Set blur radius*/
static const int blurRadius=5;
/*Enable Pixelation*/
//#define PIXELATION
/*Set pixelation radius*/
//static const int pixelSize=0;

