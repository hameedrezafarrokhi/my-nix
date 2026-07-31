#ifndef XWWW_LASTRUN_H
#define XWWW_LASTRUN_H

/* Writes an executable shell script to $HOME/.xwww-bg containing the exact
 * `xwww` invocation used for this run, with the animation forced to "none"
 * (instant set, no transition) -- exactly like feh's ~/.fehbg, meant to be
 * sourced from .xinitrc/autostart to restore the wallpaper at login without
 * replaying the transition. `image_path` should be the resolved, absolute
 * path actually used (post random-pick). Returns 0 on success. */
int lastrun_save(const char *image_path, const char *scale_mode_name, const char *bg_color_hex);

/* Reads $HOME/.xwww-bg and extracts the image path from it (used by
 * `xwww` with no arguments, and by `--restore`). Returns a malloc'd
 * string, or NULL if the file doesn't exist / has no usable path. */
char *lastrun_get_image(void);

#endif
