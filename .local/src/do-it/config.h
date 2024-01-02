/*
//         .             .              .
//         |             |              |           .
// ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,
// | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /
// `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'
//  ,|
//  `'
//  config.h
*/
#ifndef CONFIG_H_
#define CONFIG_H_

/* 1 if you're in WSL, 0 if not
 * Note: you'll need wsl-notify-send
 * for the notifications and the
 * notifications sounds and white noises
 * will not work */
static const int WSL = 0;

/* iconsoff - iconson - nerdicons
 * Note: you'll need a patched
 * nerdicons for that option */
static const char *ICONS = "nerdicons";

/* 1 if you want transparent background, 0 if not
 * Note: you'll need a terminal already transparent */
static const int BGTRANSPARENCY = 1;

#endif
