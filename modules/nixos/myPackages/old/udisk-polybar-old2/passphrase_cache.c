#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <keyutils.h>

#include "passphrase_cache.h"

static void build_desc(const char *uuid, char *out, size_t outlen) {
    snprintf(out, outlen, "polybar-udisks:luks:%s", uuid);
}

char *passphrase_cache_get(const char *uuid) {
    if (!uuid || !uuid[0]) return NULL;

    char desc[256];
    build_desc(uuid, desc, sizeof(desc));

    key_serial_t key = request_key("user", desc, NULL, KEY_SPEC_SESSION_KEYRING);
    if (key < 0) return NULL; /* nothing cached -- not an error */

    void *buf = NULL;
    long n = keyctl_read_alloc(key, &buf);
    if (n < 0 || !buf) return NULL;

    char *result = malloc((size_t)n + 1);
    if (result) {
        memcpy(result, buf, (size_t)n);
        result[n] = '\0';
    }
    memset(buf, 0, (size_t)n); /* wipe keyutils' own copy before freeing it */
    free(buf);
    return result;
}

void passphrase_cache_set(const char *uuid, const char *passphrase) {
    if (!uuid || !uuid[0] || !passphrase) return;

    char desc[256];
    build_desc(uuid, desc, sizeof(desc));

    /* add_key() on an existing "user" key with the same description
     * replaces its payload -- this is a plain "set", not just a
     * first-time create. */
    add_key("user", desc, passphrase, strlen(passphrase), KEY_SPEC_SESSION_KEYRING);
}

void passphrase_cache_forget(const char *uuid) {
    if (!uuid || !uuid[0]) return;

    char desc[256];
    build_desc(uuid, desc, sizeof(desc));

    key_serial_t key = request_key("user", desc, NULL, KEY_SPEC_SESSION_KEYRING);
    if (key >= 0) keyctl_revoke(key); /* invalidates it immediately, no need to wait for logout */
}

void passphrase_cache_wipe(char *s) {
    if (!s) return;
    volatile char *p = s;
    size_t len = strlen(s);
    for (size_t i = 0; i < len; i++) p[i] = 0;
    free(s);
}
