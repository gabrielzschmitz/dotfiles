/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx = 1; /* border pixel of windows */
static const unsigned int snap = 32;    /* snap pixel */
static int topbar = 1;                  /* -b  option; if 0 means bottom bar */
static const char *fonts[] = {"SFMono Nerd Font:size=20"};
static const char *prompt = NULL;       /* -p  option; prompt to the left of item before query */
static const char *colors[SchemeLast][2] = {
	/*     fg         bg       */
	[SchemeNorm] = { "#abb2bf", "#1e222a" },
	[SchemeSel]  = { "#1e222a", "#67b0e8" },
	[SchemeOut]  = { "#000000", "#00ffff" },
};
/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines = 0;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";
