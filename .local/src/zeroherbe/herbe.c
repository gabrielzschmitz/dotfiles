#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <X11/Xresource.h>
#include <X11/extensions/Xrandr.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#include "config.h"
#include "herbe.h"

#define XRES_STR(name)                                        \
	if (XrmGetResource(db, "herbe." #name, "*", &type, &val)) \
	name = val.addr
#define XRES_INT(name)                                        \
	if (XrmGetResource(db, "herbe." #name, "*", &type, &val)) \
	name = strtoul(val.addr, 0, 10)

Display *display;
Window window;
int exit_code = EXIT_DISMISS;

const char herbe_usage_string[] =
    "herbe [-v] [-h] <body>\n"
    "            -h           This help text\n"
    "            -v           Prints current version";

static void print_version(void)
{
    printf("herbe v%s\n", VERSION_STRING);
}

static void print_help(void)
{
    print_version();
    printf("Usage: %s\n\n", herbe_usage_string);
    exit(0);
}

static void usage(const char *err)
{
  fprintf(stderr, "Usage: %s\n", err);
  exit(EXIT_FAIL);
}

static void die(const char *format, ...)
{
	va_list ap;
	va_start(ap, format);
	vfprintf(stderr, format, ap);
	fprintf(stderr, "\n");
	va_end(ap);
	exit(EXIT_FAIL);
}

static int handle_options(const char ***argv, int *argc)
{
    const char **orig_argv = *argv;

    while (*argc > 0) {
        const char *cmd = (*argv)[0];
        if (cmd[0] != '-')
            break;

        if (!strcmp(cmd, "-h")) {
            print_help();
        }
        else if (!strcmp(cmd, "-v")) {
            print_version();
            exit(0);
        }
        else {
            fprintf(stderr, "Unknown option: %s\n", cmd);
            usage(herbe_usage_string);
        }

        (*argv)++;
        (*argc)--;
    }
    return (*argv) - orig_argv;
}

int get_max_len(char *string, XftFont *font, int max_text_width)
{
	int eol = strlen(string);
	XGlyphInfo info;
	XftTextExtentsUtf8(display, font, (FcChar8 *)string, eol, &info);

	if (info.width > max_text_width)
	{
		eol = max_text_width / font->max_advance_width;
		info.width = 0;

		while (info.width < max_text_width)
		{
			eol++;
			XftTextExtentsUtf8(display, font, (FcChar8 *)string, eol, &info);
		}

		eol--;
	}

	for (int i = 0; i < eol; i++)
		if (string[i] == '\n')
		{
			string[i] = ' ';
			return ++i;
		}

	if (info.width <= max_text_width)
		return eol;

	int temp = eol;

	while (string[eol] != ' ' && eol)
		--eol;

	if (eol == 0)
		return temp;
	else
		return ++eol;
}

void expire(int sig)
{
	XEvent event;
	event.type = ButtonPress;
	event.xbutton.button = (sig == SIGUSR2) ? (ACTION_BUTTON) : (DISMISS_BUTTON);
	XSendEvent(display, window, 0, 0, &event);
	XFlush(display);
}

void read_y_offset(unsigned int **offset, int *id) {
    int shm_id = shmget(8432, sizeof(unsigned int), IPC_CREAT | 0660);
    if (shm_id == -1) die("shmget failed");

    *offset = (unsigned int *)shmat(shm_id, 0, 0);
    if (*offset == (unsigned int *)-1) die("shmat failed\n");
    *id = shm_id;
}

void free_y_offset(int id) {
    shmctl(id, IPC_RMID, NULL);
}

int main(int argc, char *argv[])
{
	const char **av = (const char **) argv;

	if (argc == 1)
	usage(herbe_usage_string);

    /* Look for flags.. */
    av++;
    handle_options(&av, &argc);

	struct sigaction act_expire, act_ignore;

	act_expire.sa_handler = expire;
	act_expire.sa_flags = SA_RESTART;
	sigemptyset(&act_expire.sa_mask);

	act_ignore.sa_handler = SIG_IGN;
	act_ignore.sa_flags = 0;
	sigemptyset(&act_ignore.sa_mask);

	sigaction(SIGALRM, &act_expire, 0);
	sigaction(SIGTERM, &act_expire, 0);
	sigaction(SIGINT, &act_expire, 0);

	sigaction(SIGUSR1, &act_ignore, 0);
	sigaction(SIGUSR2, &act_ignore, 0);

	if (!(display = XOpenDisplay(0)))
		die("Cannot open display");

	XrmInitialize();

	char *res_man = XResourceManagerString(display);
	XrmDatabase db = XrmGetStringDatabase(res_man);

	char *type;
	XrmValue val;

	XRES_STR(background_color);
	XRES_STR(border_color);
	XRES_STR(font_color);
	XRES_STR(font_pattern);

	XRES_INT(line_spacing);
	XRES_INT(padding);
	XRES_INT(width);
	XRES_INT(border_size);
	XRES_INT(pos_x);
	XRES_INT(pos_y);
	XRES_INT(corner);
	XRES_INT(duration);

	int screen = DefaultScreen(display);
	Visual *visual = DefaultVisual(display, screen);
	Colormap colormap = DefaultColormap(display, screen);

	int screen_width = DisplayWidth(display, screen);
	int screen_height = DisplayHeight(display, screen);
	if(use_primary_monitor) {
		int nMonitors;
		XRRMonitorInfo* info = XRRGetMonitors(display, RootWindow(display, screen), 1, &nMonitors);
		for(int i = 0; i < nMonitors; i++) {
			if(info[i].primary) {
				screen_width = info[i].width;
				screen_height = info[i].height;
			}
		}
	}

	XSetWindowAttributes attributes;
	attributes.override_redirect = True;
	XftColor color;
	XftColorAllocName(display, visual, colormap, background_color, &color);
	attributes.background_pixel = color.pixel;
	XftColorAllocName(display, visual, colormap, border_color, &color);
	attributes.border_pixel = color.pixel;

	XftFont *font = XftFontOpenName(display, screen, font_pattern);

	int num_of_lines = 0;
	int max_text_width = width - 2 * padding;
	int lines_size = 5;
	char **lines = malloc(lines_size * sizeof(char *));
	if (!lines)
		die("malloc failed");

	for (int i = 1; i < argc; i++)
	{
		for (unsigned int eol = get_max_len(argv[i], font, max_text_width); eol; argv[i] += eol, num_of_lines++, eol = get_max_len(argv[i], font, max_text_width))
		{
			if (lines_size <= num_of_lines)
			{
				lines = realloc(lines, (lines_size += 5) * sizeof(char *));
				if (!lines)
					die("realloc failed");
			}

			lines[num_of_lines] = malloc((eol + 1) * sizeof(char));
			if (!lines[num_of_lines])
				die("malloc failed");

			strncpy(lines[num_of_lines], argv[i], eol);
			lines[num_of_lines][eol] = '\0';
		}
	}

    int y_offset_id;
    unsigned int *y_offset;
    read_y_offset(&y_offset, &y_offset_id);

	unsigned int text_height = font->ascent - font->descent;
	unsigned int height = (num_of_lines - 1) * line_spacing + num_of_lines * text_height + 2 * padding;
	unsigned int x = pos_x;
	unsigned int y = pos_y + *y_offset;

    unsigned int used_y_offset = (*y_offset) += height + padding;

	if (corner == TOP_RIGHT || corner == BOTTOM_RIGHT)
		x = screen_width - width - border_size * 2 - x;

	if (corner == BOTTOM_LEFT || corner == BOTTOM_RIGHT)
		y = screen_height - height - border_size * 2 - y;

	window = XCreateWindow(display, RootWindow(display, screen), x, y, width, height, border_size, DefaultDepth(display, screen),
						   CopyFromParent, visual, CWOverrideRedirect | CWBackPixel | CWBorderPixel, &attributes);

	XftDraw *draw = XftDrawCreate(display, window, visual, colormap);
	XftColorAllocName(display, visual, colormap, font_color, &color);

	XClassHint classhint = { "herbe", "herbe" };
	XSetClassHint(display, window, &classhint);

	XSelectInput(display, window, ExposureMask | ButtonPress);
	XMapWindow(display, window);

	sigaction(SIGUSR1, &act_expire, 0);
	sigaction(SIGUSR2, &act_expire, 0);

	if (duration != 0)
		alarm(duration);

	for (;;)
	{
		XEvent event;
		XNextEvent(display, &event);

		if (event.type == Expose)
		{
			XClearWindow(display, window);
			for (int i = 0; i < num_of_lines; i++){
				int len = strlen(lines[i]);
			{
				XGlyphInfo info;

				XftTextExtentsUtf8(display, font, (XftChar8 *)lines[i], len, &info);
				XftDrawStringUtf8(draw, &color, font, (width - info.width) / 2,
				                  line_spacing * i + text_height * (i + 1) + padding,
				                  (FcChar8 *)lines[i], len);
			}
			}
		}
		else if (event.type == ButtonPress)
		{
			if (event.xbutton.button == DISMISS_BUTTON)
				break;
			else if (event.xbutton.button == ACTION_BUTTON)
			{
				exit_code = EXIT_ACTION;
				break;
			}
		}
	}


	for (int i = 0; i < num_of_lines; i++)
		free(lines[i]);

    if (used_y_offset == *y_offset) free_y_offset(y_offset_id);
	free(lines);
	XftDrawDestroy(draw);
	XftColorFree(display, visual, colormap, &color);
	XftFontClose(display, font);
	XrmDestroyDatabase(db);
	XCloseDisplay(display);

	return exit_code;
}

