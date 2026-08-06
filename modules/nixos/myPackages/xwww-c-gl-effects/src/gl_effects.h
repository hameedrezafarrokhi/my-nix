#ifndef XWWW_GL_EFFECTS_H
#define XWWW_GL_EFFECTS_H

#include "buffer.h"
#include "transitions.h"

/* True if `name` is one of the GL-ported effects (regardless of whether
 * a GL context can actually be created right now). */
int gl_effect_exists(const char *name);

/* Renders one frame via GL. Returns 0 on success; -1 if GL isn't
 * available or something failed, in which case the caller should fall
 * back to the ordinary CPU transitions table for this effect. */
int gl_render_effect(const char *name, const buf_t *from, const buf_t *to, buf_t *out,
                      double t, const tparams_t *p);

#endif
