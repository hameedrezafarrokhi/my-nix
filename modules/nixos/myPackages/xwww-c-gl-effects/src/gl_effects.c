/* GL-ported effects. Each mesh effect builds vertex data on the CPU
 * (reusing the same easing/hash helpers the CPU path uses) and hands it
 * to glrender's generic lit/textured shader -- the interesting animation
 * math still lives here in plain C, only the rasterization, perspective,
 * lighting and depth-compositing are real GPU work. Fragment effects
 * (burn/melt/ripple) are the opposite: a fullscreen quad with all the
 * work done in GLSL, since noise-driven 2D distortion is what fragment
 * shaders are actually for.
 *
 * Known, disclosed simplifications (see the GL branch README section):
 *  - the "flat/background" region of half-swing does a hard cut at
 *    t=0.5 rather than a true two-texture crossfade blend;
 *  - side/edge faces on cube and the curl strip's edges use a
 *    straightforward UV mapping rather than exhaustively mirror-
 *    corrected UVs the way the primary front/back faces are;
 *  - there can be a very slight scale "pop" between the last GL frame
 *    and the guaranteed-correct final CPU-pushed frame, since the mesh
 *    effects deliberately shrink their geometry a little inside the
 *    view frustum rather than exactly edge-matching it.
 */

#include "gl_effects.h"
#include "glrender.h"
#include "mat4.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/* -------------------------------------------------------- texture cache
 * Re-uploading a 4K "from"/"to" image every single frame would be silly;
 * within one transition run, main.c calls us with the SAME buf_t
 * pointers every frame, so caching by pointer identity is enough. */
static const buf_t *cached_from_ptr = NULL, *cached_to_ptr = NULL;
static unsigned cached_from_tex = 0, cached_to_tex = 0;

static unsigned get_tex(const buf_t *b, const buf_t **cache_ptr, unsigned *cache_tex) {
    if (*cache_ptr == b && *cache_tex) return *cache_tex;
    if (*cache_tex) glr_delete_texture(*cache_tex);
    *cache_tex = glr_upload_texture(b);
    *cache_ptr = b;
    return *cache_tex;
}

/* --------------------------------------------------------------- camera
 * A perspective camera positioned so a flat quad spanning
 * x=[-aspect,aspect], y=[-1,1] at z=0 exactly fills the viewport --
 * every mesh effect is built in that coordinate space so t=0/1 line up
 * with the ordinary flat wallpaper. */
typedef struct { mat4_t proj, view; float aspect; float dist; } camera_t;

static camera_t make_camera(int w, int h) {
    camera_t c;
    c.aspect = (float)w / (float)h;
    float fovy = 35.0f * (float)M_PI / 180.0f;
    c.dist = 1.0f / tanf(fovy / 2.0f);
    c.proj = mat4_perspective(fovy, c.aspect, 0.05f, c.dist * 20.0f);
    c.view = mat4_look_at(v3(0, 0, c.dist), v3(0, 0, 0), v3(0, 1, 0));
    return c;
}

static double ease_inout(double t) { return easing_apply(EASE_INOUT_CUBIC, t); }

/* --------------------------------------------------------- mesh helpers */

static int add_quad(glr_vertex_t *out, int n, vec3_t p0, vec3_t p1, vec3_t p2, vec3_t p3,
                     float u0, float v0, float u1, float v1, float u2, float v2, float u3, float v3,
                     vec3_t normal) {
    vec3_t P[4] = { p0, p1, p2, p3 };
    float U[4] = { u0, u1, u2, u3 }, V[4] = { v0, v1, v2, v3 };
    static const int idx[6] = { 0, 1, 2, 0, 2, 3 };
    for (int i = 0; i < 6; i++) {
        int k = idx[i];
        out[n].pos[0] = P[k].x; out[n].pos[1] = P[k].y; out[n].pos[2] = P[k].z;
        out[n].uv[0] = U[k]; out[n].uv[1] = V[k];
        out[n].normal[0] = normal.x; out[n].normal[1] = normal.y; out[n].normal[2] = normal.z;
        n++;
    }
    return n;
}

static void render_grouped(camera_t cam, mat4_t model,
                            const glr_vertex_t *from_v, int from_n, unsigned from_tex,
                            const glr_vertex_t *to_v, int to_n, unsigned to_tex,
                            float clear_r, float clear_g, float clear_b) {
    mat4_t mvp = mat4_mul(cam.proj, mat4_mul(cam.view, model));
    glr_begin_frame(clear_r, clear_g, clear_b);
    if (from_n > 0) glr_draw_mesh(from_v, from_n, from_tex, mvp, model, 1);
    if (to_n > 0) glr_draw_mesh(to_v, to_n, to_tex, mvp, model, 1);
}

/* ------------------------------------------------------------------ cube
 * A real 6-face cube: 3 faces show "from", the 3 opposite faces show
 * "to", so wherever the spin lands, the visible faces are a genuine mix
 * -- not a 2-face flip pretending to be a cube. */
static int gl_cube(const buf_t *from, const buf_t *to, buf_t *out, double t, const tparams_t *p) {
    camera_t cam = make_camera(out->w, out->h);
    unsigned ft = get_tex(from, &cached_from_ptr, &cached_from_tex);
    unsigned tt = get_tex(to, &cached_to_ptr, &cached_to_tex);

    float hx = cam.aspect * 0.62f, hy = 1.0f * 0.62f, hz = fminf(cam.aspect, 1.0f) * 0.5f;
    vec3_t c[8] = {
        v3(-hx, -hy, -hz), v3(hx, -hy, -hz), v3(hx, hy, -hz), v3(-hx, hy, -hz),
        v3(-hx, -hy,  hz), v3(hx, -hy,  hz), v3(hx, hy,  hz), v3(-hx, hy,  hz),
    };
    glr_vertex_t fv[36], tv[36];
    int fn = 0, tn = 0;
    fn = add_quad(fv, fn, c[4], c[5], c[6], c[7], 0,1, 1,1, 1,0, 0,0, v3(0,0,1));
    tn = add_quad(tv, tn, c[0], c[1], c[2], c[3], 1,1, 0,1, 0,0, 1,0, v3(0,0,-1));
    fn = add_quad(fv, fn, c[5], c[1], c[2], c[6], 0,1, 1,1, 1,0, 0,0, v3(1,0,0));
    tn = add_quad(tv, tn, c[0], c[4], c[7], c[3], 0,1, 1,1, 1,0, 0,0, v3(-1,0,0));
    fn = add_quad(fv, fn, c[7], c[6], c[2], c[3], 0,1, 1,1, 1,0, 0,0, v3(0,1,0));
    tn = add_quad(tv, tn, c[0], c[1], c[5], c[4], 0,1, 1,1, 1,0, 0,0, v3(0,-1,0));

    double et = ease_inout(t);
    double total_angle = M_PI + p->cube_spin_speed * 2 * M_PI;
    float angle = (float)(total_angle * et);
    float zoom_bell = sinf((float)M_PI * (float)et);
    float zoom = 1.0f - (float)p->cube_zoom * zoom_bell;

    mat4_t model = mat4_mul(mat4_rotate_y(angle), mat4_scale(zoom, zoom, zoom));
    render_grouped(cam, model, fv, fn, ft, tv, tn, tt, 0, 0, 0);
    glr_read_frame(out);
    return 0;
}

/* ------------------------------------------------------------- axis-spin
 * A double-sided rotating card: same trick as the cube's front/back pair
 * without the other four faces, spinning around the configured axis. */
static int gl_axis_spin(const buf_t *from, const buf_t *to, buf_t *out, double t, const tparams_t *p) {
    camera_t cam = make_camera(out->w, out->h);
    unsigned ft = get_tex(from, &cached_from_ptr, &cached_from_tex);
    unsigned tt = get_tex(to, &cached_to_ptr, &cached_to_tex);

    float hx = cam.aspect, hy = 1.0f;
    vec3_t p0 = v3(-hx, -hy, 0), p1 = v3(hx, -hy, 0), p2 = v3(hx, hy, 0), p3 = v3(-hx, hy, 0);
    glr_vertex_t fv[6], tv[6];
    int fn = add_quad(fv, 0, p0, p1, p2, p3, 0,1, 1,1, 1,0, 0,0, v3(0,0,1));
    int tn = add_quad(tv, 0, p0, p1, p2, p3, 1,1, 0,1, 0,0, 1,0, v3(0,0,-1));

    double et = ease_inout(t);
    double total_angle = M_PI + p->axisspin_turns * 2 * M_PI;
    float angle = (float)(total_angle * et);
    mat4_t model = p->axisspin_vertical ? mat4_rotate_x(angle) : mat4_rotate_y(angle);

    render_grouped(cam, model, fv, fn, ft, tv, tn, tt, 0, 0, 0);
    glr_read_frame(out);
    return 0;
}

/* --------------------------------------------------- full-swing / half-swing
 * A real hinged door: the panel rotates around a vertical line (the
 * hinge) instead of just foreshortening in place, and a flat background
 * quad behind it is what the depth buffer naturally reveals as the door
 * swings clear -- this is the actual 3D-vs-2D difference the CPU path
 * couldn't give you. */
static int gl_swing(const buf_t *from, const buf_t *to, buf_t *out, double t,
                     const tparams_t *p, float pivot_frac, int dir) {
    (void)p;
    camera_t cam = make_camera(out->w, out->h);
    unsigned ft = get_tex(from, &cached_from_ptr, &cached_from_tex);
    unsigned tt = get_tex(to, &cached_to_ptr, &cached_to_tex);

    float pivot_x = (pivot_frac - 0.5f) * 2.0f * cam.aspect;
    float far_x = dir > 0 ? cam.aspect : -cam.aspect;
    float reach = fabsf(far_x - pivot_x);

    /* s: 1 = door fully flat/visible, 0 = fully swung open (invisible) */
    float s = (float)(1.0 - t);
    float angle_max = (float)M_PI * 0.5f * 0.985f;
    float angle = (1.0f - s) * angle_max * (dir > 0 ? 1.0f : -1.0f);

    vec3_t local[4] = { v3(0,-1,0), v3(dir * reach,-1,0), v3(dir * reach,1,0), v3(0,1,0) };
    vec3_t world[4];
    float ca = cosf(angle), sa = sinf(angle);
    for (int i = 0; i < 4; i++) {
        float rx = ca * local[i].x + sa * local[i].z;
        float rz = -sa * local[i].x + ca * local[i].z;
        world[i] = v3(pivot_x + rx, local[i].y, rz);
    }
    vec3_t normal = v3(sa, 0, ca);

    float u_hinge = pivot_frac, u_far = dir > 0 ? 1.0f : 0.0f;
    glr_vertex_t door_v[6];
    int door_n = add_quad(door_v, 0, world[0], world[1], world[2], world[3],
                           u_hinge,1, u_far,1, u_far,0, u_hinge,0, normal);

    glr_vertex_t bg_v[12];
    int bg_n = add_quad(bg_v, 0, v3(pivot_x,-1,0), v3(far_x,-1,0), v3(far_x,1,0), v3(pivot_x,1,0),
                         u_hinge,1, u_far,1, u_far,0, u_hinge,0, v3(0,0,1));

    /* half-swing's non-hinged side: a flat quad, hard-cut at t=0.5
     * (see the file header for why this isn't a true crossfade). */
    int has_other_side = (pivot_frac > 0.001f && pivot_frac < 0.999f);
    if (has_other_side) {
        float ox0 = dir > 0 ? -cam.aspect : pivot_x;
        float ox1 = dir > 0 ? pivot_x : cam.aspect;
        float ou0 = dir > 0 ? 0.0f : pivot_frac;
        float ou1 = dir > 0 ? pivot_frac : 1.0f;
        bg_n = add_quad(bg_v, bg_n, v3(ox0,-1,0), v3(ox1,-1,0), v3(ox1,1,0), v3(ox0,1,0),
                         ou0,1, ou1,1, ou1,0, ou0,0, v3(0,0,1));
    }

    mat4_t model = mat4_identity();
    mat4_t mvp = mat4_mul(cam.proj, mat4_mul(cam.view, model));
    glr_begin_frame(0, 0, 0);
    unsigned bg_tex = (t < 0.5) ? ft : tt; /* the other-side hard cut */
    glr_draw_mesh(bg_v, bg_n, bg_tex, mvp, model, 1);
    glr_draw_mesh(door_v, door_n, ft, mvp, model, 1);
    glr_read_frame(out);
    return 0;
}
static int gl_full_swing_forward(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)  { return gl_swing(f, t2, o, t, p, 1.0f, -1); }
static int gl_full_swing_backward(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p) { return gl_swing(t2, f, o, 1.0 - t, p, 0.0f, 1); }
static int gl_half_swing_forward(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p) {
    return gl_swing(f, t2, o, t, p, (float)(p->pivot_pct / 100.0), 1);
}
static int gl_half_swing_backward(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p) {
    return gl_swing(t2, f, o, 1.0 - t, p, (float)(p->pivot_pct / 100.0), -1);
}

/* ------------------------------------------------------- curl strip
 * Shared by page-turn (moderate radius, hinge at the center spine) and
 * roll-away/carpet (small radius, hinge at a screen edge): a strip
 * subdivided along the moving axis bends into a real cylindrical curl
 * near the active front instead of just shading a flat cut, which is
 * what actually reads as "rolling" rather than "a line with a gradient
 * on it". Past the point where the strip has wrapped fully under, it
 * stops emitting geometry -- the flat background quad behind it (drawn
 * separately by the caller) is what the depth buffer reveals there. */
static int build_curl_strip(camera_t cam, int horizontal, float hinge_frac, int dir,
                             float local_t, float curl_zone, float radius_world,
                             glr_vertex_t *verts) {
    int segs = 28;
    float half_perp = horizontal ? 1.0f : cam.aspect;
    float axis_extent = horizontal ? cam.aspect : 1.0f;
    float hinge_pos = (hinge_frac - 0.5f) * 2.0f * axis_extent;
    float far_pos = dir > 0 ? axis_extent : -axis_extent;
    float reach = fabsf(far_pos - hinge_pos);

    int n = 0;
    for (int i = 0; i < segs; i++) {
        float u0 = (float)i / segs, u1 = (float)(i + 1) / segs;
        float d0 = u0 - local_t, d1 = u1 - local_t;
        if (d0 < -curl_zone * 1.05f && d1 < -curl_zone * 1.05f) continue; /* fully wrapped under, skip */

        float samples_u[2] = { u0, u1 };
        float axis_off[2], zvals[2];
        for (int k = 0; k < 2; k++) {
            float u = samples_u[k];
            float d = u - local_t;
            float along, z;
            if (d > curl_zone) {
                along = u * reach;
                z = 0;
            } else {
                float dc = curl_zone > 0.0001f ? d : 0;
                float frac = 1.0f - (dc / (curl_zone > 0.0001f ? curl_zone : 1.0f));
                if (frac < 0) frac = 0;
                if (frac > 1) frac = 1;
                float angle = frac * (float)M_PI;
                float zone_start_along = (local_t + curl_zone) * reach;
                along = zone_start_along - radius_world * sinf(angle);
                z = radius_world * (1.0f - cosf(angle));
            }
            axis_off[k] = along;
            zvals[k] = z;
        }

        vec3_t p_a0, p_a1, p_b0, p_b1;
        if (horizontal) {
            p_a0 = v3(hinge_pos + dir * axis_off[0], -half_perp, zvals[0]);
            p_a1 = v3(hinge_pos + dir * axis_off[1], -half_perp, zvals[1]);
            p_b0 = v3(hinge_pos + dir * axis_off[0],  half_perp, zvals[0]);
            p_b1 = v3(hinge_pos + dir * axis_off[1],  half_perp, zvals[1]);
        } else {
            p_a0 = v3(-half_perp, hinge_pos + dir * axis_off[0], zvals[0]);
            p_a1 = v3(-half_perp, hinge_pos + dir * axis_off[1], zvals[1]);
            p_b0 = v3( half_perp, hinge_pos + dir * axis_off[0], zvals[0]);
            p_b1 = v3( half_perp, hinge_pos + dir * axis_off[1], zvals[1]);
        }

        float dz = zvals[1] - zvals[0];
        vec3_t normal = horizontal ? v3_norm(v3(dz > 0 ? -1.0f : (dz < 0 ? 1.0f : 0.0f), 0, 1))
                                    : v3_norm(v3(0, dz > 0 ? -1.0f : (dz < 0 ? 1.0f : 0.0f), 1));

        float far_u = dir > 0 ? 1.0f : 0.0f;
        float tex_u0 = hinge_frac + (far_u - hinge_frac) * u0;
        float tex_u1 = hinge_frac + (far_u - hinge_frac) * u1;

        if (horizontal)
            n = add_quad(verts, n, p_a0, p_a1, p_b1, p_b0, tex_u0,1, tex_u1,1, tex_u1,0, tex_u0,0, normal);
        else
            n = add_quad(verts, n, p_a0, p_a1, p_b1, p_b0, 1,tex_u0, 1,tex_u1, 0,tex_u1, 0,tex_u0, normal);

        if (n > 4096 - 6) break;
    }
    return n;
}

static int gl_curl_effect(const buf_t *from, const buf_t *to, buf_t *out, double t,
                           int horizontal, float hinge_frac, int dir,
                           float curl_zone, float radius_world) {
    camera_t cam = make_camera(out->w, out->h);
    unsigned ft = get_tex(from, &cached_from_ptr, &cached_from_tex);
    unsigned tt = get_tex(to, &cached_to_ptr, &cached_to_tex);

    static glr_vertex_t strip[4096];
    int strip_n = build_curl_strip(cam, horizontal, hinge_frac, dir, (float)t, curl_zone, radius_world, strip);

    float half_perp = horizontal ? 1.0f : cam.aspect;
    float axis_extent = horizontal ? cam.aspect : 1.0f;
    float hinge_pos = (hinge_frac - 0.5f) * 2.0f * axis_extent;
    float far_pos = dir > 0 ? axis_extent : -axis_extent;
    float far_u = dir > 0 ? 1.0f : 0.0f;

    glr_vertex_t bg[6];
    int bg_n;
    if (horizontal)
        bg_n = add_quad(bg, 0, v3(hinge_pos,-half_perp,0), v3(far_pos,-half_perp,0),
                         v3(far_pos,half_perp,0), v3(hinge_pos,half_perp,0),
                         hinge_frac,1, far_u,1, far_u,0, hinge_frac,0, v3(0,0,1));
    else
        bg_n = add_quad(bg, 0, v3(-half_perp,hinge_pos,0), v3(-half_perp,far_pos,0),
                         v3(half_perp,far_pos,0), v3(half_perp,hinge_pos,0),
                         1,hinge_frac, 1,far_u, 0,far_u, 0,hinge_frac, v3(0,0,1));

    mat4_t model = mat4_identity();
    render_grouped(cam, model, bg, bg_n, tt, strip, strip_n, ft, 0, 0, 0);
    glr_read_frame(out);
    return 0;
}

static int gl_page_turn_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)  { return gl_curl_effect(f, t2, o, t, 1, 0.5f, -1, 0.22f, (float)(p->curl_pct/100.0)*1.4f); }
static int gl_page_turn_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p) { return gl_curl_effect(f, t2, o, t, 1, 0.5f, 1, 0.22f, (float)(p->curl_pct/100.0)*1.4f); }
static int gl_page_turn_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)    { return gl_curl_effect(f, t2, o, t, 0, 0.5f, -1, 0.22f, (float)(p->curl_pct/100.0)*1.4f); }
static int gl_page_turn_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)  { return gl_curl_effect(f, t2, o, t, 0, 0.5f, 1, 0.22f, (float)(p->curl_pct/100.0)*1.4f); }

static int gl_roll_away_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)    { return gl_curl_effect(f, t2, o, t, 0, 0.0f, 1, 0.10f, (float)(p->curl_pct/100.0)*0.5f); }
static int gl_roll_away_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)  { return gl_curl_effect(f, t2, o, t, 0, 1.0f, -1, 0.10f, (float)(p->curl_pct/100.0)*0.5f); }
static int gl_roll_away_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)  { return gl_curl_effect(f, t2, o, t, 1, 0.0f, 1, 0.10f, (float)(p->curl_pct/100.0)*0.5f); }
static int gl_roll_away_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p) { return gl_curl_effect(f, t2, o, t, 1, 1.0f, -1, 0.10f, (float)(p->curl_pct/100.0)*0.5f); }

static int gl_carpet_up(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)    { return gl_curl_effect(t2, f, o, 1.0 - t, 0, 0.0f, 1, 0.10f, (float)(p->curl_pct/100.0)*0.5f); }
static int gl_carpet_down(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)  { return gl_curl_effect(t2, f, o, 1.0 - t, 0, 1.0f, -1, 0.10f, (float)(p->curl_pct/100.0)*0.5f); }
static int gl_carpet_left(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p)  { return gl_curl_effect(t2, f, o, 1.0 - t, 1, 0.0f, 1, 0.10f, (float)(p->curl_pct/100.0)*0.5f); }
static int gl_carpet_right(const buf_t *f, const buf_t *t2, buf_t *o, double t, const tparams_t *p) { return gl_curl_effect(t2, f, o, 1.0 - t, 1, 1.0f, -1, 0.10f, (float)(p->curl_pct/100.0)*0.5f); }

/* --------------------------------------------------------------- shatter
 * Real irregular 3D pieces this time: a jittered grid of seed points,
 * but each piece is an actual small quad with its own 3D translation AND
 * rotation (pitch+yaw as it tumbles), lit and perspective-correct,
 * instead of a 2D pixel-displacement trick. */
static double hashd(int a, int b, double seed) {
    unsigned h = (unsigned)(a * 374761393 + b * 668265263);
    h ^= (unsigned)(seed * 4294967295.0);
    h = (h ^ (h >> 13)) * 1274126177u;
    h ^= h >> 16;
    return (h & 0xFFFFFFu) / (double)0xFFFFFFu;
}

static int gl_shatter(const buf_t *from, const buf_t *to, buf_t *out, double t, const tparams_t *p) {
    camera_t cam = make_camera(out->w, out->h);
    unsigned ft = get_tex(from, &cached_from_ptr, &cached_from_tex);
    unsigned tt = get_tex(to, &cached_to_ptr, &cached_to_tex);

    int cols = 10, rows = 6;
    double falpha = 1.0 - (t < 0.15 ? 0.0 : (t > 0.85 ? 1.0 : (t - 0.15) / 0.7));
    if (falpha < 0) falpha = 0;

    static glr_vertex_t fv[10 * 6 * 6];
    int fn = 0;
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            if (falpha <= 0.003) continue;
            float u0 = (float)c / cols, u1 = (float)(c + 1) / cols;
            float v0 = (float)r / rows, v1 = (float)(r + 1) / rows;
            float cx = ((u0 + u1) * 0.5f - 0.5f) * 2.0f * cam.aspect;
            float cy = (0.5f - (v0 + v1) * 0.5f) * 2.0f;
            float hw = (u1 - u0) * cam.aspect, hh = (v1 - v0);

            double a = hashd(c, r, p->seed) * 2 * M_PI;
            double sp = 0.5 + hashd(c, r, p->seed + 0.31) * 1.4;
            double disp = t * t * sp * 2.2;
            float dx = (float)(cos(a) * disp);
            float dy = (float)(sin(a) * disp - t * t * 2.5); /* gravity: falling = -y in world-up space */
            float dz = (float)(hashd(c, r, p->seed + 0.62) * disp * 0.6);

            float rota = (float)(hashd(c, r, p->seed + 0.9) * 2 * M_PI - M_PI) * (float)(t * 2.2);
            float rotb = (float)(hashd(r, c, p->seed + 1.4) * 2 * M_PI - M_PI) * (float)(t * 1.6);

            vec3_t local[4] = { v3(-hw,-hh,0), v3(hw,-hh,0), v3(hw,hh,0), v3(-hw,hh,0) };
            mat4_t rot = mat4_mul(mat4_rotate_x(rotb), mat4_rotate_y(rota));
            vec3_t nrm0 = v3(0, 0, 1);
            float nx = rot.m[0]*nrm0.x+rot.m[4]*nrm0.y+rot.m[8]*nrm0.z;
            float ny = rot.m[1]*nrm0.x+rot.m[5]*nrm0.y+rot.m[9]*nrm0.z;
            float nz = rot.m[2]*nrm0.x+rot.m[6]*nrm0.y+rot.m[10]*nrm0.z;
            vec3_t world[4];
            for (int k = 0; k < 4; k++) {
                float lx = local[k].x, ly = local[k].y, lz = local[k].z;
                float wx = rot.m[0]*lx+rot.m[4]*ly+rot.m[8]*lz;
                float wy = rot.m[1]*lx+rot.m[5]*ly+rot.m[9]*lz;
                float wz = rot.m[2]*lx+rot.m[6]*ly+rot.m[10]*lz;
                world[k] = v3(cx+wx+dx, cy+wy+dy, wz+dz);
            }
            fn = add_quad(fv, fn, world[0], world[1], world[2], world[3],
                          u0,v1, u1,v1, u1,v0, u0,v0, v3(nx,ny,nz));
        }
    }

    glr_vertex_t bgv[6];
    int bgn = add_quad(bgv, 0, v3(-cam.aspect,-1,0), v3(cam.aspect,-1,0), v3(cam.aspect,1,0), v3(-cam.aspect,1,0),
                        0,1, 1,1, 1,0, 0,0, v3(0,0,1));

    mat4_t model = mat4_identity();
    render_grouped(cam, model, bgv, bgn, tt, fv, fn, ft, 0, 0, 0);
    glr_read_frame(out);
    return 0;
}

/* ------------------------------------------------------------ paper-plane
 * A small real 3D folded-paper-like mesh (still stylized -- a handful of
 * triangles, not a literal fold simulation) flown on a swooping path with
 * genuine 3D rotation, so it banks/tilts correctly instead of just
 * translating a flat card. */
static int gl_paper_plane(const buf_t *from, const buf_t *to, buf_t *out, double t, const tparams_t *p) {
    (void)p;
    camera_t cam = make_camera(out->w, out->h);
    unsigned ft = get_tex(from, &cached_from_ptr, &cached_from_tex);
    unsigned tt = get_tex(to, &cached_to_ptr, &cached_to_tex);

    double pA = 0.15, pB = 0.45, pC = 0.55, pD = 0.85;
    float px = 0, py = 0, pz = 0, scale = 0, yaw = 0, pitch = 0, roll = 0;
    int show_plane = 1, carrying_to = 0;
    unsigned bg_tex = ft;

    if (t < pA) {
        double u = easing_apply(EASE_OUT_BACK, pA > 0 ? t / pA : 1);
        scale = (float)(u < 0 ? 0 : u) * 0.5f;
        bg_tex = ft;
    } else if (t < pB) {
        double u = (t - pA) / (pB - pA);
        double eu = easing_apply(EASE_IN_CUBIC, u);
        px = (float)(eu * cam.aspect * 1.6);
        py = (float)(sin(u * M_PI) * 0.5 + eu * 0.9);
        pz = (float)(eu * 1.2);
        scale = 0.5f - 0.15f * (float)eu;
        yaw = (float)(-0.6 * eu);
        pitch = (float)(0.3 * sin(u * M_PI * 2));
        roll = (float)(-0.4 * eu);
        bg_tex = ft;
    } else if (t < pC) {
        show_plane = 0;
        bg_tex = tt;
    } else if (t < pD) {
        double u = (t - pC) / (pD - pC);
        double eu = easing_apply(EASE_OUT_CUBIC, u);
        px = (float)(-cam.aspect * 1.6 * (1 - eu));
        py = (float)(-0.9 * (1 - eu) + sin(u * M_PI) * 0.5);
        pz = (float)(1.2 * (1 - eu));
        scale = 0.35f + 0.15f * (float)eu;
        yaw = (float)(0.6 * (1 - eu));
        pitch = (float)(0.2 * sin(u * M_PI * 2));
        roll = (float)(0.4 * (1 - eu));
        carrying_to = 1;
        bg_tex = tt;
    } else {
        double u = easing_apply(EASE_IN_CUBIC, (t - pD) / (1 - pD));
        scale = 0.5f + (float)u * 3.0f;
        carrying_to = 1;
        bg_tex = tt;
        if (u > 0.5) show_plane = 0;
    }

    glr_vertex_t bgv[6];
    int bgn = add_quad(bgv, 0, v3(-cam.aspect,-1,0), v3(cam.aspect,-1,0), v3(cam.aspect,1,0), v3(-cam.aspect,1,0),
                        0,1, 1,1, 1,0, 0,0, v3(0,0,1));

    glr_vertex_t plane_v[6];
    int plane_n = 0;
    if (show_plane && scale > 0.01f) {
        vec3_t nose = v3(0, 0, 0.6f), tail = v3(0, 0.08f, -0.6f);
        vec3_t wingL = v3(-0.55f, -0.05f, -0.4f), wingR = v3(0.55f, -0.05f, -0.4f);
        vec3_t local_v[6] = { nose, tail, wingL, nose, wingR, tail };
        mat4_t rot = mat4_mul(mat4_rotate_y(yaw), mat4_mul(mat4_rotate_x(pitch), mat4_rotate_z(roll)));
        vec3_t world[6];
        for (int i = 0; i < 6; i++) {
            float lx = local_v[i].x, ly = local_v[i].y, lz = local_v[i].z;
            float wx = rot.m[0]*lx+rot.m[4]*ly+rot.m[8]*lz;
            float wy = rot.m[1]*lx+rot.m[5]*ly+rot.m[9]*lz;
            float wz = rot.m[2]*lx+rot.m[6]*ly+rot.m[10]*lz;
            world[i] = v3(px + wx * scale, py + wy * scale, pz + wz * scale);
        }
        vec3_t n1 = v3_norm(v3_cross(v3_sub(world[1], world[0]), v3_sub(world[2], world[0])));
        vec3_t n2 = v3_norm(v3_cross(v3_sub(world[4], world[3]), v3_sub(world[5], world[3])));
        for (int i = 0; i < 3; i++) {
            plane_v[plane_n].pos[0] = world[i].x; plane_v[plane_n].pos[1] = world[i].y; plane_v[plane_n].pos[2] = world[i].z;
            plane_v[plane_n].uv[0] = 0.5f + local_v[i].x; plane_v[plane_n].uv[1] = 0.5f - local_v[i].z;
            plane_v[plane_n].normal[0] = n1.x; plane_v[plane_n].normal[1] = n1.y; plane_v[plane_n].normal[2] = n1.z;
            plane_n++;
        }
        for (int i = 3; i < 6; i++) {
            plane_v[plane_n].pos[0] = world[i].x; plane_v[plane_n].pos[1] = world[i].y; plane_v[plane_n].pos[2] = world[i].z;
            plane_v[plane_n].uv[0] = 0.5f + local_v[i].x; plane_v[plane_n].uv[1] = 0.5f - local_v[i].z;
            plane_v[plane_n].normal[0] = n2.x; plane_v[plane_n].normal[1] = n2.y; plane_v[plane_n].normal[2] = n2.z;
            plane_n++;
        }
    }

    mat4_t model = mat4_identity();
    mat4_t mvp = mat4_mul(cam.proj, mat4_mul(cam.view, model));
    glr_begin_frame(0.02f, 0.02f, 0.03f);
    glr_draw_mesh(bgv, bgn, bg_tex, mvp, model, 1);
    if (plane_n > 0) glr_draw_mesh(plane_v, plane_n, carrying_to ? tt : ft, mvp, model, 1);
    glr_read_frame(out);
    return 0;
}

/* ============================================================ fragment
 * Fullscreen-quad, noise-driven effects. fbm() below is a standard
 * value-noise fractal sum, the same technique used all over shader-land. */

static const char *FBM_GLSL =
    "float hash21(vec2 p){ p=fract(p*vec2(123.34,456.21)); p+=dot(p,p+45.32); return fract(p.x*p.y); }\n"
    "float noise(vec2 p){\n"
    "    vec2 i=floor(p), f=fract(p);\n"
    "    float a=hash21(i), b=hash21(i+vec2(1,0)), c=hash21(i+vec2(0,1)), d=hash21(i+vec2(1,1));\n"
    "    vec2 u=f*f*(3.0-2.0*f);\n"
    "    return mix(mix(a,b,u.x), mix(c,d,u.x), u.y);\n"
    "}\n"
    "float fbm(vec2 p){\n"
    "    float v=0.0, amp=0.5;\n"
    "    for(int i=0;i<5;i++){ v+=amp*noise(p); p*=2.02; amp*=0.5; }\n"
    "    return v;\n"
    "}\n";

static const char *BURN_FRAG_SRC_FMT =
    "#version 330 core\n"
    "in vec2 vUV;\n"
    "out vec4 FragColor;\n"
    "uniform sampler2D uFromTex;\n"
    "uniform sampler2D uToTex;\n"
    "uniform float uT;\n"
    "uniform float uSeed;\n"
    "uniform float uExtraA;\n"
    "uniform vec2 uOrigin;\n"
    "uniform float uAspect;\n"
    "%s"
    "void main(){\n"
    "    vec2 p = (vUV - uOrigin) * vec2(uAspect,1.0);\n"
    "    float d = length(p);\n"
    "    float ang = atan(p.y,p.x);\n"
    "    float n = fbm(vec2(cos(ang),sin(ang))*3.0 + uSeed*17.0 + uT*0.6);\n"
    "    float front = uT*1.5*(0.7+0.3*fbm(vec2(uSeed*3.1,uT*0.3)));\n"
    "    float jag = mix(0.0, 0.35, uExtraA) * n;\n"
    "    float edge = d - (front + jag);\n"
    "    vec3 fireCol = mix(vec3(1.0,0.85,0.3), vec3(1.0,0.35,0.02), clamp(n,0.0,1.0));\n"
    "    vec3 charCol = vec3(0.06,0.03,0.02);\n"
    "    vec4 fromC = texture(uFromTex, vUV);\n"
    "    vec4 toC = texture(uToTex, vUV);\n"
    "    float band = 0.05;\n"
    "    vec3 outc;\n"
    "    if (edge > band) outc = fromC.rgb;\n"
    "    else if (edge > 0.0) outc = mix(fireCol, fromC.rgb, edge/band);\n"
    "    else if (edge > -band) outc = mix(charCol, fireCol, (edge+band)/band);\n"
    "    else outc = mix(charCol, toC.rgb, clamp((-edge-band)/(band*0.7), 0.0, 1.0));\n"
    "    float sparkle = hash21(vUV*800.0 + uT*130.0);\n"
    "    if (edge > -band*1.6 && edge < band*1.2 && sparkle > 0.9945) outc = vec3(1.0,0.9,0.7);\n"
    "    FragColor = vec4(outc, 1.0);\n"
    "}\n";

static const char *MELT_FRAG_SRC_FMT =
    "#version 330 core\n"
    "in vec2 vUV;\n"
    "out vec4 FragColor;\n"
    "uniform sampler2D uFromTex;\n"
    "uniform sampler2D uToTex;\n"
    "uniform float uT;\n"
    "uniform float uSeed;\n"
    "%s"
    "void main(){\n"
    "    float stagger = fbm(vec2(vUV.x*6.0+uSeed*13.0, uSeed*7.0));\n"
    "    float lt = clamp((uT - stagger*0.5)/0.6, 0.0, 1.0);\n"
    "    float warp = fbm(vec2(vUV.x*8.0, vUV.y*4.0 - uT*2.5 + uSeed*5.0)) - 0.5;\n"
    "    float boundary = lt + warp*0.18*lt;\n"
    "    float drip = 0.10*lt*lt;\n"
    "    vec2 sagUV = vUV + vec2(warp*0.02, -drip);\n"
    "    vec4 fromC = texture(uFromTex, clamp(sagUV,0.0,1.0));\n"
    "    vec4 toC = texture(uToTex, vUV);\n"
    "    float mixv = smoothstep(boundary-0.08, boundary+0.08, vUV.y);\n"
    "    FragColor = vec4(mix(toC.rgb, fromC.rgb, mixv), 1.0);\n"
    "}\n";

static const char *RIPPLE_FRAG_SRC_FMT =
    "#version 330 core\n"
    "in vec2 vUV;\n"
    "out vec4 FragColor;\n"
    "uniform sampler2D uFromTex;\n"
    "uniform sampler2D uToTex;\n"
    "uniform float uT;\n"
    "uniform float uAmp;\n"
    "uniform float uFreq;\n"
    "uniform vec2 uOrigin;\n"
    "uniform float uAspect;\n"
    "%s"
    "void main(){\n"
    "    vec2 p = (vUV - uOrigin) * vec2(uAspect,1.0);\n"
    "    float d = length(p);\n"
    "    vec2 dir = d > 0.001 ? p/d : vec2(0.0);\n"
    "    float front = uT*1.5;\n"
    "    float envelope = exp(-pow((d-front)*10.0, 2.0));\n"
    "    float wave = sin(d*uFreq*80.0 - uT*20.0) * uAmp * 0.01 * envelope;\n"
    "    vec2 duv = dir*wave / vec2(uAspect,1.0);\n"
    "    vec4 fromC = texture(uFromTex, clamp(vUV+duv,0.0,1.0));\n"
    "    vec4 toC = texture(uToTex, clamp(vUV+duv,0.0,1.0));\n"
    "    float blend = smoothstep(-0.05, 0.05, front-d);\n"
    "    FragColor = vec4(mix(fromC.rgb, toC.rgb, blend), 1.0);\n"
    "}\n";

static char *build_frag_src(const char *fmt) {
    size_t len = strlen(fmt) + strlen(FBM_GLSL) + 8;
    char *buf = malloc(len);
    snprintf(buf, len, fmt, FBM_GLSL);
    return buf;
}

enum { FRAG_BURN = 1, FRAG_MELT = 2, FRAG_RIPPLE = 3 };

static int gl_frag_run(int uid, const char *fmt, const buf_t *from, const buf_t *to, buf_t *out,
                        double t, const tparams_t *p, float amp, float freq, float extra_a) {
    unsigned ft = get_tex(from, &cached_from_ptr, &cached_from_tex);
    unsigned tt = get_tex(to, &cached_to_ptr, &cached_to_tex);

    static char *src_cache[8] = {0};
    int slot = uid % 8;
    if (!src_cache[slot]) src_cache[slot] = build_frag_src(fmt);

    glr_frag_uniforms_t u = {0};
    u.t = (float)t;
    u.seed = (float)p->seed;
    u.amp = amp;
    u.freq = freq;
    u.origin_x = (float)(p->origin_x_pct / 100.0);
    u.origin_y = (float)(p->origin_y_pct / 100.0);
    u.extra_a = extra_a;

    glr_begin_frame(0, 0, 0);
    if (glr_draw_fullscreen_frag(uid, src_cache[slot], ft, tt, &u) != 0) return -1;
    glr_read_frame(out);
    return 0;
}

static int gl_burn(const buf_t *from, const buf_t *to, buf_t *out, double t, const tparams_t *p) {
    return gl_frag_run(FRAG_BURN, BURN_FRAG_SRC_FMT, from, to, out, t, p, 0, 0, (float)p->burn_jaggedness);
}
static int gl_melt(const buf_t *from, const buf_t *to, buf_t *out, double t, const tparams_t *p) {
    return gl_frag_run(FRAG_MELT, MELT_FRAG_SRC_FMT, from, to, out, t, p, 0, 0, 0);
}
static int gl_ripple(const buf_t *from, const buf_t *to, buf_t *out, double t, const tparams_t *p) {
    return gl_frag_run(FRAG_RIPPLE, RIPPLE_FRAG_SRC_FMT, from, to, out, t, p, (float)p->ripple_amp, (float)p->ripple_freq, 0);
}

/* ------------------------------------------------------------- dispatch */

typedef struct { const char *name; int (*fn)(const buf_t *, const buf_t *, buf_t *, double, const tparams_t *); } gl_entry_t;

static const gl_entry_t GL_TABLE[] = {
    { "cube", gl_cube },
    { "axis-spin", gl_axis_spin },
    { "full-swing-forward", gl_full_swing_forward },
    { "full-swing-backward", gl_full_swing_backward },
    { "half-swing-forward", gl_half_swing_forward },
    { "half-swing-backward", gl_half_swing_backward },
    { "page-turn-left", gl_page_turn_left },
    { "page-turn-right", gl_page_turn_right },
    { "page-turn-up", gl_page_turn_up },
    { "page-turn-down", gl_page_turn_down },
    { "roll-away-up", gl_roll_away_up },
    { "roll-away-down", gl_roll_away_down },
    { "roll-away-left", gl_roll_away_left },
    { "roll-away-right", gl_roll_away_right },
    { "carpet-up", gl_carpet_up },
    { "carpet-down", gl_carpet_down },
    { "carpet-left", gl_carpet_left },
    { "carpet-right", gl_carpet_right },
    { "shatter", gl_shatter },
    { "paper-plane", gl_paper_plane },
    { "burn", gl_burn },
    { "melt", gl_melt },
    { "ripple", gl_ripple },
};
static const int GL_TABLE_N = (int)(sizeof(GL_TABLE) / sizeof(GL_TABLE[0]));

int gl_effect_exists(const char *name) {
    for (int i = 0; i < GL_TABLE_N; i++)
        if (strcasecmp(GL_TABLE[i].name, name) == 0) return 1;
    return 0;
}

int gl_render_effect(const char *name, const buf_t *from, const buf_t *to, buf_t *out,
                      double t, const tparams_t *p) {
    if (!glr_available()) return -1;
    if (glr_set_target_size(from->w, from->h) != 0) return -1;
    for (int i = 0; i < GL_TABLE_N; i++)
        if (strcasecmp(GL_TABLE[i].name, name) == 0)
            return GL_TABLE[i].fn(from, to, out, t, p);
    return -1;
}
