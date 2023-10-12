/*
//         .             .              .		    
//         |             |              |           .	    
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,  
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /   
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'  
//  ,|							    
//  `'							    
// GITHUB:https://github.com/gabrielzschmitz		    
// INSTAGRAM:https://www.instagram.com/gabrielzschmitz_/    
// DOTFILES:https://github.com/gabrielzschmitz/dotfiles/    
*/

/* See LICENSE file for copyright and license details. */
#define TERMINAL "st"
#define TERMCLASS "st"

/* appearance */
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int gappx     = 15;        /* gaps between windows */
static const unsigned int snap      = 20;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int usealtbar          = 1;        /* 1 means use non-dwm status bar */
static const char *altbarclass      = "Polybar"; /* Alternate bar class name */
static const char *alttrayname      = "tray";    /* Polybar tray instance name */
static const char *altbarcmd        = "$HOME/.config/polybar/launch.sh"; /* Alternate bar launch command */
static const char *fonts[]          = { "MonoLisa Nerd Font Mono:size=12:antialias=true:autohint=true" };
#include "zerotheme.h"
static const char *colors[][3]      = {
	/*               fg         bg          border   */
	[SchemeNorm] = { white,     black,      black},
	[SchemeSel]  = { white,      black,      black},
};

/* tagging */
static const char *tags[] = { "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  " , "  " };

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
	{ "Tomato.C", 		NULL,       NULL,       0,            1,           -1 },
	{ "calc", 		NULL,       NULL,       0,            1,           -1 },
	{ "ncpamixer", 		NULL,       NULL,       0,            1,           -1 },
	{ "sfm", 		NULL,       NULL,       0,            1,           -1 },
	{ "keyb", 		NULL,       NULL,       0,            1,           -1 },
	{ "ncmpcpp", 		NULL,       NULL,       0,            1,           -1 },
	{ "packagesupgrade", 	NULL,       NULL,       0,            1,           -1 },
	{ "weatherreport", 	NULL,       NULL,       0,            0,           -1 },
        { "eww",                NULL,       NULL,       1 << 0,	      1,           -1 },
};

/* layout(s) */
static const float mfact     = 0.5;  /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ " ﬿ ",      tile },    /* first entry is default */
	{ "  ",      NULL },    /* no layout function means floating behavior */
	{ "  ",      monocle },
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
static const char *termcmd[]  = { TERMINAL , NULL };
static const char *dmenucmd[] = { "dmenucenter_run", NULL };
static const char *passdmenucmd[] = { "passdmenu", NULL };
static const char *filescmd[] = { TERMINAL, "-c", "sfm", "-g", "100x30", "-e", "sfm", NULL };
static const char *altfilescmd[] = { "pcmanfm", NULL };
static const char *bookmark[] = { "bookmarker", "--show", NULL };
static const char *addbookmark[] = { "bookmarker", "--add", NULL };
static const char *musiccmd[] = { "musiccmd", NULL };
static const char *picomcmd[] = { "picomtoggle", NULL };
static const char *unlockycmd[] = { "unlocky", NULL };
static const char *webcmd[] = { "chromium", NULL };
static const char *emojimenu[] = { "emojipicker", NULL };
static const char *powermenu[] = { "powermenu", NULL };
static const char *shotmenu[] = { "shotmenu", NULL };
static const char *sysinfo[] = { "sysinfo", NULL };
static const char *walle[] = { "walle", NULL };
static const char *dispset[] = { "dispset", NULL };
static const char *audiocontrolcmd[] = { TERMINAL, "-c", "ncpamixer", "-g", "80x15", "-e", "ncpamixer", NULL };
static const char *tomatocmd[] = { TERMINAL, "-c", "Tomato.C", "-g", "49x25", "-e", "tomato", NULL };
static const char *keybcmd[] = { TERMINAL, "-c", "keyb", "-g", "100x30", "-e", "keyb", NULL };
static const char *mutemiccmd[] = { "pamixer", "--default-source", "--toggle-mute", NULL };

#include <X11/XF86keysym.h>
static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_p,      spawn,          {.v = passdmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY|ShiftMask,          	XK_f, 	   spawn,          {.v = filescmd } },
	{ Mod1Mask|ShiftMask,          	XK_f, 	   spawn,          {.v = altfilescmd } },
	{ MODKEY|ShiftMask,          	XK_p, 	   spawn,          {.v = picomcmd } },
	{ MODKEY|ShiftMask,          	XK_l, 	   spawn,          {.v = unlockycmd } },
	{ MODKEY,             		XK_e, 	   spawn,          {.v = emojimenu } },
	{ MODKEY,             		XK_w, 	   spawn,          {.v = webcmd } },
	{ MODKEY,             		XK_0, 	   spawn,          {.v = powermenu } },
	{ MODKEY,                       XK_b, 	   spawn,          {.v = sysinfo } },
	{ MODKEY|ShiftMask,             XK_w, 	   spawn,          {.v = walle } },
	{ MODKEY|ShiftMask,             XK_d, 	   spawn,          {.v = dispset } },
	{ MODKEY|ShiftMask,		XK_slash,  spawn,          {.v = keybcmd } },
	{ MODKEY|ShiftMask,		XK_t,	   spawn,	   {.v = tomatocmd } },
	{ MODKEY,			XK_F1,	   spawn,	   SHCMD("groff -mom $HOME/.local/share/dwm/gzdots.mom -T pdf | zathura -") },
	{ MODKEY|ShiftMask,             XK_b,      spawn,          SHCMD("$HOME/.config/polybar/launch.sh &") },
	{ Mod1Mask,                     XK_b, 	   togglebar,      {0} },
	{ MODKEY,                       XK_s, 	   spawn,          {.v = bookmark } },
	{ MODKEY|ShiftMask,             XK_s, 	   spawn,          {.v = addbookmark } },
	{ Mod1Mask,             	XK_s, 	   togglesticky,   {0} },
	{ MODKEY|ShiftMask,             XK_j,      rotatestack,    {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_k,      rotatestack,    {.i = -1 } },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY|ControlMask,           XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY|ControlMask,           XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_space,  setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_f,      togglefullscr,  {0} },
	{ MODKEY,			XK_f,	   spawn,	   SHCMD("unlocky --silent") },
	{ MODKEY|ControlMask,           XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_Left,   focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_Right,  focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_Left,   tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_Right,  tagmon,         {.i = +1 } },
	{ MODKEY,                       XK_minus,  setgaps,        {.i = -1 } },
	{ MODKEY,                       XK_equal,  setgaps,        {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_equal,  setgaps,        {.i = 0  } },
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
	{ MODKEY,			XK_Print,  spawn,          {.v = shotmenu } },
	{ 0,			        XK_Print,  spawn,          SHCMD("scrot ~/pic/allmon-$(date +%H:%M:%S).png --quality 100 --freeze") },
	{ MODKEY|ShiftMask,           	XK_m, 	   spawn,          {.v = audiocontrolcmd } },
	{ Mod1Mask,          	        XK_m, 	   spawn,          {.v = mutemiccmd } },
        { 0, XF86XK_AudioMute,			   spawn,	   SHCMD("pamixer -t") },
	{ 0, XF86XK_AudioLowerVolume,		   spawn,	   SHCMD("pamixer --allow-boost -d 5") },
	{ 0, XF86XK_AudioRaiseVolume,		   spawn,	   SHCMD("pamixer --allow-boost -i 5") },
	{ MODKEY,			XK_F4,	   spawn,	   {.v = musiccmd } },
	{ MODKEY,			XK_F10,	   spawn,	   SHCMD("mpc volume 0") },
	{ MODKEY,			XK_F11,	   spawn,	   SHCMD("mpc volume -5") },
	{ MODKEY,			XK_F12,	   spawn,	   SHCMD("mpc volume +5") },
	{ 0, XF86XK_AudioPrev,			   spawn,	   SHCMD("mpc prev && disccover notify") },
	{ 0, XF86XK_AudioNext,			   spawn,	   SHCMD("mpc next && disccover notify") },
	{ 0, XF86XK_AudioPlay,			   spawn,	   SHCMD("mpc toggle && disccover notify") },
	{ 0, XF86XK_AudioStop,			   spawn,	   SHCMD("mpc stop && disccover notify") },
	{ 0, XF86XK_Calculator,			   spawn,	   SHCMD(TERMINAL " -c calc -e qalc") },
	{ 0, XF86XK_MonBrightnessUp,		   spawn,	   SHCMD("doas /home/gabrielzschmitz/.local/bin/sunlight") },
	{ 0, XF86XK_MonBrightnessDown,		   spawn,	   SHCMD("doas /home/gabrielzschmitz/.local/bin/moonlight") },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
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

static const char *ipcsockpath = "/tmp/dwm.sock";
static IPCCommand ipccommands[] = {
  IPCCOMMAND(  view,                1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  toggleview,          1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  tag,                 1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  toggletag,           1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  tagmon,              1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  focusmon,            1,      {ARG_TYPE_SINT}   ),
  IPCCOMMAND(  focusstack,          1,      {ARG_TYPE_SINT}   ),
  IPCCOMMAND(  zoom,                1,      {ARG_TYPE_NONE}   ),
  IPCCOMMAND(  incnmaster,          1,      {ARG_TYPE_SINT}   ),
  IPCCOMMAND(  killclient,          1,      {ARG_TYPE_SINT}   ),
  IPCCOMMAND(  togglefloating,      1,      {ARG_TYPE_NONE}   ),
  IPCCOMMAND(  setmfact,            1,      {ARG_TYPE_FLOAT}  ),
  IPCCOMMAND(  setlayoutsafe,       1,      {ARG_TYPE_PTR}    ),
  IPCCOMMAND(  quit,                1,      {ARG_TYPE_NONE}   )
};

