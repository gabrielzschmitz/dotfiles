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
#define TERMINAL "st"
#define TERMCLASS "st"

/* appearance */
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int snap      = 20;       /* snap pixel */
static const unsigned int gappih    = 15;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 15;       /* vert inner gap between windows */
static const unsigned int gappoh    = 20;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 20;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int user_bh            = 20;        /* 2 is the default spacing around the bar's font */
static const int colorfultag        = 1;        /* 0 means use SchemeSel for selected non vacant tag */

static const char *fonts[]          = { "CaskaydiaCove Nerd Font:size=12:antialias=true:autohint=true" };

#include "zerotheme.h"
static const char *colors[][3]      = {
    /*                     fg       bg      border */
    [SchemeNorm]       = { black,   black,  gray2 },
    [SchemeSel]        = { black,   black,  blue  },
    [TabSel]           = { blue,    gray2,  black },
    [TabNorm]          = { gray3,   black,  black },
    [SchemeTag]        = { gray3,   black,  black },
    [SchemeTag1]       = { cyan,    black,  black },
    [SchemeTag2]       = { magenta, black,  black },
    [SchemeTag3]       = { orange,  black,  black },
    [SchemeTag4]       = { green,   black,  black },
    [SchemeTag5]       = { blue,    black,  black },
    [SchemeTag6]       = { red,     black,  black },
    [SchemeTag7]       = { yellow,  black,  black },
    [SchemeTag8]       = { gray,    black,  black },
    [SchemeLayout]     = { white,   black,  black },
    [SchemeBtnPrev]    = { green,   black,  black },
    [SchemeBtnNext]    = { yellow,  black,  black },
    [SchemeBtnClose]   = { red,     black,  black },
};

/* tagging */
static const char *tags[] = { "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  " };

static const int tagschemes[] = {
    SchemeTag1, SchemeTag2, SchemeTag3, SchemeTag4, SchemeTag5, SchemeTag6, SchemeTag7, SchemeTag8
};

static const unsigned int ulinepad	= 5;	/* horizontal padding between the underline and tag */
static const unsigned int ulinestroke	= 3;	/* thickness / height of the underline */
static const unsigned int ulinevoffset	= 0;	/* how far above the bottom of the bar the line should appear */
static const int ulineall 		= 0;	/* 1 to show underline on all tags, 0 for just the active ones */

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class                instance    title       tags mask     isfloating   monitor */
	{ "Deadbeef",     	NULL,       NULL,       0,            1,           -1 },
	{ "Gcolor3",     	NULL,       NULL,       0,            1,           -1 },
	{ "Pavucontrol", 	NULL,       NULL,       0,            1,           -1 },
	{ "Nsxiv", 	 	NULL,       NULL,       0,            1,           -1 },
	{ "Pcmanfm", 	 	NULL,       NULL,       0,            1,           -1 },
	{ "Zathura", 	 	NULL,       NULL,       0,            1,           -1 },
	{ "Blueman-manager",  	NULL,       NULL,       0,            1,           -1 },
	{ "tomato", 		NULL,       NULL,       0,            1,           -1 },
	{ "calc", 		NULL,       NULL,       0,            1,           -1 },
	{ "ncpamixer", 		NULL,       NULL,       0,            1,           -1 },
	{ "sfm", 		NULL,       NULL,       0,            1,           -1 },
	{ "keyb", 		NULL,       NULL,       0,            1,           -1 },
	{ "ncmpcpp", 		NULL,       NULL,       0,            1,           -1 },
	{ "packagesupgrade", 	NULL,       NULL,       0,            1,           -1 },
	{ "weatherreport", 	NULL,       NULL,       0,            0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.5; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"

static const Layout layouts[] = {
/* symbol     arrange function */
{ "[T]",      tile },			/* 0 first entry is default */
{ "[M]",      monocle },		/* 1 */
{ "[S]",      spiral },			/* 2 */
{ "[DW]",     dwindle },		/* 3 */
{ "[D]",      deck },			/* 4 */
{ "[BS]",     bstack },			/* 5 */
{ "[BSH]",    bstackhoriz },		/* 6 */
{ "[G]",      grid },			/* 7 */
{ "[RG]",     nrowgrid },		/* 8 */
{ "[HG]",     horizgrid },		/* 9 */
{ "[GG]",     gaplessgrid },		/* 10 */
{ "[C]",      centeredmaster },		/* 11 */
{ "[CF]",     centeredfloatingmaster },	/* 12 */
{ "[F]",      NULL },			/* 13 no layout function means floating behavior */
{ NULL,       NULL },			/* 14 */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },
#define HOLDKEY 0xffe9 // 0 - disable; 0xffe9 - Mod1Mask; 0xffeb - Mod4Mask

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
/*static const char *flavorsel[] = { "flavorsel", NULL };*/
static const char *termcmd[]  = { "st", NULL };
static const char *layoutmenu_cmd = "layoutmenu.sh";
static const char *dmenucmd[] = { "dmenu_run", NULL };
static const char *filescmd[] = { TERMINAL, "-c", "sfm", "-g", "100x30", "-e", "sfm", NULL };
static const char *musiccmd[] = { TERMINAL, "-c", "ncmpcpp", "-e", "ncmpcpp", NULL };
static const char *emojicmd[] = { "emojimenu", NULL };
static const char *picomcmd[] = { "picomtoggle", NULL };
static const char *unlockycmd[] = { "unlocky", NULL };
static const char *webcmd[] = { "chromium", NULL };
static const char *powermenu[] = { "powermenu", NULL };
static const char *shotmenu[] = { "shotmenu", NULL };
static const char *sysinfo[] = { "sysinfo", NULL };
static const char *walle[] = { "walle", NULL };
static const char *dispset[] = { "dispset", NULL };
static const char *dispfix[] = { "dispfix", NULL };
static const char *audiocontrolcmd[] = { TERMINAL, "-c", "ncpamixer", "-g", "80x15", "-e", "ncpamixer", NULL };
static const char *tomatocmd[] = { TERMINAL, "-c", "tomato", "-g", "25x14", "-e", "tomato", NULL };
static const char *keybcmd[] = { TERMINAL, "-c", "keyb", "-g", "100x30", "-e", "keyb", NULL };

#include <X11/XF86keysym.h>

static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY,             		XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,             		XK_w, 	   spawn,          {.v = webcmd } },
	{ MODKEY,             		XK_e, 	   spawn,          {.v = emojicmd } },
	{ MODKEY|ShiftMask,          	XK_f, 	   spawn,          {.v = filescmd } },
	{ MODKEY|ShiftMask,          	XK_l, 	   spawn,          {.v = unlockycmd } },
	{ MODKEY|ShiftMask,           	XK_m, 	   spawn,          {.v = audiocontrolcmd } },
	{ MODKEY,             		XK_0, 	   spawn,          {.v = powermenu } },
	{ MODKEY|ShiftMask,             XK_w, 	   spawn,          {.v = walle } },
	{ MODKEY|ShiftMask,             XK_d, 	   spawn,          {.v = dispset } },
	{ MODKEY|Mod1Mask,              XK_d, 	   spawn,          {.v = dispfix } },
	{ MODKEY,                       XK_b, 	   spawn,          {.v = sysinfo } },
	{ MODKEY|ShiftMask,          	XK_p, 	   spawn,          {.v = picomcmd } },
	{ MODKEY,			XK_F1,	   spawn,	   SHCMD("groff -mom $HOME/.local/share/dwm/gzdots.mom -T pdf | zathura -") },
	{ MODKEY|ShiftMask,		XK_slash,  spawn,          {.v = keybcmd } },
	{ MODKEY|ShiftMask,		XK_t,	   spawn,	   {.v = tomatocmd } },
	{ MODKEY|ShiftMask,             XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY|ControlMask,           XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY|ControlMask,           XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_u,      incrgaps,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_u,      incrgaps,       {.i = -1 } },
	{ MODKEY,                       XK_a,      togglegaps,     {0} },
	{ MODKEY|ShiftMask,             XK_a,      defaultgaps,    {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[4]} },
	{ MODKEY,                       XK_s,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_c,      setlayout,      {.v = &layouts[11]} },
	{ MODKEY,                       XK_space,  setlayout,      {.v = &layouts[13]} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_f,      togglefullscr,  {0} },
	{ MODKEY|ControlMask,           XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_Left,   focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_Right,  focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_Left,   tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_Right,  tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_c,      quit,           {0} },
	{ 0,			        XK_Print,  spawn,          SHCMD("scrot ~/pic/allmon-$(date +%H:%M:%S).png --quality 100 --freeze") },
	{ MODKEY,			XK_Print,  spawn,          {.v = shotmenu } },
        { 0, XF86XK_AudioMute,			   spawn,	   SHCMD("pamixer -t") },
	{ 0, XF86XK_AudioLowerVolume,		   spawn,	   SHCMD("pamixer --allow-boost -d 5") },
	{ 0, XF86XK_AudioRaiseVolume,		   spawn,	   SHCMD("pamixer --allow-boost -i 5") },
	{ MODKEY,			XK_F10,	   spawn,	   SHCMD("mpc volume 0") },
	{ MODKEY,			XK_F11,	   spawn,	   SHCMD("mpc volume -5") },
	{ MODKEY,			XK_F12,	   spawn,	   SHCMD("mpc volume +5") },
	{ 0, XF86XK_AudioPrev,			   spawn,	   SHCMD("mpc prev && disccover") },
	{ 0, XF86XK_AudioNext,			   spawn,	   SHCMD("mpc next && disccover") },
	{ 0, XF86XK_AudioPlay,			   spawn,	   SHCMD("mpc toggle && disccover") },
	{ 0, XF86XK_AudioStop,			   spawn,	   SHCMD("mpc stop && disccover") },
	{ MODKEY,			XK_F4,	   spawn,	   {.v = musiccmd } },
	{ 0, XF86XK_Calculator,			   spawn,	   SHCMD(TERMINAL " -c calc -e eva") },
	{ 0, XF86XK_MonBrightnessUp,		   spawn,	   SHCMD("doas /home/gabrielzschmitz/.local/bin/sunlight") },
	{ 0, XF86XK_MonBrightnessDown,		   spawn,	   SHCMD("doas /home/gabrielzschmitz/.local/bin/moonlight") },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        layoutmenu,     {0} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

