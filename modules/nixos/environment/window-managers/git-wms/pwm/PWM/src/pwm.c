#include <X11/Xatom.h>
#include <X11/XKBlib.h>
#include <X11/Xlib.h>
#include <X11/Xproto.h>
#include <X11/Xutil.h>
#ifdef HAVE_XRANDR
#include <X11/extensions/Xrandr.h>
#endif
#include <X11/cursorfont.h>
#include <X11/keysym.h>
#include <errno.h>
#include <locale.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#include "drw.h"
#include "util.h"

#define LENGTH(X)               (sizeof(X) / sizeof((X)[0]))
#define TAGMASK                 ((1u << LENGTH(tags)) - 1u)
#define BUTTONMASK              (ButtonPressMask|ButtonReleaseMask)
#define CLEANMASK(mask)         (mask & ~(numlockmask|LockMask) & (ShiftMask|ControlMask|Mod1Mask|Mod2Mask|Mod3Mask|Mod4Mask|Mod5Mask))
#define WIDTH(X)                ((X)->w + 2 * (X)->bw)
#define HEIGHT(X)               ((X)->h + 2 * (X)->bw)
#define INTERSECT(x,y,w,h,m)    (MAX(0, MIN((x)+(w), (m)->wx+(m)->ww) - MAX((x), (m)->wx)) \
                               * MAX(0, MIN((y)+(h), (m)->wy+(m)->wh) - MAX((y), (m)->wy)))
#define INTERSECTM(x,y,w,h,m)   (MAX(0, MIN((x)+(w), (m)->mx+(m)->mw) - MAX((x), (m)->mx)) \
                               * MAX(0, MIN((y)+(h), (m)->my+(m)->mh) - MAX((y), (m)->my)))
#define MOUSEMASK               (BUTTONMASK|PointerMotionMask)
#define ISVISIBLE(C)            ((C)->tags & (C)->mon->tagset[(C)->mon->seltags])
#define SPTAG(i)                (1u << (LENGTH(tags) + (i)))
#define SPTAGMASK               (SPTAG(0))
#define MAX(A,B)                ((A) > (B) ? (A) : (B))
#define MIN(A,B)                ((A) < (B) ? (A) : (B))

enum { CurNormal, CurResize, CurMove, CurLast };
enum { SchemeNorm, SchemeSel };
enum { NetSupported, NetWMName, NetWMState, NetWMCheck, NetWMFullscreen, NetActiveWindow, NetLast };
enum { WMProtocols, WMDelete, WMState, WMTakeFocus, WMLast };
enum { ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, ClkRootWin, ClkLast };

typedef union {
    int i;
    unsigned int ui;
    float f;
    const void *v;
} Arg;

typedef struct Client Client;
typedef struct Monitor Monitor;

struct Client {
    char name[256];
    int x, y, w, h;
    int oldx, oldy, oldw, oldh;
    int basew, baseh, incw, inch, maxw, maxh, minw, minh;
    int bw, oldbw;
    unsigned int tags;
    int isfixed, isfloating, isurgent, neverfocus, oldstate, isfullscreen;
    Window win;
    Client *next;
    Client *snext;
    Monitor *mon;
};

typedef struct {
    unsigned int nmaster;
    float mfact;
    int showbar;
    int topbar;
    unsigned int sellt;
    const void *ltidxs[2];
} Pertag;

typedef struct {
    const char *symbol;
    void (*arrange)(Monitor *);
} Layout;

struct Monitor {
    char ltsymbol[16];
    float mfact;
    int nmaster;
    int num;
    int by;
    int mx, my, mw, mh;
    int wx, wy, ww, wh;
    int gappih, gappiv, gappoh, gappov;
    unsigned int seltags;
    unsigned int sellt;
    unsigned int tagset[2];
    int showbar;
    int topbar;
    Client *clients;
    Client *sel;
    Client *stack;
    Monitor *next;
    Window barwin;
    const Layout *lt[2];
    Pertag *pertag;
};

typedef struct {
    const char *class;
    const char *instance;
    const char *title;
    unsigned int tags;
    int isfloating;
    int monitor;
} Rule;

typedef struct {
    unsigned int mod;
    KeySym keysym;
    void (*func)(const Arg *);
    const Arg arg;
} Key;

typedef struct {
    unsigned int click;
    unsigned int mask;
    unsigned int button;
    void (*func)(const Arg *arg);
    const Arg arg;
} Button;

static void applyrules(Client *c);
static int applysizehints(Client *c, int *x, int *y, int *w, int *h, int interact);
static void arrange(Monitor *m);
static void arrangemon(Monitor *m);
static void attach(Client *c);
static void attachstack(Client *c);
static void buttonpress(XEvent *e);
static void checkotherwm(void);
static void cleanup(void);
static void cleanupmon(Monitor *mon);
static void clientmessage(XEvent *e);
static void configure(Client *c);
static void configurenotify(XEvent *e);
static void configurerequest(XEvent *e);
static Monitor *createmon(void);
static void destroynotify(XEvent *e);
static void detach(Client *c);
static void detachstack(Client *c);
static Monitor *dirtomon(int dir);
static void drawbar(Monitor *m);
static void drawbars(void);
static void enternotify(XEvent *e);
static void expose(XEvent *e);
static void focus(Client *c);
static void focusin(XEvent *e);
static void focusmon(const Arg *arg);
static void focusstack(const Arg *arg);
static int getrootptr(int *x, int *y);
static long getstate(Window w);
static int gettextprop(Window w, Atom atom, char *text, unsigned int size);
static void grabbuttons(Client *c, int focused);
static void grabkeys(void);
static void incnmaster(const Arg *arg);
static void incrgaps(const Arg *arg);
static void keypress(XEvent *e);
static void killclient(const Arg *arg);
static void manage(Window w, XWindowAttributes *wa);
static void mappingnotify(XEvent *e);
static void maprequest(XEvent *e);
static void mapnotify(XEvent *e);
static void maxview(Monitor *m);
static void motionnotify(XEvent *e);
static void movemouse(const Arg *arg);
static Client *nexttiled(Client *c);
static void pop(Client *c);
static void propertynotify(XEvent *e);
static void quit(const Arg *arg);
static void resize(Client *c, int x, int y, int w, int h, int interact);
static void resizeclient(Client *c, int x, int y, int w, int h);
static void resizemouse(const Arg *arg);
static void restack(Monitor *m);
static void refreshscreen(void);
#ifdef HAVE_XRANDR
static void rrscreenchange(XEvent *e);
#endif
static void run(void);
static void scan(void);
static int sendevent(Client *c, Atom proto);
static void sendmon(Client *c, Monitor *m);
static void setclientstate(Client *c, long state);
static void setfocus(Client *c);
static void setlayout(const Arg *arg);
static void setmfact(const Arg *arg);
static void setup(void);
static void seturgent(Client *c, int urg);
static void showhide(Client *c);
static void spawn(const Arg *arg);
static void tag(const Arg *arg);
static void tagmon(const Arg *arg);
static void tile(Monitor *m);
static void togglebar(const Arg *arg);
static void togglefloating(const Arg *arg);
static void togglegaps(const Arg *arg);
static void togglescratch(const Arg *arg);
static void toggletag(const Arg *arg);
static void toggleview(const Arg *arg);
static void unfocus(Client *c, int setfocusroot);
static void unmanage(Client *c, int destroyed);
static void unmapnotify(XEvent *e);
static void updatebarpos(Monitor *m);
static void updatebars(void);
static void updateclientlist(void);
static void updatedesktopprops(void);
static void updategeom(void);
static Monitor *recttomon(int x, int y, int w, int h);
static Monitor *wintomon(Window w);
static void drwresize(void);
static void rootdims(int *w, int *h);
static void syncmonsgeom(int nn, int *rx, int *ry, int *rw, int *rh);
static void mapbars(void);
static void attachmon(Monitor *m);
static int nmonitors(void);
static int geommatch(int nn, int *rx, int *ry, int *rw, int *rh);
static int selmonidx(void);
static Monitor *montagnth(int idx);
static int tagtomonidx(int tagnum);
static unsigned int tagsformon(Monitor *m);
static unsigned int defaulttagformon(Monitor *m);
static void clienttotagmon(Client *c);
static void updatenumlockmask(void);
static void updatestatus(void);
static void updatetitle(Client *c);
static void updatewmhints(Client *c);
static void view(const Arg *arg);
static Client *wintoclient(Window w);
static int xerror(Display *dpy, XErrorEvent *ee);
static int xerrordummy(Display *dpy, XErrorEvent *ee);
static int xerrorstart(Display *dpy, XErrorEvent *ee);
static void zoom(const Arg *arg);

static int screen;
static int sw, sh;
static int bh;
static int running = 1;
static int numlockmask = 0;
static int ignoregaps = 0;
static int (*xerrorxlib)(Display *, XErrorEvent *);
static unsigned long normbg, normfg, selbg, selfg;
static char stext[256];
static unsigned int scratchtag = 0;
static Cursor cursor[CurLast];
static Display *dpy;
static Drw *drw;
static Monitor *mons, *selmon;
static Window root, wmcheckwin;
static Window dmenuwin;
static int dmenu_active;
static int dmenu_bar_restore;
static Atom wmatom[WMLast], netatom[NetLast];
static int bhpad = 0;
static float ui_scale_runtime = 1.0f;
static int borderpx_scaled = 1;
static int snap_scaled = 1;
#ifdef HAVE_XRANDR
static int rr_event_base = -1;
static int rr_error_base = -1;
#endif

#include "config.def.h"

static void (*handler[LASTEvent])(XEvent *) = {
    [ButtonPress] = buttonpress,
    [ClientMessage] = clientmessage,
    [ConfigureNotify] = configurenotify,
    [ConfigureRequest] = configurerequest,
    [DestroyNotify] = destroynotify,
    [EnterNotify] = enternotify,
    [Expose] = expose,
    [FocusIn] = focusin,
    [KeyPress] = keypress,
    [MappingNotify] = mappingnotify,
    [MapNotify] = mapnotify,
    [MapRequest] = maprequest,
    [MotionNotify] = motionnotify,
    [PropertyNotify] = propertynotify,
    [UnmapNotify] = unmapnotify
};

static int
scaleui(int value)
{
    int scaled = (int)((float)value * ui_scale_runtime + 0.5f);
    return MAX(1, scaled);
}

static void
applyrules(Client *c)
{
    XClassHint ch = { NULL, NULL };
    int pinmon = 0;
    c->isfloating = 0;
    c->tags = 0;
    if (XGetClassHint(dpy, c->win, &ch)) {
        for (unsigned int i = 0; i < LENGTH(rules); i++) {
            const Rule *r = &rules[i];
            if ((!r->title || strstr(c->name, r->title))
            && (!r->class || (ch.res_class && strstr(ch.res_class, r->class)))
            && (!r->instance || (ch.res_name && strstr(ch.res_name, r->instance)))) {
                c->isfloating = r->isfloating;
                c->tags |= r->tags;
                if (r->monitor >= 0) {
                    int k;
                    Monitor *mm;
                    for (k = 0, mm = mons; mm && k < r->monitor; mm = mm->next, k++);
                    if (mm) {
                        c->mon = mm;
                        pinmon = 1;
                    }
                }
            }
        }
    }
    if (ch.res_class) XFree(ch.res_class);
    if (ch.res_name) XFree(ch.res_name);
    c->tags = c->tags & TAGMASK ? c->tags & TAGMASK : c->mon->tagset[c->mon->seltags];
    if (per_monitor_ws && !pinmon)
        clienttotagmon(c);
}

static int
applysizehints(Client *c, int *x, int *y, int *w, int *h, int interact)
{
    *w = MAX(1, *w);
    *h = MAX(1, *h);
    if (interact) {
        if (*x > sw) *x = sw - WIDTH(c);
        if (*y > sh) *y = sh - HEIGHT(c);
        if (*x + *w + 2 * c->bw < 0) *x = 0;
        if (*y + *h + 2 * c->bw < 0) *y = 0;
    } else {
        Monitor *m = c->mon;
        if (*x >= m->wx + m->ww) *x = m->wx + m->ww - WIDTH(c);
        if (*y >= m->wy + m->wh) *y = m->wy + m->wh - HEIGHT(c);
        if (*x + *w + 2 * c->bw <= m->wx) *x = m->wx;
        if (*y + *h + 2 * c->bw <= m->wy) *y = m->wy;
    }
    if (*h < bh) *h = bh;
    if (*w < bh) *w = bh;
    return 1;
}

static void
arrange(Monitor *m)
{
    if (m)
        showhide(m->stack);
    else for (m = mons; m; m = m->next)
        showhide(m->stack);
    if (m)
        arrangemon(m);
    else for (m = mons; m; m = m->next)
        arrangemon(m);
}

static void arrangemon(Monitor *m) {
    strncpy(m->ltsymbol, m->lt[m->sellt]->symbol, sizeof m->ltsymbol - 1);
    if (m->lt[m->sellt]->arrange)
        m->lt[m->sellt]->arrange(m);
    restack(m);
}

static void attach(Client *c) { c->next = c->mon->clients; c->mon->clients = c; }
static void attachstack(Client *c) { c->snext = c->mon->stack; c->mon->stack = c; }

static void
buttonpress(XEvent *e)
{
    XButtonPressedEvent *ev = &e->xbutton;
    Monitor *m;
    for (m = mons; m; m = m->next) {
        if (ev->window != m->barwin || ev->button != Button1)
            continue;
        selmon = m;
        int x = 4;
        for (unsigned int i = 0; i < LENGTH(tags); i++) {
            if (per_monitor_ws && tagtomonidx((int)i) != m->num)
                continue;
            char buf[256];
            snprintf(buf, sizeof buf, "%s%s%s", (m->tagset[m->seltags] & 1u<<i) ? "[" : "",
                     tags[i], (m->tagset[m->seltags] & 1u<<i) ? "]" : "");
            int tw = (int)drw_font_getwidth(drw, buf) + 12;
            if (ev->x < x + tw) {
                Arg a = {.ui = 1u << i};
                view(&a);
                return;
            }
            x += tw + 2;
        }
        return;
    }
    if (ev->window == root && ev->button == Button3) {
        Arg a = {.v = dmenucmd};
        spawn(&a);
        return;
    }
    Client *c = wintoclient(ev->window);
    if (!c)
        return;
    focus(c);
    if ((ev->state & MODKEY) && ev->button == Button1
    && (!c->mon->lt[c->mon->sellt]->arrange || c->isfloating))
        movemouse(NULL);
    else if ((ev->state & MODKEY) && ev->button == Button3
    && (!c->mon->lt[c->mon->sellt]->arrange || c->isfloating))
        resizemouse(NULL);
}

static void checkotherwm(void) {
    xerrorxlib = XSetErrorHandler(xerrorstart);
    XSelectInput(dpy, DefaultRootWindow(dpy), SubstructureRedirectMask);
    XSync(dpy, False);
    XSetErrorHandler(xerrorxlib);
    XSync(dpy, False);
}

static void
cleanup(void)
{
    Monitor *m;
    XUngrabKey(dpy, AnyKey, AnyModifier, root);
    while (mons) {
        while (mons->stack)
            unmanage(mons->stack, 0);
        m = mons->next;
        cleanupmon(mons);
        mons = m;
    }
    XDestroyWindow(dpy, wmcheckwin);
    drw_free(drw);
}

static void cleanupmon(Monitor *mon) {
    if (mon->pertag) free(mon->pertag);
    if (mon->barwin) {
        XDestroyWindow(dpy, mon->barwin);
        mon->barwin = 0;
    }
    free(mon);
}

static void
clientmessage(XEvent *e)
{
    XClientMessageEvent *cme = &e->xclient;
    if (cme->message_type == netatom[NetActiveWindow]) {
        Client *c = wintoclient(cme->window);
        if (c) {
            focus(c);
            restack(c->mon);
        }
    }
}

static void configure(Client *c) {
    XConfigureEvent ce;
    ce.type = ConfigureNotify;
    ce.display = dpy;
    ce.event = c->win;
    ce.window = c->win;
    ce.x = c->x; ce.y = c->y;
    ce.width = c->w; ce.height = c->h;
    ce.border_width = c->bw;
    ce.above = None;
    ce.override_redirect = False;
    XSendEvent(dpy, c->win, False, StructureNotifyMask, (XEvent *)&ce);
}

static void
configurerequest(XEvent *e)
{
    XConfigureRequestEvent *ev = &e->xconfigurerequest;
    XWindowChanges wc;
    Client *c = wintoclient(ev->window);
    if (c) {
        if (ev->value_mask & CWBorderWidth) c->bw = ev->border_width;
        if (c->isfloating || !c->mon->lt[c->mon->sellt]->arrange) {
            Monitor *m = c->mon;
            if (ev->value_mask & CWX) c->x = ev->x;
            if (ev->value_mask & CWY) c->y = ev->y;
            if (ev->value_mask & CWWidth) c->w = ev->width;
            if (ev->value_mask & CWHeight) c->h = ev->height;
            if ((c->x + c->w) > m->wx + m->ww && c->isfloating)
                c->x = m->wx + (m->ww / 2 - WIDTH(c) / 2);
            if ((c->y + c->h) > m->wy + m->wh && c->isfloating)
                c->y = m->wy + (m->wh / 2 - HEIGHT(c) / 2);
            if ((ev->value_mask & (CWX|CWY)) && !(ev->value_mask & (CWWidth|CWHeight)))
                configure(c);
            if (ISVISIBLE(c))
                XMoveResizeWindow(dpy, c->win, c->x, c->y, c->w, c->h);
        } else configure(c);
    } else {
        wc.x = ev->x; wc.y = ev->y;
        wc.width = ev->width; wc.height = ev->height;
        wc.border_width = ev->border_width;
        wc.sibling = ev->above; wc.stack_mode = ev->detail;
        XConfigureWindow(dpy, ev->window, ev->value_mask, &wc);
    }
    XSync(dpy, False);
}

static void
configurenotify(XEvent *e)
{
    XConfigureEvent *ev = &e->xconfigure;

    if (ev->window != root)
        return;
    refreshscreen();
}

#ifdef HAVE_XRANDR
static void
rrscreenchange(XEvent *e)
{
    XRRUpdateConfiguration(e);
    refreshscreen();
}
#endif

static void
refreshscreen(void)
{
    updategeom();
}

static Monitor *
createmon(void)
{
    Monitor *m = ecalloc(1, sizeof(*m));
    m->tagset[0] = m->tagset[1] = 1;
    m->mfact = 0.55f;
    m->nmaster = 1;
    m->showbar = showbar;
    m->topbar = topbar;
    m->gappih = scaleui((int)gappih);
    m->gappiv = scaleui((int)gappiv);
    m->gappoh = scaleui((int)gappoh);
    m->gappov = scaleui((int)gappov);
    m->lt[0] = &layouts[0];
    m->lt[1] = &layouts[1];
    strncpy(m->ltsymbol, layouts[0].symbol, sizeof m->ltsymbol - 1);
    m->pertag = ecalloc(1, sizeof(Pertag));
    m->pertag->nmaster = m->nmaster;
    m->pertag->mfact = m->mfact;
    m->pertag->showbar = m->showbar;
    m->pertag->topbar = m->topbar;
    m->pertag->sellt = m->sellt;
    m->pertag->ltidxs[0] = m->lt[0];
    m->pertag->ltidxs[1] = m->lt[1];
    return m;
}

static int
nmonitors(void)
{
    int n = 0;
    Monitor *m;
    for (m = mons; m; m = m->next)
        n++;
    return n;
}

static void
attachmon(Monitor *m)
{
    m->next = NULL;
    if (!mons) {
        mons = m;
        return;
    }
    Monitor *p;
    for (p = mons; p->next; p = p->next);
    p->next = m;
}

static Monitor *
recttomon(int x, int y, int w, int h)
{
    Monitor *m, *r = mons;
    unsigned int a, area = 0;
    if (!mons)
        return NULL;
    for (m = mons; m; m = m->next) {
        a = INTERSECTM(x, y, w, h, m);
        if (a > area) {
            area = a;
            r = m;
        }
    }
    return r;
}

static Monitor *
wintomon(Window w)
{
    XWindowAttributes wa;
    if (XGetWindowAttributes(dpy, w, &wa))
        return recttomon(wa.x, wa.y, wa.width, wa.height);
    return mons;
}

static void
drwresize(void)
{
    unsigned int mw = (unsigned)MAX(sw, 1);
    Monitor *m;
    for (m = mons; m; m = m->next) {
        unsigned int w = (unsigned)MAX(m->ww, 1);
        unsigned int miw = (unsigned)MAX(m->mw, 1);
        if (w > mw) mw = w;
        if (miw > mw) mw = miw;
    }
    drw_resize(drw, mw, (unsigned)MAX(bh, 1));
}

static void
rootdims(int *w, int *h)
{
    XWindowAttributes wa;

    if (XGetWindowAttributes(dpy, root, &wa) && wa.width > 0 && wa.height > 0) {
        *w = wa.width;
        *h = wa.height;
        return;
    }
    *w = DisplayWidth(dpy, screen);
    *h = DisplayHeight(dpy, screen);
}

static void
syncmonsgeom(int nn, int *rx, int *ry, int *rw, int *rh)
{
    int i;
    Monitor *m;

    for (i = 0, m = mons; m && i < nn; m = m->next, i++) {
        m->mx = rx[i];
        m->my = ry[i];
        m->mw = rw[i];
        m->mh = rh[i];
        updatebarpos(m);
    }
}

static void
mapbars(void)
{
    Monitor *m;

    for (m = mons; m; m = m->next) {
        if (!m->barwin)
            continue;
        XMoveResizeWindow(dpy, m->barwin, m->wx, m->by, m->ww, bh);
    }
}

static int
geommatch(int nn, int *rx, int *ry, int *rw, int *rh)
{
    int i;
    Monitor *m;
    if (!mons || nn != nmonitors()) return 0;
    for (i = 0, m = mons; m && i < nn; m = m->next, i++) {
        if (m->mx != rx[i] || m->my != ry[i] || m->mw != rw[i] || m->mh != rh[i])
            return 0;
    }
    return 1;
}

static int
selmonidx(void)
{
    int i = 0;
    Monitor *m;
    if (!selmon) return 0;
    for (m = mons; m && m != selmon; m = m->next) i++;
    return i;
}

static Monitor *
montagnth(int idx)
{
    Monitor *m;
    int k;
    for (m = mons, k = 0; m && k < idx; m = m->next, k++);
    return m ? m : mons;
}

static int
tagtomonidx(int tagnum)
{
    int n;
    if (tagnum < 0 || (unsigned)tagnum >= LENGTH(tags))
        return 0;
    if (!per_monitor_ws)
        return 0;
    n = nmonitors();
    if (n < 1)
        return 0;
    if ((unsigned)tagnum < LENGTH(tags) && tagmonmap[tagnum] >= 0)
        return tagmonmap[tagnum] % n;
    return tagnum % n;
}

static unsigned int
tagsformon(Monitor *m)
{
    unsigned int mask = 0;
    unsigned int i;
    if (!m || !per_monitor_ws)
        return TAGMASK;
    for (i = 0; i < LENGTH(tags); i++) {
        if (tagtomonidx((int)i) == m->num)
            mask |= 1u << i;
    }
    if (!mask)
        mask = 1u;
    return mask;
}

static unsigned int
defaulttagformon(Monitor *m)
{
    unsigned int i;
    if (!m || !per_monitor_ws)
        return 1u;
    for (i = 0; i < LENGTH(tags); i++) {
        if (tagtomonidx((int)i) == m->num)
            return 1u << i;
    }
    return 1u;
}

static void
clienttotagmon(Client *c)
{
    Monitor *tm;
    unsigned int i;
    if (!per_monitor_ws || !c || !(c->tags & TAGMASK))
        return;
    for (i = 0; i < LENGTH(tags); i++) {
        if (c->tags & (1u << i))
            break;
    }
    if (i >= LENGTH(tags))
        return;
    tm = montagnth(tagtomonidx((int)i));
    if (tm)
        c->mon = tm;
}

static void destroynotify(XEvent *e) {
    XDestroyWindowEvent *ev = &e->xdestroywindow;
    Client *c = wintoclient(ev->window);
    if (c) unmanage(c, 1);
}

static void detach(Client *c) {
    Client **tc;
    for (tc = &c->mon->clients; *tc && *tc != c; tc = &(*tc)->next);
    *tc = c->next;
}

static void detachstack(Client *c) {
    Client **tc, *t;
    for (tc = &c->mon->stack; *tc && *tc != c; tc = &(*tc)->snext);
    *tc = c->snext;
    if (c == c->mon->sel) {
        for (t = c->mon->stack; t && !ISVISIBLE(t); t = t->snext);
        c->mon->sel = t;
    }
}

static Monitor *
dirtomon(int dir)
{
    if (dir > 0)
        return selmon->next ? selmon->next : mons;
    Monitor *m;
    for (m = mons; m->next != selmon && m->next; m = m->next);
    return m;
}

static void
drawbar(Monitor *m)
{
    const char *modesymbol = (m->lt[m->sellt] && m->lt[m->sellt]->symbol) ? m->lt[m->sellt]->symbol : "UNK";
    int x = 4;
    int tw;
    int statusw = 0;
    int brandw = 0;
    int brandx = 0;
    int statusx = 0;
    int titlew;
    char buf[256];
    drw_setscheme(drw, normfg, normbg);
    drw_rect(drw, 0, 0, m->ww, bh, 1);
    for (unsigned int i = 0; i < LENGTH(tags); i++) {
        if (per_monitor_ws && tagtomonidx((int)i) != m->num)
            continue;
        snprintf(buf, sizeof buf, "%s%s%s", (m->tagset[m->seltags] & 1u<<i) ? "[" : "",
                 tags[i], (m->tagset[m->seltags] & 1u<<i) ? "]" : "");
        tw = (int)drw_font_getwidth(drw, buf) + 12;
        if (x + tw > m->ww - 120)
            break;
        snprintf(buf, sizeof buf, "%s%s%s", (m->tagset[m->seltags] & 1u<<i) ? "[" : "",
                 tags[i], (m->tagset[m->seltags] & 1u<<i) ? "]" : "");
        drw_setscheme(drw,
            (m->tagset[m->seltags] & 1u<<i) ? selfg : normfg,
            (m->tagset[m->seltags] & 1u<<i) ? selbg : normbg);
        drw_text(drw, x, 0, (unsigned int)tw, bh, buf);
        x += tw + 2;
    }
    drw_setscheme(drw, selfg, selbg);
    tw = (int)drw_font_getwidth(drw, modesymbol) + 14;
    drw_text(drw, x, 0, (unsigned int)tw, bh, modesymbol);
    x += tw + 8;
    brandw = (int)drw_font_getwidth(drw, "pwm") + 14;
    brandx = m->ww - brandw - 2;
    if (brandx < x)
        brandx = x;
    statusw = (int)drw_font_getwidth(drw, stext) + 18;
    if (statusw < 120)
        statusw = 120;
    if (statusw > (brandx - x) / 2)
        statusw = (brandx - x) / 2;
    if (statusw < 0)
        statusw = 0;
    statusx = brandx - statusw - 2;
    titlew = statusx - x - 2;
    if (titlew < 0)
        titlew = 0;
    if (m->sel) {
        drw_setscheme(drw, selfg, selbg);
        drw_text(drw, x, 0, (unsigned int)titlew, bh, m->sel->name);
    }
    drw_setscheme(drw, normfg, normbg);
    if (statusw > 0)
        drw_text(drw, statusx, 0, (unsigned int)statusw, bh, stext);
    drw_setscheme(drw, selfg, selbg);
    drw_text(drw, brandx, 0, (unsigned int)brandw, bh, "pwm");
    drw_map(drw, m->barwin, 0, 0, m->ww, bh);
}

static void drawbars(void) { for (Monitor *m = mons; m; m = m->next) drawbar(m); }

static void enternotify(XEvent *e) {
    XCrossingEvent *ev = &e->xcrossing;
    if ((ev->mode != NotifyNormal || ev->detail == NotifyInferior) && ev->window != root) return;
    Client *c = wintoclient(ev->window);
    if (c && c != selmon->sel) focus(c);
}

static void expose(XEvent *e) {
    XExposeEvent *ev = &e->xexpose;
    Monitor *m;
    if (ev->count != 0) return;
    for (m = mons; m; m = m->next) {
        if (m->barwin == ev->window) {
            drawbar(m);
            return;
        }
    }
}

static void
focus(Client *c)
{
    if (!c || !ISVISIBLE(c))
        for (c = selmon->stack; c && !ISVISIBLE(c); c = c->snext);
    if (selmon->sel && selmon->sel != c)
        unfocus(selmon->sel, 0);
    if (c) {
        if (c->mon != selmon) selmon = c->mon;
        if (c->isurgent) seturgent(c, 0);
        detachstack(c);
        attachstack(c);
        grabbuttons(c, 1);
        XSetWindowBorder(dpy, c->win, selbg);
        setfocus(c);
    } else {
        XSetInputFocus(dpy, root, RevertToPointerRoot, CurrentTime);
        XDeleteProperty(dpy, root, netatom[NetActiveWindow]);
    }
    selmon->sel = c;
    drawbars();
}

static void focusin(XEvent *e) { (void)e; }
static void
focusmon(const Arg *arg)
{
    Monitor *m;
    if (!mons->next) return;
    if (arg->i > 0) {
        m = selmon->next ? selmon->next : mons;
    } else {
        for (m = mons; m->next != selmon && m->next; m = m->next);
    }
    unfocus(selmon->sel, 0);
    selmon = m;
    focus(NULL);
}
static void
focusstack(const Arg *arg)
{
    Client *c = NULL, *i;
    if (!selmon->sel) return;
    if (arg->i > 0) {
        for (c = selmon->sel->snext; c && !ISVISIBLE(c); c = c->snext);
        if (!c) for (c = selmon->stack; c && !ISVISIBLE(c); c = c->snext);
    } else {
        for (i = selmon->stack; i != selmon->sel; i = i->snext)
            if (ISVISIBLE(i)) c = i;
        if (!c)
            for (; i; i = i->snext)
                if (ISVISIBLE(i)) c = i;
    }
    if (c) {
        focus(c);
        restack(c->mon);
    }
}

static int getrootptr(int *x, int *y) {
    int di; unsigned int dui; Window dummy;
    return XQueryPointer(dpy, root, &dummy, &dummy, x, y, &di, &di, &dui);
}

static long getstate(Window w) {
    int format; long result = -1; unsigned char *p = NULL;
    unsigned long n, extra; Atom real;
    if (XGetWindowProperty(dpy, w, wmatom[WMState], 0L, 2L, False, wmatom[WMState],
                           &real, &format, &n, &extra, (unsigned char **)&p) != Success)
        return -1;
    if (n != 0) result = *p;
    XFree(p);
    return result;
}

static int gettextprop(Window w, Atom atom, char *text, unsigned int size) {
    char **list = NULL; int n; XTextProperty name;
    if (!text || size == 0) return 0;
    text[0] = '\0';
    if (!XGetTextProperty(dpy, w, &name, atom) || !name.nitems) return 0;
    if (name.encoding == XA_STRING) strncpy(text, (char *)name.value, size - 1);
    else if (XmbTextPropertyToTextList(dpy, &name, &list, &n) >= Success && n > 0 && *list) {
        strncpy(text, *list, size - 1);
        XFreeStringList(list);
    }
    text[size - 1] = '\0';
    XFree(name.value);
    return 1;
}

static void
grabbuttons(Client *c, int focused)
{
    unsigned int modifiers[] = {0, LockMask, numlockmask, numlockmask|LockMask};
    XUngrabButton(dpy, AnyButton, AnyModifier, c->win);
    if (!focused)
        XGrabButton(dpy, AnyButton, AnyModifier, c->win, False,
                    BUTTONMASK, GrabModeSync, GrabModeSync, None, None);
    for (unsigned int i = 0; i < LENGTH(buttons); i++) {
        if (buttons[i].click != ClkClientWin)
            continue;
        for (unsigned int j = 0; j < LENGTH(modifiers); j++)
            XGrabButton(dpy, buttons[i].button, buttons[i].mask | modifiers[j], c->win, False,
                        BUTTONMASK, GrabModeAsync, GrabModeSync, None, None);
    }
}

static void
grabkeys(void)
{
    updatenumlockmask();
    unsigned int modifiers[] = {0, LockMask, numlockmask, numlockmask|LockMask};
    XUngrabKey(dpy, AnyKey, AnyModifier, root);
    for (unsigned int i = 0; i < LENGTH(keys); i++) {
        KeyCode code = XKeysymToKeycode(dpy, keys[i].keysym);
        for (unsigned int j = 0; j < LENGTH(modifiers); j++)
            XGrabKey(dpy, code, keys[i].mod | modifiers[j], root, True, GrabModeAsync, GrabModeAsync);
    }
}

static void incnmaster(const Arg *arg) { selmon->nmaster = MAX(selmon->nmaster + arg->i, 0); arrange(selmon); }
static int gapstep(void) { return scaleui(1); }

static void incrgaps(const Arg *arg) {
    int d = gapstep() * arg->i;
    selmon->gappih = MAX(0, selmon->gappih + d);
    selmon->gappiv = MAX(0, selmon->gappiv + d);
    selmon->gappoh = MAX(0, selmon->gappoh + d);
    selmon->gappov = MAX(0, selmon->gappov + d);
    arrange(selmon);
}

static void
keypress(XEvent *e)
{
    XKeyEvent *ev = &e->xkey;
    KeySym keysym = XLookupKeysym(ev, 0);
    for (unsigned int i = 0; i < LENGTH(keys); i++) {
        if (keys[i].keysym == keysym
        && CLEANMASK(keys[i].mod) == CLEANMASK(ev->state)
        && keys[i].func)
            keys[i].func(&(keys[i].arg));
    }
}

static void
killclient(const Arg *arg)
{
    (void)arg;
    if (!selmon->sel) return;
    if (!sendevent(selmon->sel, wmatom[WMDelete])) XKillClient(dpy, selmon->sel->win);
}

static void
manage(Window w, XWindowAttributes *wa)
{
    Client *c = ecalloc(1, sizeof(*c));
    c->win = w;
    c->x = c->oldx = wa->x;
    c->y = c->oldy = wa->y;
    c->w = c->oldw = wa->width;
    c->h = c->oldh = wa->height;
    c->oldbw = wa->border_width;
    c->bw = borderpx_scaled;
    c->mon = wintomon(w);
    updatetitle(c);
    applyrules(c);
    if (c->tags & scratchtag) c->isfloating = 1;
    XSelectInput(dpy, w, EnterWindowMask | FocusChangeMask | PropertyChangeMask | StructureNotifyMask);
    grabbuttons(c, 0);
    attach(c);
    attachstack(c);
    XChangeProperty(dpy, root, XA_WM_NAME, XA_STRING, 8, PropModeAppend, (unsigned char *)"", 0);
    XMoveResizeWindow(dpy, w, c->x + 2 * sw, c->y, c->w, c->h);
    XSetWindowBorderWidth(dpy, w, c->bw);
    XSetWindowBorder(dpy, w, normbg);
    configure(c);
    XMapWindow(dpy, c->win);
    focus(NULL);
    arrange(c->mon);
}

static void mappingnotify(XEvent *e) {
    XMappingEvent *ev = &e->xmapping;
    XRefreshKeyboardMapping(ev);
    if (ev->request == MappingKeyboard) grabkeys();
}

static void maprequest(XEvent *e) {
    XMapRequestEvent *ev = &e->xmaprequest;
    XWindowAttributes wa;
    if (!XGetWindowAttributes(dpy, ev->window, &wa) || wa.override_redirect) return;
    if (!wintoclient(ev->window)) manage(ev->window, &wa);
}

static int
isdmenuwin(Window w)
{
    XClassHint ch = {0};
    int isdmenu = 0;
    Monitor *m;

    if (w == None || w == root)
        return 0;
    for (m = mons; m; m = m->next) {
        if (m->barwin == w)
            return 0;
    }
    if (XGetClassHint(dpy, w, &ch)) {
        if ((ch.res_class && strcmp(ch.res_class, "dmenu") == 0)
        ||  (ch.res_name && strcmp(ch.res_name, "dmenu") == 0))
            isdmenu = 1;
    }
    if (ch.res_class) XFree(ch.res_class);
    if (ch.res_name) XFree(ch.res_name);
    return isdmenu;
}

static void
mapnotify(XEvent *e)
{
    XMapEvent *ev = &e->xmap;
    if (!ev->override_redirect)
        return;
    if (!isdmenuwin(ev->window))
        return;
    dmenuwin = ev->window;
    if (!dmenu_active) {
        dmenu_active = 1;
        dmenu_bar_restore = selmon->showbar;
        if (selmon->showbar) {
            Monitor *mm;
            for (mm = mons; mm; mm = mm->next)
                if (mm->showbar)
                    XUnmapWindow(dpy, mm->barwin);
        }
    }
}

static void
maxview(Monitor *m)
{
    for (Client *c = nexttiled(m->clients); c; c = nexttiled(c->next))
        resize(c, m->wx, m->wy, m->ww - 2 * c->bw, m->wh - 2 * c->bw, 0);
}

static void motionnotify(XEvent *e) { (void)e; }

static void
movemouse(const Arg *arg)
{
    (void)arg;
    int x, y, ocx, ocy, nx, ny;
    Client *c;
    XEvent ev;
    if (!(c = selmon->sel)) return;
    restack(c->mon);
    ocx = c->x; ocy = c->y;
    if (XGrabPointer(dpy, root, False, MOUSEMASK, GrabModeAsync, GrabModeAsync, None, cursor[CurMove], CurrentTime) != GrabSuccess)
        return;
    if (!getrootptr(&x, &y)) return;
    do {
        XMaskEvent(dpy, MOUSEMASK|ExposureMask|SubstructureRedirectMask, &ev);
        if (ev.type == MotionNotify) {
            nx = ocx + (ev.xmotion.x - x);
            ny = ocy + (ev.xmotion.y - y);
            if (abs(c->mon->wx - nx) < snap_scaled) nx = c->mon->wx;
            if (abs(c->mon->wy - ny) < snap_scaled) ny = c->mon->wy;
            if (!c->mon->lt[c->mon->sellt]->arrange || c->isfloating)
                resize(c, nx, ny, c->w, c->h, 1);
        }
    } while (ev.type != ButtonRelease);
    XUngrabPointer(dpy, CurrentTime);
}

static Client *nexttiled(Client *c) { for (; c && (c->isfloating || !ISVISIBLE(c)); c = c->next); return c; }
static void pop(Client *c) { detach(c); attach(c); focus(c); arrange(c->mon); }

static void
propertynotify(XEvent *e)
{
    XPropertyEvent *ev = &e->xproperty;
    if ((ev->window == root) && (ev->atom == XA_WM_NAME)) updatestatus();
    else if (ev->state == PropertyDelete) return;
    else {
        Client *c = wintoclient(ev->window);
        if (!c) return;
        if (ev->atom == XA_WM_TRANSIENT_FOR) {
            if (!c->isfloating && XGetTransientForHint(dpy, c->win, &c->win))
                c->isfloating = 1;
        } else if (ev->atom == XA_WM_NAME || ev->atom == XA_WM_ICON_NAME || ev->atom == netatom[NetWMName]) {
            updatetitle(c);
            if (c == c->mon->sel) drawbar(c->mon);
        } else if (ev->atom == XA_WM_HINTS) {
            updatewmhints(c);
            drawbars();
        }
    }
}

static void quit(const Arg *arg) { (void)arg; running = 0; }

static void
resize(Client *c, int x, int y, int w, int h, int interact)
{
    if (applysizehints(c, &x, &y, &w, &h, interact))
        resizeclient(c, x, y, w, h);
}

static void
resizeclient(Client *c, int x, int y, int w, int h)
{
    XWindowChanges wc;
    c->oldx = c->x; c->oldy = c->y;
    c->oldw = c->w; c->oldh = c->h;
    c->x = wc.x = x; c->y = wc.y = y;
    c->w = wc.width = w; c->h = wc.height = h;
    wc.border_width = c->bw;
    XConfigureWindow(dpy, c->win, CWX|CWY|CWWidth|CWHeight|CWBorderWidth, &wc);
    configure(c);
    XSync(dpy, False);
}

static void
resizemouse(const Arg *arg)
{
    (void)arg;
    int ocx, ocy, nw, nh;
    Client *c;
    XEvent ev;
    if (!(c = selmon->sel)) return;
    if (XGrabPointer(dpy, root, False, MOUSEMASK, GrabModeAsync, GrabModeAsync, None, cursor[CurResize], CurrentTime) != GrabSuccess)
        return;
    ocx = c->x; ocy = c->y;
    do {
        XMaskEvent(dpy, MOUSEMASK|ExposureMask|SubstructureRedirectMask, &ev);
        if (ev.type == MotionNotify) {
            nw = MAX(ev.xmotion.x - ocx - 2 * c->bw + 1, 1);
            nh = MAX(ev.xmotion.y - ocy - 2 * c->bw + 1, 1);
            if (!c->mon->lt[c->mon->sellt]->arrange || c->isfloating)
                resize(c, c->x, c->y, nw, nh, 1);
        }
    } while (ev.type != ButtonRelease);
    XUngrabPointer(dpy, CurrentTime);
}

static void
restack(Monitor *m)
{
    if (!m->sel) return;
    if (m->sel->isfloating || !m->lt[m->sellt]->arrange)
        XRaiseWindow(dpy, m->sel->win);
    if (m->lt[m->sellt]->arrange) {
        XRaiseWindow(dpy, m->barwin);
        Client *c;
        for (c = m->stack; c; c = c->snext)
            if (!c->isfloating && ISVISIBLE(c))
                XConfigureWindow(dpy, c->win, CWSibling|CWStackMode, &(XWindowChanges){.sibling = m->barwin, .stack_mode = Below});
    }
    XSync(dpy, False);
}

static void
run(void)
{
    XEvent ev;

    while (running && !XNextEvent(dpy, &ev)) {
#ifdef HAVE_XRANDR
        if (rr_event_base >= 0 && ev.type == rr_event_base + RRScreenChangeNotify) {
            rrscreenchange(&ev);
            continue;
        }
#endif
        if (handler[ev.type])
            handler[ev.type](&ev);
    }
}

static void
scan(void)
{
    unsigned int i, num;
    Window d1, d2, *wins = NULL;
    XWindowAttributes wa;
    if (XQueryTree(dpy, root, &d1, &d2, &wins, &num)) {
        for (i = 0; i < num; i++) {
            if (!XGetWindowAttributes(dpy, wins[i], &wa) || wa.override_redirect || XGetTransientForHint(dpy, wins[i], &d1))
                continue;
            if (wa.map_state == IsViewable || getstate(wins[i]) == IconicState)
                manage(wins[i], &wa);
        }
        for (i = 0; i < num; i++) {
            if (!XGetWindowAttributes(dpy, wins[i], &wa) || wa.override_redirect || !XGetTransientForHint(dpy, wins[i], &d1))
                continue;
            if (wa.map_state == IsViewable || getstate(wins[i]) == IconicState)
                manage(wins[i], &wa);
        }
    }
    if (wins) XFree(wins);
}

static int
sendevent(Client *c, Atom proto)
{
    int n; Atom *protocols; int exists = 0;
    if (XGetWMProtocols(dpy, c->win, &protocols, &n)) {
        while (!exists && n--) exists = protocols[n] == proto;
        XFree(protocols);
    }
    if (exists) {
        XEvent ev = {0};
        ev.type = ClientMessage;
        ev.xclient.window = c->win;
        ev.xclient.message_type = wmatom[WMProtocols];
        ev.xclient.format = 32;
        ev.xclient.data.l[0] = proto;
        ev.xclient.data.l[1] = CurrentTime;
        XSendEvent(dpy, c->win, False, NoEventMask, &ev);
    }
    return exists;
}

static void sendmon(Client *c, Monitor *m) { if (c->mon == m) return; detach(c); detachstack(c); c->mon = m; c->tags = m->tagset[m->seltags]; attach(c); attachstack(c); focus(NULL); arrange(NULL); }
static void setclientstate(Client *c, long state) { long data[] = { state, None }; XChangeProperty(dpy, c->win, wmatom[WMState], wmatom[WMState], 32, PropModeReplace, (unsigned char *)data, 2); }
static void setfocus(Client *c) { if (!c->neverfocus) XSetInputFocus(dpy, c->win, RevertToPointerRoot, CurrentTime); XChangeProperty(dpy, root, netatom[NetActiveWindow], XA_WINDOW, 32, PropModeReplace, (unsigned char *)&(c->win), 1); sendevent(c, wmatom[WMTakeFocus]); }
static void setlayout(const Arg *arg) { if (!arg || !arg->v || arg->v != selmon->lt[selmon->sellt]) selmon->sellt ^= 1; if (arg && arg->v) selmon->lt[selmon->sellt] = (Layout *)arg->v; strncpy(selmon->ltsymbol, selmon->lt[selmon->sellt]->symbol, sizeof selmon->ltsymbol - 1); selmon->pertag->sellt = selmon->sellt; selmon->pertag->ltidxs[selmon->sellt] = selmon->lt[selmon->sellt]; if (selmon->sel) arrange(selmon); else drawbar(selmon); }
static void setmfact(const Arg *arg) { float f = arg->f < 1.0f ? arg->f + selmon->mfact : arg->f - 1.0f; if (!arg || !selmon->lt[selmon->sellt]->arrange || f < 0.05f || f > 0.95f) return; selmon->mfact = f; selmon->pertag->mfact = f; arrange(selmon); }

static void
setup(void)
{
    XSetWindowAttributes wa;
    const char *scaleenv;
    char *endptr;

    screen = DefaultScreen(dpy);
    root = RootWindow(dpy, screen);
    rootdims(&sw, &sh);
    normbg = BlackPixel(dpy, screen);
    normfg = WhitePixel(dpy, screen);
    drw = drw_create(dpy, screen, root, sw, 1);
    for (unsigned int i = 0; i < LENGTH(fonts) && !drw->font; i++)
        drw_setfont(drw, fonts[i]);
    if (!drw->font) die("no usable font found");
    ui_scale_runtime = (uiscale > 0.1f) ? uiscale : 1.0f;
    scaleenv = getenv("PWM_SCALE");
    if (scaleenv && *scaleenv) {
        float envscale = strtof(scaleenv, &endptr);
        if (endptr != scaleenv && envscale > 0.1f)
            ui_scale_runtime = envscale;
    }
    borderpx_scaled = scaleui((int)borderpx);
    snap_scaled = scaleui((int)snap);
    bh = scaleui((drw->font->ascent + drw->font->descent + 2 + bhpad));
    drw_resize(drw, sw, bh);
    normfg = drw_clr_create(drw, colors[SchemeNorm][0]);
    normbg = drw_clr_create(drw, colors[SchemeNorm][1]);
    selfg = drw_clr_create(drw, colors[SchemeSel][0]);
    selbg = drw_clr_create(drw, colors[SchemeSel][1]);

    cursor[CurNormal] = XCreateFontCursor(dpy, XC_left_ptr);
    cursor[CurResize] = XCreateFontCursor(dpy, XC_sizing);
    cursor[CurMove] = XCreateFontCursor(dpy, XC_fleur);
    scratchtag = SPTAG(0);

    wmatom[WMProtocols] = XInternAtom(dpy, "WM_PROTOCOLS", False);
    wmatom[WMDelete] = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
    wmatom[WMState] = XInternAtom(dpy, "WM_STATE", False);
    wmatom[WMTakeFocus] = XInternAtom(dpy, "WM_TAKE_FOCUS", False);
    netatom[NetSupported] = XInternAtom(dpy, "_NET_SUPPORTED", False);
    netatom[NetWMName] = XInternAtom(dpy, "_NET_WM_NAME", False);
    netatom[NetWMState] = XInternAtom(dpy, "_NET_WM_STATE", False);
    netatom[NetWMCheck] = XInternAtom(dpy, "_NET_SUPPORTING_WM_CHECK", False);
    netatom[NetWMFullscreen] = XInternAtom(dpy, "_NET_WM_STATE_FULLSCREEN", False);
    netatom[NetActiveWindow] = XInternAtom(dpy, "_NET_ACTIVE_WINDOW", False);

    wmcheckwin = XCreateSimpleWindow(dpy, root, 0, 0, 1, 1, 0, 0, 0);
    XChangeProperty(dpy, wmcheckwin, netatom[NetWMCheck], XA_WINDOW, 32, PropModeReplace, (unsigned char *)&wmcheckwin, 1);
    XChangeProperty(dpy, root, netatom[NetWMCheck], XA_WINDOW, 32, PropModeReplace, (unsigned char *)&wmcheckwin, 1);
    XChangeProperty(dpy, root, netatom[NetSupported], XA_ATOM, 32, PropModeReplace, (unsigned char *)netatom, NetLast);

    wa.cursor = cursor[CurNormal];
    wa.event_mask = SubstructureRedirectMask|SubstructureNotifyMask|ButtonPressMask|PointerMotionMask|EnterWindowMask|LeaveWindowMask|StructureNotifyMask|PropertyChangeMask;
    XChangeWindowAttributes(dpy, root, CWEventMask|CWCursor, &wa);
    XSelectInput(dpy, root, wa.event_mask);
#ifdef HAVE_XRANDR
    if (XRRQueryExtension(dpy, &rr_event_base, &rr_error_base))
        XRRSelectInput(dpy, root, RRScreenChangeNotifyMask);
#endif
    updategeom();
    updatebars();
    updatestatus();
    updatedesktopprops();
    grabkeys();
}

static void seturgent(Client *c, int urg) { XWMHints *wmh; c->isurgent = urg; if (!(wmh = XGetWMHints(dpy, c->win))) return; wmh->flags = urg ? (wmh->flags | XUrgencyHint) : (wmh->flags & ~XUrgencyHint); XSetWMHints(dpy, c->win, wmh); XFree(wmh); }
static void showhide(Client *c) { if (!c) return; if (ISVISIBLE(c)) { XMoveWindow(dpy, c->win, c->x, c->y); if ((!c->mon->lt[c->mon->sellt]->arrange || c->isfloating) && !c->isfullscreen) resize(c, c->x, c->y, c->w, c->h, 0); showhide(c->snext);} else { showhide(c->snext); XMoveWindow(dpy, c->win, WIDTH(c) * -2, c->y);} }

static void
spawn(const Arg *arg)
{
    if (fork() == 0) {
        if (dpy) close(ConnectionNumber(dpy));
        setsid();
        execvp(((char **)arg->v)[0], (char **)arg->v);
        die("pwm: execvp %s", ((char **)arg->v)[0]);
    }
}

static void
tag(const Arg *arg)
{
    Client *c;
    Monitor *tm;
    unsigned int newtags;
    unsigned int i;

    if (!(c = selmon->sel) || !(arg->ui & TAGMASK))
        return;
    newtags = arg->ui & TAGMASK;
    if (per_monitor_ws) {
        for (i = 0; i < LENGTH(tags); i++)
            if (newtags & (1u << i))
                break;
        tm = montagnth(tagtomonidx((int)i));
        c->tags = newtags;
        if (tm && tm != c->mon) {
            detach(c);
            detachstack(c);
            c->mon = tm;
            attach(c);
            attachstack(c);
            focus(c);
            arrange(NULL);
            return;
        }
    } else
        c->tags = newtags;
    focus(NULL);
    arrange(selmon);
}
static void tagmon(const Arg *arg) { if (!selmon->sel || !mons->next) return; sendmon(selmon->sel, dirtomon(arg->i)); }

static void
tile(Monitor *m)
{
    unsigned int i, n, h, mw, my, ty, nmaster;
    Client *c;
    int oe = ignoregaps ? 0 : m->gappoh;
    int ie = ignoregaps ? 0 : m->gappih;
    int ov = ignoregaps ? 0 : m->gappov;
    int iv = ignoregaps ? 0 : m->gappiv;
    for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++);
    if (n == 0) return;
    nmaster = (unsigned int)MAX(m->nmaster, 0);
    if (smartgaps && n == 1) oe = ov = 0;
    if (n > nmaster)
        mw = nmaster ? (m->ww + iv) * m->mfact : 0;
    else mw = m->ww - 2 * ov + iv;
    for (i = my = ty = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++) {
        if (i < nmaster) {
            h = (m->wh - my - oe - ie * (MIN(n, nmaster) - i - 1)) / (MIN(n, nmaster) - i);
            resize(c, m->wx + ov, m->wy + my + oe, mw - (2*c->bw) - iv, h - (2*c->bw), 0);
            my += HEIGHT(c) + ie;
        } else {
            h = (m->wh - ty - oe - ie * (n - i - 1)) / (n - i);
            resize(c, m->wx + mw + ov, m->wy + ty + oe, m->ww - mw - 2*c->bw - 2*ov, h - 2*c->bw, 0);
            ty += HEIGHT(c) + ie;
        }
    }
}

static void togglebar(const Arg *arg) { (void)arg; selmon->showbar = !selmon->showbar; selmon->pertag->showbar = selmon->showbar; updatebarpos(selmon); if (selmon->barwin) XMoveResizeWindow(dpy, selmon->barwin, selmon->wx, selmon->by, selmon->ww, bh); arrange(selmon); }
static void togglefloating(const Arg *arg) { (void)arg; if (!selmon->sel) return; if (selmon->sel->isfullscreen) return; selmon->sel->isfloating = !selmon->sel->isfloating; if (selmon->sel->isfloating) resize(selmon->sel, selmon->sel->x, selmon->sel->y, selmon->sel->w, selmon->sel->h, 0); arrange(selmon); }
static void togglegaps(const Arg *arg) { (void)arg; ignoregaps = !ignoregaps; arrange(NULL); }
static void togglescratch(const Arg *arg) { Client *c; Monitor *m; unsigned int found = 0; for (m = mons; m; m = m->next) for (c = m->clients; c; c = c->next) if (c->tags & scratchtag) { found = 1; if (ISVISIBLE(c)) c->tags = 0; else { c->tags = m->tagset[m->seltags]; focus(c);} } if (!found) spawn(arg); arrange(NULL); }
static void
toggletag(const Arg *arg)
{
    unsigned int allowed;
    unsigned int newtags;
    if (!selmon->sel) return;
    allowed = tagsformon(selmon);
    newtags = selmon->sel->tags ^ (arg->ui & TAGMASK & allowed);
    if (newtags) {
        selmon->sel->tags = newtags;
        focus(NULL);
        arrange(selmon);
    }
}
static void
toggleview(const Arg *arg)
{
    unsigned int allowed;
    unsigned int newtagset;
    allowed = tagsformon(selmon);
    newtagset = selmon->tagset[selmon->seltags] ^ (arg->ui & TAGMASK & allowed);
    if (newtagset) {
        selmon->tagset[selmon->seltags] = newtagset;
        focus(NULL);
        arrange(selmon);
    }
}
static void unfocus(Client *c, int setfocusroot) { if (!c) return; grabbuttons(c, 0); XSetWindowBorder(dpy, c->win, normbg); if (setfocusroot) XSetInputFocus(dpy, root, RevertToPointerRoot, CurrentTime); }

static void
unmanage(Client *c, int destroyed)
{
    Monitor *m = c->mon;
    XWindowChanges wc;
    detach(c);
    detachstack(c);
    if (!destroyed) {
        wc.border_width = c->oldbw;
        XGrabServer(dpy);
        XSetErrorHandler(xerrordummy);
        XConfigureWindow(dpy, c->win, CWBorderWidth, &wc);
        XUngrabButton(dpy, AnyButton, AnyModifier, c->win);
        setclientstate(c, WithdrawnState);
        XSync(dpy, False);
        XSetErrorHandler(xerror);
        XUngrabServer(dpy);
    }
    free(c);
    focus(NULL);
    updateclientlist();
    arrange(m);
}

static void unmapnotify(XEvent *e) {
    XUnmapEvent *ev = &e->xunmap;
    Client *c;
    if (dmenu_active && (ev->window == dmenuwin || isdmenuwin(ev->window))) {
        dmenu_active = 0;
        dmenuwin = None;
        if (dmenu_bar_restore && selmon->showbar) {
            Monitor *mm;
            for (mm = mons; mm; mm = mm->next) {
                if (mm->showbar) {
                    XMapRaised(dpy, mm->barwin);
                    drawbar(mm);
                }
            }
        }
        dmenu_bar_restore = 0;
    }
    if ((c = wintoclient(ev->window))) {
        if (ev->send_event) setclientstate(c, WithdrawnState);
        else unmanage(c, 0);
    }
}
static void updatebarpos(Monitor *m) {
    m->wx = m->mx;
    m->ww = m->mw;
    m->wy = m->my;
    m->wh = m->mh;
    if (m->showbar) {
        m->wh -= bh;
        m->by = m->topbar ? m->wy : m->wy + m->wh;
        m->wy = m->topbar ? m->wy + bh : m->wy;
    } else
        m->by = -bh;
}
static void
updatebars(void)
{
    XSetWindowAttributes wa = {
        .override_redirect = True,
        .background_pixel = normbg,
        .border_pixel = 0,
        .colormap = DefaultColormap(dpy, screen),
        .event_mask = ButtonPressMask|ExposureMask
    };
    for (Monitor *m = mons; m; m = m->next) {
        if (m->barwin) continue;
        m->barwin = XCreateWindow(dpy, root, m->wx, m->by, m->ww, bh, 0, DefaultDepth(dpy, screen), CopyFromParent, DefaultVisual(dpy, screen), CWOverrideRedirect|CWBackPixel|CWBorderPixel|CWColormap|CWEventMask, &wa);
        XDefineCursor(dpy, m->barwin, cursor[CurNormal]);
        XMapRaised(dpy, m->barwin);
    }
}

static void updateclientlist(void) {
    XDeleteProperty(dpy, root, XInternAtom(dpy, "_NET_CLIENT_LIST", False));
    for (Monitor *m = mons; m; m = m->next)
        for (Client *c = m->clients; c; c = c->next)
            XChangeProperty(dpy, root, XInternAtom(dpy, "_NET_CLIENT_LIST", False), XA_WINDOW, 32, PropModeAppend, (unsigned char *)&(c->win), 1);
}

static void
updatedesktopprops(void)
{
    Atom a;
    unsigned long geom[2];
    unsigned long work[4];

    if (!mons)
        return;
    geom[0] = (unsigned long)sw;
    geom[1] = (unsigned long)sh;
    work[0] = (unsigned long)mons->wx;
    work[1] = (unsigned long)mons->wy;
    work[2] = (unsigned long)mons->ww;
    work[3] = (unsigned long)mons->wh;
    a = XInternAtom(dpy, "_NET_DESKTOP_GEOMETRY", False);
    if (a != None)
        XChangeProperty(dpy, root, a, XA_CARDINAL, 32, PropModeReplace, (unsigned char *)geom, 2);
    a = XInternAtom(dpy, "_NET_WORKAREA", False);
    if (a != None)
        XChangeProperty(dpy, root, a, XA_CARDINAL, 32, PropModeReplace, (unsigned char *)work, 4);
}

static void
updategeom(void)
{
    int nn, i;
    int oldsw, oldsh;
    int screenchanged;
#ifdef HAVE_XRANDR
    int maj, min;
    XRRMonitorInfo *mi = NULL;
#endif
    int rx[16], ry[16], rw[16], rh[16];
    Monitor *m;
    Client *c, *orphans = NULL;
    int oidx;

    oldsw = sw;
    oldsh = sh;
    rootdims(&sw, &sh);
    screenchanged = (sw != oldsw || sh != oldsh);

    nn = 0;
#ifdef HAVE_XRANDR
    if (XRRQueryVersion(dpy, &maj, &min) && (maj > 1 || (maj == 1 && min >= 5))) {
        mi = XRRGetMonitors(dpy, root, True, &nn);
        if (mi && nn > 0) {
            for (i = 0; i < nn && i < 16; i++) {
                rx[i] = mi[i].x;
                ry[i] = mi[i].y;
                rw[i] = (int)mi[i].width;
                rh[i] = (int)mi[i].height;
            }
        } else {
            if (mi) {
                XFree(mi);
                mi = NULL;
            }
            nn = 0;
        }
    }
#endif
    if (nn <= 0) {
        nn = 1;
        rx[0] = 0;
        ry[0] = 0;
        rw[0] = sw;
        rh[0] = sh;
    }
    if (nn > 16)
        nn = 16;

    oidx = selmonidx();

    if (geommatch(nn, rx, ry, rw, rh)) {
        if (screenchanged) {
            syncmonsgeom(nn, rx, ry, rw, rh);
            drwresize();
            mapbars();
            arrange(NULL);
            drawbars();
            updatestatus();
            updatedesktopprops();
        }
#ifdef HAVE_XRANDR
        if (mi)
            XFree(mi);
#endif
        return;
    }

    for (m = mons; m; m = m->next) {
        while ((c = m->clients)) {
            detach(c);
            detachstack(c);
            c->next = orphans;
            orphans = c;
        }
        m->sel = NULL;
    }
    while (mons) {
        m = mons;
        mons = m->next;
        cleanupmon(m);
    }
    mons = NULL;
    selmon = NULL;

    for (i = 0; i < nn; i++) {
        m = createmon();
        m->num = i;
        m->mx = rx[i];
        m->my = ry[i];
        m->mw = rw[i];
        m->mh = rh[i];
        updatebarpos(m);
        if (per_monitor_ws)
            m->tagset[0] = m->tagset[1] = defaulttagformon(m);
        attachmon(m);
    }

    selmon = mons;
    for (i = 0; i < oidx && selmon && selmon->next; i++)
        selmon = selmon->next;
    if (!selmon)
        selmon = mons;

    while (orphans) {
        c = orphans;
        orphans = c->next;
        c->mon = recttomon(c->x + c->w / 2, c->y + c->h / 2, 1, 1);
        if (!c->mon)
            c->mon = mons;
        attach(c);
        attachstack(c);
    }

#ifdef HAVE_XRANDR
    if (mi)
        XFree(mi);
#endif

    updatebars();
    drwresize();
    focus(NULL);
    arrange(NULL);
    drawbars();
    updatestatus();
    updatedesktopprops();
}
static void updatenumlockmask(void) { unsigned int i; int j; XModifierKeymap *modmap = XGetModifierMapping(dpy); numlockmask = 0; for (i = 0; i < 8; i++) for (j = 0; j < modmap->max_keypermod; j++) if (modmap->modifiermap[i * modmap->max_keypermod + j] == XKeysymToKeycode(dpy, XK_Num_Lock)) numlockmask = (1 << i); XFreeModifiermap(modmap); }
static void updatestatus(void) { if (!gettextprop(root, XA_WM_NAME, stext, sizeof stext)) stext[0] = '\0'; drawbars(); }
static void updatetitle(Client *c) { if (!gettextprop(c->win, netatom[NetWMName], c->name, sizeof c->name)) gettextprop(c->win, XA_WM_NAME, c->name, sizeof c->name); if (c->name[0] == '\0') strcpy(c->name, "broken"); }
static void updatewmhints(Client *c) { XWMHints *wmh; if ((wmh = XGetWMHints(dpy, c->win))) { if (c == c->mon->sel && wmh->flags & XUrgencyHint) wmh->flags &= ~XUrgencyHint; else c->isurgent = (wmh->flags & XUrgencyHint) ? 1 : 0; if (wmh->flags & InputHint) c->neverfocus = !wmh->input; else c->neverfocus = 0; XFree(wmh);} }

static void
view(const Arg *arg)
{
    Monitor *m = selmon;
    unsigned int nm = arg->ui & TAGMASK;
    unsigned int ti;

    if (per_monitor_ws && nm && nm != TAGMASK) {
        for (ti = 0; ti < LENGTH(tags); ti++)
            if (nm & (1u << ti))
                break;
        m = montagnth(tagtomonidx((int)ti));
        nm = 1u << ti;
    }
    if (nm && nm == m->tagset[m->seltags])
        return;
    selmon = m;
    selmon->seltags ^= 1;
    if (nm & TAGMASK)
        selmon->tagset[selmon->seltags] = nm;
    selmon->nmaster = selmon->pertag->nmaster;
    selmon->mfact = selmon->pertag->mfact;
    selmon->sellt = selmon->pertag->sellt;
    selmon->lt[selmon->sellt] = (Layout *)selmon->pertag->ltidxs[selmon->sellt];
    strncpy(selmon->ltsymbol, selmon->lt[selmon->sellt]->symbol, sizeof selmon->ltsymbol - 1);
    focus(NULL);
    arrange(selmon);
}

static Client *wintoclient(Window w) { for (Monitor *m = mons; m; m = m->next) for (Client *c = m->clients; c; c = c->next) if (c->win == w) return c; return NULL; }
static int xerror(Display *dpy_, XErrorEvent *ee) { (void)dpy_; if (ee->error_code == BadWindow || (ee->request_code == X_SetInputFocus && ee->error_code == BadMatch) || (ee->request_code == X_PolyText8 && ee->error_code == BadDrawable) || (ee->request_code == X_PolyFillRectangle && ee->error_code == BadDrawable) || (ee->request_code == X_PolySegment && ee->error_code == BadDrawable) || (ee->request_code == X_ConfigureWindow && ee->error_code == BadMatch) || (ee->request_code == X_GrabButton && ee->error_code == BadAccess) || (ee->request_code == X_GrabKey && ee->error_code == BadAccess) || (ee->request_code == X_CopyArea && ee->error_code == BadDrawable)) return 0; fprintf(stderr, "pwm: fatal error: request code=%d, error code=%d\n", ee->request_code, ee->error_code); return xerrorxlib(dpy, ee); }
static int xerrordummy(Display *dpy_, XErrorEvent *ee) { (void)dpy_; (void)ee; return 0; }
static int xerrorstart(Display *dpy_, XErrorEvent *ee) { (void)dpy_; (void)ee; die("pwm: another window manager is already running"); return -1; }

static void
zoom(const Arg *arg)
{
    (void)arg;
    Client *c = selmon->sel;
    if (!selmon->lt[selmon->sellt]->arrange || !c || c->isfloating) return;
    if (c == nexttiled(selmon->clients) && !(c = nexttiled(c->next))) return;
    pop(c);
}

int
main(void)
{
    if (setlocale(LC_CTYPE, "") == NULL)
        fputs("warning: no locale support\n", stderr);
    if (!(dpy = XOpenDisplay(NULL)))
        die("pwm: cannot open display");
    checkotherwm();
    setup();
    scan();
    run();
    cleanup();
    XCloseDisplay(dpy);
    return 0;
}
