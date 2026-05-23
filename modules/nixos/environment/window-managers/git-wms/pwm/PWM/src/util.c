#include "util.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

void
die(const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
    exit(1);
}

void *
ecalloc(size_t nmemb, size_t size)
{
    void *p;

    if (!(p = calloc(nmemb, size)))
        die("fatal: could not malloc() %zu bytes", nmemb * size);
    return p;
}
