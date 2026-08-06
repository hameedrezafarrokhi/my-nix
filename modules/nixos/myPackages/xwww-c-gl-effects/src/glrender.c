#include "glrender.h"

#ifndef HAVE_GL

/* Built without GL support (no libGL/GL headers at configure time, or
 * explicitly disabled with `make HAVE_GL=0`). Every call fails cleanly;
 * gl_effects.c's gl_render_effect() checks glr_available() first and
 * returns -1 itself when it's false, so callers already fall back to
 * the CPU transitions table without any extra check needed here. */
int glr_available(void) { return 0; }
unsigned int glr_upload_texture(const buf_t *buf) { (void)buf; return 0; }
void glr_delete_texture(unsigned int tex) { (void)tex; }
int glr_set_target_size(int w, int h) { (void)w; (void)h; return -1; }
void glr_begin_frame(float r, float g, float b) { (void)r; (void)g; (void)b; }
void glr_read_frame(buf_t *out) { *out = buf_alloc(1, 1); }
void glr_draw_mesh(const glr_vertex_t *verts, int count, unsigned int tex,
                    mat4_t mvp, mat4_t model, int depth_test) {
    (void)verts; (void)count; (void)tex; (void)mvp; (void)model; (void)depth_test;
}
int glr_draw_fullscreen_frag(int frag_uid, const char *frag_src, unsigned int from_tex,
                              unsigned int to_tex, const glr_frag_uniforms_t *u) {
    (void)frag_uid; (void)frag_src; (void)from_tex; (void)to_tex; (void)u;
    return -1;
}
void glr_shutdown(void) {}

#else /* HAVE_GL */

/* GLX/OpenGL 3.3-core offscreen renderer.
 *
 * Deliberately does NOT depend on GLEW/GLAD/epoxy: everything past GL 1.1
 * is fetched by hand via glXGetProcAddressARB (which is always present in
 * libGL regardless of driver), matching what those loader libraries do
 * internally anyway. Function pointer typedefs below are prefixed XW_ so
 * they can never collide with whatever the system's real <GL/glext.h>
 * might also declare, even if it's present.
 *
 * Rendering target is an FBO, never the default framebuffer: a small
 * (1x1) override-redirect, never-mapped X window exists purely so GLX has
 * a valid drawable to make the context current against. Nothing is ever
 * displayed by this module -- every effect's output is read back into a
 * plain buf_t and handed to the same xroot_push_frame() pipeline the CPU
 * effects already use.
 */

#include <GL/glx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ---- GLX_ARB_create_context (not always in old glx.h) ---- */
#ifndef GLX_CONTEXT_MAJOR_VERSION_ARB
#define GLX_CONTEXT_MAJOR_VERSION_ARB 0x2091
#endif
#ifndef GLX_CONTEXT_MINOR_VERSION_ARB
#define GLX_CONTEXT_MINOR_VERSION_ARB 0x2092
#endif
#ifndef GLX_CONTEXT_PROFILE_MASK_ARB
#define GLX_CONTEXT_PROFILE_MASK_ARB 0x9126
#endif
#ifndef GLX_CONTEXT_CORE_PROFILE_BIT_ARB
#define GLX_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001
#endif
typedef GLXContext (*XW_PFNGLXCREATECONTEXTATTRIBSARBPROC)(Display *, GLXFBConfig, GLXContext, Bool, const int *);

/* ---- GL constants that may not be in an old system <GL/gl.h> ---- */
#ifndef GL_VERTEX_SHADER
#define GL_VERTEX_SHADER 0x8B31
#endif
#ifndef GL_FRAGMENT_SHADER
#define GL_FRAGMENT_SHADER 0x8B30
#endif
#ifndef GL_COMPILE_STATUS
#define GL_COMPILE_STATUS 0x8B81
#endif
#ifndef GL_LINK_STATUS
#define GL_LINK_STATUS 0x8B82
#endif
#ifndef GL_ARRAY_BUFFER
#define GL_ARRAY_BUFFER 0x8892
#endif
#ifndef GL_STATIC_DRAW
#define GL_STATIC_DRAW 0x88E4
#endif
#ifndef GL_DYNAMIC_DRAW
#define GL_DYNAMIC_DRAW 0x88E8
#endif
#ifndef GL_FRAMEBUFFER
#define GL_FRAMEBUFFER 0x8D40
#endif
#ifndef GL_RENDERBUFFER
#define GL_RENDERBUFFER 0x8D41
#endif
#ifndef GL_COLOR_ATTACHMENT0
#define GL_COLOR_ATTACHMENT0 0x8CE0
#endif
#ifndef GL_DEPTH_ATTACHMENT
#define GL_DEPTH_ATTACHMENT 0x8D00
#endif
#ifndef GL_DEPTH_COMPONENT24
#define GL_DEPTH_COMPONENT24 0x81A6
#endif
#ifndef GL_FRAMEBUFFER_COMPLETE
#define GL_FRAMEBUFFER_COMPLETE 0x8CD5
#endif
#ifndef GL_TEXTURE0
#define GL_TEXTURE0 0x84C0
#endif
#ifndef GL_TEXTURE1
#define GL_TEXTURE1 0x84C1
#endif
#ifndef GL_CLAMP_TO_EDGE
#define GL_CLAMP_TO_EDGE 0x812F
#endif
#ifndef GL_RGBA8
#define GL_RGBA8 0x8058
#endif
#ifndef GL_BGRA
#define GL_BGRA 0x80E1
#endif

/* ---- hand-loaded GL 1.2+ function pointers (unique-prefixed typedefs) ---- */
typedef GLuint (*XW_PFNGLCREATESHADERPROC)(GLenum);
typedef void (*XW_PFNGLSHADERSOURCEPROC)(GLuint, GLsizei, const GLchar *const *, const GLint *);
typedef void (*XW_PFNGLCOMPILESHADERPROC)(GLuint);
typedef void (*XW_PFNGLGETSHADERIVPROC)(GLuint, GLenum, GLint *);
typedef void (*XW_PFNGLGETSHADERINFOLOGPROC)(GLuint, GLsizei, GLsizei *, GLchar *);
typedef void (*XW_PFNGLDELETESHADERPROC)(GLuint);
typedef GLuint (*XW_PFNGLCREATEPROGRAMPROC)(void);
typedef void (*XW_PFNGLATTACHSHADERPROC)(GLuint, GLuint);
typedef void (*XW_PFNGLLINKPROGRAMPROC)(GLuint);
typedef void (*XW_PFNGLGETPROGRAMIVPROC)(GLuint, GLenum, GLint *);
typedef void (*XW_PFNGLGETPROGRAMINFOLOGPROC)(GLuint, GLsizei, GLsizei *, GLchar *);
typedef void (*XW_PFNGLDELETEPROGRAMPROC)(GLuint);
typedef void (*XW_PFNGLUSEPROGRAMPROC)(GLuint);
typedef void (*XW_PFNGLGENVERTEXARRAYSPROC)(GLsizei, GLuint *);
typedef void (*XW_PFNGLBINDVERTEXARRAYPROC)(GLuint);
typedef void (*XW_PFNGLDELETEVERTEXARRAYSPROC)(GLsizei, const GLuint *);
typedef void (*XW_PFNGLGENBUFFERSPROC)(GLsizei, GLuint *);
typedef void (*XW_PFNGLBINDBUFFERPROC)(GLenum, GLuint);
typedef void (*XW_PFNGLBUFFERDATAPROC)(GLenum, ptrdiff_t, const void *, GLenum);
typedef void (*XW_PFNGLDELETEBUFFERSPROC)(GLsizei, const GLuint *);
typedef void (*XW_PFNGLENABLEVERTEXATTRIBARRAYPROC)(GLuint);
typedef void (*XW_PFNGLVERTEXATTRIBPOINTERPROC)(GLuint, GLint, GLenum, GLboolean, GLsizei, const void *);
typedef GLint (*XW_PFNGLGETUNIFORMLOCATIONPROC)(GLuint, const GLchar *);
typedef void (*XW_PFNGLUNIFORMMATRIX4FVPROC)(GLint, GLsizei, GLboolean, const GLfloat *);
typedef void (*XW_PFNGLUNIFORM1IPROC)(GLint, GLint);
typedef void (*XW_PFNGLUNIFORM1FPROC)(GLint, GLfloat);
typedef void (*XW_PFNGLUNIFORM2FPROC)(GLint, GLfloat, GLfloat);
typedef void (*XW_PFNGLUNIFORM3FPROC)(GLint, GLfloat, GLfloat, GLfloat);
typedef void (*XW_PFNGLACTIVETEXTUREPROC)(GLenum);
typedef void (*XW_PFNGLGENFRAMEBUFFERSPROC)(GLsizei, GLuint *);
typedef void (*XW_PFNGLBINDFRAMEBUFFERPROC)(GLenum, GLuint);
typedef void (*XW_PFNGLFRAMEBUFFERTEXTURE2DPROC)(GLenum, GLenum, GLenum, GLuint, GLint);
typedef void (*XW_PFNGLGENRENDERBUFFERSPROC)(GLsizei, GLuint *);
typedef void (*XW_PFNGLBINDRENDERBUFFERPROC)(GLenum, GLuint);
typedef void (*XW_PFNGLRENDERBUFFERSTORAGEPROC)(GLenum, GLenum, GLsizei, GLsizei);
typedef void (*XW_PFNGLFRAMEBUFFERRENDERBUFFERPROC)(GLenum, GLenum, GLenum, GLuint);
typedef GLenum (*XW_PFNGLCHECKFRAMEBUFFERSTATUSPROC)(GLenum);
typedef void (*XW_PFNGLDELETEFRAMEBUFFERSPROC)(GLsizei, const GLuint *);
typedef void (*XW_PFNGLDELETERENDERBUFFERSPROC)(GLsizei, const GLuint *);

static XW_PFNGLCREATESHADERPROC xglCreateShader;
static XW_PFNGLSHADERSOURCEPROC xglShaderSource;
static XW_PFNGLCOMPILESHADERPROC xglCompileShader;
static XW_PFNGLGETSHADERIVPROC xglGetShaderiv;
static XW_PFNGLGETSHADERINFOLOGPROC xglGetShaderInfoLog;
static XW_PFNGLDELETESHADERPROC xglDeleteShader;
static XW_PFNGLCREATEPROGRAMPROC xglCreateProgram;
static XW_PFNGLATTACHSHADERPROC xglAttachShader;
static XW_PFNGLLINKPROGRAMPROC xglLinkProgram;
static XW_PFNGLGETPROGRAMIVPROC xglGetProgramiv;
static XW_PFNGLGETPROGRAMINFOLOGPROC xglGetProgramInfoLog;
static XW_PFNGLDELETEPROGRAMPROC xglDeleteProgram;
static XW_PFNGLUSEPROGRAMPROC xglUseProgram;
static XW_PFNGLGENVERTEXARRAYSPROC xglGenVertexArrays;
static XW_PFNGLBINDVERTEXARRAYPROC xglBindVertexArray;
static XW_PFNGLDELETEVERTEXARRAYSPROC xglDeleteVertexArrays;
static XW_PFNGLGENBUFFERSPROC xglGenBuffers;
static XW_PFNGLBINDBUFFERPROC xglBindBuffer;
static XW_PFNGLBUFFERDATAPROC xglBufferData;
static XW_PFNGLDELETEBUFFERSPROC xglDeleteBuffers;
static XW_PFNGLENABLEVERTEXATTRIBARRAYPROC xglEnableVertexAttribArray;
static XW_PFNGLVERTEXATTRIBPOINTERPROC xglVertexAttribPointer;
static XW_PFNGLGETUNIFORMLOCATIONPROC xglGetUniformLocation;
static XW_PFNGLUNIFORMMATRIX4FVPROC xglUniformMatrix4fv;
static XW_PFNGLUNIFORM1IPROC xglUniform1i;
static XW_PFNGLUNIFORM1FPROC xglUniform1f;
static XW_PFNGLUNIFORM2FPROC xglUniform2f;
static XW_PFNGLUNIFORM3FPROC xglUniform3f;
static XW_PFNGLACTIVETEXTUREPROC xglActiveTexture;
static XW_PFNGLGENFRAMEBUFFERSPROC xglGenFramebuffers;
static XW_PFNGLBINDFRAMEBUFFERPROC xglBindFramebuffer;
static XW_PFNGLFRAMEBUFFERTEXTURE2DPROC xglFramebufferTexture2D;
static XW_PFNGLGENRENDERBUFFERSPROC xglGenRenderbuffers;
static XW_PFNGLBINDRENDERBUFFERPROC xglBindRenderbuffer;
static XW_PFNGLRENDERBUFFERSTORAGEPROC xglRenderbufferStorage;
static XW_PFNGLFRAMEBUFFERRENDERBUFFERPROC xglFramebufferRenderbuffer;
static XW_PFNGLCHECKFRAMEBUFFERSTATUSPROC xglCheckFramebufferStatus;
static XW_PFNGLDELETEFRAMEBUFFERSPROC xglDeleteFramebuffers;
static XW_PFNGLDELETERENDERBUFFERSPROC xglDeleteRenderbuffers;
static XW_PFNGLXCREATECONTEXTATTRIBSARBPROC xglXCreateContextAttribsARB;

static int load_gl_functions(void) {
#define LOAD(var, name) \
    var = (void *)glXGetProcAddressARB((const GLubyte *)name); \
    if (!var) { fprintf(stderr, "xwww(gl): missing GL function %s\n", name); return -1; }
    LOAD(xglCreateShader, "glCreateShader");
    LOAD(xglShaderSource, "glShaderSource");
    LOAD(xglCompileShader, "glCompileShader");
    LOAD(xglGetShaderiv, "glGetShaderiv");
    LOAD(xglGetShaderInfoLog, "glGetShaderInfoLog");
    LOAD(xglDeleteShader, "glDeleteShader");
    LOAD(xglCreateProgram, "glCreateProgram");
    LOAD(xglAttachShader, "glAttachShader");
    LOAD(xglLinkProgram, "glLinkProgram");
    LOAD(xglGetProgramiv, "glGetProgramiv");
    LOAD(xglGetProgramInfoLog, "glGetProgramInfoLog");
    LOAD(xglDeleteProgram, "glDeleteProgram");
    LOAD(xglUseProgram, "glUseProgram");
    LOAD(xglGenVertexArrays, "glGenVertexArrays");
    LOAD(xglBindVertexArray, "glBindVertexArray");
    LOAD(xglDeleteVertexArrays, "glDeleteVertexArrays");
    LOAD(xglGenBuffers, "glGenBuffers");
    LOAD(xglBindBuffer, "glBindBuffer");
    LOAD(xglBufferData, "glBufferData");
    LOAD(xglDeleteBuffers, "glDeleteBuffers");
    LOAD(xglEnableVertexAttribArray, "glEnableVertexAttribArray");
    LOAD(xglVertexAttribPointer, "glVertexAttribPointer");
    LOAD(xglGetUniformLocation, "glGetUniformLocation");
    LOAD(xglUniformMatrix4fv, "glUniformMatrix4fv");
    LOAD(xglUniform1i, "glUniform1i");
    LOAD(xglUniform1f, "glUniform1f");
    LOAD(xglUniform2f, "glUniform2f");
    LOAD(xglUniform3f, "glUniform3f");
    LOAD(xglActiveTexture, "glActiveTexture");
    LOAD(xglGenFramebuffers, "glGenFramebuffers");
    LOAD(xglBindFramebuffer, "glBindFramebuffer");
    LOAD(xglFramebufferTexture2D, "glFramebufferTexture2D");
    LOAD(xglGenRenderbuffers, "glGenRenderbuffers");
    LOAD(xglBindRenderbuffer, "glBindRenderbuffer");
    LOAD(xglRenderbufferStorage, "glRenderbufferStorage");
    LOAD(xglFramebufferRenderbuffer, "glFramebufferRenderbuffer");
    LOAD(xglCheckFramebufferStatus, "glCheckFramebufferStatus");
    LOAD(xglDeleteFramebuffers, "glDeleteFramebuffers");
    LOAD(xglDeleteRenderbuffers, "glDeleteRenderbuffers");
    LOAD(xglXCreateContextAttribsARB, "glXCreateContextAttribsARB");
#undef LOAD
    return 0;
}

/* ------------------------------------------------------------- state */

static Display *gdpy = NULL;
static Window gwin = 0;
static GLXContext gctx = 0;
static int gl_tried = 0, gl_ok = 0;

static GLuint fbo = 0, color_tex = 0, depth_rb = 0;
static int target_w = 0, target_h = 0;

static GLuint mesh_prog = 0, mesh_vao = 0, mesh_vbo = 0;
static GLint mesh_u_mvp = -1, mesh_u_model = -1, mesh_u_tex = -1;

static GLuint quad_vao = 0, quad_vbo = 0;

#define MAX_FRAG_PROGRAMS 32
static struct { int uid; GLuint prog; } frag_cache[MAX_FRAG_PROGRAMS];
static int frag_cache_n = 0;

/* ---------------------------------------------------------- shaders */

static const char *MESH_VERT_SRC =
    "#version 330 core\n"
    "layout(location=0) in vec3 aPos;\n"
    "layout(location=1) in vec2 aUV;\n"
    "layout(location=2) in vec3 aNormal;\n"
    "uniform mat4 uMVP;\n"
    "uniform mat4 uModel;\n"
    "out vec2 vUV;\n"
    "out vec3 vNormal;\n"
    "void main() {\n"
    "    gl_Position = uMVP * vec4(aPos, 1.0);\n"
    "    vUV = aUV;\n"
    "    vNormal = mat3(uModel) * aNormal;\n"
    "}\n";

static const char *MESH_FRAG_SRC =
    "#version 330 core\n"
    "in vec2 vUV;\n"
    "in vec3 vNormal;\n"
    "uniform sampler2D uTex;\n"
    "out vec4 FragColor;\n"
    "void main() {\n"
    "    vec3 n = normalize(vNormal);\n"
    "    vec3 lightDir = normalize(vec3(0.35, 0.55, 0.75));\n"
    "    float diff = max(dot(n, lightDir), 0.0);\n"
    "    float shade = 0.42 + 0.58 * diff;\n"
    "    vec4 c = texture(uTex, vUV);\n"
    "    FragColor = vec4(c.rgb * shade, 1.0);\n"
    "}\n";

static const char *QUAD_VERT_SRC =
    "#version 330 core\n"
    "layout(location=0) in vec2 aPos;\n"
    "out vec2 vUV;\n"
    "void main() {\n"
    "    vUV = aPos * 0.5 + 0.5;\n"
    "    gl_Position = vec4(aPos, 0.0, 1.0);\n"
    "}\n";

static GLuint compile_shader(GLenum type, const char *src) {
    GLuint s = xglCreateShader(type);
    xglShaderSource(s, 1, &src, NULL);
    xglCompileShader(s);
    GLint ok = 0;
    xglGetShaderiv(s, GL_COMPILE_STATUS, &ok);
    if (!ok) {
        char log[2048];
        GLsizei n = 0;
        xglGetShaderInfoLog(s, sizeof(log), &n, log);
        fprintf(stderr, "xwww(gl): shader compile error:\n%.*s\n", (int)n, log);
        xglDeleteShader(s);
        return 0;
    }
    return s;
}

static GLuint link_program(const char *vert_src, const char *frag_src) {
    GLuint vs = compile_shader(GL_VERTEX_SHADER, vert_src);
    if (!vs) return 0;
    GLuint fs = compile_shader(GL_FRAGMENT_SHADER, frag_src);
    if (!fs) { xglDeleteShader(vs); return 0; }
    GLuint prog = xglCreateProgram();
    xglAttachShader(prog, vs);
    xglAttachShader(prog, fs);
    xglLinkProgram(prog);
    GLint ok = 0;
    xglGetProgramiv(prog, GL_LINK_STATUS, &ok);
    xglDeleteShader(vs);
    xglDeleteShader(fs);
    if (!ok) {
        char log[2048];
        GLsizei n = 0;
        xglGetProgramInfoLog(prog, sizeof(log), &n, log);
        fprintf(stderr, "xwww(gl): program link error:\n%.*s\n", (int)n, log);
        xglDeleteProgram(prog);
        return 0;
    }
    return prog;
}

/* ------------------------------------------------------------- setup */

static int try_init(void) {
    gdpy = XOpenDisplay(NULL);
    if (!gdpy) return -1;
    int screen = DefaultScreen(gdpy);

    int fbattrs[] = {
        GLX_DRAWABLE_TYPE, GLX_WINDOW_BIT,
        GLX_RENDER_TYPE, GLX_RGBA_BIT,
        GLX_RED_SIZE, 8, GLX_GREEN_SIZE, 8, GLX_BLUE_SIZE, 8,
        GLX_DOUBLEBUFFER, True,
        None
    };
    int nfb = 0;
    GLXFBConfig *fbcs = glXChooseFBConfig(gdpy, screen, fbattrs, &nfb);
    if (!fbcs || nfb == 0) { fprintf(stderr, "xwww(gl): no suitable GLX framebuffer config\n"); return -1; }
    GLXFBConfig fbc = fbcs[0];
    XFree(fbcs);

    XVisualInfo *vi = glXGetVisualFromFBConfig(gdpy, fbc);
    if (!vi) { fprintf(stderr, "xwww(gl): no visual for chosen fbconfig\n"); return -1; }

    Window root = RootWindow(gdpy, screen);
    XSetWindowAttributes swa;
    swa.colormap = XCreateColormap(gdpy, root, vi->visual, AllocNone);
    swa.override_redirect = True;
    swa.event_mask = 0;
    gwin = XCreateWindow(gdpy, root, 0, 0, 1, 1, 0, vi->depth, InputOutput,
                          vi->visual, CWColormap | CWOverrideRedirect | CWEventMask, &swa);
    /* deliberately never XMapWindow()'d -- this window is never shown */

    if (load_gl_functions() != 0) {
        XFree(vi);
        return -1;
    }

    int ctxattrs[] = {
        GLX_CONTEXT_MAJOR_VERSION_ARB, 3,
        GLX_CONTEXT_MINOR_VERSION_ARB, 3,
        GLX_CONTEXT_PROFILE_MASK_ARB, GLX_CONTEXT_CORE_PROFILE_BIT_ARB,
        None
    };
    gctx = xglXCreateContextAttribsARB(gdpy, fbc, NULL, True, ctxattrs);
    XFree(vi);
    if (!gctx) { fprintf(stderr, "xwww(gl): failed to create GL 3.3 core context\n"); return -1; }

    if (!glXMakeCurrent(gdpy, gwin, gctx)) {
        fprintf(stderr, "xwww(gl): glXMakeCurrent failed\n");
        return -1;
    }

    mesh_prog = link_program(MESH_VERT_SRC, MESH_FRAG_SRC);
    if (!mesh_prog) return -1;
    mesh_u_mvp = xglGetUniformLocation(mesh_prog, "uMVP");
    mesh_u_model = xglGetUniformLocation(mesh_prog, "uModel");
    mesh_u_tex = xglGetUniformLocation(mesh_prog, "uTex");

    xglGenVertexArrays(1, &mesh_vao);
    xglBindVertexArray(mesh_vao);
    xglGenBuffers(1, &mesh_vbo);
    xglBindBuffer(GL_ARRAY_BUFFER, mesh_vbo);
    xglEnableVertexAttribArray(0);
    xglVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(glr_vertex_t), (void *)0);
    xglEnableVertexAttribArray(1);
    xglVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(glr_vertex_t), (void *)(3 * sizeof(float)));
    xglEnableVertexAttribArray(2);
    xglVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, sizeof(glr_vertex_t), (void *)(5 * sizeof(float)));

    static const float quad[12] = { -1,-1, 1,-1, -1,1, 1,-1, 1,1, -1,1 };
    xglGenVertexArrays(1, &quad_vao);
    xglBindVertexArray(quad_vao);
    xglGenBuffers(1, &quad_vbo);
    xglBindBuffer(GL_ARRAY_BUFFER, quad_vbo);
    xglBufferData(GL_ARRAY_BUFFER, sizeof(quad), quad, GL_STATIC_DRAW);
    xglEnableVertexAttribArray(0);
    xglVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, (void *)0);

    return 0;
}

int glr_available(void) {
    if (gl_tried) return gl_ok;
    gl_tried = 1;
    gl_ok = (try_init() == 0);
    if (!gl_ok) fprintf(stderr, "xwww(gl): GL rendering unavailable, effects needing it will fall back to CPU\n");
    return gl_ok;
}

int glr_set_target_size(int w, int h) {
    if (w == target_w && h == target_h && fbo) return 0;
    if (fbo) {
        xglDeleteFramebuffers(1, &fbo);
        glDeleteTextures(1, &color_tex);
        xglDeleteRenderbuffers(1, &depth_rb);
    }
    target_w = w; target_h = h;

    glGenTextures(1, &color_tex);
    glBindTexture(GL_TEXTURE_2D, color_tex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, w, h, 0, GL_BGRA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    xglGenRenderbuffers(1, &depth_rb);
    xglBindRenderbuffer(GL_RENDERBUFFER, depth_rb);
    xglRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, w, h);

    xglGenFramebuffers(1, &fbo);
    xglBindFramebuffer(GL_FRAMEBUFFER, fbo);
    xglFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, color_tex, 0);
    xglFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depth_rb);

    if (xglCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        fprintf(stderr, "xwww(gl): FBO incomplete\n");
        return -1;
    }
    glViewport(0, 0, w, h);
    return 0;
}

void glr_begin_frame(float r, float g, float b) {
    xglBindFramebuffer(GL_FRAMEBUFFER, fbo);
    glViewport(0, 0, target_w, target_h);
    glClearColor(r, g, b, 1.0f);
    glClearDepth(1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void glr_read_frame(buf_t *out) {
    *out = buf_alloc(target_w, target_h);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(0, 0, target_w, target_h, GL_BGRA, GL_UNSIGNED_BYTE, out->pix);
    /* GL's row 0 is the bottom of the image; buf_t's row 0 is the top --
     * flip vertically. */
    int w = target_w, h = target_h;
    for (int y = 0; y < h / 2; y++) {
        uint32_t *a = &out->pix[(size_t)y * w];
        uint32_t *b = &out->pix[(size_t)(h - 1 - y) * w];
        for (int x = 0; x < w; x++) { uint32_t tmp = a[x]; a[x] = b[x]; b[x] = tmp; }
    }
}

unsigned int glr_upload_texture(const buf_t *buf) {
    GLuint tex = 0;
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    /* buf_t rows run top-to-bottom; flip once on upload so UV (0,0) means
     * top-left everywhere in this codebase, GL convention aside. */
    int w = buf->w, h = buf->h;
    uint32_t *flipped = malloc((size_t)w * h * 4);
    for (int y = 0; y < h; y++)
        memcpy(&flipped[(size_t)(h - 1 - y) * w], &buf->pix[(size_t)y * w], (size_t)w * 4);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, w, h, 0, GL_BGRA, GL_UNSIGNED_BYTE, flipped);
    free(flipped);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    return tex;
}

void glr_delete_texture(unsigned int tex) {
    GLuint t = tex;
    if (t) glDeleteTextures(1, &t);
}

void glr_draw_mesh(const glr_vertex_t *verts, int count, unsigned int tex,
                    mat4_t mvp, mat4_t model, int depth_test) {
    if (depth_test) glEnable(GL_DEPTH_TEST); else glDisable(GL_DEPTH_TEST);
    xglUseProgram(mesh_prog);
    xglUniformMatrix4fv(mesh_u_mvp, 1, GL_FALSE, mvp.m);
    xglUniformMatrix4fv(mesh_u_model, 1, GL_FALSE, model.m);
    xglActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, tex);
    xglUniform1i(mesh_u_tex, 0);

    xglBindVertexArray(mesh_vao);
    xglBindBuffer(GL_ARRAY_BUFFER, mesh_vbo);
    xglBufferData(GL_ARRAY_BUFFER, (ptrdiff_t)(count * (int)sizeof(glr_vertex_t)), verts, GL_DYNAMIC_DRAW);
    glDrawArrays(GL_TRIANGLES, 0, count);
}

static GLuint get_frag_program(int frag_uid, const char *frag_src) {
    for (int i = 0; i < frag_cache_n; i++)
        if (frag_cache[i].uid == frag_uid) return frag_cache[i].prog;
    GLuint prog = link_program(QUAD_VERT_SRC, frag_src);
    if (prog && frag_cache_n < MAX_FRAG_PROGRAMS) {
        frag_cache[frag_cache_n].uid = frag_uid;
        frag_cache[frag_cache_n].prog = prog;
        frag_cache_n++;
    }
    return prog;
}

int glr_draw_fullscreen_frag(int frag_uid, const char *frag_src,
                              unsigned int from_tex, unsigned int to_tex,
                              const glr_frag_uniforms_t *u) {
    GLuint prog = get_frag_program(frag_uid, frag_src);
    if (!prog) return -1;

    glDisable(GL_DEPTH_TEST);
    xglUseProgram(prog);
    xglActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, from_tex);
    xglActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, to_tex);

    GLint loc;
    if ((loc = xglGetUniformLocation(prog, "uFromTex")) >= 0) xglUniform1i(loc, 0);
    if ((loc = xglGetUniformLocation(prog, "uToTex")) >= 0) xglUniform1i(loc, 1);
    if ((loc = xglGetUniformLocation(prog, "uT")) >= 0) xglUniform1f(loc, u->t);
    if ((loc = xglGetUniformLocation(prog, "uSeed")) >= 0) xglUniform1f(loc, u->seed);
    if ((loc = xglGetUniformLocation(prog, "uAmp")) >= 0) xglUniform1f(loc, u->amp);
    if ((loc = xglGetUniformLocation(prog, "uFreq")) >= 0) xglUniform1f(loc, u->freq);
    if ((loc = xglGetUniformLocation(prog, "uOrigin")) >= 0) xglUniform2f(loc, u->origin_x, u->origin_y);
    if ((loc = xglGetUniformLocation(prog, "uExtraA")) >= 0) xglUniform1f(loc, u->extra_a);
    if ((loc = xglGetUniformLocation(prog, "uExtraB")) >= 0) xglUniform1f(loc, u->extra_b);
    if ((loc = xglGetUniformLocation(prog, "uExtraI")) >= 0) xglUniform1i(loc, u->extra_i);
    if ((loc = xglGetUniformLocation(prog, "uAspect")) >= 0) xglUniform1f(loc, (float)target_w / (float)target_h);

    xglBindVertexArray(quad_vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    return 0;
}

void glr_shutdown(void) {
    if (!gl_tried || !gl_ok) return;
    if (gdpy && gctx) {
        glXMakeCurrent(gdpy, None, NULL);
        glXDestroyContext(gdpy, gctx);
    }
    if (gdpy && gwin) XDestroyWindow(gdpy, gwin);
    if (gdpy) XCloseDisplay(gdpy);
    gdpy = NULL; gctx = 0; gwin = 0;
    gl_tried = 0; gl_ok = 0;
}

#endif /* HAVE_GL */
