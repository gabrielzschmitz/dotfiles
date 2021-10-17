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
static char normbgcolor[]           = "#20232f";
static char normbordercolor[]       = "#35394a";
static char normfgcolor[]           = "#9096ae";
static char selfgcolor[]            = "#20232f";
static char selbordercolor[]        = "#35394a";
static char selbgcolor[]            = "#436668";
static char *colors[][3] = {
       /*               fg           bg           border   */
       [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
       [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
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
	{ "retroarch", 	 	NULL,       NULL,       0,            1,           -1 },
	{ "cpomosai", 		NULL,       NULL,       0,            1,           -1 },
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

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *dmenucmd[] = { "dmenu_run", NULL };
static const char *flavorsel[] = { "flavorsel", NULL };
static const char *emojicmd[] = { "emojidmenu", NULL };
static const char *termcmd[] = { "st", NULL };
static const char *webcmd[] = { "chromium", NULL };
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
	{ MODKEY,             		XK_e, 	   spawn,          {.v = emojicmd } },
	{ MODKEY|ShiftMask,           	XK_f, 	   spawn,          {.v = filescmd } },
	{ MODKEY|ShiftMask,           	XK_m, 	   spawn,          {.v = audiocontrolcmd } },
	{ MODKEY,             		XK_0, 	   spawn,          {.v = powermenu } },
	{ MODKEY|ShiftMask,             XK_w, 	   spawn,          {.v = bgset } },
	{ MODKEY|ShiftMask,             XK_d, 	   spawn,          {.v = disset } },
	{ MODKEY|Mod1Mask,              XK_d, 	   spawn,          {.v = disfix } },
	{ MODKEY,			XK_F2,	   spawn,	   SHCMD("groff -mom $HOME/.local/share/dwm/gzdots.mom -T pdf | zathura -") },
	{ MODKEY|ShiftMask,		XK_t,	   spawn,	   SHCMD(TERMINAL " -c cpomosai -e cpomosai") },
	{ MODKEY,             		XK_b, 	   spawn,          {.v = sysinfo } },
	{ MODKEY|ShiftMask,             XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY|ControlMask,           XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY|ControlMask,           XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,			XK_z,	   incrgaps,	   {.i = +3 } },
	{ MODKEY,			XK_x,	   incrgaps,	   {.i = -3 } },
	{ MODKEY,	                XK_a,      togglegaps,     {0} },
	{ MODKEY|ShiftMask,    		XK_a,      defaultgaps,    {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[4]} },
	{ MODKEY,                       XK_M,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_s,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_c,      setlayout,      {.v = &layouts[11]} },
	{ MODKEY,                       XK_space,  setlayout,      {.v = &layouts[13]} },
	{ MODKEY|ControlMask,		XK_comma,  cyclelayout,    {.i = -1 } },
	{ MODKEY|ControlMask,           XK_period, cyclelayout,    {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,             		XK_f,      togglefullscr,  {0} },
	{ MODKEY|ControlMask,           XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_Left,   focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_Right,  focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_Left,   tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_Right,  tagmon,         {.i = +1 } },
	{ MODKEY,                       XK_F1,     xrdb,           {.v = NULL } },
	{ MODKEY|Mod1Mask,              XK_f, 	   spawn,          {.v = flavorsel } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ 0,				XK_Print,  spawn,          SHCMD("fullscreenshot") },
	{ ShiftMask,			XK_Print,  spawn,	   SHCMD("selectivescreenshot") },
	{ ShiftMask|ControlMask,	XK_Print,  spawn,	   SHCMD("fullcountdownscreenshot") },
	{ ControlMask,			XK_Print,  spawn,	   SHCMD("allscreenshot") },
	{ 0, XF86XK_AudioMute,			   spawn,	   SHCMD("pamixer -t") },
	{ 0, XF86XK_AudioLowerVolume,		   spawn,	   SHCMD("pamixer --allow-boost -d 5") },
	{ 0, XF86XK_AudioRaiseVolume,		   spawn,	   SHCMD("pamixer --allow-boost -i 5") },
	{ MODKEY,			XK_F10,	   spawn,	   SHCMD("mpc volume 0") },
	{ MODKEY,			XK_F11,	   spawn,	   SHCMD("mpc volume -5") },
	{ MODKEY,			XK_F12,	   spawn,	   SHCMD("mpc volume +5") },
	{ 0, XF86XK_AudioPrev,			   spawn,	   SHCMD("mpc prev && covernotify") },
	{ 0, XF86XK_AudioNext,			   spawn,	   SHCMD("mpc next && covernotify") },
	{ 0, XF86XK_AudioPlay,			   spawn,	   SHCMD("mpc toggle && covernotify") },
	{ 0, XF86XK_AudioStop,			   spawn,	   SHCMD("mpc stop && covernotify") },
	{ MODKEY,			XK_F5,	   spawn,	   SHCMD(TERMINAL " -e ncmpcpp") },
	{ 0, XF86XK_Calculator,			   spawn,	   SHCMD(TERMINAL " -e bc -l") },
	{ 0, XF86XK_MonBrightnessUp,		   spawn,	   SHCMD("xbacklight -inc 15") },
	{ 0, XF86XK_MonBrightnessDown,		   spawn,	   SHCMD("xbacklight -dec 15") },
	{ MODKEY|ShiftMask,             XK_c,      quit,           {0} },

	/* { MODKEY|Mod4Mask,              XK_h,      incrgaps,       {.i = +1 } }, */
	/* { MODKEY|Mod4Mask,              XK_l,      incrgaps,       {.i = -1 } }, */
	/* { MODKEY|Mod4Mask|ShiftMask,    XK_h,      incrogaps,      {.i = +1 } }, */
	/* { MODKEY|Mod4Mask|ShiftMask,    XK_l,      incrogaps,      {.i = -1 } }, */
	/* { MODKEY|Mod4Mask|ControlMask,  XK_h,      incrigaps,      {.i = +1 } }, */
	/* { MODKEY|Mod4Mask|ControlMask,  XK_l,      incrigaps,      {.i = -1 } }, */
	/* { MODKEY|Mod4Mask|ShiftMask,    XK_0,      defaultgaps,    {0} }, */
	/* { MODKEY,                       XK_y,      incrihgaps,     {.i = +1 } }, */
	/* { MODKEY,                       XK_o,      incrihgaps,     {.i = -1 } }, */
	/* { MODKEY|ControlMask,           XK_y,      incrivgaps,     {.i = +1 } }, */
	/* { MODKEY|ControlMask,           XK_o,      incrivgaps,     {.i = -1 } }, */
	/* { MODKEY|Mod4Mask,              XK_y,      incrohgaps,     {.i = +1 } }, */
	/* { MODKEY|Mod4Mask,              XK_o,      incrohgaps,     {.i = -1 } }, */
	/* { MODKEY|ShiftMask,             XK_y,      incrovgaps,     {.i = +1 } }, */
	/* { MODKEY|ShiftMask,             XK_o,      incrovgaps,     {.i = -1 } }, */
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

