#ifndef MISC_HH
#define MISC_HH

#pragma GCC diagnostic ignored "-Winvalid-offsetof"

#include <stdlib.h>

typedef unsigned char uchar;
typedef unsigned int uint;
typedef unsigned short ushort;
typedef unsigned long ulong;

template <typename T> inline T * malloc(size_t s) { return static_cast<T *>(malloc(s * sizeof(T))); }
template <typename T> inline T * calloc(size_t s) { return static_cast<T *>(calloc(s, sizeof(T))); }
template <typename T> inline T * realloc(void * p, size_t s) { return static_cast<T *>(realloc(p, s * sizeof(T))); }

inline void * operator new(size_t, void * p) { return p; }

#define mnew(T, ...) (new (malloc(sizeof(T))) T(__VA_ARGS__))
#define mdelete(T, p) do { (p)->~T(); free(p); } while (false)

extern bool str_eq(const char *, const char *);
extern bool to_int(const char *, int *);
extern bool to_uint(const char *, uint *);

inline const uchar * str_cast(const char * s) { return reinterpret_cast<const uchar *>(s); }
inline uchar * str_cast(char * s) { return reinterpret_cast<uchar *>(s); }

template <typename T> T div2(T v) = delete;
inline int div2(int v) { return v >> 1; }

#endif
