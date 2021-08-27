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
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 10;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 20;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 20;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int user_bh            = 40;       /* 0 means that dwm will calculate bar height, >= 1 means dwm will user_bh as bar height */
static const int vertpad            = 20;       /* vertical padding of bar */
static const int sidepad            = 20;       /* horizontal padding of bar */
static const char *fonts[]          = { "FiraCode Nerd Font:size=12:antialias=true:autohint=true" };
static const char col_gray1[]       = "#20232f";
static const char col_gray2[]       = "#35394a";
static const char col_gray3[]       = "#9096ae";
static const char col_gray4[]       = "#20232f";
static const char col_cyan[]        = "#446781";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging */
static const char *tags[] = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      		instance    title       tags mask     isfloating   monitor */
	{ "Gcolor3",     	NULL,       NULL,       0,            1,           -1 },
	{ "Pavucontrol", 	NULL,       NULL,       0,            1,           -1 },
	{ "Sxiv", 	 	NULL,       NULL,       0,            1,           -1 },
	{ "Pcmanfm", 	 	NULL,       NULL,       0,            1,           -1 },
	{ "Zathura", 	 	NULL,       NULL,       0,            1,           -1 },
	{ "packagesupgrade", 	NULL,       NULL,       0,            1,           -1 },
	{ "weatherreport", 	NULL,       NULL,       0,            0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
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

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
/* commands */
static const char *dmenucmd[] = { "dmenu_run", NULL };
static const char *termcmd[] = { "st", NULL };
static const char *webcmd[] = { "brave", NULL };
static const char *filescmd[] = { "pcmanfm", NULL };
static const char *powermenu[] = { "powermenu", NULL };
static const char *sysinfo[] = { "sysinfo", NULL };
static const char *bgset[] = { "bgset", NULL };
static const char *disset[] = { "disset", NULL };
static const char *disfix[] = { "disfix", NULL };
static const char *audiocontrolcmd[] = { "pavucontrol", NULL };

#include <X11/XF86keysym.h>
static Key keys[] = {
	/* modifier                     key        function        argument */

	{ MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY,             		XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,             		XK_w, 	   spawn,          {.v = webcmd } },
	{ MODKEY|ShiftMask,           	XK_f, 	   spawn,          {.v = filescmd } },
	{ MODKEY|ShiftMask,           	XK_m, 	   spawn,          {.v = audiocontrolcmd } },
	{ MODKEY,             		XK_0, 	   spawn,          {.v = powermenu } },
	{ MODKEY|ShiftMask,             XK_w, 	   spawn,          {.v = bgset } },
	{ MODKEY|ShiftMask,             XK_d, 	   spawn,          {.v = disset } },
	{ MODKEY|Mod1Mask,              XK_d, 	   spawn,          {.v = disfix } },
	{ MODKEY|ShiftMask,             XK_b, 	   spawn,          {.v = sysinfo } },
	{ MODKEY,			XK_F1,	   spawn,	   SHCMD("groff -mom $HOME/.local/share/dwm/gzdots.mom -Tpdf | zathura -") },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY|ControlMask,           XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY|ControlMask,           XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY|Mod1Mask,              XK_u,      incrgaps,       {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_u,      incrgaps,       {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_i,      incrigaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_i,      incrigaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_o,      incrogaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_o,      incrogaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_6,      incrihgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_6,      incrihgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_7,      incrivgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_7,      incrivgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_8,      incrohgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_8,      incrohgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_9,      incrovgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_9,      incrovgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_0,      togglegaps,     {0} },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_0,      defaultgaps,    {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_s,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_c,      setlayout,      {.v = &layouts[11]} },
	{ MODKEY,                       XK_space,  setlayout,      {.v = &layouts[13]} },
	{ MODKEY|ControlMask,		XK_comma,  cyclelayout,    {.i = -1 } },
	{ MODKEY|ControlMask,           XK_period, cyclelayout,    {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,             		XK_f,      togglefullscr,  {0} },
	{ MODKEY|ControlMask,           XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ 0,				XK_Print,  spawn,          SHCMD("$HOME/.scripts/screenshotscripts/fullscreenshot.sh") },
	{ ShiftMask,			XK_Print,  spawn,	   SHCMD("$HOME/.scripts/screenshotscripts/selectivescreenshot.sh") },
	{ ShiftMask|ControlMask,	XK_Print,  spawn,	   SHCMD("$HOME/.scripts/screenshotscripts/fullcountdownscreenshot.sh") },
	{ ControlMask,			XK_Print,  spawn,	   SHCMD("$HOME/.scripts/screenshotscripts/allscreenshot.sh") },
	{ 0, XF86XK_AudioMute,			   spawn,	   SHCMD("pamixer -t") },
	{ 0, XF86XK_AudioLowerVolume,		   spawn,	   SHCMD("pamixer --allow-boost -d 5") },
	{ 0, XF86XK_AudioRaiseVolume,		   spawn,	   SHCMD("pamixer --allow-boost -i 5") },
	{ MODKEY,			XK_F11,	   spawn,	   SHCMD("mpc volume -5") },
	{ MODKEY,			XK_F12,	   spawn,	   SHCMD("mpc volume +5") },
	{ 0, XF86XK_AudioPrev,			   spawn,	   SHCMD("mpc prev && covernotify") },
	{ 0, XF86XK_AudioNext,			   spawn,	   SHCMD("mpc next && covernotify") },
	{ 0, XF86XK_AudioPlay,			   spawn,	   SHCMD("mpc toggle && covernotify") },
	{ 0, XF86XK_AudioStop,			   spawn,	   SHCMD("mpc stop && covernotify") },
	{ 0, XF86XK_AudioMedia,			   spawn,	   SHCMD(TERMINAL " -e ncmpcpp") },
	{ 0, XF86XK_Calculator,			   spawn,	   SHCMD(TERMINAL " -e bc -l") },
	{ 0, XF86XK_Music,			   spawn,	   SHCMD(TERMINAL " -e ncmpcpp") },
	{ 0, XF86XK_HomePage,			   spawn,	   SHCMD(TERMINAL " -e lf $HOME") },
	{ 0, XF86XK_MonBrightnessUp,		   spawn,	   SHCMD("xbacklight -inc 15") },
	{ 0, XF86XK_MonBrightnessDown,		   spawn,	   SHCMD("xbacklight -dec 15") },
	{ MODKEY|ShiftMask,             XK_c,      quit,           {0} },
};


/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
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

