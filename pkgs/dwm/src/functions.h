/**
 * @file functions.h
 * @brief Function declarations shared by the dwm configuration and core.
 */

/**
 * @name Key binding functions
 * @{
 */
static void defaultgaps(const Arg* arg);
static void incrgaps(const Arg* arg);
static void incrigaps(const Arg* arg);
static void incrogaps(const Arg* arg);
static void incrohgaps(const Arg* arg);
static void incrovgaps(const Arg* arg);
static void incrihgaps(const Arg* arg);
static void incrivgaps(const Arg* arg);
static void togglegaps(const Arg* arg);
/** @} */

/**
 * @name Layouts
 * @{
 */
static void bstack(Monitor* m);
static void bstackhoriz(Monitor* m);
static void centeredmaster(Monitor* m);
static void centeredfloatingmaster(Monitor* m);
static void deck(Monitor* m);
static void dwindle(Monitor* m);
static void fibonacci(Monitor* m, int s);
static void gaplessgrid(Monitor* m);
static void grid(Monitor* m);
static void horizgrid(Monitor* m);
static void nrowgrid(Monitor* m);
static void spiral(Monitor* m);
static void tile(Monitor* m);
/** @} */

/**
 * @name Internals
 * @{
 */
static void getgaps(Monitor* m, int* oh, int* ov, int* ih, int* iv,
                    unsigned int* nc);
static void getfacts(Monitor* m, int msize, int ssize, float* mf, float* sf,
                     int* mr, int* sr);
static void setgaps(int oh, int ov, int ih, int iv);
/** @} */

/**
 * @name Commands
 * @{
 */
static void movestack(const Arg* arg);
static void shiftview(const Arg* arg);
/** @} */
