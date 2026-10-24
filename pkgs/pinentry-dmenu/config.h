/* See LICENSE file for copyright and license details. */
/* Default settings; can be overridden by command line. */

static int bottom = 0;
static int embedded = 0;
static int minpwlen = 32;
static int mon = -1;
static int lineheight = 0;
static int min_lineheight = 8;

static const char* asterisk = "*";
static const char* fonts[] = {"SFMono Nerd Font:size=20"};
static const char* prompt = NULL;
static const char* colors[SchemeLast][4] = {
  [SchemePrompt] = {"#1e222a", "#7aa2f7"},
  [SchemeNormal] = {"#abb2bf", "#1e222a"},
  [SchemeSelect] = {"#1e222a", "#7aa2f7"},
  [SchemeDesc] = {"#282c34", "#668ee3"}};
