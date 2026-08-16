#ifndef PASSPHRASE_CACHE_H
#define PASSPHRASE_CACHE_H

/*
 * passphrase_cache.h
 *
 * LUKS passphrase caching lives ONLY in the kernel's per-UID user
 * keyring (see man 7 keyrings) -- never on disk, never in a config
 * file, never in this process's own memory beyond the moment of the
 * D-Bus call. Scoped to the UID rather than the login session
 * specifically because the session keyring requires PAM
 * (pam_keyinit) to have set one up at login, which not every setup
 * does -- the user keyring needs no such setup and persists for as
 * long as you're logged in (any process/open file under that UID
 * keeps it alive), which survives across the many short-lived
 * one-shot processes this module spawns per menu click (unlike
 * in-process caching, which wouldn't), and needs no IPC to a daemon
 * that might not even be running (works identically under -d/interval
 * mode). Requires libkeyutils (the `keyutils` package).
 */

/* Looks up a cached passphrase for `uuid`. Returns a malloc'd string
 * (caller must overwrite-then-free it -- see passphrase_cache_wipe)
 * or NULL if nothing is cached (or caching is disabled). */
char *passphrase_cache_get(const char *uuid);

/* Caches `passphrase` for `uuid` in the session keyring. No-op if
 * REMEMBER_PASSPHRASE_DEFAULT / the per-device override says not to
 * remember this one. */
void passphrase_cache_set(const char *uuid, const char *passphrase);

/* Explicitly forgets a cached passphrase early (the "Forget
 * Passphrase" menu row), rather than waiting for logout. */
void passphrase_cache_forget(const char *uuid);

/* Zeroes `s` in place before freeing it -- use this instead of a bare
 * free() for any buffer that ever held a passphrase in plaintext. */
void passphrase_cache_wipe(char *s);

#endif /* PASSPHRASE_CACHE_H */
