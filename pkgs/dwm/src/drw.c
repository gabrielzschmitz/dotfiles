/**
 * @file drw.c
 * @brief Drawing primitives for bars, tabs and text.
 *
 * Provides the drawable, font, colour and cursor abstractions used by the
 * window manager to compose the bar off-screen before copying it to screen.
 */
// clang-format off
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <Imlib2.h>

#include "drw.h"
#include "util.h"
// clang-format on

#define UTF_INVALID 0xFFFD
#define UTF_SIZ 4

static const unsigned char utfbyte[UTF_SIZ + 1] = {0x80, 0, 0xC0, 0xE0, 0xF0};
static const unsigned char utfmask[UTF_SIZ + 1] = {0xC0, 0x80, 0xE0, 0xF0,
                                                   0xF8};
static const long utfmin[UTF_SIZ + 1] = {0, 0, 0x80, 0x800, 0x10000};
static const long utfmax[UTF_SIZ + 1] = {0x10FFFF, 0x7F, 0x7FF, 0xFFFF,
                                         0x10FFFF};

/**
 * @brief Decode one byte of a UTF-8 sequence.
 *
 * @param c          Byte to decode.
 * @param i          Receives the sequence length.
 * @return Decoded payload bits.
 */
static long utf8decodebyte(const char c, size_t* i) {
  for (*i = 0; *i < (UTF_SIZ + 1); ++(*i))
    if (((unsigned char)c & utfmask[*i]) == utfbyte[*i])
      return (unsigned char)c & ~utfmask[*i];
  return 0;
}

/**
 * @brief Validate a decoded code point and replace invalid values.
 *
 * @param u          Code point to validate, updated in place.
 * @param i          Length of the encoded sequence.
 * @return Number of bytes in the code point.
 */
static size_t utf8validate(long* u, size_t i) {
  if (!BETWEEN(*u, utfmin[i], utfmax[i]) || BETWEEN(*u, 0xD800, 0xDFFF))
    *u = UTF_INVALID;
  for (i = 1; *u > utfmax[i]; ++i);
  return i;
}

/**
 * @brief Decode a UTF-8 code point from a byte buffer.
 *
 * @param c          Input buffer.
 * @param u          Receives the decoded code point.
 * @param clen       Number of available bytes.
 * @return Number of bytes consumed.
 */
static size_t utf8decode(const char* c, long* u, size_t clen) {
  size_t i, j, len, type;
  long udecoded;

  *u = UTF_INVALID;
  if (!clen) return 0;
  udecoded = utf8decodebyte(c[0], &len);
  if (!BETWEEN(len, 1, UTF_SIZ)) return 1;
  for (i = 1, j = 1; i < clen && j < len; ++i, ++j) {
    udecoded = (udecoded << 6) | utf8decodebyte(c[i], &type);
    if (type) return j;
  }
  if (j < len) return 0;
  *u = udecoded;
  utf8validate(u, len);

  return len;
}

/**
 * @brief Create a drawing context backed by an off-screen pixmap.
 *
 * @param dpy        X display connection.
 * @param screen     X screen number.
 * @param root       Root window of the screen.
 * @param w          Initial width.
 * @param h          Initial height.
 * @return Newly allocated drawing context.
 */
Drw* drw_create(Display* dpy, int screen, Window root, unsigned int w,
                unsigned int h) {
  Drw* drw = ecalloc(1, sizeof(Drw));

  drw->dpy = dpy;
  drw->screen = screen;
  drw->root = root;
  drw->w = w;
  drw->h = h;
  drw->drawable = XCreatePixmap(dpy, root, w, h, DefaultDepth(dpy, screen));
  drw->picture = XRenderCreatePicture(
    dpy, drw->drawable,
    XRenderFindVisualFormat(dpy, DefaultVisual(dpy, screen)), 0, NULL);
  drw->gc = XCreateGC(dpy, root, 0, NULL);
  XSetLineAttributes(dpy, drw->gc, 1, LineSolid, CapButt, JoinMiter);

  return drw;
}

/**
 * @brief Resize the pixmap and picture used by a drawing context.
 *
 * @param drw        Drawing context.
 * @param w          New width.
 * @param h          New height.
 */
void drw_resize(Drw* drw, unsigned int w, unsigned int h) {
  if (!drw) return;

  drw->w = w;
  drw->h = h;
  if (drw->picture) XRenderFreePicture(drw->dpy, drw->picture);
  if (drw->drawable) XFreePixmap(drw->dpy, drw->drawable);
  drw->drawable = XCreatePixmap(drw->dpy, drw->root, w, h,
                                DefaultDepth(drw->dpy, drw->screen));
  drw->picture = XRenderCreatePicture(
    drw->dpy, drw->drawable,
    XRenderFindVisualFormat(drw->dpy, DefaultVisual(drw->dpy, drw->screen)), 0,
    NULL);
}

/**
 * @brief Free a drawing context and all of its resources.
 *
 * @param drw        Drawing context to free.
 */
void drw_free(Drw* drw) {
  XRenderFreePicture(drw->dpy, drw->picture);
  XFreePixmap(drw->dpy, drw->drawable);
  XFreeGC(drw->dpy, drw->gc);
  drw_fontset_free(drw->fonts);
  free(drw);
}

/**
 * @brief Load a font by name or fontconfig pattern.
 *
 * @param drw        Drawing context.
 * @param fontname   Font name, or NULL.
 * @param fontpattern Fontconfig pattern, or NULL.
 * @return Loaded font, or NULL on failure.
 *
 * @note This is an implementation detail; use drw_fontset_create() instead.
 */
static Fnt* xfont_create(Drw* drw, const char* fontname,
                         FcPattern* fontpattern) {
  Fnt* font;
  XftFont* xfont = NULL;
  FcPattern* pattern = NULL;

  if (fontname) {
    /* Using the pattern found at font->xfont->pattern does not yield the
		 * same substitution results as using the pattern returned by
		 * FcNameParse; using the latter results in the desired fallback
		 * behaviour whereas the former just results in missing-character
		 * rectangles being drawn, at least with some fonts. */
    if (!(xfont = XftFontOpenName(drw->dpy, drw->screen, fontname))) {
      fprintf(stderr, "error, cannot load font from name: '%s'\n", fontname);
      return NULL;
    }
    if (!(pattern = FcNameParse((FcChar8*)fontname))) {
      fprintf(stderr, "error, cannot parse font name to pattern: '%s'\n",
              fontname);
      XftFontClose(drw->dpy, xfont);
      return NULL;
    }
  } else if (fontpattern) {
    if (!(xfont = XftFontOpenPattern(drw->dpy, fontpattern))) {
      fprintf(stderr, "error, cannot load font from pattern.\n");
      return NULL;
    }
  } else {
    die("no font specified.");
  }

  font = ecalloc(1, sizeof(Fnt));
  font->xfont = xfont;
  font->pattern = pattern;
  font->h = xfont->ascent + xfont->descent;
  font->dpy = drw->dpy;

  return font;
}

/**
 * @brief Free a single loaded font.
 *
 * @param font       Font to free.
 */
static void xfont_free(Fnt* font) {
  if (!font) return;
  if (font->pattern) FcPatternDestroy(font->pattern);
  XftFontClose(font->dpy, font->xfont);
  free(font);
}

/**
 * @brief Create a font set from an ordered list of font names.
 *
 * @param drw        Drawing context.
 * @param fonts      Array of font names.
 * @param fontcount  Number of names in the array.
 * @return Font set, or NULL on failure.
 */
Fnt* drw_fontset_create(Drw* drw, const char* fonts[], size_t fontcount) {
  Fnt *cur, *ret = NULL;
  size_t i;

  if (!drw || !fonts) return NULL;

  for (i = 1; i <= fontcount; i++) {
    if ((cur = xfont_create(drw, fonts[fontcount - i], NULL))) {
      cur->next = ret;
      ret = cur;
    }
  }
  return (drw->fonts = ret);
}

/**
 * @brief Free a font set, including all fallback fonts.
 *
 * @param font       First font in the set.
 */
void drw_fontset_free(Fnt* font) {
  if (font) {
    drw_fontset_free(font->next);
    xfont_free(font);
  }
}

/**
 * @brief Allocate a colour from its X colour name.
 *
 * @param drw        Drawing context.
 * @param dest       Destination colour.
 * @param clrname    X colour name.
 */
void drw_clr_create(Drw* drw, Clr* dest, const char* clrname) {
  if (!drw || !dest || !clrname) return;

  if (!XftColorAllocName(drw->dpy, DefaultVisual(drw->dpy, drw->screen),
                         DefaultColormap(drw->dpy, drw->screen), clrname, dest))
    die("error, cannot allocate color '%s'", clrname);

  dest->pixel |= 0xff << 24;
}

/**
 * @brief Allocate a colour scheme from an array of colour names.
 *
 * @param drw        Drawing context.
 * @param clrnames   Array of colour names.
 * @param clrcount   Number of colours.
 * @return Allocated colour scheme, or NULL on failure.
 *
 * @note The caller must free the returned scheme with free(3).
 */
Clr* drw_scm_create(Drw* drw, const char* clrnames[], size_t clrcount) {
  size_t i;
  Clr* ret;

  /* need at least two colors for a scheme */
  if (!drw || !clrnames || clrcount < 2 ||
      !(ret = ecalloc(clrcount, sizeof(XftColor))))
    return NULL;

  for (i = 0; i < clrcount; i++) drw_clr_create(drw, &ret[i], clrnames[i]);
  return ret;
}

/**
 * @brief Select the font set used by a drawing context.
 *
 * @param drw        Drawing context.
 * @param set        Font set to use.
 */
void drw_setfontset(Drw* drw, Fnt* set) {
  if (drw) drw->fonts = set;
}

/**
 * @brief Select the colour scheme used by a drawing context.
 *
 * @param drw        Drawing context.
 * @param scm        Colour scheme to use.
 */
void drw_setscheme(Drw* drw, Clr* scm) {
  if (drw) drw->scheme = scm;
}

/**
 * @brief Create a scaled ARGB picture from raw pixel data.
 *
 * @param drw        Drawing context.
 * @param src        Source ARGB pixels.
 * @param srcw       Source width.
 * @param srch       Source height.
 * @param dstw       Destination width.
 * @param dsth       Destination height.
 * @return Scaled picture, or None on failure.
 */
Picture drw_picture_create_resized(Drw* drw, char* src, unsigned int srcw,
                                   unsigned int srch, unsigned int dstw,
                                   unsigned int dsth) {
  Pixmap pm;
  Picture pic;
  GC gc;

  if (srcw <= (dstw << 1u) && srch <= (dsth << 1u)) {
    XImage img = {srcw,
                  srch,
                  0,
                  ZPixmap,
                  src,
                  ImageByteOrder(drw->dpy),
                  BitmapUnit(drw->dpy),
                  BitmapBitOrder(drw->dpy),
                  32,
                  32,
                  0,
                  32,
                  0,
                  0,
                  0};
    XInitImage(&img);

    pm = XCreatePixmap(drw->dpy, drw->root, srcw, srch, 32);
    gc = XCreateGC(drw->dpy, pm, 0, NULL);
    XPutImage(drw->dpy, pm, gc, &img, 0, 0, 0, 0, srcw, srch);
    XFreeGC(drw->dpy, gc);

    pic = XRenderCreatePicture(
      drw->dpy, pm, XRenderFindStandardFormat(drw->dpy, PictStandardARGB32), 0,
      NULL);
    XFreePixmap(drw->dpy, pm);

    XRenderSetPictureFilter(drw->dpy, pic, FilterBilinear, NULL, 0);
    XTransform xf;
    xf.matrix[0][0] = (srcw << 16u) / dstw;
    xf.matrix[0][1] = 0;
    xf.matrix[0][2] = 0;
    xf.matrix[1][0] = 0;
    xf.matrix[1][1] = (srch << 16u) / dsth;
    xf.matrix[1][2] = 0;
    xf.matrix[2][0] = 0;
    xf.matrix[2][1] = 0;
    xf.matrix[2][2] = 65536;
    XRenderSetPictureTransform(drw->dpy, pic, &xf);
  } else {
    Imlib_Image origin =
      imlib_create_image_using_data(srcw, srch, (DATA32*)src);
    if (!origin) return None;
    imlib_context_set_image(origin);
    imlib_image_set_has_alpha(1);
    Imlib_Image scaled =
      imlib_create_cropped_scaled_image(0, 0, srcw, srch, dstw, dsth);
    imlib_free_image_and_decache();
    if (!scaled) return None;
    imlib_context_set_image(scaled);
    imlib_image_set_has_alpha(1);

    XImage img = {dstw,
                  dsth,
                  0,
                  ZPixmap,
                  (char*)imlib_image_get_data_for_reading_only(),
                  ImageByteOrder(drw->dpy),
                  BitmapUnit(drw->dpy),
                  BitmapBitOrder(drw->dpy),
                  32,
                  32,
                  0,
                  32,
                  0,
                  0,
                  0};
    XInitImage(&img);

    pm = XCreatePixmap(drw->dpy, drw->root, dstw, dsth, 32);
    gc = XCreateGC(drw->dpy, pm, 0, NULL);
    XPutImage(drw->dpy, pm, gc, &img, 0, 0, 0, 0, dstw, dsth);
    imlib_free_image_and_decache();
    XFreeGC(drw->dpy, gc);

    pic = XRenderCreatePicture(
      drw->dpy, pm, XRenderFindStandardFormat(drw->dpy, PictStandardARGB32), 0,
      NULL);
    XFreePixmap(drw->dpy, pm);
  }

  return pic;
}

/**
 * @brief Draw a filled or outlined rectangle in the current colour.
 *
 * @param drw        Drawing context.
 * @param x          Rectangle x coordinate.
 * @param y          Rectangle y coordinate.
 * @param w          Rectangle width.
 * @param h          Rectangle height.
 * @param filled     Non-zero to fill the rectangle.
 * @param invert     Non-zero to use the background colour.
 */
void drw_rect(Drw* drw, int x, int y, unsigned int w, unsigned int h,
              int filled, int invert) {
  if (!drw || !drw->scheme) return;
  XSetForeground(drw->dpy, drw->gc,
                 invert ? drw->scheme[ColBg].pixel : drw->scheme[ColFg].pixel);
  if (filled)
    XFillRectangle(drw->dpy, drw->drawable, drw->gc, x, y, w, h);
  else
    XDrawRectangle(drw->dpy, drw->drawable, drw->gc, x, y, w - 1, h - 1);
}

/**
 * @brief Draw UTF-8 text with font fallback and ellipsis handling.
 *
 * @param drw        Drawing context.
 * @param x          Text x coordinate.
 * @param y          Text y coordinate.
 * @param w          Available width.
 * @param h          Available height.
 * @param lpad       Left padding.
 * @param text       Text to draw.
 * @param invert     Non-zero to invert colours.
 * @return Right edge of the drawn text, or its measured width when not
 *         rendering.
 */
int drw_text(Drw* drw, int x, int y, unsigned int w, unsigned int h,
             unsigned int lpad, const char* text, int invert) {
  int i, ty, ellipsis_x = 0;
  unsigned int tmpw, ew, ellipsis_w = 0, ellipsis_len;
  XftDraw* d = NULL;
  Fnt *usedfont, *curfont, *nextfont;
  int utf8strlen, utf8charlen, render = x || y || w || h;
  long utf8codepoint = 0;
  const char* utf8str;
  FcCharSet* fccharset;
  FcPattern* fcpattern;
  FcPattern* match;
  XftResult result;
  int charexists = 0, overflow = 0;
  /* keep track of a couple codepoints for which we have no match. */
  enum { nomatches_len = 64 };
  static struct {
    long codepoint[nomatches_len];
    unsigned int idx;
  } nomatches;
  static unsigned int ellipsis_width = 0;

  if (!drw || (render && (!drw->scheme || !w)) || !text || !drw->fonts)
    return 0;

  if (!render) {
    w = invert ? invert : ~invert;
  } else {
    XSetForeground(drw->dpy, drw->gc,
                   drw->scheme[invert ? ColFg : ColBg].pixel);
    XFillRectangle(drw->dpy, drw->drawable, drw->gc, x, y, w, h);
    d = XftDrawCreate(drw->dpy, drw->drawable,
                      DefaultVisual(drw->dpy, drw->screen),
                      DefaultColormap(drw->dpy, drw->screen));
    x += lpad;
    w -= lpad;
  }

  usedfont = drw->fonts;
  if (!ellipsis_width && render)
    ellipsis_width = drw_fontset_getwidth(drw, "...");
  while (1) {
    ew = ellipsis_len = utf8strlen = 0;
    utf8str = text;
    nextfont = NULL;
    while (*text) {
      utf8charlen = utf8decode(text, &utf8codepoint, UTF_SIZ);
      for (curfont = drw->fonts; curfont; curfont = curfont->next) {
        charexists =
          charexists || XftCharExists(drw->dpy, curfont->xfont, utf8codepoint);
        if (charexists) {
          drw_font_getexts(curfont, text, utf8charlen, &tmpw, NULL);
          if (ew + ellipsis_width <= w) {
            /* keep track where the ellipsis still fits */
            ellipsis_x = x + ew;
            ellipsis_w = w - ew;
            ellipsis_len = utf8strlen;
          }

          if (ew + tmpw > w) {
            overflow = 1;
            /* called from drw_fontset_getwidth_clamp():
						 * it wants the width AFTER the overflow
						 */
            if (!render)
              x += tmpw;
            else
              utf8strlen = ellipsis_len;
          } else if (curfont == usedfont) {
            utf8strlen += utf8charlen;
            text += utf8charlen;
            ew += tmpw;
          } else {
            nextfont = curfont;
          }
          break;
        }
      }

      if (overflow || !charexists || nextfont)
        break;
      else
        charexists = 0;
    }

    if (utf8strlen) {
      if (render) {
        ty = y + (h - usedfont->h) / 2 + usedfont->xfont->ascent;
        XftDrawStringUtf8(d, &drw->scheme[invert ? ColBg : ColFg],
                          usedfont->xfont, x, ty, (XftChar8*)utf8str,
                          utf8strlen);
      }
      x += ew;
      w -= ew;
    }
    if (render && overflow)
      drw_text(drw, ellipsis_x, y, ellipsis_w, h, 0, "...", invert);

    if (!*text || overflow) {
      break;
    } else if (nextfont) {
      charexists = 0;
      usedfont = nextfont;
    } else {
      /* Regardless of whether or not a fallback font is found, the
			 * character must be drawn. */
      charexists = 1;

      for (i = 0; i < nomatches_len; ++i) {
        /* avoid calling XftFontMatch if we know we won't find a match */
        if (utf8codepoint == nomatches.codepoint[i]) goto no_match;
      }

      fccharset = FcCharSetCreate();
      FcCharSetAddChar(fccharset, utf8codepoint);

      if (!drw->fonts->pattern) {
        /* Refer to the comment in xfont_create for more information. */
        die("the first font in the cache must be loaded from a font string.");
      }

      fcpattern = FcPatternDuplicate(drw->fonts->pattern);
      FcPatternAddCharSet(fcpattern, FC_CHARSET, fccharset);
      FcPatternAddBool(fcpattern, FC_SCALABLE, FcTrue);

      FcConfigSubstitute(NULL, fcpattern, FcMatchPattern);
      FcDefaultSubstitute(fcpattern);
      match = XftFontMatch(drw->dpy, drw->screen, fcpattern, &result);

      FcCharSetDestroy(fccharset);
      FcPatternDestroy(fcpattern);

      if (match) {
        usedfont = xfont_create(drw, NULL, match);
        if (usedfont &&
            XftCharExists(drw->dpy, usedfont->xfont, utf8codepoint)) {
          for (curfont = drw->fonts; curfont->next; curfont = curfont->next);
          curfont->next = usedfont;
        } else {
          xfont_free(usedfont);
          nomatches.codepoint[++nomatches.idx % nomatches_len] = utf8codepoint;
        no_match:
          usedfont = drw->fonts;
        }
      }
    }
  }
  if (d) XftDrawDestroy(d);

  return x + (render ? w : 0);
}

/**
 * @brief Composite a picture onto the drawing context.
 *
 * @param drw        Drawing context.
 * @param x          Destination x coordinate.
 * @param y          Destination y coordinate.
 * @param w          Destination width.
 * @param h          Destination height.
 * @param pic        Picture to composite.
 */
void drw_pic(Drw* drw, int x, int y, unsigned int w, unsigned int h,
             Picture pic) {
  if (!drw) return;
  XRenderComposite(drw->dpy, PictOpOver, pic, None, drw->picture, 0, 0, 0, 0, x,
                   y, w, h);
}

/**
 * @brief Copy the drawing context to a window and flush the connection.
 *
 * @param drw        Drawing context.
 * @param win        Destination window.
 * @param x          Source x coordinate.
 * @param y          Source y coordinate.
 * @param w          Width to copy.
 * @param h          Height to copy.
 */
void drw_map(Drw* drw, Window win, int x, int y, unsigned int w,
             unsigned int h) {
  if (!drw) return;

  XCopyArea(drw->dpy, drw->drawable, win, drw->gc, x, y, w, h, x, y);
  XSync(drw->dpy, False);
}

/**
 * @brief Measure the rendered width of a string.
 *
 * @param drw        Drawing context.
 * @param text       Text to measure.
 * @return Width in pixels.
 */
unsigned int drw_fontset_getwidth(Drw* drw, const char* text) {
  if (!drw || !drw->fonts || !text) return 0;
  return drw_text(drw, 0, 0, 0, 0, 0, text, 0);
}

/**
 * @brief Measure a string but clamp the result to a maximum width.
 *
 * @param drw        Drawing context.
 * @param text       Text to measure.
 * @param n          Maximum width.
 * @return Width in pixels, at most n.
 */
unsigned int drw_fontset_getwidth_clamp(Drw* drw, const char* text,
                                        unsigned int n) {
  unsigned int tmp = 0;
  if (drw && drw->fonts && text && n)
    tmp = drw_text(drw, 0, 0, 0, 0, 0, text, n);
  return MIN(n, tmp);
}

/**
 * @brief Measure the extents of a UTF-8 string.
 *
 * @param font       Font to measure with.
 * @param text       Text to measure.
 * @param len        Number of bytes to measure.
 * @param w          Receives the width.
 * @param h          Receives the height.
 */
void drw_font_getexts(Fnt* font, const char* text, unsigned int len,
                      unsigned int* w, unsigned int* h) {
  XGlyphInfo ext;

  if (!font || !text) return;

  XftTextExtentsUtf8(font->dpy, font->xfont, (XftChar8*)text, len, &ext);
  if (w) *w = ext.xOff;
  if (h) *h = font->h;
}

/**
 * @brief Create a cursor of the given X cursor shape.
 *
 * @param drw        Drawing context.
 * @param shape      X cursor shape constant.
 * @return Newly allocated cursor, or NULL on failure.
 */
Cur* drw_cur_create(Drw* drw, int shape) {
  Cur* cur;

  if (!drw || !(cur = ecalloc(1, sizeof(Cur)))) return NULL;

  cur->cursor = XCreateFontCursor(drw->dpy, shape);

  return cur;
}

/**
 * @brief Free a cursor created by drw_cur_create().
 *
 * @param drw        Drawing context.
 * @param cursor     Cursor to free.
 */
void drw_cur_free(Drw* drw, Cur* cursor) {
  if (!cursor) return;

  XFreeCursor(drw->dpy, cursor->cursor);
  free(cursor);
}
