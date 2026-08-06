#ifndef XWWW_GLRENDER_H
#define XWWW_GLRENDER_H

#include "buffer.h"
#include "mat4.h"

/* Tries (once) to create an offscreen GLX 3.3-core context + FBO. Returns
 * 1 if GL rendering is usable, 0 if not (caller should fall back to the
 * CPU transition path -- nothing here is a hard dependency). Safe to
 * call repeatedly; only the first call does the actual work. */
int glr_available(void);

/* Uploads `buf` (ARGB buf_t) as a GL_RGBA8 texture. Returns 0 on failure. */
unsigned int glr_upload_texture(const buf_t *buf);
void glr_delete_texture(unsigned int tex);

/* (Re)size the offscreen render target. Returns 0 on success. */
int glr_set_target_size(int w, int h);

void glr_begin_frame(float r, float g, float b);

/* Reads the FBO back into a freshly-allocated buf_t. */
void glr_read_frame(buf_t *out);

typedef struct { float pos[3]; float uv[2]; float normal[3]; } glr_vertex_t;

/* Draws `count` vertices (GL_TRIANGLES) with the shared lit/textured
 * shader: `tex` bound, transformed by `mvp` (and `model` for the normals). */
void glr_draw_mesh(const glr_vertex_t *verts, int count, unsigned int tex,
                    mat4_t mvp, mat4_t model, int depth_test);

typedef struct {
    float t;
    float seed;
    float amp, freq;
    float origin_x, origin_y; /* 0..1 */
    float extra_a, extra_b;
    int   extra_i;
} glr_frag_uniforms_t;

/* Compiles+caches a fullscreen-quad fragment shader (keyed by frag_uid,
 * compiled once) and draws it with fromTex/toTex bound to units 0/1.
 * Returns 0 on success. */
int glr_draw_fullscreen_frag(int frag_uid, const char *frag_src,
                              unsigned int from_tex, unsigned int to_tex,
                              const glr_frag_uniforms_t *u);

void glr_shutdown(void);

#endif
