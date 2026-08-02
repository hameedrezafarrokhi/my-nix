#ifndef COUNTDOWN_XAPP_H
#define COUNTDOWN_XAPP_H

#include "common.h"

/* Runs the whole app: creates the window, enters the event loop, and only
 * returns on exit. Returns the process exit code (0 normally, 1 if the
 * user dismissed via right-click, matching common CLI "cancel" conventions). */
int xapp_run(config_t *cfg);

#endif
