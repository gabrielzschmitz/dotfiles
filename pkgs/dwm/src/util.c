/**
 * @file util.c
 * @brief Small allocation and fatal-error helpers.
 */
// clang-format off
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "util.h"
// clang-format on

/**
 * @brief Print an error message and terminate the process.
 *
 * @param fmt        printf(3)-style format string.
 * @param ...        Format arguments.
 *
 * @note This function does not return.
 */
void die(const char* fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);

  if (fmt[0] && fmt[strlen(fmt) - 1] == ':') {
    fputc(' ', stderr);
    perror(NULL);
  } else {
    fputc('\n', stderr);
  }

  exit(1);
}

/**
 * @brief Allocate zeroed memory and abort on failure.
 *
 * @param nmemb      Number of elements.
 * @param size       Size of each element.
 * @return Pointer to the allocated memory.
 */
void* ecalloc(size_t nmemb, size_t size) {
  void* p;

  if (!(p = calloc(nmemb, size))) die("calloc:");
  return p;
}
