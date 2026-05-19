#include "misc.hh"

static char to_lower(char c)
{
	if (c < 'A' || c > 'Z')
		return c;
	return c + ('a' - 'A');
}

bool str_eq(const char * s1, const char * s2)
{
	for (size_t n = 0;; n++)
	{
		if (to_lower(s1[n]) != to_lower(s2[n])) break;
		if (!s1[n]) return true;
	}
	return false;
}

bool to_int(const char * str, int * ret)
{
	char * end;
	long l = strtol(str, &end, 0);
	if (l < -32768 || l > 32767) return false;
	if (*end) return false;
	*ret = l;
	return true;
}

bool to_uint(const char * str, uint * ret)
{
	char * end;
	long l = strtol(str, &end, 0);
	if (l < 0 || l > 65535) return false;
	if (*end) return false;
	*ret = l;
	return true;
}
