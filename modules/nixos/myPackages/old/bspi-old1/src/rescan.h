#ifndef BSPI_RESCAN_H
#define BSPI_RESCAN_H

#include "config.h"
#include "xclass.h"

/* Queries bspwm's full tree, recomputes every desktop's icon-based
 * name (applying [ignore] rules and each desktop's [workspaces]
 * prefix), and renames any desktop whose current name doesn't match.
 * Every failure mode short of "couldn't reach the bspwm socket at
 * all" is logged and skipped rather than propagated - a single
 * malformed/half-updated node must never take the daemon down.
 *
 * Returns 0 normally, -1 only if bspwm itself couldn't be reached
 * (the caller may want to back off before retrying in that case). */
int bspi_rescan(const char *sock_path, const bspi_config_t *cfg, xclass_ctx_t *xctx);

#endif /* BSPI_RESCAN_H */
