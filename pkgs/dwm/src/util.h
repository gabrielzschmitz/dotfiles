/**
 * @file util.h
 * @brief Common macros and allocation helpers.
 */

/** @brief Return the larger of two values. */
#define MAX(A, B) ((A) > (B) ? (A) : (B))
/** @brief Return the smaller of two values. */
#define MIN(A, B) ((A) < (B) ? (A) : (B))
/** @brief Test whether X lies between A and B, inclusive. */
#define BETWEEN(X, A, B) ((A) <= (X) && (X) <= (B))

/**
 * @brief Print an error message and terminate the process.
 *
 * @param fmt        printf(3)-style format string.
 * @param ...        Format arguments.
 */
void die(const char* fmt, ...);

/**
 * @brief Allocate zeroed memory and abort on failure.
 *
 * @param nmemb      Number of elements.
 * @param size       Size of each element.
 * @return Pointer to the allocated memory.
 */
void* ecalloc(size_t nmemb, size_t size);
