#ifndef RENDER_H
#define RENDER_H

#include "device.h"
#include "mtp.h"

/* Prints the full polybar module string (one segment per device --
 * disks first, then phones -- joined by SEPARATOR, honoring every
 * BAR_SHOW_* toggle in config.h) to stdout, newline-terminated.
 * `mtp_list` may be NULL if MTP support isn't available this run. */
void render_bar(const DeviceList *list, const MtpDeviceList *mtp_list);

/* Prints a JSON array (one object per device/phone, disambiguated by
 * a "kind" field) to stdout. Schema is documented in README.md. */
void render_json(const DeviceList *list, const MtpDeviceList *mtp_list);

/* Returns the absolute path to this running binary (cached after the
 * first call), used to resolve the {SELF} placeholder in click
 * actions and custom menu entries. Falls back to argv0 if
 * /proc/self/exe can't be read (e.g. non-Linux -- not expected here,
 * but cheap to guard). */
const char *render_self_path(const char *argv0);

/* Substitutes {SELF} {ID} {NODE} {NAME} {MOUNTPOINT} in `tmpl`.
 * `d` may be NULL (fields substitute to empty strings) -- used for
 * the no-device-icon click actions. render_substitute() shell-quotes
 * every substituted value (for polybar %{A...:cmd:} strings, which
 * polybar runs through the shell); render_substitute_raw() does not
 * (for building an execvp() argv where no shell is involved, e.g.
 * custom menu entries and the file manager launcher). */
void render_substitute(const char *tmpl, const Device *d, char *out, size_t outlen);
void render_substitute_raw(const char *tmpl, const Device *d, char *out, size_t outlen);

#endif /* RENDER_H */
