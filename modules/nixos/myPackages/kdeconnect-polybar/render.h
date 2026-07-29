#ifndef RENDER_H
#define RENDER_H

#include <X11/Xlib.h>

/* Per-device bookkeeping so the daemon can detect *transitions*
 * (newly connected, newly disconnected, battery just crossed the low
 * threshold, a pairing request just appeared) instead of re-acting on
 * every single render. */
typedef struct {
    char *id;
    int notified_pairing;
    int known;             /* have we seen this device before this run? */
    int was_reachable;
    int was_trusted;
    int was_low_battery;
} TrackedDevice;

typedef struct {
    TrackedDevice *devices;
    int count;
    Display *dpy;           /* used to pop the pairing-request menu; may be NULL to skip that (e.g. plain -d dump) */
    const char *self_exe;   /* embedded into click-handler commands   */
    int show_battery;       /* print numeric battery % next to the icon */
} RenderState;

void render_state_init(RenderState *state, Display *dpy, const char *self_exe, int show_battery);
void render_state_free(RenderState *state);

/* Builds the polybar module text for current device state (caller
 * frees the returned string with free()). As a side effect, may fire
 * desktop notifications (config.h toggles) and/or pop the incoming
 * pairing-request menu, based on transitions since the last call. */
char *render_module(RenderState *state);

/* Same underlying device data, formatted as a JSON array instead of
 * polybar markup -- one object per device with id/name/type/
 * reachable/paired/battery/low_battery/signal_bars/state/icon. Shares
 * the same transition-tracking `state` and the same side effects
 * (notifications, pairing prompt) as render_module(). Caller frees
 * the returned string. */
char *render_module_json(RenderState *state);

#endif /* RENDER_H */
