/**
 * @file dwm.c
 * @brief Dynamic window manager core.
 *
 * dynamic window manager is designed like any other X client as well. It is
 * driven through handling X events. In contrast to other X clients, a window
 * manager selects for SubstructureRedirectMask on the root window, to receive
 * events about window (dis-)appearance. Only one X connection at a time is
 * allowed to select for this event mask.
 *
 * The event handlers of dwm are organized in an array which is accessed
 * whenever a new event has been fetched. This allows event dispatching in O(1)
 * time.
 *
 * Each child of the root window is called a client, except windows which have
 * set the override_redirect flag. Clients are organized in a linked client
 * list on each monitor, the focus history is remembered through a stack list
 * on each monitor. Each client contains a bit array to indicate the tags of a
 * client.
 *
 * Keys and tagging rules are organized as arrays and defined in config.h.
 *
 * To understand everything else, start reading main().
 */
// clang-format off
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xproto.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
#include <X11/keysym.h>
#include <errno.h>
#include <locale.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <limits.h>
#include <stdint.h>
#ifdef XINERAMA
#include <X11/extensions/Xinerama.h>
#endif /* XINERAMA */
#include <X11/Xft/Xft.h>
#include <Imlib2.h>
#include "drw.h"
#include "util.h"
// clang-format on

/* macros */
#define BUTTONMASK (ButtonPressMask | ButtonReleaseMask)
#define CLEANMASK(mask)                                                   \
  (mask & ~(numlockmask | LockMask) &                                     \
   (ShiftMask | ControlMask | Mod1Mask | Mod2Mask | Mod3Mask | Mod4Mask | \
    Mod5Mask))
#define INTERSECT(x, y, w, h, m)                                   \
  (MAX(0, MIN((x) + (w), (m)->wx + (m)->ww) - MAX((x), (m)->wx)) * \
   MAX(0, MIN((y) + (h), (m)->wy + (m)->wh) - MAX((y), (m)->wy)))
#define INTERSECTC(x, y, w, h, z)                               \
  (MAX(0, MIN((x) + (w), (z)->x + (z)->w) - MAX((x), (z)->x)) * \
   MAX(0, MIN((y) + (h), (z)->y + (z)->h) - MAX((y), (z)->y)))
#define ISVISIBLE(C) ((C->tags & C->mon->tagset[C->mon->seltags]))
#define HIDDEN(C) ((getstate(C->win) == IconicState))
#define LENGTH(X) (sizeof X / sizeof X[0])
#define MOUSEMASK (BUTTONMASK | PointerMotionMask)
#define WIDTH(X) ((X)->w + 2 * (X)->bw)
#define HEIGHT(X) ((X)->h + 2 * (X)->bw)
#define TAGMASK ((1 << LENGTH(tags)) - 1)
#define TAGSLENGTH (LENGTH(tags))
#define TEXTW(X) (drw_fontset_getwidth(drw, (X)) + lrpad)
#define MAXTABS 50

#define SYSTEM_TRAY_REQUEST_DOCK 0

/* XEMBED messages */
#define XEMBED_EMBEDDED_NOTIFY 0
#define XEMBED_WINDOW_ACTIVATE 1
#define XEMBED_FOCUS_IN 4
#define XEMBED_MODALITY_ON 10

#define XEMBED_MAPPED (1 << 0)
#define XEMBED_WINDOW_ACTIVATE 1
#define XEMBED_WINDOW_DEACTIVATE 2

#define VERSION_MAJOR 0
#define VERSION_MINOR 0
#define XEMBED_EMBEDDED_VERSION (VERSION_MAJOR << 16) | VERSION_MINOR

/* enums */
/** @brief Cursor shapes used by the window manager. */
enum {
  CurNormal,
  CurResize,
  CurMove,
  CurResizeHorzArrow,
  CurResizeVertArrow,
  CurLast
};
/** @brief Colour scheme slots used across the bar and tab bar. */
enum {
  SchemeNorm,
  SchemeSel,
  SchemeTitle,
  SchemeTag,
  SchemeTag1,
  SchemeTag2,
  SchemeTag3,
  SchemeTag4,
  SchemeTag5,
  SchemeTag6,
  SchemeTag7,
  SchemeTag8,
  SchemeTag9,
  SchemeLayout,
  TabSel,
  TabNorm,
  SchemeBtnPrev,
  SchemeBtnNext,
  SchemeBtnClose
};
/** @brief EWMH atoms advertised to clients. */
enum {
  NetSupported,
  NetWMName,
  NetWMIcon,
  NetWMState,
  NetWMCheck,
  NetSystemTray,
  NetSystemTrayOP,
  NetSystemTrayOrientation,
  NetSystemTrayOrientationHorz,
  NetWMFullscreen,
  NetActiveWindow,
  NetWMWindowType,
  NetWMWindowTypeDialog,
  NetClientList,
  NetClientInfo,
  NetDesktopNames,
  NetDesktopViewport,
  NetNumberOfDesktops,
  NetCurrentDesktop,
  NetLast
};
/** @brief XEmbed atoms used by the system tray. */
enum { Manager, Xembed, XembedInfo, XLast };
/** @brief ICCCM atoms used by the window manager. */
enum { WMProtocols, WMDelete, WMState, WMTakeFocus, WMLast };
/** @brief Clickable bar and window regions. */
enum {
  ClkTagBar,
  ClkTabBar,
  ClkTabPrev,
  ClkTabNext,
  ClkTabClose,
  ClkLtSymbol,
  ClkStatusText,
  ClkWinTitle,
  ClkClientWin,
  ClkRootWin,
  ClkLast
};

/** @brief Tab bar visibility modes. */
enum showtab_modes {
  showtab_never,
  showtab_auto,
  showtab_nmodes,
  showtab_always
};

/** @brief Generic argument passed to key and button handlers. */
typedef union {
  int i;           /**< Signed integer argument. */
  unsigned int ui; /**< Unsigned integer or tag mask argument. */
  float f;         /**< Floating point argument. */
  const void* v;   /**< Pointer argument. */
} Arg;

/** @brief A mouse button binding. */
typedef struct {
  unsigned int click;           /**< Region where the binding applies. */
  unsigned int mask;            /**< Modifier mask. */
  unsigned int button;          /**< Button number. */
  void (*func)(const Arg* arg); /**< Handler to invoke. */
  const Arg arg;                /**< Handler argument. */
} Button;

typedef struct Monitor Monitor;
typedef struct Client Client;
/** @brief A managed X window. */
struct Client {
  char name[256];             /**< Window title. */
  float mina, maxa;           /**< Minimum and maximum aspect ratio. */
  float cfact;                /**< Client size factor within its area. */
  int x, y, w, h;             /**< Current geometry. */
  int oldx, oldy, oldw, oldh; /**< Geometry before the last change. */
  /** Size hints and increments. */
  int basew, baseh, incw, inch, maxw, maxh, minw, minh, hintsvalid;
  int bw, oldbw;     /**< Current and original border width. */
  unsigned int tags; /**< Tag mask of the client. */
  int isfixed, iscentered, isfloating, isurgent, neverfocus, oldstate,
    isfullscreen;        /**< Client state flags. */
  unsigned int icw, ich; /**< Scaled icon dimensions. */
  Picture icon;          /**< Cached icon picture. */
  int beingmoved;        /**< Non-zero while interactively moved. */
  Client* next;          /**< Next client on the monitor. */
  Client* snext;         /**< Next client in the focus stack. */
  Monitor* mon;          /**< Monitor owning the client. */
  Window win;            /**< X window handle. */
};

/** @brief A keyboard binding. */
typedef struct {
  unsigned int mod;         /**< Modifier mask. */
  KeySym keysym;            /**< Key symbol. */
  void (*func)(const Arg*); /**< Handler to invoke. */
  const Arg arg;            /**< Handler argument. */
} Key;

/** @brief A window layout. */
typedef struct {
  const char* symbol;        /**< Short symbol shown in the bar. */
  void (*arrange)(Monitor*); /**< Arrange function, or NULL for floating. */
} Layout;

/** @brief A client matching rule. */
typedef struct {
  const char* class;    /**< WM_CLASS to match, or NULL. */
  const char* instance; /**< WM_CLASS instance to match, or NULL. */
  const char* title;    /**< Window title substring to match, or NULL. */
  unsigned int tags;    /**< Tags assigned on match. */
  int iscentered;       /**< Non-zero to center the client. */
  int isfloating;       /**< Non-zero to make the client floating. */
  int monitor;          /**< Target monitor number, or -1. */
} Rule;

typedef struct Systray Systray;
/** @brief The system tray window and its icons. */
struct Systray {
  Window win;    /**< Tray selection owner window. */
  Client* icons; /**< Linked list of tray icons. */
};

/** @brief A bar launcher entry. */
typedef struct {
  const char** command; /**< NULL-terminated command vector. */
  const char* name;     /**< Label displayed in the bar. */
} Launcher;

/* function declarations */
static void applyrules(Client* c);
static int applysizehints(Client* c, int* x, int* y, int* w, int* h,
                          int interact);
static void arrange(Monitor* m);
static void arrangemon(Monitor* m);
static void attach(Client* c);
static void attachstack(Client* c);
static void buttonpress(XEvent* e);
static void checkotherwm(void);
static void cleanup(void);
static void cleanupmon(Monitor* mon);
static void clientmessage(XEvent* e);
static void configure(Client* c);
static void configurenotify(XEvent* e);
static void configurerequest(XEvent* e);
static Monitor* createmon(void);
static void cyclelayout(const Arg* arg);
static void destroynotify(XEvent* e);
static void detach(Client* c);
static void detachstack(Client* c);
static Monitor* dirtomon(int dir);
static void dragmfact(const Arg* arg);
static void dragcfact(const Arg* arg);
static void drawbar(Monitor* m);
static void drawbars(void);
static int drawstatusbar(Monitor* m, int bh, char* text);
static void drawtab(Monitor* m);
static void drawtabs(void);
static void enternotify(XEvent* e);
static void expose(XEvent* e);
static void focus(Client* c);
static void focusin(XEvent* e);
static void focusmon(const Arg* arg);
static void focusstack(const Arg* arg);
static void focuswin(const Arg* arg);
static Atom getatomprop(Client* c, Atom prop);
static Picture geticonprop(Window w, unsigned int* icw, unsigned int* ich);
static int getrootptr(int* x, int* y);
static long getstate(Window w);
static unsigned int getsystraywidth();
static int gettextprop(Window w, Atom atom, char* text, unsigned int size);
static void grabbuttons(Client* c, int focused);
static void grabkeys(void);
static void hide(Client* c);
static void incnmaster(const Arg* arg);
static void keypress(XEvent* e);
static void killclient(const Arg* arg);
static void manage(Window w, XWindowAttributes* wa);
static void mappingnotify(XEvent* e);
static void maprequest(XEvent* e);
static void monocle(Monitor* m);
static void motionnotify(XEvent* e);
static void movemouse(const Arg* arg);
static void moveorplace(const Arg* arg);
static Client* nexttiled(Client* c);
static void placemouse(const Arg* arg);
static void pop(Client* c);
static void propertynotify(XEvent* e);
static void quit(const Arg* arg);
static void restart(const Arg* arg);
static Client* recttoclient(int x, int y, int w, int h);
static Monitor* recttomon(int x, int y, int w, int h);
static void removesystrayicon(Client* i);
static void resize(Client* c, int x, int y, int w, int h, int interact);
static void resizebarwin(Monitor* m);
static void resizeclient(Client* c, int x, int y, int w, int h);
static void resizemouse(const Arg* arg);
static void resizerequest(XEvent* e);
static void restack(Monitor* m);
static void run(void);
static void scan(void);
static int sendevent(Window w, Atom proto, int m, long d0, long d1, long d2,
                     long d3, long d4);
static void sendmon(Client* c, Monitor* m);
static void setborderpx(const Arg* arg);
static void setclientstate(Client* c, long state);
static void setclienttagprop(Client* c);
static void setcurrentdesktop(void);
static void setdesktopnames(void);
static void setfocus(Client* c);
static void setfullscreen(Client* c, int fullscreen);
static void setlayout(const Arg* arg);
static void setcfact(const Arg* arg);
static void setmfact(const Arg* arg);
static void setnumdesktops(void);
static void setup(void);
static void setviewport(void);
static void seturgent(Client* c, int urg);
static void show(Client* c);
static void showhide(Client* c);
static void showtagpreview(int tag);
static void spawn(const Arg* arg);
static void switchtag(void);
static Monitor* systraytomon(Monitor* m);
static void tabmode(const Arg* arg);
static void tag(const Arg* arg);
static void tagmon(const Arg* arg);
static void togglebar(const Arg* arg);
static void togglefloating(const Arg* arg);
static void togglefullscr(const Arg* arg);
static void toggletag(const Arg* arg);
static void toggleview(const Arg* arg);
static void freeicon(Client* c);
static void hidewin(const Arg* arg);
static void restorewin(const Arg* arg);
static void unfocus(Client* c, int setfocus);
static void unmanage(Client* c, int destroyed);
static void unmapnotify(XEvent* e);
static void updatecurrentdesktop(void);
static void updatebarpos(Monitor* m);
static void updatebars(void);
static void updatepreview(void);
static void updateclientlist(void);
static int updategeom(void);
static void updatenumlockmask(void);
static void updatesizehints(Client* c);
static void updatestatus(void);
static void updatesystray(void);
static void updatesystrayicongeom(Client* i, int w, int h);
static void updatesystrayiconstate(Client* i, XPropertyEvent* ev);
static void updatetitle(Client* c);
static void updateicon(Client* c);
static void updatewindowtype(Client* c);
static void updatewmhints(Client* c);
static void view(const Arg* arg);
static Client* wintoclient(Window w);
static Monitor* wintomon(Window w);
static Client* wintosystrayicon(Window w);
static int xerror(Display* dpy, XErrorEvent* ee);
static int xerrordummy(Display* dpy, XErrorEvent* ee);
static int xerrorstart(Display* dpy, XErrorEvent* ee);
static void zoom(const Arg* arg);

/* variables */
static Systray* systray = NULL;
static const char broken[] = "broken";
static char stext[1024];
static int screen;
static int sw, sh; /* X display screen geometry width, height */
static int bh;     /* bar height */
static int th = 0; /* tab bar geometry */
static int lrpad;  /* sum of left and right padding for text */
static int (*xerrorxlib)(Display*, XErrorEvent*);
static unsigned int numlockmask = 0;
static void (*handler[LASTEvent])(XEvent*) = {
  [ButtonPress] = buttonpress,
  [ClientMessage] = clientmessage,
  [ConfigureRequest] = configurerequest,
  [ConfigureNotify] = configurenotify,
  [DestroyNotify] = destroynotify,
  [EnterNotify] = enternotify,
  [Expose] = expose,
  [FocusIn] = focusin,
  [KeyPress] = keypress,
  [MappingNotify] = mappingnotify,
  [MapRequest] = maprequest,
  [MotionNotify] = motionnotify,
  [PropertyNotify] = propertynotify,
  [ResizeRequest] = resizerequest,
  [UnmapNotify] = unmapnotify};
static Atom wmatom[WMLast], netatom[NetLast], xatom[XLast];
static int running = 1;
static Cur* cursor[CurLast];
static Clr **scheme, clrborder;
static Display* dpy;
static Drw* drw;
static Monitor *mons, *selmon;
static Window root, wmcheckwin;

#define hiddenWinStackMax 100
static int hiddenWinStackTop = -1;
static Client* hiddenWinStack[hiddenWinStackMax];

/* configuration, allows nested code to access above variables */
#include "config.h"

typedef struct Pertag Pertag;
/** @brief A monitor and its per-monitor layout state. */
struct Monitor {
  char ltsymbol[16];           /**< Layout symbol shown in the bar. */
  float mfact;                 /**< Master area factor. */
  int nmaster;                 /**< Number of clients in the master area. */
  int num;                     /**< Monitor number. */
  int by;                      /**< Bar geometry. */
  int ty;                      /**< Tab bar geometry. */
  int mx, my, mw, mh;          /**< Screen size. */
  int wx, wy, ww, wh;          /**< Window area. */
  int gappih;                  /**< Horizontal gap between windows. */
  int gappiv;                  /**< Vertical gap between windows. */
  int gappoh;                  /**< Horizontal outer gaps. */
  int gappov;                  /**< Vertical outer gaps. */
  unsigned int borderpx;       /**< Border width. */
  unsigned int seltags;        /**< Selected tag set index. */
  unsigned int sellt;          /**< Selected layout index. */
  unsigned int tagset[2];      /**< Tag sets for the two views. */
  unsigned int colorfultag;    /**< Non-zero to colour tag labels. */
  int showbar, showtab;        /**< Whether the bar and tab bar are shown. */
  int topbar, toptab;          /**< Whether the bar and tab bar are on top. */
  Client* clients;             /**< Linked list of clients on the monitor. */
  Client* sel;                 /**< Currently focused client. */
  Client* stack;               /**< Focus stack. */
  Monitor* next;               /**< Next monitor in the list. */
  Window barwin;               /**< Bar window. */
  Window tabwin;               /**< Tab bar window. */
  Window tagwin;               /**< Tag preview window. */
  Pixmap tagmap[LENGTH(tags)]; /**< Tag preview pixmaps. */
  int previewshow;             /**< Non-zero when tag previews are shown. */
  int ntabs;                   /**< Number of open tabs. */
  int tab_widths[MAXTABS];     /**< Width of each tab. */
  int tab_btn_w[3];            /**< Width of the tab buttons. */
  const Layout* lt[2];         /**< Layouts for the two layout slots. */
  Pertag* pertag;              /**< Per-tag state. */
};

#include "movestack.c"
#include "shiftview.c"
#include "vanitygaps.c"

/** @brief Per-tag copies of the layout settings. */
struct Pertag {
  unsigned int curtag, prevtag;              /**< Current and previous tag. */
  int nmasters[LENGTH(tags) + 1];            /**< Master count per tag. */
  float mfacts[LENGTH(tags) + 1];            /**< Master factor per tag. */
  unsigned int sellts[LENGTH(tags) + 1];     /**< Selected layout per tag. */
  const Layout* ltidxs[LENGTH(tags) + 1][2]; /**< Layouts per tag and slot. */
  int showbars[LENGTH(tags) + 1];            /**< Bar visibility per tag. */
};

/** @brief Compile-time check that all tags fit into an unsigned int. */
struct NumTags {
  char limitexceeded[LENGTH(tags) > 31 ? -1 : 1];
};

/* function implementations */
/**
 * @brief Apply the tag and state rules from config.h to a client.
 *
 * @param c          Client to configure.
 */
void applyrules(Client* c) {
  const char* class, *instance;
  unsigned int i;
  const Rule* r;
  Monitor* m;
  XClassHint ch = {NULL, NULL};

  c->iscentered = 0;
  c->isfloating = 0;
  c->tags = 0;
  XGetClassHint(dpy, c->win, &ch);
  class = ch.res_class ? ch.res_class : broken;
  instance = ch.res_name ? ch.res_name : broken;

  for (i = 0; i < LENGTH(rules); i++) {
    r = &rules[i];
    if ((!r->title || strstr(c->name, r->title)) &&
        (!r->class || strstr(class, r->class)) &&
        (!r->instance || strstr(instance, r->instance))) {
      c->iscentered = r->iscentered;
      c->isfloating = r->isfloating;
      c->tags |= r->tags;
      for (m = mons; m && m->num != r->monitor; m = m->next);
      if (m) c->mon = m;
    }
  }
  if (ch.res_class) XFree(ch.res_class);
  if (ch.res_name) XFree(ch.res_name);
  c->tags =
    c->tags & TAGMASK ? c->tags & TAGMASK : c->mon->tagset[c->mon->seltags];
}

/**
 * @brief Clamp a proposed geometry to the size hints advertised by a client.
 *
 * @param c          Client whose hints are applied.
 * @param x          Proposed x coordinate.
 * @param y          Proposed y coordinate.
 * @param w          Proposed width.
 * @param h          Proposed height.
 * @param interact   Non-zero for interactive resizing.
 * @return Non-zero when the geometry was changed.
 */
int applysizehints(Client* c, int* x, int* y, int* w, int* h, int interact) {
  int baseismin;
  Monitor* m = c->mon;

  *w = MAX(1, *w);
  *h = MAX(1, *h);
  if (interact) {
    if (*x > sw) *x = sw - WIDTH(c);
    if (*y > sh) *y = sh - HEIGHT(c);
    if (*x + *w + 2 * c->bw < 0) *x = 0;
    if (*y + *h + 2 * c->bw < 0) *y = 0;
  } else {
    if (*x >= m->wx + m->ww) *x = m->wx + m->ww - WIDTH(c);
    if (*y >= m->wy + m->wh) *y = m->wy + m->wh - HEIGHT(c);
    if (*x + *w + 2 * c->bw <= m->wx) *x = m->wx;
    if (*y + *h + 2 * c->bw <= m->wy) *y = m->wy;
  }
  if (*h < bh) *h = bh;
  if (*w < bh) *w = bh;
  if (resizehints || c->isfloating || !c->mon->lt[c->mon->sellt]->arrange) {
    if (!c->hintsvalid) updatesizehints(c);
    /* see last two sentences in ICCCM 4.1.2.3 */
    baseismin = c->basew == c->minw && c->baseh == c->minh;
    if (!baseismin) { /* temporarily remove base dimensions */
      *w -= c->basew;
      *h -= c->baseh;
    }
    /* adjust for aspect limits */
    if (c->mina > 0 && c->maxa > 0) {
      if (c->maxa < (float)*w / *h)
        *w = *h * c->maxa + 0.5;
      else if (c->mina < (float)*h / *w)
        *h = *w * c->mina + 0.5;
    }
    if (baseismin) { /* increment calculation requires this */
      *w -= c->basew;
      *h -= c->baseh;
    }
    /* adjust for increment value */
    if (c->incw) *w -= *w % c->incw;
    if (c->inch) *h -= *h % c->inch;
    /* restore base dimensions */
    *w = MAX(*w + c->basew, c->minw);
    *h = MAX(*h + c->baseh, c->minh);
    if (c->maxw) *w = MIN(*w, c->maxw);
    if (c->maxh) *h = MIN(*h, c->maxh);
  }
  return *x != c->x || *y != c->y || *w != c->w || *h != c->h;
}

/**
 * @brief Show, arrange and restack clients on a monitor.
 *
 * @param m          Monitor to arrange, or NULL for every monitor.
 */
void arrange(Monitor* m) {
  if (m)
    showhide(m->stack);
  else
    for (m = mons; m; m = m->next) showhide(m->stack);
  if (m) {
    arrangemon(m);
    restack(m);
  } else
    for (m = mons; m; m = m->next) arrangemon(m);
}

/**
 * @brief Update a monitor's auxiliary windows and run its layout function.
 *
 * @param m          Monitor to arrange.
 */
void arrangemon(Monitor* m) {
  updatebarpos(m);
  updatesystray();
  XMoveResizeWindow(dpy, m->tabwin, m->wx + m->gappov, m->ty,
                    m->ww - 2 * m->gappov, th);
  XMoveWindow(dpy, m->tagwin, m->wx + m->gappov,
              m->by + (m->topbar ? (bh + m->gappoh)
                                 : (-(m->mh / scalepreview) - m->gappoh)));
  snprintf(m->ltsymbol, sizeof m->ltsymbol, "%s", m->lt[m->sellt]->symbol);
  if (m->lt[m->sellt]->arrange) m->lt[m->sellt]->arrange(m);
}

/**
 * @brief Insert a client into its monitor's client list.
 *
 * @param c          Client to attach.
 */
void attach(Client* c) {
  if (new_window_attach_on_end) {
    Client** tmp = &c->mon->clients;
    while (*tmp) tmp = &(*tmp)->next;
    *tmp = c;
  } else {
    c->next = c->mon->clients;
    c->mon->clients = c;
  }
}

/**
 * @brief Push a client onto its monitor's focus stack.
 *
 * @param c          Client to attach.
 */
void attachstack(Client* c) {
  c->snext = c->mon->stack;
  c->mon->stack = c;
}

/**
 * @brief Dispatch a pointer button press to the configured handler.
 *
 * @param e          X button press event.
 */
void buttonpress(XEvent* e) {
  unsigned int i, x, click;
  int loop;
  Arg arg = {0};
  Client* c;
  Monitor* m;
  XButtonPressedEvent* ev = &e->xbutton;

  click = ClkRootWin;
  /* focus monitor if necessary */
  if ((m = wintomon(ev->window)) && m != selmon) {
    unfocus(selmon->sel, 1);
    selmon = m;
    focus(NULL);
  }
  if (ev->window == selmon->barwin) {
    if (selmon->previewshow) {
      XUnmapWindow(dpy, selmon->tagwin);
      selmon->previewshow = 0;
    }
    i = x = 0;
    do x += TEXTW(tags[i]);
    while (ev->x >= x && ++i < LENGTH(tags));
    if (i < LENGTH(tags)) {
      click = ClkTagBar;
      arg.ui = 1 << i;
      goto execute_handler;
    } else if (ev->x < x + TEXTW(selmon->ltsymbol)) {
      click = ClkLtSymbol;
      goto execute_handler;
    }

    x += TEXTW(selmon->ltsymbol);

    for (i = 0; i < LENGTH(launchers); i++) {
      x += TEXTW(launchers[i].name);

      if (ev->x < x) {
        Arg a;
        a.v = launchers[i].command;
        spawn(&a);
        return;
      }
    }

    if (ev->x > selmon->ww - (int)TEXTW(stext))
      click = ClkStatusText;
    else
      click = ClkWinTitle;
  }

  if (ev->window == selmon->tabwin) {
    i = 0;
    x = 0;
    for (c = selmon->clients; c; c = c->next) {
      if (!ISVISIBLE(c)) continue;
      x += selmon->tab_widths[i];
      if (ev->x > x)
        ++i;
      else
        break;
      if (i >= m->ntabs) break;
    }
    if (c && ev->x <= x) {
      click = ClkTabBar;
      arg.ui = i;
    } else {
      x = selmon->ww - 2 * m->gappov;
      for (loop = 2; loop >= 0; loop--) {
        x -= selmon->tab_btn_w[loop];
        if (ev->x > x) break;
      }
      if (ev->x >= x) click = ClkTabPrev + loop;
    }
  } else if ((c = wintoclient(ev->window))) {
    focus(c);
    restack(selmon);
    XAllowEvents(dpy, ReplayPointer, CurrentTime);
    click = ClkClientWin;
  }

execute_handler:

  for (i = 0; i < LENGTH(buttons); i++)
    if (click == buttons[i].click && buttons[i].func &&
        buttons[i].button == ev->button &&
        CLEANMASK(buttons[i].mask) == CLEANMASK(ev->state))
      buttons[i].func(
        ((click == ClkTagBar || click == ClkTabBar) && buttons[i].arg.i == 0)
          ? &arg
          : &buttons[i].arg);
}

/**
 * @brief Check that no other window manager already selected the root window.
 */
void checkotherwm(void) {
  xerrorxlib = XSetErrorHandler(xerrorstart);
  /* this causes an error if some other window manager is running */
  XSelectInput(dpy, DefaultRootWindow(dpy), SubstructureRedirectMask);
  XSync(dpy, False);
  XSetErrorHandler(xerror);
  XSync(dpy, False);
}

/**
 * @brief Release all window manager resources before exiting.
 */
void cleanup(void) {
  Arg a = {.ui = ~0};
  Layout foo = {"", NULL};
  Monitor* m;
  size_t i;

  view(&a);
  selmon->lt[selmon->sellt] = &foo;
  for (m = mons; m; m = m->next)
    while (m->stack) unmanage(m->stack, 0);
  XUngrabKey(dpy, AnyKey, AnyModifier, root);
  while (mons) cleanupmon(mons);
  if (showsystray) {
    XUnmapWindow(dpy, systray->win);
    XDestroyWindow(dpy, systray->win);
    free(systray);
  }
  for (i = 0; i < CurLast; i++) drw_cur_free(drw, cursor[i]);
  for (i = 0; i < LENGTH(colors) + 1; i++) free(scheme[i]);
  free(scheme);
  XDestroyWindow(dpy, wmcheckwin);
  drw_free(drw);
  XSync(dpy, False);
  XSetInputFocus(dpy, PointerRoot, RevertToPointerRoot, CurrentTime);
  XDeleteProperty(dpy, root, netatom[NetActiveWindow]);
}

/**
 * @brief Unlink and free a monitor and its windows.
 *
 * @param mon        Monitor to destroy.
 */
void cleanupmon(Monitor* mon) {
  Monitor* m;
  size_t i;

  if (mon == mons)
    mons = mons->next;
  else {
    for (m = mons; m && m->next != mon; m = m->next);
    m->next = mon->next;
  }
  for (i = 0; i < LENGTH(tags); i++) {
    if (mon->tagmap[i]) XFreePixmap(dpy, mon->tagmap[i]);
  }
  XUnmapWindow(dpy, mon->barwin);
  XDestroyWindow(dpy, mon->barwin);
  XUnmapWindow(dpy, mon->tabwin);
  XDestroyWindow(dpy, mon->tabwin);
  XUnmapWindow(dpy, mon->tagwin);
  XDestroyWindow(dpy, mon->tagwin);
  free(mon);
}

/**
 * @brief Handle EWMH and XEmbed client messages, including systray docking.
 *
 * @param e          X client message event.
 */
void clientmessage(XEvent* e) {
  XWindowAttributes wa;
  XSetWindowAttributes swa;
  XClientMessageEvent* cme = &e->xclient;
  Client* c = wintoclient(cme->window);

  if (showsystray && cme->window == systray->win &&
      cme->message_type == netatom[NetSystemTrayOP]) {
    if (cme->data.l[1] == SYSTEM_TRAY_REQUEST_DOCK) {
      if (!(c = (Client*)calloc(1, sizeof(Client))))
        die("fatal: could not malloc() %u bytes\n", sizeof(Client));
      if (!(c->win = cme->data.l[2])) {
        free(c);
        return;
      }
      c->mon = selmon;
      c->next = systray->icons;
      systray->icons = c;
      if (!XGetWindowAttributes(dpy, c->win, &wa)) {
        wa.width = bh;
        wa.height = bh;
        wa.border_width = 0;
      }
      c->x = c->oldx = c->y = c->oldy = 0;
      c->w = c->oldw = wa.width;
      c->h = c->oldh = wa.height;
      c->oldbw = wa.border_width;
      c->bw = 0;
      c->isfloating = True;
      c->tags = 1;
      updatesizehints(c);
      updatesystrayicongeom(c, wa.width, wa.height);
      XAddToSaveSet(dpy, c->win);
      XSelectInput(
        dpy, c->win,
        StructureNotifyMask | PropertyChangeMask | ResizeRedirectMask);
      XClassHint ch = {"dwmsystray", "dwmsystray"};
      XSetClassHint(dpy, c->win, &ch);
      XReparentWindow(dpy, c->win, systray->win, 0, 0);
      /* use parents background color */
      swa.background_pixel = scheme[SchemeNorm][ColBg].pixel;
      XChangeWindowAttributes(dpy, c->win, CWBackPixel, &swa);
      sendevent(c->win, netatom[Xembed], StructureNotifyMask, CurrentTime,
                XEMBED_EMBEDDED_NOTIFY, 0, systray->win,
                XEMBED_EMBEDDED_VERSION);
      /* FIXME not sure if I have to send these events, too */
      sendevent(c->win, netatom[Xembed], StructureNotifyMask, CurrentTime,
                XEMBED_FOCUS_IN, 0, systray->win, XEMBED_EMBEDDED_VERSION);
      sendevent(c->win, netatom[Xembed], StructureNotifyMask, CurrentTime,
                XEMBED_WINDOW_ACTIVATE, 0, systray->win,
                XEMBED_EMBEDDED_VERSION);
      sendevent(c->win, netatom[Xembed], StructureNotifyMask, CurrentTime,
                XEMBED_MODALITY_ON, 0, systray->win, XEMBED_EMBEDDED_VERSION);
      XSync(dpy, False);
      resizebarwin(selmon);
      updatesystray();
      setclientstate(c, NormalState);
    }
    return;
  }
  if (!c) return;
  if (cme->message_type == netatom[NetWMState]) {
    if (cme->data.l[1] == netatom[NetWMFullscreen] ||
        cme->data.l[2] == netatom[NetWMFullscreen])
      setfullscreen(c, (cme->data.l[0] == 1 /* _NET_WM_STATE_ADD    */
                        || (cme->data.l[0] == 2 /* _NET_WM_STATE_TOGGLE */ &&
                            !c->isfullscreen)));
  } else if (cme->message_type == netatom[NetActiveWindow]) {
    if (c != selmon->sel && !c->isurgent) seturgent(c, 1);
  }
}

/**
 * @brief Send a synthetic ConfigureNotify event describing the client geometry.
 *
 * @param c          Client to notify.
 */
void configure(Client* c) {
  XConfigureEvent ce;

  ce.type = ConfigureNotify;
  ce.display = dpy;
  ce.event = c->win;
  ce.window = c->win;
  ce.x = c->x;
  ce.y = c->y;
  ce.width = c->w;
  ce.height = c->h;
  ce.border_width = c->bw;
  ce.above = None;
  ce.override_redirect = False;
  XSendEvent(dpy, c->win, False, StructureNotifyMask, (XEvent*)&ce);
}

/**
 * @brief React to root window size changes by updating monitors and bars.
 *
 * @param e          X configure notify event.
 */
void configurenotify(XEvent* e) {
  Monitor* m;
  Client* c;
  XConfigureEvent* ev = &e->xconfigure;
  int dirty;

  /* TODO: updategeom handling sucks, needs to be simplified */
  if (ev->window == root) {
    dirty = (sw != ev->width || sh != ev->height);
    sw = ev->width;
    sh = ev->height;
    if (updategeom() || dirty) {
      drw_resize(drw, sw, bh);
      updatebars();
      for (m = mons; m; m = m->next) {
        for (c = m->clients; c; c = c->next)
          if (c->isfullscreen) resizeclient(c, m->mx, m->my, m->mw, m->mh);
        resizebarwin(m);
      }
      focus(NULL);
      arrange(NULL);
    }
  }
}

/**
 * @brief Honour a client's configure request where the layout permits it.
 *
 * @param e          X configure request event.
 */
void configurerequest(XEvent* e) {
  Client* c;
  Monitor* m;
  XConfigureRequestEvent* ev = &e->xconfigurerequest;
  XWindowChanges wc;

  if ((c = wintoclient(ev->window))) {
    if (ev->value_mask & CWBorderWidth)
      c->bw = ev->border_width;
    else if (c->isfloating || !selmon->lt[selmon->sellt]->arrange) {
      m = c->mon;
      if (ev->value_mask & CWX) {
        c->oldx = c->x;
        c->x = m->mx + ev->x;
      }
      if (ev->value_mask & CWY) {
        c->oldy = c->y;
        c->y = m->my + ev->y;
      }
      if (ev->value_mask & CWWidth) {
        c->oldw = c->w;
        c->w = ev->width;
      }
      if (ev->value_mask & CWHeight) {
        c->oldh = c->h;
        c->h = ev->height;
      }
      if ((c->x + c->w) > m->mx + m->mw && c->isfloating)
        c->x = m->mx + (m->mw / 2 - WIDTH(c) / 2);
      if ((c->y + c->h) > m->my + m->mh && c->isfloating)
        c->y = m->my + (m->mh / 2 - HEIGHT(c) / 2);
      if ((ev->value_mask & (CWX | CWY)) &&
          !(ev->value_mask & (CWWidth | CWHeight)))
        configure(c);
      if (ISVISIBLE(c)) XMoveResizeWindow(dpy, c->win, c->x, c->y, c->w, c->h);
    } else
      configure(c);
  } else {
    wc.x = ev->x;
    wc.y = ev->y;
    wc.width = ev->width;
    wc.height = ev->height;
    wc.border_width = ev->border_width;
    wc.sibling = ev->above;
    wc.stack_mode = ev->detail;
    XConfigureWindow(dpy, ev->window, ev->value_mask, &wc);
  }
  XSync(dpy, False);
}

/**
 * @brief Allocate and initialize a monitor using the configured defaults.
 * @return Newly created monitor.
 */
Monitor* createmon(void) {
  Monitor* m;
  size_t i;

  m = ecalloc(1, sizeof(Monitor));
  m->tagset[0] = m->tagset[1] = 1;
  m->mfact = mfact;
  m->nmaster = nmaster;
  m->showbar = showbar;
  m->showtab = showtab;
  m->topbar = topbar;
  m->toptab = toptab;
  m->ntabs = 0;
  m->colorfultag = colorfultag ? colorfultag : 0;
  m->gappih = gappih;
  m->gappiv = gappiv;
  m->gappoh = gappoh;
  m->gappov = gappov;
  m->borderpx = borderpx;
  m->lt[0] = &layouts[0];
  m->lt[1] = &layouts[1 % LENGTH(layouts)];
  for (i = 0; i < LENGTH(tags); i++) m->tagmap[i] = 0;
  m->previewshow = 0;
  strncpy(m->ltsymbol, layouts[0].symbol, sizeof m->ltsymbol);
  m->pertag = ecalloc(1, sizeof(Pertag));
  m->pertag->curtag = m->pertag->prevtag = 1;

  for (i = 0; i <= LENGTH(tags); i++) {
    m->pertag->nmasters[i] = m->nmaster;
    m->pertag->mfacts[i] = m->mfact;

    m->pertag->ltidxs[i][0] = m->lt[0];
    m->pertag->ltidxs[i][1] = m->lt[1];
    m->pertag->sellts[i] = m->sellt;

    m->pertag->showbars[i] = m->showbar;
  }

  return m;
}

/**
 * @brief Switch to the next or previous layout in the layout list.
 *
 * @param arg        Positive for next, negative for previous.
 */
void cyclelayout(const Arg* arg) {
  Layout* l;
  for (l = (Layout*)layouts; l != selmon->lt[selmon->sellt]; l++);
  if (arg->i > 0) {
    if (l->symbol && (l + 1)->symbol)
      setlayout(&((Arg){.v = (l + 1)}));
    else
      setlayout(&((Arg){.v = layouts}));
  } else {
    if (l != layouts && (l - 1)->symbol)
      setlayout(&((Arg){.v = (l - 1)}));
    else
      setlayout(&((Arg){.v = &layouts[LENGTH(layouts) - 2]}));
  }
}

/**
 * @brief Handle destruction of a managed client or systray icon.
 *
 * @param e          X destroy notify event.
 */
void destroynotify(XEvent* e) {
  Client* c;
  XDestroyWindowEvent* ev = &e->xdestroywindow;

  if ((c = wintoclient(ev->window)))
    unmanage(c, 1);
  else if ((c = wintosystrayicon(ev->window))) {
    removesystrayicon(c);
    resizebarwin(selmon);
    updatesystray();
  }
}

/**
 * @brief Remove a client from its monitor's client list.
 *
 * @param c          Client to detach.
 */
void detach(Client* c) {
  Client** tc;

  for (tc = &c->mon->clients; *tc && *tc != c; tc = &(*tc)->next);
  *tc = c->next;
}

/**
 * @brief Remove a client from its monitor's focus stack.
 *
 * @param c          Client to detach.
 */
void detachstack(Client* c) {
  Client **tc, *t;

  for (tc = &c->mon->stack; *tc && *tc != c; tc = &(*tc)->snext);
  *tc = c->snext;

  if (c == c->mon->sel) {
    for (t = c->mon->stack; t && !ISVISIBLE(t); t = t->snext);
    c->mon->sel = t;
  }
}

/**
 * @brief Return the monitor adjacent to the selected one in a direction.
 *
 * @param dir        Positive for next, negative for previous.
 * @return Adjacent monitor, wrapping around the monitor list.
 */
Monitor* dirtomon(int dir) {
  Monitor* m = NULL;

  if (dir > 0) {
    if (!(m = selmon->next)) m = mons;
  } else if (selmon == mons)
    for (m = mons; m->next; m = m->next);
  else
    for (m = mons; m->next != selmon; m = m->next);
  return m;
}

/**
 * @brief Render the status text, including the built-in colour markup.
 *
 * @param m          Monitor whose bar is drawn.
 * @param bh         Bar height.
 * @param stext      Status string to render.
 * @return Left edge of the drawn status area.
 */
int drawstatusbar(Monitor* m, int bh, char* stext) {
  int ret, i, w, x, len;
  short isCode = 0;
  char* text;
  char* p;

  len = strlen(stext) + 1;
  if (!(text = (char*)malloc(sizeof(char) * len))) die("malloc");
  p = text;
  memcpy(text, stext, len);

  /* compute width of the status text */
  w = 0;
  i = -1;
  while (text[++i]) {
    if (text[i] == '^') {
      if (!isCode) {
        isCode = 1;
        text[i] = '\0';
        w += TEXTW(text) - lrpad;
        text[i] = '^';
        if (text[++i] == 'f') w += atoi(text + ++i);
      } else {
        isCode = 0;
        text = text + i + 1;
        i = -1;
      }
    }
  }
  if (!isCode)
    w += TEXTW(text) - lrpad;
  else
    isCode = 0;
  text = p;

  w += horizpadbar;
  if (floatbar) {
    ret = x = m->ww - m->gappov * 2 - borderpx - w;
    x = m->ww - m->gappov * 2 - borderpx - w - getsystraywidth();
  } else {
    ret = x = m->ww - borderpx - w;
    x = m->ww - w - getsystraywidth();
  }

  drw_setscheme(drw, scheme[LENGTH(colors)]);
  drw->scheme[ColFg] = scheme[SchemeNorm][ColFg];
  drw->scheme[ColBg] = scheme[SchemeNorm][ColBg];
  drw_rect(drw, x, borderpx, w, bh, 1, 1);
  x += horizpadbar / 2;

  /* process status text */
  i = -1;
  while (text[++i]) {
    if (text[i] == '^' && !isCode) {
      isCode = 1;

      text[i] = '\0';
      w = TEXTW(text) - lrpad;
      drw_text(drw, x, borderpx + vertpadbar / 2, w, bh - vertpadbar, 0, text,
               0);

      x += w;

      /* process code */
      while (text[++i] != '^') {
        if (text[i] == 'c') {
          char buf[8];
          memcpy(buf, (char*)text + i + 1, 7);
          buf[7] = '\0';
          drw_clr_create(drw, &drw->scheme[ColFg], buf);
          i += 7;
        } else if (text[i] == 'b') {
          char buf[8];
          memcpy(buf, (char*)text + i + 1, 7);
          buf[7] = '\0';
          drw_clr_create(drw, &drw->scheme[ColBg], buf);
          i += 7;
        } else if (text[i] == 'd') {
          drw->scheme[ColFg] = scheme[SchemeNorm][ColFg];
          drw->scheme[ColBg] = scheme[SchemeNorm][ColBg];
        } else if (text[i] == 'r') {
          int rx = atoi(text + ++i);
          while (text[++i] != ',');
          int ry = atoi(text + ++i);
          while (text[++i] != ',');
          int rw = atoi(text + ++i);
          while (text[++i] != ',');
          int rh = atoi(text + ++i);

          drw_rect(drw, rx + x, ry + borderpx + vertpadbar / 2, rw, rh, 1, 0);
        } else if (text[i] == 'f') {
          x += atoi(text + ++i);
        }
      }

      text = text + i + 1;
      i = -1;
      isCode = 0;
    }
  }

  if (!isCode) {
    w = TEXTW(text) - lrpad;
    drw_text(drw, x, borderpx + vertpadbar / 2, w, bh - vertpadbar, 0, text, 0);
  }

  drw_setscheme(drw, scheme[SchemeNorm]);
  free(p);

  return ret;
}

/**
 * @brief Interactively adjust the selected client's cfact with the pointer.
 *
 * @param arg        Unused key binding argument.
 */
void dragcfact(const Arg* arg) {
  int prev_x, prev_y, dist_x, dist_y;
  float fact;
  Client* c;
  XEvent ev;
  Time lasttime = 0;

  if (!(c = selmon->sel)) return;
  if (c->isfloating) {
    resizemouse(arg);
    return;
  }
#if !FAKEFULLSCREEN_PATCH
#if FAKEFULLSCREEN_CLIENT_PATCH
  if (c->isfullscreen &&
      !c->fakefullscreen) /* no support resizing fullscreen windows by mouse */
    return;
#else
  if (c->isfullscreen) /* no support resizing fullscreen windows by mouse */
    return;
#endif  // FAKEFULLSCREEN_CLIENT_PATCH
#endif  // !FAKEFULLSCREEN_PATCH
  restack(selmon);

  if (XGrabPointer(dpy, root, False, MOUSEMASK, GrabModeAsync, GrabModeAsync,
                   None, cursor[CurResize]->cursor, CurrentTime) != GrabSuccess)
    return;
  XWarpPointer(dpy, None, c->win, 0, 0, 0, 0, c->w / 2, c->h / 2);

  prev_x = prev_y = -999999;

  do {
    XMaskEvent(dpy, MOUSEMASK | ExposureMask | SubstructureRedirectMask, &ev);
    switch (ev.type) {
      case ConfigureRequest:
      case Expose:
      case MapRequest:
        handler[ev.type](&ev);
        break;
      case MotionNotify:
        if ((ev.xmotion.time - lasttime) <= (1000 / 120)) continue;
        lasttime = ev.xmotion.time;
        if (prev_x == -999999) {
          prev_x = ev.xmotion.x_root;
          prev_y = ev.xmotion.y_root;
        }

        dist_x = ev.xmotion.x - prev_x;
        dist_y = ev.xmotion.y - prev_y;

        if (abs(dist_x) > abs(dist_y)) {
          fact = (float)4.0 * dist_x / c->mon->ww;
        } else {
          fact = (float)-4.0 * dist_y / c->mon->wh;
        }

        if (fact) setcfact(&((Arg){.f = fact}));

        prev_x = ev.xmotion.x;
        prev_y = ev.xmotion.y;
        break;
    }
  } while (ev.type != ButtonRelease);

  XWarpPointer(dpy, None, c->win, 0, 0, 0, 0, c->w / 2, c->h / 2);

  XUngrabPointer(dpy, CurrentTime);
  while (XCheckMaskEvent(dpy, EnterWindowMask, &ev));
}

/**
 * @brief Interactively adjust the selected monitor's mfact with the pointer.
 *
 * @param arg        Unused key binding argument.
 */
void dragmfact(const Arg* arg) {
  unsigned int n;
  int py, px;          // pointer coordinates
  int ax, ay, aw, ah;  // area position, width and height
  int center = 0, horizontal = 0, mirror = 0,
      fixed = 0;  // layout configuration
  double fact;
  Monitor* m;
  XEvent ev;
  Time lasttime = 0;

  m = selmon;

#if VANITYGAPS_PATCH
  int oh, ov, ih, iv;
  getgaps(m, &oh, &ov, &ih, &iv, &n);
#else
  Client* c;
  for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++);
#endif  // VANITYGAPS_PATCH

  ax = m->wx;
  ay = m->wy;
  ah = m->wh;
  aw = m->ww;

  if (!n) return;
#if FLEXTILE_DELUXE_LAYOUT
  else if (m->lt[m->sellt]->arrange == &flextile) {
    int layout = m->ltaxis[LAYOUT];
    if (layout < 0) {
      mirror = 1;
      layout *= -1;
    }
    if (layout > FLOATING_MASTER) {
      layout -= FLOATING_MASTER;
      fixed = 1;
    }

    if (layout == SPLIT_HORIZONTAL || layout == SPLIT_HORIZONTAL_DUAL_STACK)
      horizontal = 1;
    else if (layout == SPLIT_CENTERED_VERTICAL && (fixed || n - m->nmaster > 1))
      center = 1;
    else if (layout == FLOATING_MASTER) {
      center = 1;
      if (aw < ah) horizontal = 1;
    } else if (layout == SPLIT_CENTERED_HORIZONTAL) {
      if (fixed || n - m->nmaster > 1) center = 1;
      horizontal = 1;
    }
  }
#endif  // FLEXTILE_DELUXE_LAYOUT
#if CENTEREDMASTER_LAYOUT
  else if (m->lt[m->sellt]->arrange == &centeredmaster &&
           (fixed || n - m->nmaster > 1))
    center = 1;
#endif  // CENTEREDMASTER_LAYOUT
#if CENTEREDFLOATINGMASTER_LAYOUT
  else if (m->lt[m->sellt]->arrange == &centeredfloatingmaster)
    center = 1;
#endif  // CENTEREDFLOATINGMASTER_LAYOUT
#if BSTACK_LAYOUT
  else if (m->lt[m->sellt]->arrange == &bstack)
    horizontal = 1;
#endif  // BSTACK_LAYOUT
#if BSTACKHORIZ_LAYOUT
  else if (m->lt[m->sellt]->arrange == &bstackhoriz)
    horizontal = 1;
#endif  // BSTACKHORIZ_LAYOUT

  /* do not allow mfact to be modified under certain conditions */
  if (!m->lt[m->sellt]->arrange                     // floating layout
      || (!fixed && m->nmaster && n <= m->nmaster)  // no master
#if MONOCLE_LAYOUT
      || m->lt[m->sellt]->arrange == &monocle
#endif  // MONOCLE_LAYOUT
#if GRIDMODE_LAYOUT
      || m->lt[m->sellt]->arrange == &grid
#endif  // GRIDMODE_LAYOUT
#if HORIZGRID_LAYOUT
      || m->lt[m->sellt]->arrange == &horizgrid
#endif  // HORIZGRID_LAYOUT
#if GAPPLESSGRID_LAYOUT
      || m->lt[m->sellt]->arrange == &gaplessgrid
#endif  // GAPPLESSGRID_LAYOUT
#if NROWGRID_LAYOUT
      || m->lt[m->sellt]->arrange == &nrowgrid
#endif  // NROWGRID_LAYOUT
#if FLEXTILE_DELUXE_LAYOUT
      ||
      (m->lt[m->sellt]->arrange == &flextile && m->ltaxis[LAYOUT] == NO_SPLIT)
#endif  // FLEXTILE_DELUXE_LAYOUT
  )
    return;

#if VANITYGAPS_PATCH
  ay += oh;
  ax += ov;
  aw -= 2 * ov;
  ah -= 2 * oh;
#endif  // VANITYGAPS_PATCH

  if (center) {
    if (horizontal) {
      px = ax + aw / 2;
#if VANITYGAPS_PATCH
      py = ay + ah / 2 + (ah - 2 * ih) * (m->mfact / 2.0) + ih / 2;
#else
      py = ay + ah / 2 + ah * m->mfact / 2.0;
#endif        // VANITYGAPS_PATCH
    } else {  // vertical split
#if VANITYGAPS_PATCH
      px = ax + aw / 2 + (aw - 2 * iv) * m->mfact / 2.0 + iv / 2;
#else
      px = ax + aw / 2 + aw * m->mfact / 2.0;
#endif  // VANITYGAPS_PATCH
      py = ay + ah / 2;
    }
  } else if (horizontal) {
    px = ax + aw / 2;
    if (mirror)
#if VANITYGAPS_PATCH
      py = ay + (ah - ih) * (1.0 - m->mfact) + ih / 2;
#else
      py = ay + (ah * (1.0 - m->mfact));
#endif  // VANITYGAPS_PATCH
    else
#if VANITYGAPS_PATCH
      py = ay + ((ah - ih) * m->mfact) + ih / 2;
#else
      py = ay + (ah * m->mfact);
#endif      // VANITYGAPS_PATCH
  } else {  // vertical split
    if (mirror)
#if VANITYGAPS_PATCH
      px = ax + (aw - iv) * (1.0 - m->mfact) + iv / 2;
#else
      px = ax + (aw * m->mfact);
#endif  // VANITYGAPS_PATCH
    else
#if VANITYGAPS_PATCH
      px = ax + ((aw - iv) * m->mfact) + iv / 2;
#else
      px = ax + (aw * m->mfact);
#endif  // VANITYGAPS_PATCH
    py = ay + ah / 2;
  }

  if (XGrabPointer(
        dpy, root, False, MOUSEMASK, GrabModeAsync, GrabModeAsync, None,
        cursor[horizontal ? CurResizeVertArrow : CurResizeHorzArrow]->cursor,
        CurrentTime) != GrabSuccess)
    return;
  XWarpPointer(dpy, None, root, 0, 0, 0, 0, px, py);

  do {
    XMaskEvent(dpy, MOUSEMASK | ExposureMask | SubstructureRedirectMask, &ev);
    switch (ev.type) {
      case ConfigureRequest:
      case Expose:
      case MapRequest:
        handler[ev.type](&ev);
        break;
      case MotionNotify:
        if ((ev.xmotion.time - lasttime) <= (1000 / 40)) continue;
        if (lasttime != 0) {
          px = ev.xmotion.x;
          py = ev.xmotion.y;
        }
        lasttime = ev.xmotion.time;

#if VANITYGAPS_PATCH
        if (center)
          if (horizontal)
            if (py - ay > ah / 2)
              fact = (double)1.0 -
                     (ay + ah - py - ih / 2) * 2 / (double)(ah - 2 * ih);
            else
              fact =
                (double)1.0 - (py - ay - ih / 2) * 2 / (double)(ah - 2 * ih);
          else if (px - ax > aw / 2)
            fact =
              (double)1.0 - (ax + aw - px - iv / 2) * 2 / (double)(aw - 2 * iv);
          else
            fact = (double)1.0 - (px - ax - iv / 2) * 2 / (double)(aw - 2 * iv);
        else if (horizontal)
          fact = (double)(py - ay - ih / 2) / (double)(ah - ih);
        else
          fact = (double)(px - ax - iv / 2) / (double)(aw - iv);
#else
        if (center)
          if (horizontal)
            if (py - ay > ah / 2)
              fact = (double)1.0 - (ay + ah - py) * 2 / (double)ah;
            else
              fact = (double)1.0 - (py - ay) * 2 / (double)ah;
          else if (px - ax > aw / 2)
            fact = (double)1.0 - (ax + aw - px) * 2 / (double)aw;
          else
            fact = (double)1.0 - (px - ax) * 2 / (double)aw;
        else if (horizontal)
          fact = (double)(py - ay) / (double)ah;
        else
          fact = (double)(px - ax) / (double)aw;
#endif  // VANITYGAPS_PATCH

        if (!center && mirror) fact = 1.0 - fact;

        setmfact(&((Arg){.f = 1.0 + fact}));
        px = ev.xmotion.x;
        py = ev.xmotion.y;
        break;
    }
  } while (ev.type != ButtonRelease);

  XUngrabPointer(dpy, CurrentTime);
  while (XCheckMaskEvent(dpy, EnterWindowMask, &ev));
}

/**
 * @brief Draw the tag, title, status and systray areas of a monitor's bar.
 *
 * @param m          Monitor whose bar is drawn.
 */
void drawbar(Monitor* m) {
  int x, y = borderpx, w, sw = 0, stw = 0;
  int bh_n = bh - borderpx * 2;
  int mw;
  if (floatbar) {
    mw = m->ww - m->gappov * 2 - borderpx * 2;
  } else {
    mw = m->ww - borderpx * 2;
  }
  int boxs = drw->fonts->h / 9;
  int boxw = drw->fonts->h / 6 + 2;
  unsigned int i, occ = 0, urg = 0;
  Client* c;

  XSetForeground(drw->dpy, drw->gc, clrborder.pixel);
  if (floatbar) {
    XFillRectangle(drw->dpy, drw->drawable, drw->gc, 0, 0,
                   m->ww - m->gappov * 2, bh);
  } else {
    XFillRectangle(drw->dpy, drw->drawable, drw->gc, 0, 0, m->ww, bh);
  }

  if (showsystray && m == systraytomon(m)) stw = getsystraywidth();

  if (!m->showbar) return;

  /* draw status first so it can be overdrawn by tags later */
  if (m == selmon) { /* status is only drawn on selected monitor */
    sw = drawstatusbar(m, bh_n, stext);
  }

  resizebarwin(m);
  for (c = m->clients; c; c = c->next) {
    occ |= c->tags;
    if (c->isurgent) urg |= c->tags;
  }
  x = borderpx;
  for (i = 0; i < LENGTH(tags); i++) {
    w = TEXTW(tags[i]);
    drw_setscheme(
      drw, scheme[occ & 1 << i ? (m->colorfultag ? tagschemes[i] : SchemeSel)
                               : SchemeTag]);
    drw_text(drw, x, y, w, bh_n, lrpad / 2, tags[i], urg & 1 << i);
    if (ulineall || m->tagset[m->seltags] & 1 << i)
      drw_rect(drw, x + ulinepad, bh_n - ulinestroke - ulinevoffset,
               w - (ulinepad * 2), ulinestroke, 1, 0);
    x += w;
  }
  w = TEXTW(m->ltsymbol);
  drw_setscheme(drw, scheme[SchemeLayout]);
  x = drw_text(drw, x, 0, w, bh, lrpad / 2, m->ltsymbol, 0);

  for (i = 0; i < LENGTH(launchers); i++) {
    w = TEXTW(launchers[i].name);
    drw_text(drw, x, 0, w, bh, lrpad / 2, launchers[i].name, urg & 1 << i);
    x += w;
  }

  w = sw + borderpx - stw - x;
  if (w > bh_n) {
    if (m->sel) {
      drw_setscheme(drw, scheme[m == selmon ? SchemeTitle : SchemeNorm]);
      drw_text(drw, x, 0, w, bh,
               lrpad / 2 + (m->sel->icon ? m->sel->icw + ICONSPACING : 0),
               m->sel->name, 0);
      if (m->sel->icon)
        drw_pic(drw, x + lrpad / 2, (bh - m->sel->ich) / 2, m->sel->icw,
                m->sel->ich, m->sel->icon);
      if (m->sel->isfloating)
        drw_rect(drw, x + boxs, boxs, boxw, boxw, m->sel->isfixed, 0);
    } else {
      drw_setscheme(drw, scheme[SchemeNorm]);
      if (floatbar) {
        drw_rect(drw, x, y, w - m->gappov * 2, bh_n, 1, 1);
      } else {
        drw_rect(drw, x, y, w, bh_n, 1, 1);
      }
    }
  }
  drw_map(drw, m->barwin, 0, 0, m->ww - stw, bh);
}

/**
 * @brief Premultiply the colour channels of an ARGB pixel by its alpha value.
 *
 * @param p          ARGB pixel value.
 * @return Premultiplied ARGB pixel value.
 */
static uint32_t prealpha(uint32_t p) {
  uint8_t a = p >> 24u;
  uint32_t rb = (a * (p & 0xFF00FFu)) >> 8u;
  uint32_t g = (a * (p & 0x00FF00u)) >> 8u;
  return (rb & 0xFF00FFu) | (g & 0x00FF00u) | (a << 24u);
}

/**
 * @brief Read, scale and premultiply a window's _NET_WM_ICON property.
 *
 * @param win        Window whose icon is loaded.
 * @param picw       Receives icon width.
 * @param pich       Receives icon height.
 * @return Icon picture, or None when no usable icon exists.
 */
Picture geticonprop(Window win, unsigned int* picw, unsigned int* pich) {
  int format;
  unsigned long n, extra, *p = NULL;
  Atom real;

  if (XGetWindowProperty(dpy, win, netatom[NetWMIcon], 0L, LONG_MAX, False,
                         AnyPropertyType, &real, &format, &n, &extra,
                         (unsigned char**)&p) != Success)
    return None;
  if (n == 0 || format != 32) {
    XFree(p);
    return None;
  }

  unsigned long* bstp = NULL;
  uint32_t w, h, sz;
  {
    unsigned long* i;
    const unsigned long* end = p + n;
    uint32_t bstd = UINT32_MAX, d, m;
    for (i = p; i < end - 1; i += sz) {
      if ((w = *i++) >= 16384 || (h = *i++) >= 16384) {
        XFree(p);
        return None;
      }
      if ((sz = w * h) > end - i) break;
      if ((m = w > h ? w : h) >= ICONSIZE && (d = m - ICONSIZE) < bstd) {
        bstd = d;
        bstp = i;
      }
    }
    if (!bstp) {
      for (i = p; i < end - 1; i += sz) {
        if ((w = *i++) >= 16384 || (h = *i++) >= 16384) {
          XFree(p);
          return None;
        }
        if ((sz = w * h) > end - i) break;
        if ((d = ICONSIZE - (w > h ? w : h)) < bstd) {
          bstd = d;
          bstp = i;
        }
      }
    }
    if (!bstp) {
      XFree(p);
      return None;
    }
  }

  if ((w = *(bstp - 2)) == 0 || (h = *(bstp - 1)) == 0) {
    XFree(p);
    return None;
  }

  uint32_t icw, ich;
  if (w <= h) {
    ich = ICONSIZE;
    icw = w * ICONSIZE / h;
    if (icw == 0) icw = 1;
  } else {
    icw = ICONSIZE;
    ich = h * ICONSIZE / w;
    if (ich == 0) ich = 1;
  }
  *picw = icw;
  *pich = ich;

  uint32_t i, *bstp32 = (uint32_t*)bstp;
  for (sz = w * h, i = 0; i < sz; ++i) bstp32[i] = prealpha(bstp[i]);

  Picture ret = drw_picture_create_resized(drw, (char*)bstp, w, h, icw, ich);
  XFree(p);

  return ret;
}

/**
 * @brief Draw the bar of every monitor.
 */
void drawbars(void) {
  Monitor* m;

  for (m = mons; m; m = m->next) drawbar(m);
}

/**
 * @brief Draw the tab bar of every monitor.
 */
void drawtabs(void) {
  Monitor* m;

  for (m = mons; m; m = m->next) drawtab(m);
}

/**
 * @brief Comparison function used to sort integer widths with qsort(3).
 *
 * @param p1         First integer.
 * @param p2         Second integer.
 * @return Non-zero when the first value is greater than the second.
 */
static int cmpint(const void* p1, const void* p2) {
  /* The actual arguments to this function are "pointers to
     pointers to char", but strcmp(3) arguments are "pointers
     to char", hence the following cast plus dereference */
  return *((int*)p1) > *(int*)p2;
}

/**
 * @brief Draw the tab bar listing visible clients on a monitor.
 *
 * @param m          Monitor whose tab bar is drawn.
 */
void drawtab(Monitor* m) {
  Client* c;
  int i;
  char* btn_prev = "";
  char* btn_next = "";
  char* btn_close = " ";
  int buttons_w = 0;
  int sorted_label_widths[MAXTABS];
  int tot_width = 0;
  int maxsize = bh;
  int x = 0;
  int w = 0;
  int mw = floatbar ? m->ww - 2 * m->gappov : m->ww;
  buttons_w += TEXTW(btn_prev) - lrpad + horizpadtabo;
  buttons_w += TEXTW(btn_next) - lrpad + horizpadtabo;
  buttons_w += TEXTW(btn_close) - lrpad + horizpadtabo;
  tot_width = buttons_w;

  /* Calculates number of labels and their width */
  m->ntabs = 0;
  for (c = m->clients; c; c = c->next) {
    if (!ISVISIBLE(c)) continue;
    m->tab_widths[m->ntabs] =
      MIN(TEXTW(c->name) - lrpad + horizpadtabi + horizpadtabo, 250);
    tot_width += m->tab_widths[m->ntabs];
    ++m->ntabs;
    if (m->ntabs >= MAXTABS) break;
  }

  if (tot_width >
      mw) {  //not enough space to display the labels, they need to be truncated
    memcpy(sorted_label_widths, m->tab_widths, sizeof(int) * m->ntabs);
    qsort(sorted_label_widths, m->ntabs, sizeof(int), cmpint);
    for (i = 0; i < m->ntabs; ++i) {
      if (tot_width + (m->ntabs - i) * sorted_label_widths[i] > mw) break;
      tot_width += sorted_label_widths[i];
    }
    maxsize = (mw - tot_width) / (m->ntabs - i);
    maxsize = (m->ww - tot_width) / (m->ntabs - i);
  } else {
    maxsize = mw;
  }
  i = 0;

  /* cleans window */
  drw_setscheme(drw, scheme[TabNorm]);
  drw_rect(drw, 0, 0, mw, th, 1, 1);

  for (c = m->clients; c; c = c->next) {
    if (!ISVISIBLE(c)) continue;
    if (i >= m->ntabs) break;
    if (m->tab_widths[i] > maxsize) m->tab_widths[i] = maxsize;
    w = m->tab_widths[i];
    drw_setscheme(drw, scheme[(c == m->sel) ? TabSel : TabNorm]);
    drw_text(drw, x + horizpadtabo / 2, vertpadbar / 2, w - horizpadtabo,
             th - vertpadbar, horizpadtabi / 2, c->name, 0);
    x += w;
    ++i;
  }

  w = mw - buttons_w - x;
  x += w;
  drw_setscheme(drw, scheme[SchemeBtnPrev]);
  w = TEXTW(btn_prev) - lrpad + horizpadtabo;
  m->tab_btn_w[0] = w;
  drw_text(drw, x + horizpadtabo / 2, vertpadbar / 2, w, th - vertpadbar, 0,
           btn_prev, 0);
  x += w;
  drw_setscheme(drw, scheme[SchemeBtnNext]);
  w = TEXTW(btn_next) - lrpad + horizpadtabo;
  m->tab_btn_w[1] = w;
  drw_text(drw, x + horizpadtabo / 2, vertpadbar / 2, w, th - vertpadbar, 0,
           btn_next, 0);
  x += w;
  drw_setscheme(drw, scheme[SchemeBtnClose]);
  w = TEXTW(btn_close) - lrpad + horizpadtabo;
  m->tab_btn_w[2] = w;
  drw_text(drw, x + horizpadtabo / 2, vertpadbar / 2, w, th - vertpadbar, 0,
           btn_close, 0);
  x += w;

  drw_map(drw, m->tabwin, 0, 0, m->ww, th);
}

/**
 * @brief Handle the pointer entering a window and update focus accordingly.
 *
 * @param e          X crossing event.
 */
void enternotify(XEvent* e) {
  Client* c;
  Monitor* m;
  XCrossingEvent* ev = &e->xcrossing;

  if ((ev->mode != NotifyNormal || ev->detail == NotifyInferior) &&
      ev->window != root)
    return;
  c = wintoclient(ev->window);
  m = c ? c->mon : wintomon(ev->window);
  if (m != selmon) {
    unfocus(selmon->sel, 1);
    selmon = m;
  } else if (!c || c == selmon->sel)
    return;
  focus(c);
}

/**
 * @brief Redraw the bar and systray after an expose event.
 *
 * @param e          X expose event.
 */
void expose(XEvent* e) {
  Monitor* m;
  XExposeEvent* ev = &e->xexpose;

  if (ev->count == 0 && (m = wintomon(ev->window))) {
    drawbar(m);
    if (m == selmon) updatesystray();
  }
}

/**
 * @brief Focus a client, or the most recently focused visible client.
 *
 * @param c          Client to focus, or NULL to choose one.
 */
void focus(Client* c) {
  if (!c || (!ISVISIBLE(c) || HIDDEN(c)))
    for (c = selmon->stack; c && (!ISVISIBLE(c) || HIDDEN(c)); c = c->snext);
  if (selmon->sel && selmon->sel != c) unfocus(selmon->sel, 0);
  if (c) {
    if (c->mon != selmon) selmon = c->mon;
    if (c->isurgent) seturgent(c, 0);
    detachstack(c);
    attachstack(c);
    grabbuttons(c, 1);
    XSetWindowBorder(dpy, c->win, scheme[SchemeSel][ColBorder].pixel);
    setfocus(c);
  } else {
    XSetInputFocus(dpy, root, RevertToPointerRoot, CurrentTime);
    XDeleteProperty(dpy, root, netatom[NetActiveWindow]);
  }
  selmon->sel = c;
  drawbars();
  drawtabs();
}

/**
 * @brief Restore focus when a client acquires it unexpectedly.
 *
 * @param e          X focus change event.
 *
 * @note Some broken clients acquire focus on their own; this handler forces
 *       focus back to the selected client.
 */
void focusin(XEvent* e) {
  XFocusChangeEvent* ev = &e->xfocus;

  if (selmon->sel && ev->window != selmon->sel->win) setfocus(selmon->sel);
}

/**
 * @brief Focus the monitor adjacent to the selected one.
 *
 * @param arg        Positive for next, negative for previous.
 */
void focusmon(const Arg* arg) {
  Monitor* m;

  if (!mons->next) return;
  if ((m = dirtomon(arg->i)) == selmon) return;
  unfocus(selmon->sel, 0);
  selmon = m;
  focus(NULL);
}

/**
 * @brief Focus the next or previous visible client in the stack.
 *
 * @param arg        Positive for next, negative for previous.
 */
void focusstack(const Arg* arg) {
  Client *c = NULL, *i;

  if (!selmon->sel || (selmon->sel->isfullscreen && lockfullscreen)) return;
  if (arg->i > 0) {
    for (c = selmon->sel->next; c && (!ISVISIBLE(c) || HIDDEN(c)); c = c->next);
    if (!c)
      for (c = selmon->clients; c && (!ISVISIBLE(c) || HIDDEN(c)); c = c->next);
  } else {
    for (i = selmon->clients; i != selmon->sel; i = i->next)
      if (ISVISIBLE(i) && !HIDDEN(i)) c = i;
    if (!c)
      for (; i; i = i->next)
        if (ISVISIBLE(i) && !HIDDEN(i)) c = i;
  }
  if (c) {
    focus(c);
    restack(selmon);
  }
}

/**
 * @brief Focus the visible client at the given index.
 *
 * @param arg        Zero-based index among visible clients.
 */
void focuswin(const Arg* arg) {
  int iwin = arg->i;
  Client* c = NULL;
  for (c = selmon->clients; c && (iwin || !ISVISIBLE(c)); c = c->next) {
    if (ISVISIBLE(c)) --iwin;
  };
  if (c) {
    focus(c);
    restack(selmon);
  }
}

/**
 * @brief Read an atom-valued property from a client window.
 *
 * @param c          Client whose property is read.
 * @param prop       Property atom.
 * @return Property value, or None when unavailable.
 */
Atom getatomprop(Client* c, Atom prop) {
  int di;
  unsigned long dl;
  unsigned char* p = NULL;
  Atom da, atom = None;
  /* FIXME getatomprop should return the number of items and a pointer to
   * the stored data instead of this workaround */
  Atom req = XA_ATOM;
  if (prop == xatom[XembedInfo]) req = xatom[XembedInfo];

  if (XGetWindowProperty(dpy, c->win, prop, 0L, sizeof atom, False, req, &da,
                         &di, &dl, &dl, &p) == Success &&
      p) {
    atom = *(Atom*)p;
    if (da == xatom[XembedInfo] && dl == 2) atom = ((Atom*)p)[1];
    XFree(p);
  }
  return atom;
}

/**
 * @brief Query the current pointer position relative to the root window.
 *
 * @param x          Receives the pointer x coordinate.
 * @param y          Receives the pointer y coordinate.
 * @return Non-zero on success.
 */
int getrootptr(int* x, int* y) {
  int di;
  unsigned int dui;
  Window dummy;

  return XQueryPointer(dpy, root, &dummy, &dummy, x, y, &di, &di, &dui);
}

/**
 * @brief Read the ICCCM WM_STATE property of a window.
 *
 * @param w          Window to inspect.
 * @return WM_STATE value, or -1 when the property is absent.
 */
long getstate(Window w) {
  int format;
  long result = -1;
  unsigned char* p = NULL;
  unsigned long n, extra;
  Atom real;

  if (XGetWindowProperty(dpy, w, wmatom[WMState], 0L, 2L, False,
                         wmatom[WMState], &real, &format, &n, &extra,
                         (unsigned char**)&p) != Success)
    return -1;
  if (n != 0) result = *p;
  XFree(p);
  return result;
}

/**
 * @brief Calculate the width occupied by the systray and its icons.
 * @return Width in pixels, or 1 when the systray is empty.
 */
unsigned int getsystraywidth() {
  unsigned int w = 0;
  Client* i;
  if (showsystray)
    for (i = systray->icons; i; w += i->w + systrayspacing, i = i->next);
  return w ? w + systrayspacing : 1;
}

/**
 * @brief Read a text property into a NUL-terminated buffer.
 *
 * @param w          Window whose property is read.
 * @param atom       Property atom.
 * @param text       Destination buffer.
 * @param size       Size of the destination buffer.
 * @return Non-zero when a value was read.
 */
int gettextprop(Window w, Atom atom, char* text, unsigned int size) {
  char** list = NULL;
  int n;
  XTextProperty name;

  if (!text || size == 0) return 0;
  text[0] = '\0';
  if (!XGetTextProperty(dpy, w, &name, atom) || !name.nitems) return 0;
  if (name.encoding == XA_STRING) {
    strncpy(text, (char*)name.value, size - 1);
  } else if (XmbTextPropertyToTextList(dpy, &name, &list, &n) >= Success &&
             n > 0 && *list) {
    strncpy(text, *list, size - 1);
    XFreeStringList(list);
  }
  text[size - 1] = '\0';
  XFree(name.value);
  return 1;
}

/**
 * @brief Grab the configured mouse buttons on a client window.
 *
 * @param c          Client whose buttons are grabbed.
 * @param focused    Non-zero for the focused button set.
 */
void grabbuttons(Client* c, int focused) {
  updatenumlockmask();
  {
    unsigned int i, j;
    unsigned int modifiers[] = {0, LockMask, numlockmask,
                                numlockmask | LockMask};
    XUngrabButton(dpy, AnyButton, AnyModifier, c->win);
    if (!focused)
      XGrabButton(dpy, AnyButton, AnyModifier, c->win, False, BUTTONMASK,
                  GrabModeSync, GrabModeSync, None, None);
    for (i = 0; i < LENGTH(buttons); i++)
      if (buttons[i].click == ClkClientWin)
        for (j = 0; j < LENGTH(modifiers); j++)
          XGrabButton(dpy, buttons[i].button, buttons[i].mask | modifiers[j],
                      c->win, False, BUTTONMASK, GrabModeAsync, GrabModeSync,
                      None, None);
  }
}

/**
 * @brief Grab all configured key bindings on the root window.
 */
void grabkeys(void) {
  updatenumlockmask();
  {
    unsigned int i, j, k;
    unsigned int modifiers[] = {0, LockMask, numlockmask,
                                numlockmask | LockMask};
    int start, end, skip;
    KeySym* syms;
    XUngrabKey(dpy, AnyKey, AnyModifier, root);
    XDisplayKeycodes(dpy, &start, &end);
    syms = XGetKeyboardMapping(dpy, start, end - start + 1, &skip);
    if (!syms) return;
    for (k = start; k <= end; k++)
      for (i = 0; i < LENGTH(keys); i++)
        /* skip modifier codes, we do that ourselves */
        if (keys[i].keysym == syms[(k - start) * skip])
          for (j = 0; j < LENGTH(modifiers); j++)
            XGrabKey(dpy, k, keys[i].mod | modifiers[j], root, True,
                     GrabModeAsync, GrabModeAsync);
    XFree(syms);
  }
}

/**
 * @brief Release a client's cached icon picture.
 *
 * @param c          Client whose icon is freed.
 */
void freeicon(Client* c) {
  if (c->icon) {
    XRenderFreePicture(dpy, c->icon);
    c->icon = None;
  }
}

/**
 * @brief Unmap a client without unmanaging it.
 *
 * @param c          Client to hide.
 */
void hide(Client* c) {
  if (!c || HIDDEN(c)) return;

  Window w = c->win;
  static XWindowAttributes ra, ca;

  // more or less taken directly from blackbox's hide() function
  XGrabServer(dpy);
  XGetWindowAttributes(dpy, root, &ra);
  XGetWindowAttributes(dpy, w, &ca);
  // prevent UnmapNotify events
  XSelectInput(dpy, root, ra.your_event_mask & ~SubstructureNotifyMask);
  XSelectInput(dpy, w, ca.your_event_mask & ~StructureNotifyMask);
  XUnmapWindow(dpy, w);
  setclientstate(c, IconicState);
  XSelectInput(dpy, root, ra.your_event_mask);
  XSelectInput(dpy, w, ca.your_event_mask);
  XUngrabServer(dpy);

  focus(c->snext);
  arrange(c->mon);
}

/**
 * @brief Increase or decrease the number of clients in the master area.
 *
 * @param arg        Amount to add to nmaster.
 */
void incnmaster(const Arg* arg) {
  selmon->nmaster = selmon->pertag->nmasters[selmon->pertag->curtag] =
    MAX(selmon->nmaster + arg->i, 0);
  arrange(selmon);
}

#ifdef XINERAMA
/**
 * @brief Check whether an Xinerama geometry is not already present in a list.
 *
 * @param unique     Array of accepted geometries.
 * @param n          Number of entries.
 * @param info       Candidate geometry.
 * @return Non-zero when the geometry is unique.
 */
static int isuniquegeom(XineramaScreenInfo* unique, size_t n,
                        XineramaScreenInfo* info) {
  while (n--)
    if (unique[n].x_org == info->x_org && unique[n].y_org == info->y_org &&
        unique[n].width == info->width && unique[n].height == info->height)
      return 0;
  return 1;
}
#endif /* XINERAMA */

/**
 * @brief Look up and execute the key binding for a key press.
 *
 * @param e          X key press event.
 */
void keypress(XEvent* e) {
  unsigned int i;
  KeySym keysym;
  XKeyEvent* ev;

  ev = &e->xkey;
  keysym = XKeycodeToKeysym(dpy, (KeyCode)ev->keycode, 0);
  for (i = 0; i < LENGTH(keys); i++)
    if (keysym == keys[i].keysym &&
        CLEANMASK(keys[i].mod) == CLEANMASK(ev->state) && keys[i].func)
      keys[i].func(&(keys[i].arg));
}

/**
 * @brief Ask the selected client to close, killing it as a fallback.
 *
 * @param arg        Unused key binding argument.
 */
void killclient(const Arg* arg) {
  if (!selmon->sel) return;
  if (!sendevent(selmon->sel->win, wmatom[WMDelete], NoEventMask,
                 wmatom[WMDelete], CurrentTime, 0, 0, 0)) {
    XGrabServer(dpy);
    XSetErrorHandler(xerrordummy);
    XSetCloseDownMode(dpy, DestroyAll);
    XKillClient(dpy, selmon->sel->win);
    XSync(dpy, False);
    XSetErrorHandler(xerror);
    XUngrabServer(dpy);
  }
}

/**
 * @brief Adopt an existing X window as a managed client.
 *
 * @param w          Window to manage.
 * @param wa         Attributes of the window.
 */
void manage(Window w, XWindowAttributes* wa) {
  Client *c, *t = NULL;
  Window trans = None;
  XWindowChanges wc;

  c = ecalloc(1, sizeof(Client));
  c->win = w;
  c->x = c->oldx = wa->x;
  c->y = c->oldy = wa->y;
  c->w = c->oldw = wa->width;
  c->h = c->oldh = wa->height;
  c->oldbw = wa->border_width;
  c->cfact = 1.0;

  updateicon(c);
  updatetitle(c);
  if (XGetTransientForHint(dpy, w, &trans) && (t = wintoclient(trans))) {
    c->mon = t->mon;
    c->tags = t->tags;
  } else {
    c->mon = selmon;
    applyrules(c);
  }

  if (c->x + WIDTH(c) > c->mon->wx + c->mon->ww)
    c->x = c->mon->wx + c->mon->ww - WIDTH(c);
  if (c->y + HEIGHT(c) > c->mon->wy + c->mon->wh)
    c->y = c->mon->wy + c->mon->wh - HEIGHT(c);
  c->x = MAX(c->x, c->mon->wx);
  c->y = MAX(c->y, c->mon->wy);
  c->bw = c->mon->borderpx;

  wc.border_width = c->bw;
  XConfigureWindow(dpy, w, CWBorderWidth, &wc);
  XSetWindowBorder(dpy, w, scheme[SchemeNorm][ColBorder].pixel);
  configure(c); /* propagates border_width, if size doesn't change */
  updatewindowtype(c);
  updatesizehints(c);
  updatewmhints(c);
  {
    int format;
    unsigned long *data, n, extra;
    Monitor* m;
    Atom atom;
    if (XGetWindowProperty(dpy, c->win, netatom[NetClientInfo], 0L, 2L, False,
                           XA_CARDINAL, &atom, &format, &n, &extra,
                           (unsigned char**)&data) == Success &&
        n == 2) {
      c->tags = *data;
      for (m = mons; m; m = m->next) {
        if (m->num == *(data + 1)) {
          c->mon = m;
          break;
        }
      }
    }
    if (n > 0) XFree(data);
  }
  setclienttagprop(c);

  if (c->iscentered) {
    c->x = c->mon->mx + (c->mon->mw - WIDTH(c)) / 2;
    c->y = c->mon->my + (c->mon->mh - HEIGHT(c)) / 2;
  }
  XSelectInput(dpy, w,
               EnterWindowMask | FocusChangeMask | PropertyChangeMask |
                 StructureNotifyMask);
  grabbuttons(c, 0);
  if (!c->isfloating) c->isfloating = c->oldstate = trans != None || c->isfixed;
  if (c->isfloating) XRaiseWindow(dpy, c->win);
  attach(c);
  attachstack(c);
  XChangeProperty(dpy, root, netatom[NetClientList], XA_WINDOW, 32,
                  PropModeAppend, (unsigned char*)&(c->win), 1);
  XMoveResizeWindow(dpy, c->win, c->x + 2 * sw, c->y, c->w,
                    c->h); /* some windows require this */
  if (!HIDDEN(c)) setclientstate(c, NormalState);
  if (c->mon == selmon) unfocus(selmon->sel, 0);
  c->mon->sel = c;
  arrange(c->mon);
  if (!HIDDEN(c)) XMapWindow(dpy, c->win);
  focus(NULL);
}

/**
 * @brief Refresh the keyboard mapping and re-grab key bindings.
 *
 * @param e          X mapping event.
 */
void mappingnotify(XEvent* e) {
  XMappingEvent* ev = &e->xmapping;

  XRefreshKeyboardMapping(ev);
  if (ev->request == MappingKeyboard) grabkeys();
}

/**
 * @brief Manage a window that requests to be mapped.
 *
 * @param e          X map request event.
 */
void maprequest(XEvent* e) {
  static XWindowAttributes wa;
  XMapRequestEvent* ev = &e->xmaprequest;
  Client* i;
  if ((i = wintosystrayicon(ev->window))) {
    sendevent(i->win, netatom[Xembed], StructureNotifyMask, CurrentTime,
              XEMBED_WINDOW_ACTIVATE, 0, systray->win, XEMBED_EMBEDDED_VERSION);
    resizebarwin(selmon);
    updatesystray();
  }

  if (!XGetWindowAttributes(dpy, ev->window, &wa) || wa.override_redirect)
    return;
  if (!wintoclient(ev->window)) manage(ev->window, &wa);
}

/**
 * @brief Arrange every visible client full-size in the monitor's area.
 *
 * @param m          Monitor to arrange.
 */
void monocle(Monitor* m) {
  unsigned int n = 0;

  Client* c;

  for (c = m->clients; c; c = c->next)
    if (ISVISIBLE(c)) n++;

  if (n > 0) /* override layout symbol */
    snprintf(m->ltsymbol, sizeof m->ltsymbol, "[%d]", n);

  int newx, newy, neww, newh;

  for (c = nexttiled(m->clients); c; c = nexttiled(c->next)) {
    newx = m->wx + m->gappov - c->bw;
    newy = m->wy + m->gappoh - c->bw;
    neww = m->ww - 2 * (m->gappov + c->bw);
    newh = m->wh - 2 * (m->gappoh + c->bw);

    applysizehints(c, &newx, &newy, &neww, &newh, 0);

    if (neww < m->ww) newx = m->wx + (m->ww - (neww + 2 * c->bw)) / 2;

    if (newh < m->wh) newy = m->wy + (m->wh - (newh + 2 * c->bw)) / 2;

    resize(c, newx, newy, neww, newh, 0);
  }
}

/**
 * @brief Handle pointer motion for tag previews and monitor focus.
 *
 * @param e          X motion event.
 */
void motionnotify(XEvent* e) {
  unsigned int i, x;
  static Monitor* mon = NULL;
  Monitor* m;
  XMotionEvent* ev = &e->xmotion;

  if (ev->window == selmon->barwin) {
    i = x = 0;
    do x += TEXTW(tags[i]);
    while (ev->x >= x && ++i < LENGTH(tags));
    if (i < LENGTH(tags)) {
      if ((i + 1) != selmon->previewshow &&
          !(selmon->tagset[selmon->seltags] & 1 << i)) {
        selmon->previewshow = i + 1;
        showtagpreview(i);
      } else if (selmon->tagset[selmon->seltags] & 1 << i) {
        selmon->previewshow = 0;
        showtagpreview(0);
      }
    } else if (selmon->previewshow != 0) {
      selmon->previewshow = 0;
      showtagpreview(0);
    }
  } else if (selmon->previewshow != 0) {
    selmon->previewshow = 0;
    showtagpreview(0);
  }

  if (ev->window != root) return;
  if ((m = recttomon(ev->x_root, ev->y_root, 1, 1)) != mon && mon) {
    unfocus(selmon->sel, 1);
    selmon = m;
    focus(NULL);
  }
  mon = m;
}

/**
 * @brief Reload a client's icon from its _NET_WM_ICON property.
 *
 * @param c          Client whose icon is updated.
 */
void updateicon(Client* c) {
  freeicon(c);
  c->icon = geticonprop(c->win, &c->icw, &c->ich);
}

/**
 * @brief Move floating clients and place tiled clients with the pointer.
 *
 * @param arg        Placement mode passed to placemouse().
 */
void moveorplace(const Arg* arg) {
  if ((!selmon->lt[selmon->sellt]->arrange ||
       (selmon->sel && selmon->sel->isfloating)))
    movemouse(arg);
  else
    placemouse(arg);
}

/**
 * @brief Interactively move the selected client with the pointer.
 *
 * @param arg        Unused key binding argument.
 */
void movemouse(const Arg* arg) {
  int x, y, ocx, ocy, nx, ny;
  Client* c;
  Monitor* m;
  XEvent ev;
  Time lasttime = 0;

  if (!(c = selmon->sel)) return;
  if (c->isfullscreen) /* no support moving fullscreen windows by mouse */
    return;
  restack(selmon);
  ocx = c->x;
  ocy = c->y;
  if (XGrabPointer(dpy, root, False, MOUSEMASK, GrabModeAsync, GrabModeAsync,
                   None, cursor[CurMove]->cursor, CurrentTime) != GrabSuccess)
    return;
  if (!getrootptr(&x, &y)) return;
  do {
    XMaskEvent(dpy, MOUSEMASK | ExposureMask | SubstructureRedirectMask, &ev);
    switch (ev.type) {
      case ConfigureRequest:
      case Expose:
      case MapRequest:
        handler[ev.type](&ev);
        break;
      case MotionNotify:
        if ((ev.xmotion.time - lasttime) <= (1000 / 60)) continue;
        lasttime = ev.xmotion.time;

        nx = ocx + (ev.xmotion.x - x);
        ny = ocy + (ev.xmotion.y - y);
        if (abs(selmon->wx - nx) < snap)
          nx = selmon->wx;
        else if (abs((selmon->wx + selmon->ww) - (nx + WIDTH(c))) < snap)
          nx = selmon->wx + selmon->ww - WIDTH(c);
        if (abs(selmon->wy - ny) < snap)
          ny = selmon->wy;
        else if (abs((selmon->wy + selmon->wh) - (ny + HEIGHT(c))) < snap)
          ny = selmon->wy + selmon->wh - HEIGHT(c);
        if (!c->isfloating && selmon->lt[selmon->sellt]->arrange &&
            (abs(nx - c->x) > snap || abs(ny - c->y) > snap))
          togglefloating(NULL);
        if (!selmon->lt[selmon->sellt]->arrange || c->isfloating)
          resize(c, nx, ny, c->w, c->h, 1);
        break;
    }
  } while (ev.type != ButtonRelease);
  XUngrabPointer(dpy, CurrentTime);
  if ((m = recttomon(c->x, c->y, c->w, c->h)) != selmon) {
    sendmon(c, m);
    selmon = m;
    focus(NULL);
  }
}

/**
 * @brief Return the next visible, non-floating client in a list.
 *
 * @param c          Start of the search.
 * @return Next tiled client, or NULL if none exists.
 */
Client* nexttiled(Client* c) {
  for (; c && (c->isfloating || (!ISVISIBLE(c) || HIDDEN(c))); c = c->next);
  return c;
}

/**
 * @brief Interactively place the selected client into a tiled position.
 *
 * @param arg        Placement mode: 0, 1 or 2.
 */
void placemouse(const Arg* arg) {
  int x, y, px, py, ocx, ocy, nx = -9999, ny = -9999, freemove = 0;
  Client *c, *r = NULL, *at, *prevr;
  Monitor* m;
  XEvent ev;
  XWindowAttributes wa;
  Time lasttime = 0;
  int attachmode, prevattachmode;
  attachmode = prevattachmode = -1;

  if (!(c = selmon->sel) ||
      !c->mon->lt[c->mon->sellt]
         ->arrange) /* no support for placemouse when floating layout is used */
    return;
  if (c->isfullscreen) /* no support placing fullscreen windows by mouse */
    return;
  restack(selmon);
  prevr = c;
  if (XGrabPointer(dpy, root, False, MOUSEMASK, GrabModeAsync, GrabModeAsync,
                   None, cursor[CurMove]->cursor, CurrentTime) != GrabSuccess)
    return;

  c->isfloating = 0;
  c->beingmoved = 1;

  XGetWindowAttributes(dpy, c->win, &wa);
  ocx = wa.x;
  ocy = wa.y;

  if (arg->i == 2)  // warp cursor to client center
    XWarpPointer(dpy, None, c->win, 0, 0, 0, 0, WIDTH(c) / 2, HEIGHT(c) / 2);

  if (!getrootptr(&x, &y)) return;

  do {
    XMaskEvent(dpy, MOUSEMASK | ExposureMask | SubstructureRedirectMask, &ev);
    switch (ev.type) {
      case ConfigureRequest:
      case Expose:
      case MapRequest:
        handler[ev.type](&ev);
        break;
      case MotionNotify:
        if ((ev.xmotion.time - lasttime) <= (1000 / 60)) continue;
        lasttime = ev.xmotion.time;

        nx = ocx + (ev.xmotion.x - x);
        ny = ocy + (ev.xmotion.y - y);

        if (!freemove && (abs(nx - ocx) > snap || abs(ny - ocy) > snap))
          freemove = 1;

        if (freemove) XMoveWindow(dpy, c->win, nx, ny);

        if ((m = recttomon(ev.xmotion.x, ev.xmotion.y, 1, 1)) && m != selmon)
          selmon = m;

        if (
          arg->i ==
          1) {  // tiled position is relative to the client window center point
          px = nx + wa.width / 2;
          py = ny + wa.height / 2;
        } else {  // tiled position is relative to the mouse cursor
          px = ev.xmotion.x;
          py = ev.xmotion.y;
        }

        r = recttoclient(px, py, 1, 1);

        if (!r || r == c) break;

        attachmode = 0;  // below
        if (((float)(r->y + r->h - py) / r->h) >
            ((float)(r->x + r->w - px) / r->w)) {
          if (abs(r->y - py) < r->h / 2) attachmode = 1;  // above
        } else if (abs(r->x - px) < r->w / 2)
          attachmode = 1;  // above

        if ((r && r != prevr) || (attachmode != prevattachmode)) {
          detachstack(c);
          detach(c);
          if (c->mon != r->mon) {
            arrangemon(c->mon);
            c->tags = r->mon->tagset[r->mon->seltags];
          }

          c->mon = r->mon;
          r->mon->sel = r;

          if (attachmode) {
            if (r == r->mon->clients)
              attach(c);
            else {
              for (at = r->mon->clients; at->next != r; at = at->next);
              c->next = at->next;
              at->next = c;
            }
          } else {
            c->next = r->next;
            r->next = c;
          }

          attachstack(c);
          arrangemon(r->mon);
          prevr = r;
          prevattachmode = attachmode;
        }
        break;
    }
  } while (ev.type != ButtonRelease);
  XUngrabPointer(dpy, CurrentTime);

  if ((m = recttomon(ev.xmotion.x, ev.xmotion.y, 1, 1)) && m != c->mon) {
    detach(c);
    detachstack(c);
    arrangemon(c->mon);
    c->mon = m;
    c->tags = m->tagset[m->seltags];
    attach(c);
    attachstack(c);
    selmon = m;
  }

  focus(c);
  c->beingmoved = 0;

  if (nx != -9999) resize(c, nx, ny, c->w, c->h, 0);
  arrangemon(c->mon);
}

/**
 * @brief Move a client to the head of the client list and focus it.
 *
 * @param c          Client to promote.
 */
void pop(Client* c) {
  detach(c);
  attach(c);
  focus(c);
  arrange(c->mon);
}

/**
 * @brief React to property changes on clients, the root window and systray
 *        icons.
 *
 * @param e          X property event.
 */
void propertynotify(XEvent* e) {
  Client* c;
  Window trans;
  XPropertyEvent* ev = &e->xproperty;

  if ((c = wintosystrayicon(ev->window))) {
    if (ev->atom == XA_WM_NORMAL_HINTS) {
      updatesizehints(c);
      updatesystrayicongeom(c, c->w, c->h);
    } else
      updatesystrayiconstate(c, ev);
    resizebarwin(selmon);
    updatesystray();
  }
  if ((ev->window == root) && (ev->atom == XA_WM_NAME))
    updatestatus();
  else if (ev->state == PropertyDelete)
    return;
  else if ((c = wintoclient(ev->window))) {
    switch (ev->atom) {
      default:
        break;
      case XA_WM_TRANSIENT_FOR:
        if (!c->isfloating && (XGetTransientForHint(dpy, c->win, &trans)) &&
            (c->isfloating = (wintoclient(trans)) != NULL))
          arrange(c->mon);
        break;
      case XA_WM_NORMAL_HINTS:
        c->hintsvalid = 0;
        break;
      case XA_WM_HINTS:
        updatewmhints(c);
        drawbars();
        drawtabs();
        break;
    }
    if (ev->atom == XA_WM_NAME || ev->atom == netatom[NetWMName]) {
      updatetitle(c);
      if (c == c->mon->sel) drawbar(c->mon);
      drawtab(c->mon);
    }

    else if (ev->atom == netatom[NetWMIcon]) {
      updateicon(c);
      if (c == c->mon->sel) drawbar(c->mon);
    }

    if (ev->atom == netatom[NetWMWindowType]) updatewindowtype(c);
  }
}

/**
 * @brief Leave the event loop so the window manager can be restarted.
 *
 * @param arg        Unused key binding argument.
 */
void restart(const Arg* arg) { running = 0; }

/**
 * @brief Find the tiled client that intersects a rectangle the most.
 *
 * @param x          Rectangle x coordinate.
 * @param y          Rectangle y coordinate.
 * @param w          Rectangle width.
 * @param h          Rectangle height.
 * @return Best matching client, or NULL if nothing intersects.
 */
Client* recttoclient(int x, int y, int w, int h) {
  Client *c, *r = NULL;
  int a, area = 0;

  for (c = nexttiled(selmon->clients); c; c = nexttiled(c->next)) {
    if ((a = INTERSECTC(x, y, w, h, c)) > area) {
      area = a;
      r = c;
    }
  }
  return r;
}

/**
 * @brief Find the monitor that intersects a rectangle the most.
 *
 * @param x          Rectangle x coordinate.
 * @param y          Rectangle y coordinate.
 * @param w          Rectangle width.
 * @param h          Rectangle height.
 * @return Best matching monitor, defaulting to the selected monitor.
 */
Monitor* recttomon(int x, int y, int w, int h) {
  Monitor *m, *r = selmon;
  int a, area = 0;

  for (m = mons; m; m = m->next)
    if ((a = INTERSECT(x, y, w, h, m)) > area) {
      area = a;
      r = m;
    }
  return r;
}

/**
 * @brief Remove an icon from the systray icon list and free it.
 *
 * @param i          Systray icon to remove.
 */
void removesystrayicon(Client* i) {
  Client** ii;

  if (!showsystray || !i) return;
  for (ii = &systray->icons; *ii && *ii != i; ii = &(*ii)->next);
  if (ii) *ii = i->next;
  free(i);
}

/**
 * @brief Resize a client after applying its size hints.
 *
 * @param c          Client to resize.
 * @param x          New x coordinate.
 * @param y          New y coordinate.
 * @param w          New width.
 * @param h          New height.
 * @param interact   Non-zero for interactive resizing.
 */
void resize(Client* c, int x, int y, int w, int h, int interact) {
  if (applysizehints(c, &x, &y, &w, &h, interact)) resizeclient(c, x, y, w, h);
}

/**
 * @brief Position and size a monitor's bar window.
 *
 * @param m          Monitor whose bar is resized.
 */
void resizebarwin(Monitor* m) {
  unsigned int w = floatbar ? m->ww - 2 * m->gappov : m->ww;
  if (showsystray && m == systraytomon(m)) w -= getsystraywidth();
  if (floatbar) {
    XMoveResizeWindow(dpy, m->barwin, m->wx + m->gappov, m->by, w, bh);
  } else {
    XMoveResizeWindow(dpy, m->barwin, m->wx, m->by, w, bh);
  }
}

/**
 * @brief Apply a geometry to a client window and notify it.
 *
 * @param c          Client to configure.
 * @param x          New x coordinate.
 * @param y          New y coordinate.
 * @param w          New width.
 * @param h          New height.
 */
void resizeclient(Client* c, int x, int y, int w, int h) {
  XWindowChanges wc;

  c->oldx = c->x;
  c->x = wc.x = x;
  c->oldy = c->y;
  c->y = wc.y = y;
  c->oldw = c->w;
  c->w = wc.width = w;
  c->oldh = c->h;
  c->h = wc.height = h;

  if (c->beingmoved) return;

  wc.border_width = c->bw;
  XConfigureWindow(dpy, c->win, CWX | CWY | CWWidth | CWHeight | CWBorderWidth,
                   &wc);
  configure(c);
  XSync(dpy, False);
}

/**
 * @brief Interactively resize the selected client with the pointer.
 *
 * @param arg        Unused key binding argument.
 */
void resizemouse(const Arg* arg) {
  int ocx, ocy, nw, nh;
  Client* c;
  Monitor* m;
  XEvent ev;
  Time lasttime = 0;

  if (!(c = selmon->sel)) return;
  if (c->isfullscreen) /* no support resizing fullscreen windows by mouse */
    return;
  restack(selmon);
  ocx = c->x;
  ocy = c->y;
  if (XGrabPointer(dpy, root, False, MOUSEMASK, GrabModeAsync, GrabModeAsync,
                   None, cursor[CurResize]->cursor, CurrentTime) != GrabSuccess)
    return;
  XWarpPointer(dpy, None, c->win, 0, 0, 0, 0, c->w + c->bw - 1,
               c->h + c->bw - 1);
  do {
    XMaskEvent(dpy, MOUSEMASK | ExposureMask | SubstructureRedirectMask, &ev);
    switch (ev.type) {
      case ConfigureRequest:
      case Expose:
      case MapRequest:
        handler[ev.type](&ev);
        break;
      case MotionNotify:
        if ((ev.xmotion.time - lasttime) <= (1000 / 60)) continue;
        lasttime = ev.xmotion.time;

        nw = MAX(ev.xmotion.x - ocx - 2 * c->bw + 1, 1);
        nh = MAX(ev.xmotion.y - ocy - 2 * c->bw + 1, 1);
        if (c->mon->wx + nw >= selmon->wx &&
            c->mon->wx + nw <= selmon->wx + selmon->ww &&
            c->mon->wy + nh >= selmon->wy &&
            c->mon->wy + nh <= selmon->wy + selmon->wh) {
          if (!c->isfloating && selmon->lt[selmon->sellt]->arrange &&
              (abs(nw - c->w) > snap || abs(nh - c->h) > snap))
            togglefloating(NULL);
        }
        if (!selmon->lt[selmon->sellt]->arrange || c->isfloating)
          resize(c, c->x, c->y, nw, nh, 1);
        break;
    }
  } while (ev.type != ButtonRelease);
  XWarpPointer(dpy, None, c->win, 0, 0, 0, 0, c->w + c->bw - 1,
               c->h + c->bw - 1);
  XUngrabPointer(dpy, CurrentTime);
  while (XCheckMaskEvent(dpy, EnterWindowMask, &ev));
  if ((m = recttomon(c->x, c->y, c->w, c->h)) != selmon) {
    sendmon(c, m);
    selmon = m;
    focus(NULL);
  }
}

/**
 * @brief Handle resize requests from systray icons.
 *
 * @param e          X resize request event.
 */
void resizerequest(XEvent* e) {
  XResizeRequestEvent* ev = &e->xresizerequest;
  Client* i;

  if ((i = wintosystrayicon(ev->window))) {
    updatesystrayicongeom(i, ev->width, ev->height);
    resizebarwin(selmon);
    updatesystray();
  }
}

/**
 * @brief Redraw bars and order client windows below them.
 *
 * @param m          Monitor whose windows are restacked.
 */
void restack(Monitor* m) {
  Client* c;
  XEvent ev;
  XWindowChanges wc;

  drawbar(m);
  drawtab(m);
  if (!m->sel) return;
  if (m->sel->isfloating || !m->lt[m->sellt]->arrange)
    XRaiseWindow(dpy, m->sel->win);
  if (m->lt[m->sellt]->arrange) {
    wc.stack_mode = Below;
    wc.sibling = m->barwin;
    for (c = m->stack; c; c = c->snext)
      if (!c->isfloating && ISVISIBLE(c)) {
        XConfigureWindow(dpy, c->win, CWSibling | CWStackMode, &wc);
        wc.sibling = c->win;
      }
  }
  XSync(dpy, False);
  while (XCheckMaskEvent(dpy, EnterWindowMask, &ev));
}

/**
 * @brief Run the main X event loop until the window manager exits.
 */
void run(void) {
  XEvent ev;
  XSync(dpy, False);
  while (running && !XNextEvent(dpy, &ev))
    if (handler[ev.type]) handler[ev.type](&ev);
}

/**
 * @brief Manage windows that already exist when the window manager starts.
 */
void scan(void) {
  unsigned int i, num;
  Window d1, d2, *wins = NULL;
  XWindowAttributes wa;

  if (XQueryTree(dpy, root, &d1, &d2, &wins, &num)) {
    for (i = 0; i < num; i++) {
      if (!XGetWindowAttributes(dpy, wins[i], &wa) || wa.override_redirect ||
          XGetTransientForHint(dpy, wins[i], &d1))
        continue;
      if (wa.map_state == IsViewable || getstate(wins[i]) == IconicState)
        manage(wins[i], &wa);
    }
    for (i = 0; i < num; i++) { /* now the transients */
      if (!XGetWindowAttributes(dpy, wins[i], &wa)) continue;
      if (XGetTransientForHint(dpy, wins[i], &d1) &&
          (wa.map_state == IsViewable || getstate(wins[i]) == IconicState))
        manage(wins[i], &wa);
    }
    if (wins) XFree(wins);
  }
}

/**
 * @brief Move a client to another monitor.
 *
 * @param c          Client to move.
 * @param m          Destination monitor.
 */
void sendmon(Client* c, Monitor* m) {
  if (c->mon == m) return;
  unfocus(c, 1);
  detach(c);
  detachstack(c);
  c->mon = m;
  c->tags = m->tagset[m->seltags];
  attach(c);
  attachstack(c);
  setclienttagprop(c);
  focus(NULL);
  arrange(NULL);
}

/**
 * @brief Change the border width of the selected monitor and its clients.
 *
 * @param arg        Border delta, or 0 to restore the configured width.
 */
void setborderpx(const Arg* arg) {
  Client* c;
  int prev_borderpx = selmon->borderpx;

  if (arg->i == 0)
    selmon->borderpx = borderpx;
  else if (selmon->borderpx + arg->i < 0)
    selmon->borderpx = 0;
  else
    selmon->borderpx += arg->i;

  for (c = selmon->clients; c; c = c->next) {
    if (c->bw + arg->i < 0)
      c->bw = selmon->borderpx = 0;
    else
      c->bw = selmon->borderpx;
    if (c->isfloating || !selmon->lt[selmon->sellt]->arrange) {
      if (arg->i != 0 && prev_borderpx + arg->i >= 0)
        resize(c, c->x, c->y, c->w - (arg->i * 2), c->h - (arg->i * 2), 0);
      else if (arg->i != 0)
        resizeclient(c, c->x, c->y, c->w, c->h);
      else if (prev_borderpx > borderpx)
        resize(c, c->x, c->y, c->w + 2 * (prev_borderpx - borderpx),
               c->h + 2 * (prev_borderpx - borderpx), 0);
      else if (prev_borderpx < borderpx)
        resize(c, c->x, c->y, c->w - 2 * (borderpx - prev_borderpx),
               c->h - 2 * (borderpx - prev_borderpx), 0);
    }
  }
  arrange(selmon);
}

/**
 * @brief Write the ICCCM WM_STATE property for a client.
 *
 * @param c          Client to update.
 * @param state      New WM_STATE value.
 */
void setclientstate(Client* c, long state) {
  long data[] = {state, None};

  XChangeProperty(dpy, c->win, wmatom[WMState], wmatom[WMState], 32,
                  PropModeReplace, (unsigned char*)data, 2);
}

/**
 * @brief Publish the currently selected tag as _NET_CURRENT_DESKTOP.
 */
void setcurrentdesktop(void) {
  long data[] = {0};
  XChangeProperty(dpy, root, netatom[NetCurrentDesktop], XA_CARDINAL, 32,
                  PropModeReplace, (unsigned char*)data, 1);
}
/**
 * @brief Publish the tag names as _NET_DESKTOP_NAMES.
 */
void setdesktopnames(void) {
  XTextProperty text;
  Xutf8TextListToTextProperty(dpy, tags, TAGSLENGTH, XUTF8StringStyle, &text);
  XSetTextProperty(dpy, root, &text, netatom[NetDesktopNames]);
}

/**
 * @brief Send an ICCCM or EWMH client message to a window.
 *
 * @param w          Destination window.
 * @param proto      Protocol or message atom.
 * @param mask       Event mask for XSendEvent().
 * @param d0         First data value.
 * @param d1         Second data value.
 * @param d2         Third data value.
 * @param d3         Fourth data value.
 * @param d4         Fifth data value.
 * @return Non-zero when the message was supported and sent.
 */
int sendevent(Window w, Atom proto, int mask, long d0, long d1, long d2,
              long d3, long d4) {
  int n;
  Atom *protocols, mt;
  int exists = 0;
  XEvent ev;

  if (proto == wmatom[WMTakeFocus] || proto == wmatom[WMDelete]) {
    mt = wmatom[WMProtocols];
    if (XGetWMProtocols(dpy, w, &protocols, &n)) {
      while (!exists && n--) exists = protocols[n] == proto;
      XFree(protocols);
    }
  } else {
    exists = True;
    mt = proto;
  }
  if (exists) {
    ev.type = ClientMessage;
    ev.xclient.window = w;
    ev.xclient.message_type = mt;
    ev.xclient.format = 32;
    ev.xclient.data.l[0] = d0;
    ev.xclient.data.l[1] = d1;
    ev.xclient.data.l[2] = d2;
    ev.xclient.data.l[3] = d3;
    ev.xclient.data.l[4] = d4;
    XSendEvent(dpy, w, False, mask, &ev);
  }
  return exists;
}

/**
 * @brief Publish the number of tags as _NET_NUMBER_OF_DESKTOPS.
 */
void setnumdesktops(void) {
  long data[] = {TAGSLENGTH};
  XChangeProperty(dpy, root, netatom[NetNumberOfDesktops], XA_CARDINAL, 32,
                  PropModeReplace, (unsigned char*)data, 1);
}

/**
 * @brief Give input focus to a client and notify it.
 *
 * @param c          Client to focus.
 */
void setfocus(Client* c) {
  if (!c->neverfocus) {
    XSetInputFocus(dpy, c->win, RevertToPointerRoot, CurrentTime);
    XChangeProperty(dpy, root, netatom[NetActiveWindow], XA_WINDOW, 32,
                    PropModeReplace, (unsigned char*)&(c->win), 1);
  }
  sendevent(c->win, wmatom[WMTakeFocus], NoEventMask, wmatom[WMTakeFocus],
            CurrentTime, 0, 0, 0);
}

/**
 * @brief Enter or leave fullscreen mode for a client.
 *
 * @param c          Client to update.
 * @param fullscreen Non-zero to enable fullscreen.
 */
void setfullscreen(Client* c, int fullscreen) {
  if (fullscreen && !c->isfullscreen) {
    XChangeProperty(dpy, c->win, netatom[NetWMState], XA_ATOM, 32,
                    PropModeReplace, (unsigned char*)&netatom[NetWMFullscreen],
                    1);
    c->isfullscreen = 1;
    c->oldstate = c->isfloating;
    c->oldbw = c->bw;
    c->bw = 0;
    c->isfloating = 1;
    resizeclient(c, c->mon->mx, c->mon->my, c->mon->mw, c->mon->mh);
    XRaiseWindow(dpy, c->win);
  } else if (!fullscreen && c->isfullscreen) {
    XChangeProperty(dpy, c->win, netatom[NetWMState], XA_ATOM, 32,
                    PropModeReplace, (unsigned char*)0, 0);
    c->isfullscreen = 0;
    c->isfloating = c->oldstate;
    c->bw = c->oldbw;
    c->x = c->oldx;
    c->y = c->oldy;
    c->w = c->oldw;
    c->h = c->oldh;
    resizeclient(c, c->x, c->y, c->w, c->h);
    arrange(c->mon);
  }
}

/**
 * @brief Select a layout for the current tag.
 *
 * @param arg        Layout to select, or NULL to toggle layouts.
 */
void setlayout(const Arg* arg) {
  if (!arg || !arg->v || arg->v != selmon->lt[selmon->sellt])
    selmon->sellt = selmon->pertag->sellts[selmon->pertag->curtag] ^= 1;
  if (arg && arg->v)
    selmon->lt[selmon->sellt] =
      selmon->pertag->ltidxs[selmon->pertag->curtag][selmon->sellt] =
        (Layout*)arg->v;
  snprintf(selmon->ltsymbol, sizeof selmon->ltsymbol, "%s",
           selmon->lt[selmon->sellt]->symbol);
  if (selmon->sel)
    arrange(selmon);
  else
    drawbar(selmon);
}

/**
 * @brief Set or adjust the selected client's cfact.
 *
 * @param arg        Delta, or an absolute value encoded above 4.0.
 */
void setcfact(const Arg* arg) {
  float f;
  Client* c;

  c = selmon->sel;

  if (!arg || !c || !selmon->lt[selmon->sellt]->arrange) return;
  if (!arg->f)
    f = 1.0;
  else if (arg->f > 4.0)  // set fact absolutely
    f = arg->f - 4.0;
  else
    f = arg->f + c->cfact;
  if (f < 0.25)
    f = 0.25;
  else if (f > 4.0)
    f = 4.0;
  c->cfact = f;
  arrange(selmon);
}

/**
 * @brief Set or adjust the selected monitor's mfact.
 *
 * @param arg        Delta, or an absolute value encoded above 1.0.
 */
void setmfact(const Arg* arg) {
  float f;

  if (!arg || !selmon->lt[selmon->sellt]->arrange) return;
  f = arg->f < 1.0 ? arg->f + selmon->mfact : arg->f - 1.0;
  if (f < 0.05 || f > 0.95) return;
  selmon->mfact = selmon->pertag->mfacts[selmon->pertag->curtag] = f;
  arrange(selmon);
}

/**
 * @brief Initialize the display, atoms, cursors, colours, bars and system tray.
 */
void setup(void) {
  int i;
  XSetWindowAttributes wa;
  Atom utf8string;
  struct sigaction sa;
  /* do not transform children into zombies when they terminate */
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_NOCLDSTOP | SA_NOCLDWAIT | SA_RESTART;
  sa.sa_handler = SIG_IGN;
  sigaction(SIGCHLD, &sa, NULL);

  /* clean up any zombies (inherited from .xinitrc etc) immediately */
  while (waitpid(-1, NULL, WNOHANG) > 0);

  /* init screen */
  screen = DefaultScreen(dpy);
  sw = DisplayWidth(dpy, screen);
  sh = DisplayHeight(dpy, screen);
  root = RootWindow(dpy, screen);
  drw = drw_create(dpy, screen, root, sw, sh);
  if (!drw_fontset_create(drw, fonts, LENGTH(fonts)))
    die("no fonts could be loaded.");
  lrpad = drw->fonts->h;
  bh = drw->fonts->h + 2 + vertpadbar + borderpx * 2;
  th = vertpadtab;
  updategeom();
  /* init atoms */
  utf8string = XInternAtom(dpy, "UTF8_STRING", False);
  wmatom[WMProtocols] = XInternAtom(dpy, "WM_PROTOCOLS", False);
  wmatom[WMDelete] = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
  wmatom[WMState] = XInternAtom(dpy, "WM_STATE", False);
  wmatom[WMTakeFocus] = XInternAtom(dpy, "WM_TAKE_FOCUS", False);
  netatom[NetActiveWindow] = XInternAtom(dpy, "_NET_ACTIVE_WINDOW", False);
  netatom[NetSupported] = XInternAtom(dpy, "_NET_SUPPORTED", False);
  netatom[NetSystemTray] = XInternAtom(dpy, "_NET_SYSTEM_TRAY_S0", False);
  netatom[NetSystemTrayOP] = XInternAtom(dpy, "_NET_SYSTEM_TRAY_OPCODE", False);
  netatom[NetSystemTrayOrientation] =
    XInternAtom(dpy, "_NET_SYSTEM_TRAY_ORIENTATION", False);
  netatom[NetSystemTrayOrientationHorz] =
    XInternAtom(dpy, "_NET_SYSTEM_TRAY_ORIENTATION_HORZ", False);
  netatom[NetWMName] = XInternAtom(dpy, "_NET_WM_NAME", False);
  netatom[NetWMIcon] = XInternAtom(dpy, "_NET_WM_ICON", False);
  netatom[NetWMState] = XInternAtom(dpy, "_NET_WM_STATE", False);
  netatom[NetWMCheck] = XInternAtom(dpy, "_NET_SUPPORTING_WM_CHECK", False);
  netatom[NetWMFullscreen] =
    XInternAtom(dpy, "_NET_WM_STATE_FULLSCREEN", False);
  netatom[NetWMWindowType] = XInternAtom(dpy, "_NET_WM_WINDOW_TYPE", False);
  netatom[NetWMWindowTypeDialog] =
    XInternAtom(dpy, "_NET_WM_WINDOW_TYPE_DIALOG", False);
  netatom[NetClientList] = XInternAtom(dpy, "_NET_CLIENT_LIST", False);
  xatom[Manager] = XInternAtom(dpy, "MANAGER", False);
  xatom[Xembed] = XInternAtom(dpy, "_XEMBED", False);
  xatom[XembedInfo] = XInternAtom(dpy, "_XEMBED_INFO", False);
  netatom[NetDesktopViewport] =
    XInternAtom(dpy, "_NET_DESKTOP_VIEWPORT", False);
  netatom[NetNumberOfDesktops] =
    XInternAtom(dpy, "_NET_NUMBER_OF_DESKTOPS", False);
  netatom[NetCurrentDesktop] = XInternAtom(dpy, "_NET_CURRENT_DESKTOP", False);
  netatom[NetDesktopNames] = XInternAtom(dpy, "_NET_DESKTOP_NAMES", False);
  netatom[NetClientInfo] = XInternAtom(dpy, "_NET_CLIENT_INFO", False);
  /* init cursors */
  cursor[CurNormal] = drw_cur_create(drw, XC_left_ptr);
  cursor[CurResize] = drw_cur_create(drw, XC_sizing);
  cursor[CurMove] = drw_cur_create(drw, XC_fleur);
  cursor[CurResizeHorzArrow] = drw_cur_create(drw, XC_sb_h_double_arrow);
  cursor[CurResizeVertArrow] = drw_cur_create(drw, XC_sb_v_double_arrow);
  /* init appearance */
  scheme = ecalloc(LENGTH(colors) + 1, sizeof(Clr*));
  scheme[LENGTH(colors)] = drw_scm_create(drw, colors[0], 3);
  for (i = 0; i < LENGTH(colors); i++)
    scheme[i] = drw_scm_create(drw, colors[i], 3);
  drw_clr_create(drw, &clrborder, col_borderbar);
  /* init system tray */
  updatesystray();
  /* init bars */
  updatebars();
  updatestatus();
  updatebarpos(selmon);
  updatepreview();
  /* supporting window for NetWMCheck */
  wmcheckwin = XCreateSimpleWindow(dpy, root, 0, 0, 1, 1, 0, 0, 0);
  XChangeProperty(dpy, wmcheckwin, netatom[NetWMCheck], XA_WINDOW, 32,
                  PropModeReplace, (unsigned char*)&wmcheckwin, 1);
  XChangeProperty(dpy, wmcheckwin, netatom[NetWMName], utf8string, 8,
                  PropModeReplace, (unsigned char*)"dwm", 3);
  XChangeProperty(dpy, root, netatom[NetWMCheck], XA_WINDOW, 32,
                  PropModeReplace, (unsigned char*)&wmcheckwin, 1);
  /* EWMH support per view */
  XChangeProperty(dpy, root, netatom[NetSupported], XA_ATOM, 32,
                  PropModeReplace, (unsigned char*)netatom, NetLast);
  setnumdesktops();
  setcurrentdesktop();
  setdesktopnames();
  setviewport();
  XDeleteProperty(dpy, root, netatom[NetClientList]);
  XDeleteProperty(dpy, root, netatom[NetClientInfo]);
  /* select events */
  wa.cursor = cursor[CurNormal]->cursor;
  wa.event_mask = SubstructureRedirectMask | SubstructureNotifyMask |
                  ButtonPressMask | PointerMotionMask | EnterWindowMask |
                  LeaveWindowMask | StructureNotifyMask | PropertyChangeMask;
  XChangeWindowAttributes(dpy, root, CWEventMask | CWCursor, &wa);
  XSelectInput(dpy, root, wa.event_mask);
  grabkeys();
  focus(NULL);
}
/**
 * @brief Publish the desktop viewport as _NET_DESKTOP_VIEWPORT.
 */
void setviewport(void) {
  long data[] = {0, 0};
  XChangeProperty(dpy, root, netatom[NetDesktopViewport], XA_CARDINAL, 32,
                  PropModeReplace, (unsigned char*)data, 2);
}

/**
 * @brief Set or clear a client's urgency hint.
 *
 * @param c          Client to update.
 * @param urg        Non-zero to mark the client urgent.
 */
void seturgent(Client* c, int urg) {
  XWMHints* wmh;

  c->isurgent = urg;
  if (!(wmh = XGetWMHints(dpy, c->win))) return;
  wmh->flags = urg ? (wmh->flags | XUrgencyHint) : (wmh->flags & ~XUrgencyHint);
  XSetWMHints(dpy, c->win, wmh);
  XFree(wmh);
}

/**
 * @brief Map a previously hidden client.
 *
 * @param c          Client to show.
 */
void show(Client* c) {
  if (!c || !HIDDEN(c)) return;

  XMapWindow(dpy, c->win);
  setclientstate(c, NormalState);
  arrange(c->mon);
}

/**
 * @brief Recursively show or hide clients according to tag visibility.
 *
 * @param c          Start of the focus stack.
 */
void showhide(Client* c) {
  if (!c) return;
  if (ISVISIBLE(c)) {
    /* show clients top down */
    XMoveWindow(dpy, c->win, c->x, c->y);
    if ((!c->mon->lt[c->mon->sellt]->arrange || c->isfloating) &&
        !c->isfullscreen)
      resize(c, c->x, c->y, c->w, c->h, 0);
    showhide(c->snext);
  } else {
    /* hide clients bottom up */
    showhide(c->snext);
    XMoveWindow(dpy, c->win, WIDTH(c) * -2, c->y);
  }
}

/**
 * @brief Show the preview image for a tag, or unmap the preview window.
 *
 * @param tag        Tag index to preview.
 */
void showtagpreview(int tag) {
  if (!selmon->previewshow || !tag_preview) {
    XUnmapWindow(dpy, selmon->tagwin);
    return;
  }

  if (selmon->tagmap[tag]) {
    XSetWindowBackgroundPixmap(dpy, selmon->tagwin, selmon->tagmap[tag]);
    XCopyArea(dpy, selmon->tagmap[tag], selmon->tagwin, drw->gc, 0, 0,
              selmon->mw / scalepreview, selmon->mh / scalepreview, 0, 0);
    XSync(dpy, False);
    XMapWindow(dpy, selmon->tagwin);
  } else
    XUnmapWindow(dpy, selmon->tagwin);
}

/**
 * @brief Fork and execute a command from a key binding.
 *
 * @param arg        Argument vector to execute.
 */
void spawn(const Arg* arg) {
  struct sigaction sa;
  if (fork() == 0) {
    if (dpy) close(ConnectionNumber(dpy));
    setsid();
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sa.sa_handler = SIG_DFL;
    sigaction(SIGCHLD, &sa, NULL);
    execvp(((char**)arg->v)[0], (char**)arg->v);
    die("dwm: execvp '%s' failed:", ((char**)arg->v)[0]);
  }
}

/**
 * @brief Publish a client's tags and monitor as _NET_CLIENT_INFO.
 *
 * @param c          Client to update.
 */
void setclienttagprop(Client* c) {
  long data[] = {(long)c->tags, (long)c->mon->num};
  XChangeProperty(dpy, c->win, netatom[NetClientInfo], XA_CARDINAL, 32,
                  PropModeReplace, (unsigned char*)data, 2);
}

/**
 * @brief Capture preview images for the tags of the new view.
 */
void switchtag(void) {
  int i;
  unsigned int occ = 0;
  Client* c;
  Imlib_Image image;

  for (c = selmon->clients; c; c = c->next) occ |= c->tags;
  for (i = 0; i < LENGTH(tags); i++) {
    if (selmon->tagset[selmon->seltags] & 1 << i) {
      if (selmon->tagmap[i] != 0) {
        XFreePixmap(dpy, selmon->tagmap[i]);
        selmon->tagmap[i] = 0;
      }
      if (occ & 1 << i && tag_preview) {
        image = imlib_create_image(sw, sh);
        imlib_context_set_image(image);
        imlib_context_set_display(dpy);
        imlib_context_set_visual(DefaultVisual(dpy, screen));
        imlib_context_set_drawable(RootWindow(dpy, screen));
        imlib_copy_drawable_to_image(0, selmon->mx, selmon->my, selmon->mw,
                                     selmon->mh, 0, 0, 1);
        selmon->tagmap[i] =
          XCreatePixmap(dpy, selmon->tagwin, selmon->mw / scalepreview,
                        selmon->mh / scalepreview, DefaultDepth(dpy, screen));
        imlib_context_set_drawable(selmon->tagmap[i]);
        imlib_render_image_part_on_drawable_at_size(
          0, 0, selmon->mw, selmon->mh, 0, 0, selmon->mw / scalepreview,
          selmon->mh / scalepreview);
        imlib_free_image();
      }
    }
  }
}

/**
 * @brief Change the tab bar visibility mode.
 *
 * @param arg        Mode to select, or negative to cycle.
 */
void tabmode(const Arg* arg) {
  if (arg && arg->i >= 0)
    selmon->showtab = arg->ui % showtab_nmodes;
  else
    selmon->showtab = (selmon->showtab + 1) % showtab_nmodes;
  arrange(selmon);
}

/**
 * @brief Move the selected client to the given tags.
 *
 * @param arg        Tag mask to assign.
 */
void tag(const Arg* arg) {
  Client* c;
  if (selmon->sel && arg->ui & TAGMASK) {
    c = selmon->sel;
    selmon->sel->tags = arg->ui & TAGMASK;
    setclienttagprop(c);
    focus(NULL);
    arrange(selmon);
  }
}

/**
 * @brief Move the selected client to an adjacent monitor.
 *
 * @param arg        Positive for next, negative for previous.
 */
void tagmon(const Arg* arg) {
  if (!selmon->sel || !mons->next) return;
  sendmon(selmon->sel, dirtomon(arg->i));
}

/**
 * @brief Toggle bar visibility for the current tag.
 *
 * @param arg        Unused key binding argument.
 */
void togglebar(const Arg* arg) {
  selmon->showbar = selmon->pertag->showbars[selmon->pertag->curtag] =
    !selmon->showbar;
  updatebarpos(selmon);
  resizebarwin(selmon);
  if (showsystray) {
    XWindowChanges wc;
    if (!selmon->showbar)
      wc.y = -bh;
    else if (selmon->showbar) {
      wc.y = selmon->gappoh;
      if (!selmon->topbar) wc.y = selmon->mh - bh + selmon->gappoh;
    }
    XConfigureWindow(dpy, systray->win, CWY, &wc);
  }
  arrange(selmon);
}

/**
 * @brief Toggle the selected client between tiled and floating state.
 *
 * @param arg        Unused key binding argument.
 */
void togglefloating(const Arg* arg) {
  if (!selmon->sel) return;
  if (selmon->sel->isfullscreen) /* no support for fullscreen windows */
    return;
  selmon->sel->isfloating = !selmon->sel->isfloating || selmon->sel->isfixed;
  if (selmon->sel->isfloating)
    resize(selmon->sel, selmon->sel->x, selmon->sel->y, selmon->sel->w,
           selmon->sel->h, 0);
  arrange(selmon);
}

/**
 * @brief Toggle fullscreen mode for the selected client.
 *
 * @param arg        Unused key binding argument.
 */
void togglefullscr(const Arg* arg) {
  if (selmon->sel) setfullscreen(selmon->sel, !selmon->sel->isfullscreen);
}

/**
 * @brief Toggle the selected client's membership in the given tags.
 *
 * @param arg        Tag mask to toggle.
 */
void toggletag(const Arg* arg) {
  unsigned int newtags;

  if (!selmon->sel) return;
  newtags = selmon->sel->tags ^ (arg->ui & TAGMASK);
  if (newtags) {
    selmon->sel->tags = newtags;
    setclienttagprop(selmon->sel);
    focus(NULL);
    arrange(selmon);
  }
  updatecurrentdesktop();
}

/**
 * @brief Toggle the set of tags currently viewed on the selected monitor.
 *
 * @param arg        Tag mask to toggle.
 */
void toggleview(const Arg* arg) {
  unsigned int newtagset =
    selmon->tagset[selmon->seltags] ^ (arg->ui & TAGMASK);
  int i;

  if (newtagset) {
    switchtag();
    selmon->tagset[selmon->seltags] = newtagset;

    if (newtagset == ~0) {
      selmon->pertag->prevtag = selmon->pertag->curtag;
      selmon->pertag->curtag = 0;
    }

    /* test if the user did not select the same tag */
    if (!(newtagset & 1 << (selmon->pertag->curtag - 1))) {
      selmon->pertag->prevtag = selmon->pertag->curtag;
      for (i = 0; !(newtagset & 1 << i); i++);
      selmon->pertag->curtag = i + 1;
    }

    /* apply settings for this view */
    selmon->nmaster = selmon->pertag->nmasters[selmon->pertag->curtag];
    selmon->mfact = selmon->pertag->mfacts[selmon->pertag->curtag];
    selmon->sellt = selmon->pertag->sellts[selmon->pertag->curtag];
    selmon->lt[selmon->sellt] =
      selmon->pertag->ltidxs[selmon->pertag->curtag][selmon->sellt];
    selmon->lt[selmon->sellt ^ 1] =
      selmon->pertag->ltidxs[selmon->pertag->curtag][selmon->sellt ^ 1];

    if (selmon->showbar != selmon->pertag->showbars[selmon->pertag->curtag])
      togglebar(NULL);

    focus(NULL);
    arrange(selmon);
  }
  updatecurrentdesktop();
}

/**
 * @brief Hide the selected window and remember it for later restore.
 *
 * @param arg        Unused key binding argument.
 */
void hidewin(const Arg* arg) {
  if (!selmon->sel) return;
  Client* c = (Client*)selmon->sel;
  hide(c);
  hiddenWinStack[++hiddenWinStackTop] = c;
}

/**
 * @brief Restore the most recently hidden window on the current tag.
 *
 * @param arg        Unused key binding argument.
 */
void restorewin(const Arg* arg) {
  int i = hiddenWinStackTop;
  while (i > -1) {
    if (HIDDEN(hiddenWinStack[i]) &&
        hiddenWinStack[i]->tags == selmon->tagset[selmon->seltags]) {
      show(hiddenWinStack[i]);
      focus(hiddenWinStack[i]);
      restack(selmon);
      for (int j = i; j < hiddenWinStackTop; ++j) {
        hiddenWinStack[j] = hiddenWinStack[j + 1];
      }
      --hiddenWinStackTop;
      return;
    }
    --i;
  }
}

/**
 * @brief Remove focus styling and button grabs from a client.
 *
 * @param c          Client to unfocus.
 * @param setfocus   Non-zero to move input focus back to the root window.
 */
void unfocus(Client* c, int setfocus) {
  if (!c) return;
  grabbuttons(c, 0);
  XSetWindowBorder(dpy, c->win, scheme[SchemeNorm][ColBorder].pixel);
  if (setfocus) {
    XSetInputFocus(dpy, root, RevertToPointerRoot, CurrentTime);
    XDeleteProperty(dpy, root, netatom[NetActiveWindow]);
  }
}

/**
 * @brief Stop managing a client and release its resources.
 *
 * @param c          Client to unmanage.
 * @param destroyed  Non-zero when the X window was already destroyed.
 */
void unmanage(Client* c, int destroyed) {
  Monitor* m = c->mon;
  XWindowChanges wc;

  detach(c);
  detachstack(c);
  freeicon(c);

  if (!destroyed) {
    wc.border_width = c->oldbw;
    XGrabServer(dpy); /* avoid race conditions */
    XSetErrorHandler(xerrordummy);
    XSelectInput(dpy, c->win, NoEventMask);
    XConfigureWindow(dpy, c->win, CWBorderWidth, &wc); /* restore border */
    XUngrabButton(dpy, AnyButton, AnyModifier, c->win);
    setclientstate(c, WithdrawnState);
    XSync(dpy, False);
    XSetErrorHandler(xerror);
    XUngrabServer(dpy);
  }
  free(c);
  focus(NULL);
  updateclientlist();
  arrange(m);
}

/**
 * @brief Handle an unmapped client window or systray icon.
 *
 * @param e          X unmap event.
 */
void unmapnotify(XEvent* e) {
  Client* c;
  XUnmapEvent* ev = &e->xunmap;

  if ((c = wintoclient(ev->window))) {
    if (ev->send_event)
      setclientstate(c, WithdrawnState);
    else
      unmanage(c, 0);
  } else if ((c = wintosystrayicon(ev->window))) {
    /* KLUDGE! sometimes icons occasionally unmap their windows, but do
     * _not_ destroy them. We map those windows back */
    XMapRaised(dpy, c->win);
    updatesystray();
  }
}

/**
 * @brief Create the bar and tab windows for every monitor.
 */
void updatebars(void) {
  unsigned int w;
  Monitor* m;
  XSetWindowAttributes wa = {
    .override_redirect = True,
    .background_pixmap = ParentRelative,
    .event_mask = ButtonPressMask | ExposureMask | PointerMotionMask};

  XClassHint ch = {"dwm", "dwm"};
  for (m = mons; m; m = m->next) {
    if (m->barwin) continue;
    w = m->ww;
    if (showsystray && m == systraytomon(m)) w -= getsystraywidth();
    m->barwin = XCreateWindow(
      dpy, root, m->wx + m->gappov, m->by, w - 2 * m->gappov, bh, 0,
      DefaultDepth(dpy, screen), CopyFromParent, DefaultVisual(dpy, screen),
      CWOverrideRedirect | CWBackPixmap | CWEventMask, &wa);
    XDefineCursor(dpy, m->barwin, cursor[CurNormal]->cursor);
    if (showsystray && m == systraytomon(m)) XMapRaised(dpy, systray->win);
    XMapRaised(dpy, m->barwin);
    m->tabwin = XCreateWindow(
      dpy, root, m->wx + m->gappov, m->ty, m->ww - 2 * m->gappov, th, 0,
      DefaultDepth(dpy, screen), CopyFromParent, DefaultVisual(dpy, screen),
      CWOverrideRedirect | CWBackPixmap | CWEventMask, &wa);
    XDefineCursor(dpy, m->tabwin, cursor[CurNormal]->cursor);
    XMapRaised(dpy, m->tabwin);
    XSetClassHint(dpy, m->barwin, &ch);
  }
}

/**
 * @brief Create the tag preview windows for every monitor.
 */
void updatepreview(void) {
  Monitor* m;

  XSetWindowAttributes wa = {.override_redirect = True,
                             .background_pixmap = ParentRelative,
                             .event_mask = ButtonPressMask | ExposureMask};
  for (m = mons; m; m = m->next) {
    m->tagwin = XCreateWindow(
      dpy, root, m->wx, m->by + bh, m->mw / 4, m->mh / 4, 0,
      DefaultDepth(dpy, screen), CopyFromParent, DefaultVisual(dpy, screen),
      CWOverrideRedirect | CWBackPixmap | CWEventMask, &wa);
    XDefineCursor(dpy, m->tagwin, cursor[CurNormal]->cursor);
    XMapRaised(dpy, m->tagwin);
    XUnmapWindow(dpy, m->tagwin);
  }
}

/**
 * @brief Compute the bar and tab geometry and the usable window area.
 *
 * @param m          Monitor to update.
 */
void updatebarpos(Monitor* m) {
  Client* c;
  int nvis = 0;

  m->wy = m->my;
  m->wh = m->mh;

  for (c = m->clients; c; c = c->next) {
    if (ISVISIBLE(c)) ++nvis;
  }

  if (m->showtab == showtab_always ||
      ((m->showtab == showtab_auto) && (nvis > 1) &&
       (m->lt[m->sellt]->arrange == monocle))) {
    m->topbar = !toptab;
    m->wh -=
      th + ((m->topbar == toptab && m->showbar) ? 0 : m->gappoh) - m->gappoh;
    m->ty = m->toptab ? m->wy + ((m->topbar && m->showbar) ? 0 : m->gappoh)
                      : m->wy + m->wh - m->gappoh;
    if (m->toptab)
      m->wy += th + ((m->topbar && m->showbar) ? 0 : m->gappoh) - m->gappoh;
  } else {
    m->ty = -th - m->gappoh;
    m->topbar = topbar;
  }
  if (m->showbar) {
    if (floatbar) {
      m->wh = m->wh - m->gappoh - bh;
      m->by = m->topbar ? m->wy + m->gappoh : m->wy + m->wh;
    } else {
      m->wh = m->wh - bh;
      m->by = m->topbar ? m->wy : m->wy + m->wh;
    }
    if (m->topbar) {
      m->wy = floatbar ? bh + gappoh : bh;
    }
  } else
    m->by = -bh - m->gappoh;
}

/**
 * @brief Publish the list of managed clients as _NET_CLIENT_LIST.
 */
void updateclientlist() {
  Client* c;
  Monitor* m;

  XDeleteProperty(dpy, root, netatom[NetClientList]);
  for (m = mons; m; m = m->next)
    for (c = m->clients; c; c = c->next)
      XChangeProperty(dpy, root, netatom[NetClientList], XA_WINDOW, 32,
                      PropModeAppend, (unsigned char*)&(c->win), 1);
}

/**
 * @brief Publish the selected tag index as _NET_CURRENT_DESKTOP.
 */
void updatecurrentdesktop(void) {
  long rawdata[] = {selmon->tagset[selmon->seltags]};
  int i = 0;
  while (*rawdata >> (i + 1)) {
    i++;
  }
  long data[] = {i};
  XChangeProperty(dpy, root, netatom[NetCurrentDesktop], XA_CARDINAL, 32,
                  PropModeReplace, (unsigned char*)data, 1);
}

/**
 * @brief Synchronize the monitor list with the current screen geometry.
 * @return Non-zero when the geometry changed.
 */
int updategeom(void) {
  int dirty = 0;

#ifdef XINERAMA
  if (XineramaIsActive(dpy)) {
    int i, j, n, nn;
    Client* c;
    Monitor* m;
    XineramaScreenInfo* info = XineramaQueryScreens(dpy, &nn);
    XineramaScreenInfo* unique = NULL;

    for (n = 0, m = mons; m; m = m->next, n++);
    /* only consider unique geometries as separate screens */
    unique = ecalloc(nn, sizeof(XineramaScreenInfo));
    for (i = 0, j = 0; i < nn; i++)
      if (isuniquegeom(unique, j, &info[i]))
        memcpy(&unique[j++], &info[i], sizeof(XineramaScreenInfo));
    XFree(info);
    nn = j;
    /* new monitors if nn > n */
    for (i = n; i < nn; i++) {
      for (m = mons; m && m->next; m = m->next);
      if (m)
        m->next = createmon();
      else
        mons = createmon();
    }
    for (i = 0, m = mons; i < nn && m; m = m->next, i++)
      if (i >= n || unique[i].x_org != m->mx || unique[i].y_org != m->my ||
          unique[i].width != m->mw || unique[i].height != m->mh) {
        dirty = 1;
        m->num = i;
        m->mx = m->wx = unique[i].x_org;
        m->my = m->wy = unique[i].y_org;
        m->mw = m->ww = unique[i].width;
        m->mh = m->wh = unique[i].height;
        updatebarpos(m);
      }
    /* removed monitors if n > nn */
    for (i = nn; i < n; i++) {
      for (m = mons; m && m->next; m = m->next);
      while ((c = m->clients)) {
        dirty = 1;
        m->clients = c->next;
        detachstack(c);
        c->mon = mons;
        attach(c);
        attachstack(c);
      }
      if (m == selmon) selmon = mons;
      cleanupmon(m);
    }
    free(unique);
  } else
#endif /* XINERAMA */
  {    /* default monitor setup */
    if (!mons) mons = createmon();
    if (mons->mw != sw || mons->mh != sh) {
      dirty = 1;
      mons->mw = mons->ww = sw;
      mons->mh = mons->wh = sh;
      updatebarpos(mons);
    }
  }
  if (dirty) {
    selmon = mons;
    selmon = wintomon(root);
  }
  return dirty;
}

/**
 * @brief Determine the modifier mask currently assigned to Num Lock.
 */
void updatenumlockmask(void) {
  unsigned int i, j;
  XModifierKeymap* modmap;

  numlockmask = 0;
  modmap = XGetModifierMapping(dpy);
  for (i = 0; i < 8; i++)
    for (j = 0; j < modmap->max_keypermod; j++)
      if (modmap->modifiermap[i * modmap->max_keypermod + j] ==
          XKeysymToKeycode(dpy, XK_Num_Lock))
        numlockmask = (1 << i);
  XFreeModifiermap(modmap);
}

/**
 * @brief Cache the size hints advertised by a client.
 *
 * @param c          Client whose hints are read.
 */
void updatesizehints(Client* c) {
  long msize;
  XSizeHints size;

  if (!XGetWMNormalHints(dpy, c->win, &size, &msize))
    /* size is uninitialized, ensure that size.flags aren't used */
    size.flags = PSize;
  if (size.flags & PBaseSize) {
    c->basew = size.base_width;
    c->baseh = size.base_height;
  } else if (size.flags & PMinSize) {
    c->basew = size.min_width;
    c->baseh = size.min_height;
  } else
    c->basew = c->baseh = 0;
  if (size.flags & PResizeInc) {
    c->incw = size.width_inc;
    c->inch = size.height_inc;
  } else
    c->incw = c->inch = 0;
  if (size.flags & PMaxSize) {
    c->maxw = size.max_width;
    c->maxh = size.max_height;
  } else
    c->maxw = c->maxh = 0;
  if (size.flags & PMinSize) {
    c->minw = size.min_width;
    c->minh = size.min_height;
  } else if (size.flags & PBaseSize) {
    c->minw = size.base_width;
    c->minh = size.base_height;
  } else
    c->minw = c->minh = 0;
  if (size.flags & PAspect) {
    c->mina = (float)size.min_aspect.y / size.min_aspect.x;
    c->maxa = (float)size.max_aspect.x / size.max_aspect.y;
  } else
    c->maxa = c->mina = 0.0;
  c->isfixed = (c->maxw && c->maxh && c->maxw == c->minw && c->maxh == c->minh);
  c->hintsvalid = 1;
}

/**
 * @brief Read the root window name and redraw the status area.
 */
void updatestatus(void) {
  if (!gettextprop(root, XA_WM_NAME, stext, sizeof(stext)))
    strcpy(stext, "dwm-" VERSION);
  drawbar(selmon);
  updatesystray();
}

/**
 * @brief Apply the systray icon size policy to an icon.
 *
 * @param i          Systray icon.
 * @param w          Requested width.
 * @param h          Requested height.
 */
void updatesystrayicongeom(Client* i, int w, int h) {
  int rh = bh - vertpadbar;

  if (!i) return;

  applysizehints(i, &(i->x), &(i->y), &(i->w), &(i->h), False);

  if (systrayiconsize >= rh) {
    i->w = rh;
    i->h = rh;
    i->y = i->y + vertpadbar / 2;
  } else {
    i->w = systrayiconsize;
    i->h = systrayiconsize;
    /* center icons vertically if smaller than bar */
    i->y = (rh - systrayiconsize) / 2 + vertpadbar;
  }
}

/**
 * @brief React to XEmbed state changes of a systray icon.
 *
 * @param i          Systray icon.
 * @param ev         Property event that changed.
 */
void updatesystrayiconstate(Client* i, XPropertyEvent* ev) {
  long flags;
  int code = 0;

  if (!showsystray || !i || ev->atom != xatom[XembedInfo] ||
      !(flags = getatomprop(i, xatom[XembedInfo])))
    return;

  if (flags & XEMBED_MAPPED && !i->tags) {
    i->tags = 1;
    code = XEMBED_WINDOW_ACTIVATE;
    XMapRaised(dpy, i->win);
    setclientstate(i, NormalState);
  } else if (!(flags & XEMBED_MAPPED) && i->tags) {
    i->tags = 0;
    code = XEMBED_WINDOW_DEACTIVATE;
    XUnmapWindow(dpy, i->win);
    setclientstate(i, WithdrawnState);
  } else
    return;
  sendevent(i->win, xatom[Xembed], StructureNotifyMask, CurrentTime, code, 0,
            systray->win, XEMBED_EMBEDDED_VERSION);
}

/**
 * @brief Create, size and restack the systray and its icons.
 */
void updatesystray(void) {
  XSetWindowAttributes wa;
  XWindowChanges wc;
  Client* i;
  Monitor* m = systraytomon(NULL);
  unsigned int x = floatbar ? m->mx + m->mw - m->gappov : m->mx + m->mw;
  unsigned int w = 1;

  if (!showsystray) return;
  if (!systray) {
    /* init systray */
    if (!(systray = (Systray*)calloc(1, sizeof(Systray))))
      die("fatal: could not malloc() %u bytes\n", sizeof(Systray));
    systray->win = XCreateSimpleWindow(dpy, root, x, m->by, w, bh, 0, 0,
                                       scheme[SchemeSel][ColBg].pixel);
    wa.event_mask = ButtonPressMask | ExposureMask;
    wa.override_redirect = True;
    wa.background_pixel = scheme[SchemeNorm][ColBg].pixel;
    XSelectInput(dpy, systray->win, SubstructureNotifyMask);
    XChangeProperty(dpy, systray->win, netatom[NetSystemTrayOrientation],
                    XA_CARDINAL, 32, PropModeReplace,
                    (unsigned char*)&netatom[NetSystemTrayOrientationHorz], 1);
    XChangeWindowAttributes(
      dpy, systray->win, CWEventMask | CWOverrideRedirect | CWBackPixel, &wa);
    XMapRaised(dpy, systray->win);
    XSetSelectionOwner(dpy, netatom[NetSystemTray], systray->win, CurrentTime);
    if (XGetSelectionOwner(dpy, netatom[NetSystemTray]) == systray->win) {
      sendevent(root, xatom[Manager], StructureNotifyMask, CurrentTime,
                netatom[NetSystemTray], systray->win, 0, 0);
      XSync(dpy, False);
    } else {
      fprintf(stderr, "dwm: unable to obtain system tray.\n");
      free(systray);
      systray = NULL;
      return;
    }
  }
  for (w = 0, i = systray->icons; i; i = i->next) {
    /* make sure the background color stays the same */
    wa.background_pixel = scheme[SchemeNorm][ColBg].pixel;
    XChangeWindowAttributes(dpy, i->win, CWBackPixel, &wa);
    XMapRaised(dpy, i->win);
    w += systrayspacing;
    i->x = w;
    if (systrayiconsize >= bh)
      i->y = 0;
    else
      i->y = (bh - systrayiconsize) / 2;
    XMoveResizeWindow(dpy, i->win, i->x, i->y, i->w, i->h);
    w += i->w;
    if (i->mon != m) i->mon = m;
  }
  w = w ? w + systrayspacing : 1;
  x -= w;
  XMoveResizeWindow(dpy, systray->win, x, m->by, w, bh);
  wc.x = x;
  wc.y = m->by;
  wc.width = w;
  wc.height = bh;
  wc.stack_mode = Above;
  wc.sibling = m->barwin;
  XConfigureWindow(dpy, systray->win,
                   CWX | CWY | CWWidth | CWHeight | CWSibling | CWStackMode,
                   &wc);
  XMapWindow(dpy, systray->win);
  XMapSubwindows(dpy, systray->win);
  XSetForeground(dpy, drw->gc, scheme[SchemeNorm][ColBg].pixel);
  XFillRectangle(dpy, systray->win, drw->gc, 0, 0, w, bh);
  XSync(dpy, False);
}

/**
 * @brief Read and cache a client's window title.
 *
 * @param c          Client whose title is updated.
 */
void updatetitle(Client* c) {
  if (!gettextprop(c->win, netatom[NetWMName], c->name, sizeof c->name))
    gettextprop(c->win, XA_WM_NAME, c->name, sizeof c->name);
  if (c->name[0] == '\0') /* hack to mark broken clients */
    strcpy(c->name, broken);
}

/**
 * @brief Apply fullscreen and dialog hints from a client's window type.
 *
 * @param c          Client to update.
 */
void updatewindowtype(Client* c) {
  Atom state = getatomprop(c, netatom[NetWMState]);
  Atom wtype = getatomprop(c, netatom[NetWMWindowType]);

  if (state == netatom[NetWMFullscreen]) setfullscreen(c, 1);
  if (wtype == netatom[NetWMWindowTypeDialog]) {
    c->iscentered = 1;
    c->isfloating = 1;
  }
}

/**
 * @brief Read urgency and input hints from a client's WM_HINTS property.
 *
 * @param c          Client to update.
 */
void updatewmhints(Client* c) {
  XWMHints* wmh;

  if ((wmh = XGetWMHints(dpy, c->win))) {
    if (c == selmon->sel && wmh->flags & XUrgencyHint) {
      wmh->flags &= ~XUrgencyHint;
      XSetWMHints(dpy, c->win, wmh);
    } else
      c->isurgent = (wmh->flags & XUrgencyHint) ? 1 : 0;
    if (wmh->flags & InputHint)
      c->neverfocus = !wmh->input;
    else
      c->neverfocus = 0;
    XFree(wmh);
  }
}

/**
 * @brief Switch the selected monitor to the given tags.
 *
 * @param arg        Tag mask to view.
 */
void view(const Arg* arg) {
  int i;
  unsigned int tmptag;

  if ((arg->ui & TAGMASK) == selmon->tagset[selmon->seltags]) return;
  switchtag();
  selmon->seltags ^= 1;
  if (arg->ui & TAGMASK) {
    selmon->pertag->prevtag = selmon->pertag->curtag;
    selmon->tagset[selmon->seltags] = arg->ui & TAGMASK;

    if (arg->ui == ~0)
      selmon->pertag->curtag = 0;
    else {
      for (i = 0; !(arg->ui & 1 << i); i++);
      selmon->pertag->curtag = i + 1;
    }
  } else {
    tmptag = selmon->pertag->prevtag;
    selmon->pertag->prevtag = selmon->pertag->curtag;
    selmon->pertag->curtag = tmptag;
  }

  selmon->nmaster = selmon->pertag->nmasters[selmon->pertag->curtag];
  selmon->mfact = selmon->pertag->mfacts[selmon->pertag->curtag];
  selmon->sellt = selmon->pertag->sellts[selmon->pertag->curtag];
  selmon->lt[selmon->sellt] =
    selmon->pertag->ltidxs[selmon->pertag->curtag][selmon->sellt];
  selmon->lt[selmon->sellt ^ 1] =
    selmon->pertag->ltidxs[selmon->pertag->curtag][selmon->sellt ^ 1];

  if (selmon->showbar != selmon->pertag->showbars[selmon->pertag->curtag])
    togglebar(NULL);
  focus(NULL);
  arrange(selmon);
  updatecurrentdesktop();
}

/**
 * @brief Find a managed client by its X window.
 *
 * @param w          Window to look up.
 * @return Matching client, or NULL if the window is not managed.
 */
Client* wintoclient(Window w) {
  Client* c;
  Monitor* m;

  for (m = mons; m; m = m->next)
    for (c = m->clients; c; c = c->next)
      if (c->win == w) return c;
  return NULL;
}

/**
 * @brief Find a systray icon by its X window.
 *
 * @param w          Window to look up.
 * @return Matching icon, or NULL if the window is not an icon.
 */
Client* wintosystrayicon(Window w) {
  Client* i = NULL;

  if (!showsystray || !w) return i;
  for (i = systray->icons; i && i->win != w; i = i->next);
  return i;
}

/**
 * @brief Find the monitor that owns a window.
 *
 * @param w          Window to look up.
 * @return Owning monitor, defaulting to the selected monitor.
 */
Monitor* wintomon(Window w) {
  int x, y;
  Client* c;
  Monitor* m;

  if (w == root && getrootptr(&x, &y)) return recttomon(x, y, 1, 1);
  for (m = mons; m; m = m->next)
    if (w == m->barwin || w == m->tabwin) return m;
  if ((c = wintoclient(w))) return c->mon;
  return selmon;
}

/* There's no way to check accesses to destroyed windows, thus those cases are
 * ignored (especially on UnmapNotify's). Other types of errors call Xlibs
 * default error handler, which may call exit. */
/**
 * @brief Tolerate expected X errors and forward fatal ones to Xlib.
 *
 * @param dpy        Display connection.
 * @param ee         X error event.
 * @return Zero for ignored errors; otherwise the original handler's result.
 */
int xerror(Display* dpy, XErrorEvent* ee) {
  if (ee->error_code == BadWindow ||
      (ee->request_code == X_SetInputFocus && ee->error_code == BadMatch) ||
      (ee->request_code == X_PolyText8 && ee->error_code == BadDrawable) ||
      (ee->request_code == X_PolyFillRectangle &&
       ee->error_code == BadDrawable) ||
      (ee->request_code == X_PolySegment && ee->error_code == BadDrawable) ||
      (ee->request_code == X_ConfigureWindow && ee->error_code == BadMatch) ||
      (ee->request_code == X_GrabButton && ee->error_code == BadAccess) ||
      (ee->request_code == X_GrabKey && ee->error_code == BadAccess) ||
      (ee->request_code == X_CopyArea && ee->error_code == BadDrawable))
    return 0;
  fprintf(stderr, "dwm: fatal error: request code=%d, error code=%d\n",
          ee->request_code, ee->error_code);
  return xerrorxlib(dpy, ee); /* may call exit */
}

/**
 * @brief Ignore an X error while performing an operation known to race.
 *
 * @param dpy        Display connection.
 * @param ee         Ignored X error event.
 * @return Always zero.
 */
int xerrordummy(Display* dpy, XErrorEvent* ee) { return 0; }

/* Startup Error handler to check if another window manager
 * is already running. */
/**
 * @brief Startup error handler used to detect another running window manager.
 *
 * @param dpy        Display connection.
 * @param ee         X error event.
 * @return Never returns.
 */
int xerrorstart(Display* dpy, XErrorEvent* ee) {
  die("dwm: another window manager is already running");
  return -1;
}

/**
 * @brief Determine which monitor hosts the systray.
 *
 * @param m          Monitor to test, or NULL for the default selection.
 * @return Host monitor, or NULL when the systray is not shown there.
 */
Monitor* systraytomon(Monitor* m) {
  Monitor* t;
  int i, n;
  if (!systraypinning) {
    if (!m) return selmon;
    return m == selmon ? m : NULL;
  }
  for (n = 1, t = mons; t && t->next; n++, t = t->next);
  for (i = 1, t = mons; t && t->next && i < systraypinning; i++, t = t->next);
  if (systraypinningfailfirst && n < systraypinning) return mons;
  return t;
}

/**
 * @brief Promote the selected client to the master area.
 *
 * @param arg        Unused key binding argument.
 */
void zoom(const Arg* arg) {
  Client* c = selmon->sel;

  if (!selmon->lt[selmon->sellt]->arrange || !c || c->isfloating) return;
  if (c == nexttiled(selmon->clients) && !(c = nexttiled(c->next))) return;
  pop(c);
}

/**
 * @brief Program entry point: parse arguments and start the window manager.
 *
 * @param argc       Argument count.
 * @param argv       Argument vector.
 * @return EXIT_SUCCESS on a clean shutdown.
 */
int main(int argc, char* argv[]) {
  if (argc == 2 && !strcmp("-v", argv[1]))
    die("dwm-" VERSION);
  else if (argc != 1 && strcmp("-s", argv[1]))
    die("usage: dwm [-v]");
  if (!setlocale(LC_CTYPE, "") || !XSupportsLocale())
    fputs("warning: no locale support\n", stderr);
  if (!(dpy = XOpenDisplay(NULL))) die("dwm: cannot open display");
  if (argc > 1 && !strcmp("-s", argv[1])) {
    XStoreName(dpy, RootWindow(dpy, DefaultScreen(dpy)), argv[2]);
    XCloseDisplay(dpy);
    return 0;
  }
  checkotherwm();
  setup();
#ifdef __OpenBSD__
  if (pledge("stdio rpath proc exec", NULL) == -1) die("pledge");
#endif /* __OpenBSD__ */
  scan();
  run();
  cleanup();
  XCloseDisplay(dpy);
  return EXIT_SUCCESS;
}
