#ifndef WMCLASS_H
#define WMCLASS_H

/* Opens the X display once. Returns 0 on success. Safe to call even if a
 * pure-console environment has no X (matching functions below just fail
 * gracefully afterwards and rule class/instance/title matching is skipped). */
int wm_init(void);

/* window_id is bspwm's NODE_ID parsed from hex, which is the raw X11 Window. */
int wm_get_class(unsigned long window_id, char *instance_out, int inst_sz, char *class_out, int class_sz);
int wm_get_title(unsigned long window_id, char *title_out, int title_sz);

void wm_shutdown(void);

#endif
