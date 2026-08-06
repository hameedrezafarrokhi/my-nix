#ifndef XWWW_MAT4_H
#define XWWW_MAT4_H

/* Column-major 4x4 float matrices, matching GL's expected layout so they
 * can be passed straight to glUniformMatrix4fv(..., GL_FALSE, m). */

#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef struct { float m[16]; } mat4_t;
typedef struct { float x, y, z; } vec3_t;

static inline vec3_t v3(float x, float y, float z) { vec3_t v = { x, y, z }; return v; }

static inline vec3_t v3_sub(vec3_t a, vec3_t b) { return v3(a.x - b.x, a.y - b.y, a.z - b.z); }
static inline vec3_t v3_cross(vec3_t a, vec3_t b) {
    return v3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}
static inline float v3_dot(vec3_t a, vec3_t b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
static inline vec3_t v3_norm(vec3_t a) {
    float l = sqrtf(v3_dot(a, a));
    if (l < 1e-8f) return v3(0, 0, 0);
    return v3(a.x / l, a.y / l, a.z / l);
}

static inline mat4_t mat4_identity(void) {
    mat4_t r = { { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 } };
    return r;
}

static inline mat4_t mat4_mul(mat4_t a, mat4_t b) {
    mat4_t r;
    for (int c = 0; c < 4; c++) {
        for (int row = 0; row < 4; row++) {
            float s = 0;
            for (int k = 0; k < 4; k++) s += a.m[k * 4 + row] * b.m[c * 4 + k];
            r.m[c * 4 + row] = s;
        }
    }
    return r;
}

static inline mat4_t mat4_translate(float x, float y, float z) {
    mat4_t r = mat4_identity();
    r.m[12] = x; r.m[13] = y; r.m[14] = z;
    return r;
}

static inline mat4_t mat4_scale(float x, float y, float z) {
    mat4_t r = mat4_identity();
    r.m[0] = x; r.m[5] = y; r.m[10] = z;
    return r;
}

static inline mat4_t mat4_rotate_x(float a) {
    mat4_t r = mat4_identity();
    float c = cosf(a), s = sinf(a);
    r.m[5] = c; r.m[6] = s; r.m[9] = -s; r.m[10] = c;
    return r;
}
static inline mat4_t mat4_rotate_y(float a) {
    mat4_t r = mat4_identity();
    float c = cosf(a), s = sinf(a);
    r.m[0] = c; r.m[2] = -s; r.m[8] = s; r.m[10] = c;
    return r;
}
static inline mat4_t mat4_rotate_z(float a) {
    mat4_t r = mat4_identity();
    float c = cosf(a), s = sinf(a);
    r.m[0] = c; r.m[1] = s; r.m[4] = -s; r.m[5] = c;
    return r;
}

/* Right-handed perspective projection, standard OpenGL clip space (z in
 * [-1,1] after the divide). fovy in radians. */
static inline mat4_t mat4_perspective(float fovy, float aspect, float znear, float zfar) {
    mat4_t r = { {0} };
    float f = 1.0f / tanf(fovy / 2.0f);
    r.m[0] = f / aspect;
    r.m[5] = f;
    r.m[10] = (zfar + znear) / (znear - zfar);
    r.m[11] = -1.0f;
    r.m[14] = (2 * zfar * znear) / (znear - zfar);
    return r;
}

/* Camera at `eye` looking at `center`, `up` roughly upward. */
static inline mat4_t mat4_look_at(vec3_t eye, vec3_t center, vec3_t up) {
    vec3_t f = v3_norm(v3_sub(center, eye));
    vec3_t s = v3_norm(v3_cross(f, up));
    vec3_t u = v3_cross(s, f);
    mat4_t r = mat4_identity();
    r.m[0] = s.x; r.m[4] = s.y; r.m[8]  = s.z;
    r.m[1] = u.x; r.m[5] = u.y; r.m[9]  = u.z;
    r.m[2] = -f.x; r.m[6] = -f.y; r.m[10] = -f.z;
    r.m[12] = -v3_dot(s, eye);
    r.m[13] = -v3_dot(u, eye);
    r.m[14] = v3_dot(f, eye);
    return r;
}

#endif
