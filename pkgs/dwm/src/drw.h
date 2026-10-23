/**
 * @file drw.h
 * @brief Public drawing abstraction used by dwm.
 */

/** @brief A loaded mouse cursor. */
typedef struct {
  Cursor cursor; /**< X cursor handle. */
} Cur;

/** @brief A loaded font and the fontconfig pattern it was created from. */
typedef struct Fnt {
  Display* dpy;       /**< X display connection. */
  unsigned int h;     /**< Font height, ascent plus descent. */
  XftFont* xfont;     /**< Xft font handle. */
  FcPattern* pattern; /**< Fontconfig pattern, if loaded by name. */
  struct Fnt* next;   /**< Next fallback font in the set. */
} Fnt;

/** @brief Colour scheme indices. */
enum { ColFg, ColBg, ColBorder };
typedef XftColor Clr; /**< An allocated colour. */

/** @brief Off-screen drawable and its drawing state. */
typedef struct {
  unsigned int w, h; /**< Drawable dimensions. */
  Display* dpy;      /**< X display connection. */
  int screen;        /**< X screen number. */
  Window root;       /**< Root window of the screen. */
  Drawable drawable; /**< Off-screen pixmap. */
  Picture picture;   /**< Render picture for the pixmap. */
  Pixmap bgmap;      /**< Background pixmap. */
  GC gc;             /**< Graphics context. */
  Clr* scheme;       /**< Active colour scheme. */
  Fnt* fonts;        /**< Active font set. */
} Drw;

/**
 * @name Drawable abstraction
 * @{
 */
Drw* drw_create(Display* dpy, int screen, Window win, unsigned int w,
                unsigned int h);
void drw_resize(Drw* drw, unsigned int w, unsigned int h);
void drw_free(Drw* drw);
/** @} */

/**
 * @name Font abstraction
 * @{
 */
Fnt* drw_fontset_create(Drw* drw, const char* fonts[], size_t fontcount);
void drw_fontset_free(Fnt* set);
unsigned int drw_fontset_getwidth(Drw* drw, const char* text);
unsigned int drw_fontset_getwidth_clamp(Drw* drw, const char* text,
                                        unsigned int n);
void drw_font_getexts(Fnt* font, const char* text, unsigned int len,
                      unsigned int* w, unsigned int* h);
/** @} */

/**
 * @name Colour scheme abstraction
 * @{
 */
void drw_clr_create(Drw* drw, Clr* dest, const char* clrname);
Clr* drw_scm_create(Drw* drw, const char* clrnames[], size_t clrcount);
/** @} */

/**
 * @name Cursor abstraction
 * @{
 */
Cur* drw_cur_create(Drw* drw, int shape);
void drw_cur_free(Drw* drw, Cur* cursor);
/** @} */

/**
 * @name Drawing context manipulation
 * @{
 */
void drw_setfontset(Drw* drw, Fnt* set);
void drw_setscheme(Drw* drw, Clr* scm);
/** @} */

/**
 * @name Picture abstraction
 * @{
 */
Picture drw_picture_create_resized(Drw* drw, char* src, unsigned int src_w,
                                   unsigned int src_h, unsigned int dst_w,
                                   unsigned int dst_h);
/** @} */

/**
 * @name Drawing functions
 * @{
 */
void drw_rect(Drw* drw, int x, int y, unsigned int w, unsigned int h,
              int filled, int invert);
int drw_text(Drw* drw, int x, int y, unsigned int w, unsigned int h,
             unsigned int lpad, const char* text, int invert);
void drw_pic(Drw* drw, int x, int y, unsigned int w, unsigned int h,
             Picture pic);
/** @} */

/**
 * @name Map functions
 * @{
 */
void drw_map(Drw* drw, Window win, int x, int y, unsigned int w,
             unsigned int h);
/** @} */
